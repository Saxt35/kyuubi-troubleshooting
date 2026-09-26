# kyuubi-troubleshooting

Troubleshooting y operación de una plataforma Big Data de gobierno (HASSERV/COMIMSA), con contenido anonimizado para incidentes reales y operación diaria.

## Caso estrella (RCA)

**Incidente:** `79.7 GB` en `/tmp/hive` saturaron HDFS y detonaron una caída en cascada en servicios de consulta.

**Impacto observado:**
- HDFS sin capacidad útil
- Falla de sesiones y ejecución en Kyuubi
- Degradación/caída de Livy y Zeppelin
- Riesgo operativo para pipelines y consumo analítico

## Stack cubierto

- Apache Kyuubi
- Spark 3.x
- YARN (4 nodos)
- HDFS HA
- Hive
- Airflow
- Zeppelin
- Livy
- Orígenes y formatos: Oracle, Postgres, MySQL, Excel, PDF
- Flujo principal: Hive → Spark → Jena Fuseki / pgvector / ClickHouse
- Consumo: Metabase (permisos por perfil) + Portal Next.js

## Contenido operativo (17 guías)

El repositorio documenta guías de diagnóstico, recuperación y prevención, incluyendo:

1. Diagnóstico de red (`nc`, `Test-NetConnection`)
2. Diagnóstico de contenedor (`docker top`, `netstat`)
3. Capacidad y salud de HDFS (`hdfs dfsadmin -report`)
4. Estado de nodos YARN (`yarn node -list`)
5. Estado de sesiones Livy/Zeppelin/Kyuubi (`curl 8998/sessions`)
6. Validación de conectividad Airflow + JDBC (`jdbc:hive2://<HOST>:<PORT>`)
7. Runbook preventivo
8. MDM Governance
9–17. Procedimientos complementarios de operación, monitoreo, escalamiento y remediación para el mismo stack

## Relación con otros repositorios

- Repo hermano: [**ai-knowledge-platform-graphrag**](https://github.com/Saxt35/ai-knowledge-platform-graphrag) (métrica de *faithfulness* reportada: `0.91`, usada para evaluar consistencia entre respuesta y evidencia recuperada)

## Anonimización

Todo el material usa placeholders y no contiene datos sensibles:

- `<HOST>`
- `<USER>`
- `<PORT>`

Sin datos de gobierno.
