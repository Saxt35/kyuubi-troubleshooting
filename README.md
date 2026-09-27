# kyuubi-troubleshooting

> **RCA real Big Data Platform: 79.7GB `/tmp/hive/<USER>/staging` → HDFS >90% → YARN sin espacio → Kyuubi / Livy / Zeppelin caídos**
> Anonimizado | 17 Runbooks | Kyuubi vs Livy | `kyuubi-defaults.conf` + limpieza staging

[![RCA: 79.7GB Staging Leak](https://img.shields.io/badge/RCA-79.7GB%20Staging%20Leak-red?style=for-the-badge)](https://github.com/Saxt35/kyuubi-troubleshooting#1-rca-real)
[![HDFS: >90% Full](https://img.shields.io/badge/HDFS-%3E90%25%20Full-orange?style=for-the-badge)](https://github.com/Saxt35/kyuubi-troubleshooting#2-impacto)
[![Stack: Kyuubi-Livy-YARN-HDFS](https://img.shields.io/badge/Stack-Kyuubi%20Livy%20YARN%20HDFS-blue?style=for-the-badge)](https://github.com/Saxt35/kyuubi-troubleshooting#3-arquitectura-de-falla)
[![Status: Resolved Anonymized](https://img.shields.io/badge/Status-Resolved%20Anonymized-green?style=for-the-badge)](https://github.com/Saxt35/kyuubi-troubleshooting#-nota-de-confidencialidad)

**Autor:** Noe Briones | AI Architect / MDM Lead / Staff Data Engineer | HASSERV / COMIMSA
**Repo hermano (Arquitectura):** [ai-knowledge-platform-graphrag](https://github.com/Saxt35/ai-knowledge-platform-graphrag) - GraphRAG Faithfulness 0.91 | 5 capas | Jena+pgvector+ClickHouse

---

## ⚠️ Nota de Confidencialidad

> Este repositorio presenta una versión anonimizada de un incidente real en plataforma Big Data empresarial. Por confidencialidad no se incluyen hosts reales, usuarios, logs propietarios ni configuraciones sensibles.
> Todo host, puerto y usuario está anonimizado como `<HOST>`, `<PORT>`, `<USER>`, `<KYUUBI_HOST>`, `<LIVY_HOST>`.
> La métrica 79.7GB y la cadena de falla HDFS→YARN→Kyuubi/Livy/Zeppelin son reales, los artefactos son representaciones conceptuales.

---

## 1. RCA Real

**Síntoma inicial:** Zeppelin 503, Kyuubi JDBC `jdbc:hive2://<KYUUBI_HOST>:10009` timeout, Livy sessions stuck, Airflow DAGs fallando.

**Root Cause encontrado:**
```bash
hdfs dfs -du -h /tmp/hive/<USER>/staging
# 79.7G  /tmp/hive/<USER>/staging

df -h
# /data  91%  HDFS DataNode >90%

yarn node -list
# UNHEALTHY - local-dirs usable space below threshold
```

**Causa técnica:** Spark no limpiaba `spark.local.dir` ni `/tmp/hive/<USER>/staging` tras jobs fallidos vía Livy. Acumulación 6 meses. Livy no tenía `livy.server.session.timeout` ni `spark.sql.warehouse.dir` aislado. Kyuubi comparte mismo `HADOOP_TMP_DIR`.

---

## 2. Impacto

| Capa | Impacto |
| :--- | :--- |
| **HDFS** | >90% full, DataNodes en alerta, no replica bloques nuevos |
| **YARN** | NodeManagers UNHEALTHY, no asigna containers |
| **Kyuubi** | `jdbc:hive2://<KYUUBI_HOST>:10009` - Connection refused / timeout |
| **Livy** | Sessions `dead`, no libera staging |
| **Zeppelin** | Interpreters Kyuubi/Livy caídos, notas 500 |
| **Airflow** | DAGs SparkSubmitOperator fallando |
| **Negocio** | Portal Next.js + Tree.js 3D sin datos, Metabase sin refresco |

Ver diagrama: `diagrams/` - Flujo de falla en cascada.

---

## 3. Arquitectura de Falla

### Diagrama 1: Tecnologías Soporte - Plataforma afectada

[![Architecture Anon](./diagrams/architecture_anon.png)]

**Mapeado a este RCA:**
- **Ingesta:** Spark-SQL jobs via Livy dejan basura en `/tmp/hive/<USER>/staging`
- **Infra:** HADOOP HDFS (91%) + HADOOP YARN (UNHEALTHY) + APACHE LIVY + APACHE ZEPPELIN
- **Subyacente:** Spark 3.x + YARN 4 nodes + Kyuubi `jdbc:hive2://<KYUUBI_HOST>:10009`

### Diagrama 2: Cadena de Falla

```
[Spark Job Livy] --falla--> [/tmp/hive/<USER>/staging no limpiado]
        |
        v
[HDFS 79.7GB acumulados] --> [HDFS >90%] --> [YARN local-dirs <10%]
        |
        v
[YARN UNHEALTHY] --> [Kyuubi no inicia containers] + [Livy sessions dead]
        |
        v
[Zeppelin 503] + [Airflow DAGs failed] + [Portal sin datos]
```

---

## 4. Solución

### Immediate Fix (P0)

```bash
# 1. Identificar top staging
hdfs dfs -du -h /tmp/hive/ | sort -hr | head -20
# 79.7G <USER>

# 2. Limpiar staging >7 días (anonimizado)
hdfs dfs -find /tmp/hive/<USER>/staging -type d -mtime +7 -exec hdfs dfs -rm -r {} \;

# 3. Limpiar spark local dirs en cada NodeManager
# En cada <HOST> YARN:
rm -rf /data/yarn/nm-local-dir/usercache/<USER>/appcache/*
rm -rf /tmp/hive/<USER>/*

# 4. Restart YARN + Kyuubi + Livy
sudo systemctl restart hadoop-yarn-nodemanager
sudo systemctl restart kyuubi
sudo systemctl restart livy
```

**Resultado:** HDFS 91% -> 62%, YARN HEALTHY, Kyuubi UP.

### Preventive Fix (P1) - `kyuubi-defaults.conf` + `livy.conf`

```properties
# kyuubi-defaults.conf - <KYUUBI_HOST>
kyuubi.ha.enabled=true
kyuubi.ha.zookeeper.quorum=<HOST>:2181
kyuubi.engine.share.level=CONNECTION
kyuubi.session.engine.check.interval=PT5M
kyuubi.engine.alive.probe.enabled=true
# Limpieza staging
spark.sql.warehouse.dir=hdfs:///apps/kyuubi/warehouse/<USER>
spark.hadoop.hive.exec.scratchdir=/tmp/hive/<USER>/staging
spark.hadoop.hive.exec.stagingdir=/tmp/hive/<USER>/staging
# TTL
spark.hadoop.hive.exec.scratchdir.lock=true
```

```properties
# livy.conf - <LIVY_HOST>
livy.server.session.timeout=1h
livy.server.session.timeout-check=true
livy.server.recovery.state-store=hdfs:///apps/livy/sessions
livy.spark.deploy-mode=cluster
```

```bash
# Cron limpieza diaria - Airflow DAG
0 2 * * * hdfs dfs -find /tmp/hive -type d -mtime +3 -exec hdfs dfs -rm -r {} \;
```

Ver `runbook/` con 17 procedimientos detallados.

---

## 5. Participación Personal

**Rol: Staff Data Engineer / Big Data Platform Owner**

1. **Detección:** Correlacioné Zeppelin 503 + YARN UNHEALTHY + HDFS >90% via Hue + YARN UI
2. **RCA:** Identifiqué 79.7GB en `/tmp/hive/<USER>/staging` con `hdfs dfs -du -h`
3. **Fix inmediato:** Limpieza + restart coordinado YARN/Kyuubi/Livy sin pérdida datos
4. **Fix preventivo:** Diseño `kyuubi-defaults.conf` con `engine.share.level=CONNECTION` + `warehouse.dir` aislado por `<USER>`
5. **Gobernanza:** Creación 17 runbooks + dashboard Metabase HDFS usage + alerta >75%
6. **ADR:** 006-Kyuubi vs Livy (por qué Kyuubi multi-tenant resiste mejor leak que Livy session-per-user)

---

## 6. Estructura Repo

```
/diagrams/
  - tecnologias-soporte-bigdata-platform.png  # Plataforma afectada
  - kyuubi-failure-cascade.png                # Diagrama cadena falla HDFS->YARN->Kyuubi
/docs/
  - adr/
    - 006-kyuubi-vs-livy.md                   # ADR compartido con repo hermano
  - 14_Caso_Real_Spark_Staging.md             # RCA detallado anonimizado
/runbook/
  - 01_hdfs_du_check.md
  - 02_yarn_unhealthy_fix.md
  - 03_kyuubi_restart.md
  - ... (17 runbooks)
```

`.gitignore` bloquea `private/`, `*.log`, `*.env`, `*.xlsx`

---

## 7. Ecosistema

**Operations (este repo):** RCA 79.7GB staging leak → HDFS >90% → YARN → Kyuubi/Livy/Zeppelin
**Architecture:** [ai-knowledge-platform-graphrag](https://github.com/Saxt35/ai-knowledge-platform-graphrag) - Diseño 5 capas GraphRAG Faithfulness 0.91 sobre misma plataforma.

Juntos: **Operación + Arquitectura = Staff Data Engineer / AI Architect completo**

---

## 8. Para Reclutadores

Evidencia de: Troubleshooting Big Data Platform (HDFS/YARN/Kyuubi/Livy/Zeppelin), RCA real 79.7GB, Administración Hadoop, Spark tuning, `kyuubi-defaults.conf` hardening, Runbooks operativos, Prevención HDFS full.

No requiere instalación. Revisar `docs/14_Caso_Real_Spark_Staging.md` + `runbook/`

*Anonimizado - Métrica 79.7GB real, artefactos conceptuales - Sept 2026*
