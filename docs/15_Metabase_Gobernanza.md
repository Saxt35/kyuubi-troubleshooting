# 15 - Access via Metabase - Role-Based Governance

## Architecture
All platform data (Spark-SQL, MongoDB, Postgres, Oracle, Kafka, ClickHouse, Jena) 
is exposed via Metabase, not direct HDFS/Kyuubi access.

## Permission Model
- Profile: Researcher, Analyst, Admin, Guest
- Interests: scholarships, researchers, offices, etc.
- Actions: View dashboards, Analyze (ad-hoc SQL via Kyuubi JDBC), Download (CSV/XLSX with limits)

## Flow
User login in Metabase -> SSO/LDAP -> Validate profile ->
Metabase executes jdbc:hive2://<KYUUBI_HOST>:<PORT> with service account ->
Kyuubi -> YARN -> Spark -> HDFS -> Return to Metabase

## Link to your RCA
When Kyuubi fell (case 14 - 79.7GB staging) or Livy dead, Metabase showed "Session Closed".

Publicable: YES - Generic governance description, no internal Metabase URLs.