# Architecture - Anonymized for Public GitHub

This diagram is a sanitized version of the internal platform diagram.

- Original contained Gobierno de Mexico logos and '2026 Ano de Margarita Maza' -> Removed
- All hostnames, IPs, and internal project names removed
- Only open-source tech stack remains

![Architecture Anonymized](./architecture_anon.png)

## Tech Stack
- Data: Spark-SQL, MongoDB, Postgres, Oracle, Apache Kafka (Structured Streaming)
- OLAP: ClickHouse
- BI: Metabase, PostgreSQL
- Graph: Apache Jena Fuseki
- AI: GNN/HUG, Geometric deep learning, PYTorch, Spark NLP, Spark ML
- Viz: JavaScript Node.js Tree.js
- Infra: HADOOP HDFS, HADOOP YARN, APACHE LIVY, DOCKER, DOCKER COMPOSE, CELERY, AIRFLOW, ZEPPELIN, HUE, KAFKA CONTROL CENTER, KAFKA CONNECT
