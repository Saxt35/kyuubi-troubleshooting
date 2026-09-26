# 13 - Diagnóstico Livy y Zeppelin

## Sesiones
```bash
curl http://localhost:8998/sessions
# Público
curl http://<LIVY_HOST>:8998/sessions
```

Estados:
- idle
- starting
- dead

## Reinicio
```bash
docker restart livy
docker restart zeppelin
kubectl rollout restart deployment livy -n <livy-ns>
kubectl rollout restart deployment zeppelin -n <zeppelin-ns>
```