# 03 - Diagnóstico de Contenedor Kyuubi

- `kubectl logs -n <hive-namespace> <kyuubi-pod>`
- `kubectl get svc -n <hive-namespace>`
- `kubectl describe networkpolicy`

Hallazgo: Kyuubi pod escuchando en 0.0.0.0:10009 pero Service ClusterIP no tenía endpoints por label mismatch.
Fix: Corregir selector `app: kyuubi-server` en Service.