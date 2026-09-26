# 04 - Validación Airflow -> Hive / Kyuubi

DAG de prueba:

```python
from airflow.providers.jdbc.hooks.jdbc import JdbcHook

def test_kyuubi_conn():
    hook = JdbcHook(jdbc_conn_id='kyuubi_jdbc_anon')
    conn = hook.get_conn()
    cursor = conn.cursor()
    cursor.execute("SHOW DATABASES")
    print(cursor.fetchall())
```

Error original: `Connection timed out`
Fix: Actualizar connection string en Airflow Connections a `jdbc:hive2://<HIVE_HOST>:<HIVE_PORT>/default`