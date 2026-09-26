#!/bin/bash
# Runbook Kyuubi Troubleshooting - Anonimizado
# Autor: Noe Briones - AI Architect

set -e

KYUUBI_HOST="<KYUUBI_HOST>"
KYUUBI_PORT="<KYUUBI_PORT>"
LIVY_HOST="<LIVY_HOST>"
HDFS_NAMENODE="<HDFS_NAMENODE>"

echo "=== 1. Diagnostico Red Kyuubi ==="
nc -vz $KYUUBI_HOST $KYUUBI_PORT || echo "Kyuubi no accesible"
# Windows alternativa: Test-NetConnection -ComputerName $KYUUBI_HOST -Port $KYUUBI_PORT

echo "=== 2. Diagnostico Contenedor ==="
docker ps | grep kyuubi || echo "Contenedor no encontrado"
docker top kyuubi || true
netstat -tulpn | grep $KYUUBI_PORT || ss -tulpn | grep $KYUUBI_PORT

echo "=== 3. Diagnostico HDFS - Caso 79.7GB ==="
hdfs dfsadmin -report
hdfs dfs -du -s -h /tmp/hive
hdfs dfs -du -s -h /tmp
hdfs dfs -df -h

echo "=== 4. Diagnostico YARN ==="
yarn node -list
yarn application -list

echo "=== 5. Diagnostico Kyuubi Caida ==="
ps aux | grep kyuubi
jps | grep Kyuubi
tail -100 /var/log/kyuubi/kyuubi.log || tail -100 ./logs/kyuubi.log

echo "=== 6. Diagnostico Livy + Zeppelin ==="
curl -s http://$LIVY_HOST:8998/sessions | head -50
curl -s http://$LIVY_HOST:8998/sessions | grep -E "idle|dead|running"

echo "=== 7. Limpieza Staging (RCA 79.7GB) ==="
echo "hdfs dfs -rm -r -skipTrash /tmp/hive/<USER>/staging/*"
echo "Ejecutar solo despues de validar con equipo"

echo "Runbook completado - ver docs/ para detalle"
