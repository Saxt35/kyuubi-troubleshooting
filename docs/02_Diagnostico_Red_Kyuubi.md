# 02 - Diagnóstico de Red - Kyuubi

## Pruebas realizadas
- `Test-NetConnection -ComputerName <HIVE_HOST> -Port <HIVE_PORT>` (PowerShell)
- `telnet <HIVE_HOST> <HIVE_PORT>`
- `nc -vz <HIVE_HOST> <HIVE_PORT>`
- `kubectl exec -it <zeppelin-pod> -- nc -vz <HIVE_HOST> <HIVE_PORT>`

## Hallazgos
- Ping OK pero TCP SYN sin ACK en puerto 10009
- NSG de Azure bloqueaba egress del namespace analytics -> ingress kyuubi
- DNS interno: kyuubi-service no resolvía fuera del namespace

## Evidencia sanitizada
```bash
# Ejemplo anonimizado
nc -vz kyuubi-service.hive-namespace.svc.cluster.local 10009
# Connection to ... 10009 port [tcp/*] succeeded!
```