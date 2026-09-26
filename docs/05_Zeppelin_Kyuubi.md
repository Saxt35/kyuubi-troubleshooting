# 05 - Validación desde Zeppelin

```sql
%jdbc(hive)
SHOW TABLES
```

Interpreter JDBC configurado con:

```
jdbc:hive2://<HIVE_HOST>:<HIVE_PORT>/;auth=noSasl
```

Prueba definitiva desde nota Zeppelin con `%sh`:

```bash
nc -vz <HIVE_HOST> <HIVE_PORT>
```

Resultado: succeeded -> interpreter reiniciado -> tablas visibles.