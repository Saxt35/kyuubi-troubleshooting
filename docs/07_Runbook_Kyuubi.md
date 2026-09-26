# 07 - Runbook - Troubleshooting Conectividad Kyuubi

## Paso 1: Validar red
```bash
nc -vz <HIVE_HOST> <HIVE_PORT>
telnet <HIVE_HOST> <HIVE_PORT>
Test-NetConnection <HIVE_HOST> -Port <HIVE_PORT>
```

## Paso 2: Validar desde contenedor
```bash
kubectl exec -it <pod> -n <ns> -- /bin/bash
nc -vz <HIVE_HOST> <HIVE_PORT>
```

## Paso 3: Validar JDBC
Beeline / Zeppelin %jdbc

## Paso 4: Logs
`kubectl logs <kyuubi-pod> -n <ns>`

## Paso 5: NSG / NetworkPolicy
Revisar reglas Azure NSG y Kubernetes NetworkPolicy.