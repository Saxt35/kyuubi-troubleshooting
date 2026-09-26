# 14 - Caso Real: Spark Staging 79.7 GB - Root Cause de Caída

## Síntoma (tu caso real)
```text
Session Closed
spark-submit start failed
```

En Zeppelin %livykyuubi.pyspark3 y %kyuubisql fallaban, YARN mostraba ACCEPTED sin pasar a RUNNING.

## Hallazgo (anonimizado)
```text
# Original: /spark/staging/noe.briones/.sparkStaging = 79.7 GB
# Versión pública:
 /spark/staging/<USER>/.sparkStaging = 79.7 GB
```

Staging acumulado de meses sin limpieza. HDFS se quedó sin espacio para nuevas apps.

## Validación - Tu comando real
```bash
docker exec -it namenode hdfs dfs -du -s -h /spark/staging/*
# K8s
kubectl exec -n <hdfs-ns> <namenode-pod> -- hdfs dfs -du -s -h /spark/staging/*

# Ver por usuario (público)
hdfs dfs -du -s -h /spark/staging/* | sort -hr | head -20
```

## Limpieza - Tu comando real anonimizado
```bash
# Original con tu usuario: hdfs dfs -rm -r -skipTrash /spark/staging/noe.briones/.sparkStaging/*
# Versión pública segura:

docker exec -it namenode hdfs dfs -rm -r -skipTrash /spark/staging/<USER>/.sparkStaging/*
# O con fecha
hdfs dfs -rm -r -skipTrash /spark/staging/<USER>/.sparkStaging/*_2024*

# Verificación post-limpieza
hdfs dfsadmin -report | grep -A2 "DFS Remaining"
```

## Recuperación - Tu flujo real (caso de caída total)

### 1. Reinicio Spark/YARN
```bash
docker restart resourcemanager
docker restart nodemanager
docker restart nodemanager1
docker restart nodemanager2
docker restart nodemanager3

# K8s
kubectl rollout restart deployment resourcemanager -n <yarn-ns>
kubectl rollout restart daemonset nodemanager -n <yarn-ns>
```

### 2. Reinicio Livy
```bash
docker restart livy
kubectl rollout restart deployment livy -n <livy-ns>
```

### 3. Reinicio Zeppelin
```bash
docker restart zeppelin
kubectl rollout restart deployment zeppelin -n <zeppelin-ns>
```

### 4. Validación final
```bash
# Tu flujo de 4 pasos
docker top kyuubi
netstat -tlnp | grep 10209
nc -vz <KYUUBI_HOST> <KYUUBI_PORT>
curl http://<LIVY_HOST>:8998/sessions  # debe volver a idle
```

## Lección para AI Architect

Este caso demuestra RCA completo de 7 capas:

Docker -> HDFS (79.7GB staging) -> YARN (sin recursos) -> Kyuubi (no lanza session) -> Livy (dead) -> Zeppelin (Session Closed) -> Limpieza + reinicio controlado

Publicable: SI, solo si anonimizas <USER> en lugar de noe.briones.

## Checklist final de sanitización para este repo

- [x] Reemplazado noe.briones por <USER>
- [x] Sin IPs reales (usaste ip:puerto, localhost, 127.0.0.1)
- [x] Sin hostnames internos
- [x] Sin passwords (zeppelin.zeppelin sanitizado)