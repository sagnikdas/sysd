import '../../domain/models/concept.dart';
import '../../core/theme/app_colors.dart';

const _cat = 'Data Engineering';
final _color = AppColors.dataEngineering;

final conceptsDataEngineering = <Concept>[
  Concept(
    id: 109,
    category: _cat,
    color: _color,
    icon: '🏗️',
    title: 'ETL vs ELT',
    tagline: 'When to transform',
    diagram: '''
  ETL: Extract → Transform (small engine) → Load warehouse

  ELT: Extract → Load raw → Transform in SQL (warehouse compute)

  Cloud favors ELT (Snowflake/BQ scale)''',
    bullets: [
      'ETL transforms data before storing it in the warehouse — like sorting groceries before putting them in the pantry. ELT dumps raw data first and transforms inside the warehouse — organizing after everything is stored',
      'Cloud warehouses (Snowflake, BigQuery) made ELT the default because they have massive compute power. It\'s easier to load raw data, then iterate on transforms using SQL — you can always re-transform without re-extracting',
      'ETL is still preferred when you need to filter sensitive data (PII scrubbing) before it reaches the warehouse, or when the raw format needs specialized processing engines that SQL can\'t handle',
      'Modern ELT uses dbt to write transformations as version-controlled SQL models — with tests, documentation, and CI/CD. This brings software engineering discipline to data pipelines',
      'In interviews: "we extract raw events into S3, load into BigQuery, and transform using dbt with quality tests. We keep raw data so we can re-transform without re-extracting if business logic changes"',
    ],
    mnemonic: 'ELT = dump first, ask questions in SQL',
    interviewQ: 'Choose ETL vs ELT for SaaS product analytics',
    interviewA: 'ELT to cloud warehouse: ingest raw events and snapshots into S3/BigQuery, model in dbt for marts. Use ETL components only where PII must be tokenized before landing or formats are hostile. Keep lineage. For high-volume logs, preprocess cheaply (Kafka → compacted Parquet) then load.',
    difficulty: Difficulty.beginner,
    tags: ['data-engineering', 'warehouse', 'etl'],
  ),
  Concept(
    id: 110,
    category: _cat,
    color: _color,
    icon: '📦',
    title: 'Data Lake vs Warehouse',
    tagline: 'Cheap lake, fast warehouse',
    diagram: '''
  Lake: S3/GCS Parquet/Delta — cheap, flexible schema
  Warehouse: BQ/Snowflake — SQL perf, governance

  Lakehouse: merge both (Delta/Iceberg)''',
    bullets: [
      'A data lake stores everything in cheap object storage (S3) in its original format — accepts all deliveries without unpacking. A data warehouse is a structured database purpose-built for fast analytical queries',
      'Data lakes are cheap and flexible: store terabytes for pennies, any format. But without governance, a lake becomes a "data swamp" — nobody knows what\'s in there or if it\'s trustworthy',
      'Data warehouses (Snowflake, BigQuery) are expensive per-byte but blazingly fast for SQL queries, with built-in governance and BI tool integration. They hold curated, trusted data for dashboards',
      'Modern "Lakehouse" architectures (Delta Lake, Iceberg) bridge both: warehouse features (ACID transactions, schema enforcement, time-travel) on data lake storage. Cost of a lake with capabilities of a warehouse',
      'In interviews: "raw events land in S3 Parquet. dbt transforms load curated marts into BigQuery for analyst SQL. ML training reads features directly from the lake. Cheap storage with fast analytics"',
    ],
    mnemonic: 'Lake = raw pantry; warehouse = meal prep kitchen',
    interviewQ: 'When warehouse over lake query?',
    interviewA: 'When analysts need fast interactive SQL, joins at scale, and strong governance/BI integration. Lake for ML features, archival, cheap retention, and diverse formats. Modern lakehouse tries to unify. Cost: scanning full lake expensive — aggregate to warehouse marts for dashboards.',
    difficulty: Difficulty.intermediate,
    tags: ['data-engineering', 'lake', 'warehouse'],
  ),
  Concept(
    id: 111,
    category: _cat,
    color: _color,
    icon: '🔄',
    title: 'Change Data Capture',
    tagline: 'Stream DB changes',
    diagram: '''
  WAL / binlog ──► Debezium ──► Kafka
                                    │
                            consumers: search, cache, lake''',
    bullets: [
      'CDC streams database changes (inserts, updates, deletes) in real-time by reading the transaction log — like subscribing to a live feed of every edit instead of periodically checking for differences',
      'Key advantage over polling: CDC captures every change as it happens, with no delay and no missed updates. Polling adds load, introduces latency, and can miss rapid changes between polls',
      'Common use cases: keeping a search index (Elasticsearch) in sync, invalidating cache entries, replicating to a data lake, and feeding event-driven pipelines without modifying application code',
      'Tools like Debezium read the PostgreSQL WAL or MySQL binlog and publish to Kafka. An initial snapshot captures existing data, then streaming captures all subsequent changes',
      'In interviews: "Debezium CDC streams database changes to Kafka. The search service consumes events to update Elasticsearch in near-real-time, staying consistent with the source of truth — no dual writes needed"',
    ],
    mnemonic: 'CDC = database twitch stream',
    interviewQ: 'Invalidate cache when row updates',
    interviewA: 'CDC from Postgres logical replication to Kafka topic per table. Consumer updates cache key by primary key. Idempotent upserts. Handle tombstones for deletes. Lag monitoring — if cache stale too long, fallback to DB read. Alternative: dual-write risky; CDC is safer single source of truth.',
    difficulty: Difficulty.intermediate,
    tags: ['data-engineering', 'cdc', 'messaging'],
  ),
  Concept(
    id: 112,
    category: _cat,
    color: _color,
    icon: '📐',
    title: 'Star Schema',
    tagline: 'Facts surrounded by dimensions',
    diagram: '''
        dim_date
            │
  dim_user ─┼─ fact_orders ─┬─ dim_product
            │                 │
                        dim_geo''',
    bullets: [
      'A star schema organizes analytical data around a central "fact" table (measurable events — orders, clicks) surrounded by "dimension" tables (descriptive context — who, what, when, where). Named for its star-like shape',
      'Fact tables store measurable data: each row is an event with numeric measures (amount, quantity, duration) and foreign keys to dimensions. They\'re large (millions to billions of rows) and narrow',
      'Dimension tables store descriptive attributes: who (customer name, plan tier), what (product category), when (date, day of week), where (city, region). Small but wide with many filtering columns',
      'Star schemas are intentionally denormalized — dimensions are flat to make queries fast and simple. The opposite of normalized OLTP schemas. In analytics, read speed trumps write efficiency',
      'In interviews: "warehouse uses a star schema with fact_orders at center, joined to dim_user, dim_product, dim_date, dim_geo. Makes dashboard queries like revenue by product by region by month simple and fast"',
    ],
    mnemonic: 'Star = fact sun, dimension planets',
    interviewQ: 'Model subscriptions for revenue reporting',
    interviewA: 'Fact_subscription_daily grain: user_id, date_key, revenue, MRR movement. Dimensions: user (plan tier, region), product plan, date. Handle upgrades/downgrades with SCD2 on plan dimension. Conformed dimensions across facts for drill-across. Avoid fan-out double counting when joining multiple facts without care.',
    difficulty: Difficulty.intermediate,
    tags: ['data-engineering', 'warehouse', 'modeling'],
  ),
  Concept(
    id: 113,
    category: _cat,
    color: _color,
    icon: '✅',
    title: 'Data Quality',
    tagline: 'Trust or ignore analytics',
    diagram: '''
  Great Expectations / dbt tests
  Row counts, null rates, uniqueness, freshness SLA

  Alerts to Slack on failure''',
    bullets: [
      'Data quality determines whether your dashboards are trustworthy. "Revenue up 50%" means nothing if the data has duplicates, missing records, or broken joins. Without checks, teams build shadow spreadsheets',
      'Test at every stage: at ingest (expected number of records?), after transformation (required fields non-null? foreign keys match?), and at the mart layer (sums match source?). dbt tests and Great Expectations automate this',
      'Freshness monitoring is critical: if your pipeline is silently delayed, dashboards show stale data that looks correct. Set freshness SLAs per table and alert when breached',
      'When a quality check fails, quarantine the bad batch instead of letting corrupted data flow downstream. Better to have a delayed but correct dashboard than a real-time wrong one',
      'In interviews: "every dbt model has tests for non-null keys, referential integrity, and value ranges. We monitor freshness SLAs and alert if delayed. Bad batches are quarantined, not published"',
    ],
    mnemonic: 'No tests → Excel shadow IT',
    interviewQ: 'Dashboard wrong for a week — prevention?',
    interviewA: 'Add dbt tests: not null on keys, accepted values, referential integrity to dims, row count vs source tolerance. Freshness checks on tables. Canary queries comparing daily totals to finance source. Lineage to trace bug. Incident process for data quality SLOs. Producer schema registry with compatibility checks.',
    difficulty: Difficulty.intermediate,
    tags: ['data-engineering', 'quality', 'analytics'],
  ),
  Concept(
    id: 114,
    category: _cat,
    color: _color,
    icon: '⏰',
    title: 'Batch vs Stream Processing',
    tagline: 'Latency vs complexity',
    diagram: '''
  Batch: hourly/daily jobs, high throughput, simpler correctness

  Stream: Flink/Spark Streaming — low latency, stateful windows

  Lambda: both — reconcile''',
    bullets: [
      'Batch processing runs jobs at scheduled intervals on accumulated data (washing a full load), while stream processing handles data continuously as it arrives (washing each item under a faucet immediately)',
      'Batch is simpler, cheaper, and more correct — it has complete data for heavy computations. Use for daily reports, warehouse refreshes, and anything where hours of latency is acceptable',
      'Stream delivers results in seconds — essential for fraud detection (block NOW), live dashboards, and real-time personalization. More complex: handling late events, exactly-once semantics, and stateful windowing',
      'A common hybrid: stream for immediate actions (fraud alerts, real-time feeds) and batch for corrections and heavy analytics (daily reconciliation, model retraining). Batch catches what stream got wrong',
      'In interviews: "fraud scoring on Flink for sub-second decisions. Revenue reports as batch dbt jobs because accuracy matters more than speed. We reconcile the two nightly"',
    ],
    mnemonic: 'Stream = live TV; batch = nightly rerun',
    interviewQ: 'Hourly batch too slow for fraud',
    interviewA: 'Move scoring to stream processor consuming transaction topic with stateful windows (e.g. 5-min spend per card). Combine with online feature store for model inputs. Keep batch for reconciliation and model retraining. Idempotent rules engine. Fallback human review queue when score borderline.',
    difficulty: Difficulty.advanced,
    tags: ['data-engineering', 'streaming', 'architecture'],
  ),
  Concept(
    id: 115,
    category: _cat,
    color: _color,
    icon: '🔐',
    title: 'PII in Pipelines',
    tagline: 'Minimize, tokenize, audit',
    diagram: '''
  Hash user_id for joins analysts don’t need raw
  Tokenization vault for reversible cases
  Column-level ACL in warehouse''',
    bullets: [
      'PII — names, emails, phone numbers, IP addresses — needs special handling. It\'s not just good practice; GDPR and CCPA carry significant fines for mishandling personal data',
      'The principle is data minimization: only collect PII you need, tokenize or hash it as early as possible, and restrict access with column-level permissions. Analysts counting users don\'t need email addresses',
      'Tokenize PII before it lands in the data lake when possible. Replace user@email.com with a pseudonymous token reversible only by a tokenization vault. The lake never contains raw PII',
      'The hardest part is deletion: "right to erasure" means you must delete a user\'s data everywhere — databases, lake, marts, caches, backups. Map your data lineage so you know every place PII flows',
      'In interviews: "PII classified in our catalog. Tokenized at ingestion. Analysts access tokenized data; only fraud team accesses raw PII with audited access. Lineage tracking enables GDPR deletion requests"',
    ],
    mnemonic: 'PII is toxic — handle with gloves',
    interviewQ: 'GDPR delete in warehouse',
    interviewA: 'Maintain mapping vault or use salted hashes that can be tombstoned. For event streams, append deletion events; consumers compact. Time-travel tables complicate erasure — legal retention policies. Some systems overwrite partitions on rewrite. Document impossible guarantees vs anonymization approach. Involve legal.',
    difficulty: Difficulty.advanced,
    tags: ['data-engineering', 'privacy', 'compliance'],
  ),
  Concept(
    id: 116,
    category: _cat,
    color: _color,
    icon: '📊',
    title: 'Apache Spark Mental Model',
    tagline: 'Distributed dataframe ops',
    diagram: '''
  Driver plans DAG
  Executors run tasks on partitions

  shuffle: expensive repartition/groupBy''',
    bullets: [
      'Spark processes large datasets by distributing work across many machines. You write code as if working with a single dataframe, but Spark splits data into partitions processed in parallel across a cluster',
      'Operations are either "narrow" (each partition processes independently — filter, map) or "wide" (data must shuffle between machines — groupBy, join). Shuffles are expensive — minimize them for performance',
      'The most common performance killer is data skew: one key has 100x more data than others, one partition becomes the bottleneck. Fix by salting the key (adding random suffixes) then re-aggregating',
      'Key tips: push filters early (predicate pushdown — let storage filter before Spark reads), partition by common query columns (date), and never call collect() on large datasets — it pulls all data to one machine',
      'In interviews: "daily pipeline reads Parquet partitioned by date, pushes predicates to skip irrelevant partitions, uses salted keys for skewed groupBy operations. We monitor shuffle size and spill metrics"',
    ],
    mnemonic: 'Spark = dataframe spread across cluster',
    interviewQ: 'Spark job slow after groupBy',
    interviewA: 'Likely skew — few keys dominate partitions. Salting keys for aggregation then merge. Increase shuffle partitions cautiously. AQE skew join handling. Broadcast small table if eligible. Check spill metrics. Repartition upstream evenly. Consider incremental processing instead of full scan.',
    difficulty: Difficulty.intermediate,
    tags: ['data-engineering', 'spark', 'big-data'],
  ),
  Concept(
    id: 117,
    category: _cat,
    color: _color,
    icon: '🔗',
    title: 'Data Lineage',
    tagline: 'Trace column to source',
    diagram: '''
  Raw.events ─► staging ─► mart_revenue
       │                        │
       └─ OpenLineage / dbt docs ─► UI graph''',
    bullets: [
      'Data lineage maps where data came from, how it was transformed, and where it flows — like a family tree for data showing the complete ancestry of every dashboard number back to its raw source',
      'Main use case: impact analysis. If the "users" table changes its schema, lineage tells you instantly which downstream tables, marts, and dashboards will break — before the change causes incorrect reports',
      'When a metric looks wrong, lineage traces backward through every transformation to find where the calculation diverged. Without it, debugging means manually reading SQL and guessing',
      'Regulatory requirements (SOC2, GDPR) demand data provenance. Automated lineage (from dbt DAGs, OpenLineage hooks, SQL parsing) provides audit trails without manual documentation',
      'In interviews: "dbt generates our transformation DAG and column-level lineage. Before changing any source table, we check downstream impact. We pair lineage with a data catalog for ownership tagging"',
    ],
    mnemonic: 'Lineage = family tree for data',
    interviewQ: 'SOC2 asks about data provenance',
    interviewA: 'Implement automated lineage capture: dbt exposes DAG, ingestion tools with OpenLineage, warehouse query logs for ad-hoc. Document owners per table. Access logs retained. For PII columns, track transforms (masking). Regular export of lineage graph for auditors. Integrate catalog (DataHub, Collibra).',
    difficulty: Difficulty.intermediate,
    tags: ['data-engineering', 'governance', 'compliance'],
  ),
  Concept(
    id: 118,
    category: _cat,
    color: _color,
    icon: '🎯',
    title: 'Feature Store',
    tagline: 'ML features online + offline',
    diagram: '''
  Offline: training historical feature snapshots
  Online: low-latency serving for inference

  Same definitions — point-in-time correctness''',
    bullets: [
      'A feature store manages the features (input variables) used by ML models — ensuring the same feature definition is used during training and production serving, eliminating a common source of ML bugs',
      'The biggest problem: training-serving skew. "Average purchase in 30 days" might be computed differently in batch training vs real-time serving. A feature store uses one definition for both',
      'Two interfaces: offline store (for training — point-in-time correct historical features, avoiding future data leakage) and online store (for serving — low-latency feature lookups during inference)',
      'Feature freshness matters: if a real-time fraud model uses "transactions last hour" but the feature updates daily, the model loses predictive power. Monitor freshness and null rates',
      'In interviews: "fraud model features managed in a feature store with shared definitions. Stream processing updates real-time features, batch jobs compute historical aggregates — eliminating training-serving skew"',
    ],
    mnemonic: 'Feature store = single recipe for train and prod',
    interviewQ: 'Model works offline, fails online',
    interviewA: 'Training-serving skew: different aggregation windows or missing default imputation online. Use feature store with shared transformation code. Validate online features logged and compared to offline expectations. Latency constraints may truncate history — document differences. Shadow traffic testing before full rollout.',
    difficulty: Difficulty.advanced,
    tags: ['data-engineering', 'ml', 'architecture'],
  ),
];
