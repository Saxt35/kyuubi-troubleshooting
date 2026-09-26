# 06 - Configuración JDBC Validada (ANONIMIZADA)

> IMPORTANTE: No incluir IPs reales, usuarios o passwords en repo público.

Configuración segura:

```properties
# kyuubi-defaults.conf anon
kyuubi.frontend.bind.host=0.0.0.0
kyuubi.frontend.bind.port=10009
```

```ini
# JDBC URL pública de ejemplo
jdbc:hive2://<HIVE_HOST>:<HIVE_PORT>/default;transportMode=binary;auth=noSasl
# O con Service DNS
jdbc:hive2://kyuubi-service.<NAMESPACE>.svc.cluster.local:10009/default
```

Test con Beeline:

```bash
beeline -u "jdbc:hive2://<HIVE_HOST>:<HIVE_PORT>/default" -e "SELECT 1"
```