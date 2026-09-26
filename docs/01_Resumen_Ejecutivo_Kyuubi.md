# 01 - Resumen Ejecutivo - Diagnóstico de Conectividad Kyuubi / Hive

**Contexto:** No se alcanzaba el servidor Hive desde Jobs de PySpark y Zeppelin en cluster Kubernetes.

**Stack:** Apache Kyuubi, Hive, Spark, Zeppelin, Airflow, Azure K8s

**Root Cause:** Regla de NSG / Firewall bloqueando puerto 10009 entre namespace de Zeppelin y servicio Kyuubi + DNS interno no resolviendo.

**Impacto:** Jobs fallando con timeout JDBC.

**Solución:** Apertura de puerto, validación de JDBC con IP placeholder, y pruebas de conectividad.

**Resultado:** Conectividad restablecida, validada desde Zeppelin, Airflow y pods.