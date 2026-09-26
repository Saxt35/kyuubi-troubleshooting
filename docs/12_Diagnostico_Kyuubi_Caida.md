# 12 - Diagnóstico Kyuubi - Caída Total

## Estado - Tu comando real
```bash
docker ps | grep kyuubi
# K8s
kubectl get pods -n <hive-ns> | grep kyuubi
```

## Puerto - Tu comando real anonimizado
```bash
# Original: nc -vz 127.0.0.1 10209 (localhost - OK para local, pero para público usar placeholder)
# Versión pública:
nc -vz <KYUUBI_HOST> <KYUUBI_PORT>
# Tu validación interna:
nc -vz 127.0.0.1 10009
ss -tlnp | grep 10009
netstat -tlnp | grep 10209
```

Nota: En tu caso usas 10209 y 10009 - Documentar ambos. 10009 es default Kyuubi, 10209 puede ser mapping Docker.

## Logs
```bash
docker logs kyuubi --tail 200
# Buscar
docker logs kyuubi --tail 500 | grep -i "ERROR\|Exception\|OutOfMemory\|Metastore"
```

## JDBC - Tu config anonimizada
```text
# Original: jdbc:hive2://IP:10209
# Pública:
jdbc:hive2://<KYUUBI_HOST>:<KYUUBI_PORT>/default
jdbc:hive2://kyuubi-service.<NAMESPACE>.svc.cluster.local:10009/default
```

## Checklist de caída
- [ ] docker ps -> kyuubi UP?
- [ ] netstat -> 10009 LISTEN?
- [ ] nc -vz -> TCP OK?
- [ ] hdfs dfsadmin -report -> HDFS OK?
- [ ] yarn node -list -> YARN OK?
- [ ] logs -> OOM? Metastore down?

Publicable: SI (con placeholders)