# 11 - Diagnóstico YARN - Caso Caída Kyuubi

## ResourceManager - Tu comando real
```bash
docker exec -it resourcemanager yarn node -list
# K8s version
kubectl exec -n <yarn-ns> <rm-pod> -- yarn node -list
```

Esperado:
```text
Total Nodes: 4
Node-State: RUNNING (x4)
```

Si < 4 o UNHEALTHY -> YARN es causa, Kyuubi no puede lanzar Spark Sessions.

## Aplicaciones
```bash
docker exec -it resourcemanager yarn application -list
# Filtrar Kyuubi
yarn application -list | grep -i kyuubi
yarn application -list | grep -i livy
```

Revisar estado: ACCEPTED (sin recursos), RUNNING, FAILED.

## Dependencia
Kyuubi -> YARN -> HDFS. Si YARN caído, `nc -vz ip:puerto` puede dar OK pero `SHOW TABLES` falla.

Publicable: SI