# 17 - MDM - Master Data & Transversal Catalogs

## Ingestion
- DBs: Oracle, Postgres, MySQL
- Files: Excel, PDF (extraction with Python + Spark)
- Whole platform

## Goal
Generate master data and transversal catalogs to avoid duplication,
implement policies, business rules, data governance.

## Implementation - Zeppelin

- %livykyuubi.pyspark3 / %livykyuubi.spark3 (Python + Spark)
- %kyuubisql (catalog validation in Hive)
- Apache Spark, Apache Livy

### MDM Flow

1. Ingestion: Oracle/Postgres/MySQL via Spark JDBC + Excel/PDF via pandas/PyPDF2 in Zeppelin
2. Standardization: union + dropDuplicates(["id_hash", "normalized_name"])
3. Transversal Catalogs: CREATE TABLE master_catalog AS SELECT ...
4. Business Rules: dedup rule ID+Name+DOB, policy: Oracle wins > Postgres
5. Exposure: Hive (saveAsTable) -> ClickHouse -> Jena Fuseki -> pgvector -> Metabase + Next.js portal

## Link to your 2 RCA cases
- Case 14 (79.7GB staging): staging was from MDM jobs in Zeppelin not cleaning /spark/staging/<USER>/
- Case 2: If HDFS full, MDM cannot generate catalogs

Publicable: YES - Only tech names and MDM pattern, no real table names, no PII.