# 10 - Diagnóstico HDFS - Caso Caída Kyuubi

## Estado general (tu comando real anonimizado)
```bash
docker exec -it namenode hdfs dfsadmin -report
# En K8s
kubectl exec -n <hdfs-ns> <namenode-pod> -- hdfs dfsadmin -report
```

Revisar:
```text
DFS Remaining
DFS Used%
Missing Blocks
Live datanodes
Dead datanodes
```

Si `DFS Remaining` bajo o `Missing Blocks > 0` -> HDFS es causa raíz, Kyuubi falla en cascada.

## Safe Mode
```bash
# Verificar
docker exec -it namenode hdfs dfsadmin -safemode get
kubectl exec -n <hdfs-ns> <namenode-pod> -- hdfs dfsadmin -safemode get

# Salir (solo si es seguro)
docker exec -it namenode hdfs dfsadmin -safemode leave
```

## Consumo - Tu comando real
```bash
docker exec -it namenode hdfs dfs -du -s -h /spark/*
# Público
hdfs dfs -du -s -h /spark/*
hdfs dfs -du -s -h /tmp/hive
hdfs dfs -du -s -h /tmp/kyuubi
```

Alerta: Si `/spark/*` lleno, Spark History y Kyuubi no pueden escribir staging.

Publicable: SI - Sin IPs reales.