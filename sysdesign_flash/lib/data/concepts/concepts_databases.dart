import '../../domain/models/concept.dart';
import '../../core/theme/app_colors.dart';

const _cat = 'Databases';
final _color = AppColors.databases;

final conceptsDatabases = <Concept>[
  Concept(
    id: 21,
    category: _cat,
    color: _color,
    icon: '🗄️',
    title: 'SQL vs NoSQL',
    tagline: 'Structure vs flexibility',
    diagram: '''
  SQL (Relational):
  ┌─────────────────────┐
  │ users               │
  │ id │ name  │ email  │
  │  1 │ Alice │ a@x.co │
  │  2 │ Bob   │ b@x.co │
  └─────────────────────┘
  → Schema enforced, ACID, JOINs

  NoSQL (Document):
  {
    "id": 1,
    "name": "Alice",
    "posts": [{...}, {...}]
  }
  → Flexible schema, embedded data''',
    bullets: [
      'SQL: fixed schema, ACID transactions, powerful JOINs — PostgreSQL, MySQL',
      'NoSQL: flexible schema, horizontal scale, denormalized — MongoDB, DynamoDB',
      'SQL excels at: complex queries, relationships, transactional integrity',
      'NoSQL excels at: high write throughput, schema evolution, horizontal scaling',
      'Choose based on query patterns, not hype — many systems use both (polyglot)',
    ],
    mnemonic: 'SQL = Structured + Safe; NoSQL = Scalable + Flexible',
    interviewQ: 'Design Instagram storage — SQL or NoSQL?',
    interviewA: 'Both (polyglot persistence). PostgreSQL for user profiles, relationships, and auth (needs ACID + JOINs). Cassandra for posts/feed (high write throughput, time-series queries, horizontal scaling). Redis for caching hot data and feed assembly. S3 for image/video storage. The choice depends on the specific data access pattern, not one-size-fits-all.',
    difficulty: Difficulty.beginner,
    tags: ['databases', 'sql', 'nosql'],
  ),
  Concept(
    id: 22,
    category: _cat,
    color: _color,
    icon: '🐘',
    title: 'Relational DB (PostgreSQL)',
    tagline: 'The gold standard for structured data',
    diagram: '''
  ┌──────────┐    ┌──────────┐
  │  users   │    │  posts   │
  │──────────│    │──────────│
  │ id  (PK) │←──┤ user_id  │
  │ name     │    │ title    │
  │ email    │    │ content  │
  └──────────┘    │ created  │
                  └──────────┘

  SELECT u.name, p.title
  FROM users u
  JOIN posts p ON u.id = p.user_id
  WHERE u.id = 1;''',
    bullets: [
      'ACID: Atomicity, Consistency, Isolation, Durability — guaranteed',
      'Rich query language (SQL), views, stored procedures, triggers',
      'Indexes: B-tree (default), GIN (full-text), GiST (geo), BRIN (time-series)',
      'Extensions: PostGIS (geo), pg_trgm (fuzzy search), timescaledb',
      'Scaling: read replicas, partitioning, Citus for horizontal sharding',
    ],
    mnemonic: 'PostgreSQL = Swiss army knife of databases',
    interviewQ: 'Design a user-relationship graph — can PostgreSQL handle it?',
    interviewA: 'Yes, for moderate scale. Use a junction table: friendships(user_a, user_b). Index both columns. For "friends of friends": recursive CTE or 2-hop join. At scale (billions of edges), switch to a graph DB like Neo4j. PostgreSQL handles up to ~100M relationships well with proper indexing. Use materialized views for precomputed social queries.',
    difficulty: Difficulty.beginner,
    tags: ['databases', 'sql', 'postgresql'],
  ),
  Concept(
    id: 23,
    category: _cat,
    color: _color,
    icon: '📊',
    title: 'Wide-Column Store (Cassandra)',
    tagline: 'Massive write throughput, distributed by design',
    diagram: '''
  Row Key: user_123
  ┌─────────────────────────────┐
  │ Col: post_ts1 │ Col: post_ts2 │
  │ {title, body} │ {title, body} │
  └─────────────────────────────┘

  Ring topology:
  ┌───┐   ┌───┐
  │ N1│───│ N2│
  └─┬─┘   └─┬─┘
    │       │
  ┌─┴─┐   ┌─┴─┐
  │ N4│───│ N3│
  └───┘   └───┘
  → Data partitioned by consistent hash''',
    bullets: [
      'Column families with dynamic columns — no fixed schema per row',
      'Masterless: all nodes are equal, no single point of failure',
      'Tunable consistency: ONE, QUORUM, ALL per query',
      'Optimized for writes: append-only LSM tree, compaction in background',
      'Best for: time-series, IoT, activity feeds, messaging — write-heavy workloads',
    ],
    mnemonic: 'Cassandra = write-heavy, masterless, linearly scalable',
    interviewQ: 'Design a time-series metrics store for 10M data points/sec',
    interviewA: 'Cassandra with time-bucketed partition keys: metric_name + day. Each row holds one day of data points as columns (sorted by timestamp). Write path: client → any node → coordinator → replicate to N nodes. Tunable consistency: ONE for writes (speed), QUORUM for reads (accuracy). TTL for auto-expiry of old data. Compaction strategy: TimeWindowCompactionStrategy.',
    difficulty: Difficulty.intermediate,
    tags: ['databases', 'nosql', 'cassandra'],
  ),
  Concept(
    id: 24,
    category: _cat,
    color: _color,
    icon: '📄',
    title: 'Document DB (MongoDB)',
    tagline: 'Schema flexibility for evolving data',
    diagram: '''
  Collection: users
  ┌──────────────────────────┐
  │ {                        │
  │   "_id": "abc123",       │
  │   "name": "Alice",       │
  │   "posts": [             │
  │     {"title": "...",     │
  │      "tags": ["go"]}     │
  │   ],                     │
  │   "address": {           │
  │     "city": "SF"         │
  │   }                      │
  │ }                        │
  └──────────────────────────┘
  → Embedded documents, no JOINs needed''',
    bullets: [
      'Documents (JSON/BSON) with nested objects and arrays',
      'Schema-less: each document can have different fields',
      'Embed related data to avoid joins — denormalized by design',
      'Good for: CMS, user profiles, catalogs, prototyping',
      'Trade-off: no cross-document ACID (until v4.0 multi-doc transactions)',
    ],
    mnemonic: 'MongoDB = JSON in, JSON out — model your objects directly',
    interviewQ: 'Design a CMS — why choose a document DB?',
    interviewA: 'CMS content is heterogeneous: blog posts have different fields than product pages or FAQs. Document DB lets each content type have its own schema without migrations. Embed comments within the document for single-read performance. Index on tags and content_type for filtering. Use MongoDB Atlas Search for full-text search. Downside: cross-content-type queries and reporting are harder without JOINs.',
    difficulty: Difficulty.beginner,
    tags: ['databases', 'nosql', 'mongodb'],
  ),
  Concept(
    id: 25,
    category: _cat,
    color: _color,
    icon: '🔑',
    title: 'Key-Value Store (Redis)',
    tagline: 'Blazing fast in-memory data',
    diagram: '''
  SET user:123 "Alice"      → O(1)
  GET user:123              → "Alice"

  Data structures:
  ┌──────────────────────────┐
  │ Strings: simple K-V      │
  │ Hashes:  user:{name,age} │
  │ Lists:   message queue   │
  │ Sets:    unique tags     │
  │ Sorted Sets: leaderboard │
  │ Streams: event log       │
  └──────────────────────────┘
  All operations: O(1) or O(log N)''',
    bullets: [
      'In-memory: sub-millisecond reads/writes — 100K+ ops/sec per node',
      'Rich data structures: strings, hashes, lists, sets, sorted sets, streams',
      'Use cases: caching, sessions, rate limiting, pub/sub, leaderboards',
      'Persistence: RDB snapshots + AOF append-only file for durability',
      'Cluster mode: hash slots (16384) distributed across nodes for horizontal scale',
    ],
    mnemonic: 'Redis = Remote Dictionary Server — in-memory Swiss army knife',
    interviewQ: 'Design a session store for 10M concurrent users',
    interviewA: 'Redis Cluster with hash-slot sharding. Key: session:{token}, Value: hash of user data. TTL: 30 minutes (auto-expire idle sessions). SET with NX for atomic session creation. Pipeline commands for batch operations. Persistence: AOF with fsync every second (balance durability vs speed). Sentinel for automatic failover. Memory: ~1KB per session × 10M = 10GB — fits in memory easily.',
    difficulty: Difficulty.beginner,
    tags: ['databases', 'redis', 'caching'],
  ),
  Concept(
    id: 26,
    category: _cat,
    color: _color,
    icon: '🌳',
    title: 'B-Tree & Database Indexes',
    tagline: 'How indexes speed lookups',
    diagram: '''
  Table rows (heap)          B-Tree index on user_id
  ┌────┬────────┐           ┌─────────────────────┐
  │ id │ user_id│           │ 42 → ptr to row 3   │
  ├────┼────────┤           │ 57 → ptr to row 1   │
  │ 1  │   57   │           │ 91 → ptr to row 2   │
  │ 2  │   91   │           └─────────────────────┘
  │ 3  │   42   │           SELECT * WHERE user_id=42
  └────┴────────┘           → O(log N) index seek + 1 row fetch''',
    bullets: [
      'Default B-tree (PostgreSQL B-tree) keeps keys sorted for range queries and equality',
      'Index = smaller structure; trade-off: extra disk + slower writes (maintain tree)',
      'Covering index: include columns in index so queries avoid heap lookups',
      'Wrong index = full table scan — EXPLAIN ANALYZE to verify plans',
      'Composite index column order matters: (a,b) helps WHERE a=? but not WHERE b=? alone',
    ],
    mnemonic: 'Index = sorted phone book for your column',
    interviewQ: 'Why did our query get slow after we added more data?',
    interviewA: 'Likely missing or unused index, or statistics drift. Check EXPLAIN: Seq Scan on large table means full scan. Add index on filter/join columns used in WHERE. Ensure ANALYZE runs after bulk loads. Watch for selective predicates — low cardinality columns (e.g. boolean) may not benefit. Consider partial indexes for hot subsets.',
    difficulty: Difficulty.intermediate,
    tags: ['databases', 'indexing', 'performance'],
  ),
  Concept(
    id: 27,
    category: _cat,
    color: _color,
    icon: '📑',
    title: 'Read Replicas',
    tagline: 'Scale reads, tolerate primary failure',
    diagram: '''
  Writes ──────► PRIMARY (source of truth)
                    │
         async/sync copy
                    ▼
    ┌───────────┬───────────┐
    │ Replica 1 │ Replica 2 │
    └───────────┘ └───────────┘
         ▲              ▲
         └──────┬───────┘
            read traffic

  Lag: replica may be milliseconds–seconds behind''',
    bullets: [
      'Primary handles writes; replicas replay WAL/binlog for read scaling',
      'Replication lag: users may read stale data right after a write — design UX accordingly',
      'Promote replica to primary on failover (manual or orchestrated — Patroni, RDS)',
      'Read-your-writes: route same session to primary or use sync replica',
      'Connection pooling: separate pools for read vs write endpoints',
    ],
    mnemonic: 'One writer, many readers — mind the lag',
    interviewQ: 'How do you scale reads for a read-heavy product?',
    interviewA: 'Add read replicas behind a load balancer; route analytics and list endpoints to replicas. Use streaming replication with monitoring on lag. For strong consistency after profile update, stick to primary for that user’s next read or use session affinity. Cache hot keys in Redis. Sharding is the next step when single primary can’t handle writes.',
    difficulty: Difficulty.intermediate,
    tags: ['databases', 'replication', 'scaling'],
  ),
  Concept(
    id: 28,
    category: _cat,
    color: _color,
    icon: '🔀',
    title: 'Sharding Strategies',
    tagline: 'Split data across many databases',
    diagram: '''
  Router / app layer
        │
   hash(user_id) % N
        │
   ┌────┼────┬────┐
   ▼    ▼    ▼    ▼
  DB0  DB1  DB2  DB3

  Range shard (by region):
  US ──► Shard A    EU ──► Shard B''',
    bullets: [
      'Hash sharding: even spread; range queries across shards are painful',
      'Range/geo sharding: locality and range queries easier; hotspots if skewed',
      'Shard key is permanent — wrong key causes expensive resharding',
      'Cross-shard JOINs avoided: denormalize or fan-out queries + merge in app',
      'Resharding: dual-write, backfill, cutover — use orchestration (Vitess, Cockroach)',
    ],
    mnemonic: 'Shard key picks your future pain or peace',
    interviewQ: 'When do you shard a database?',
    interviewA: 'When vertical scaling and replicas are exhausted — single-node CPU/IO or write throughput ceiling. Choose shard key with high cardinality and even access (e.g. user_id). Plan resharding story early. Avoid cross-shard transactions; use sagas or per-shard consistency. Start with fewer shards and split when metrics demand.',
    difficulty: Difficulty.advanced,
    tags: ['databases', 'sharding', 'scaling'],
  ),
  Concept(
    id: 29,
    category: _cat,
    color: _color,
    icon: '⚡',
    title: 'DynamoDB Partition & Sort Keys',
    tagline: 'Single-table design on AWS',
    diagram: '''
  PK (partition)     SK (sort)
  USER#123          PROFILE
  USER#123          ORDER#9001
  USER#123          ORDER#9002

  Hot partition if PK skew:
  CELEB#1 ──► one partition overloads''',
    bullets: [
      'Partition key determines which node holds the row — hot keys throttle the table',
      'Sort key enables range queries within a partition (e.g. orders by time)',
      'GSI/LSI project alternate access patterns — each index has its own partition heat',
      'Single-table design: encode entity type in SK to colocate related items',
      'Understand RCU/WCU, bursts, and on-demand vs provisioned pricing',
    ],
    mnemonic: 'PK = which drawer; SK = order inside the drawer',
    interviewQ: 'Why is our DynamoDB table throttling?',
    interviewA: 'Hot partition: too many requests hit the same partition key. Redistribute — add random suffix to write-heavy keys and read with Query fan-out, or use write sharding pattern. Check adaptive capacity and on-demand mode. For GSI, skewed attributes become hot secondaries. Redesign access patterns so load spreads across many partition key values.',
    difficulty: Difficulty.advanced,
    tags: ['databases', 'dynamodb', 'aws'],
  ),
  Concept(
    id: 30,
    category: _cat,
    color: _color,
    icon: '🔒',
    title: 'Isolation Levels & MVCC',
    tagline: 'What concurrent transactions see',
    diagram: '''
  Tx1: BEGIN ... UPDATE balance ...
  Tx2: BEGIN ... SELECT balance ...

  READ COMMITTED: Tx2 sees only committed data
  REPEATABLE READ: Tx2 snapshot at start — same read twice
  SERIALIZABLE: as if transactions ran one-by-one

  MVCC: keep row versions; readers don’t block writers''',
    bullets: [
      'Lower isolation = higher throughput, more anomalies (dirty read, phantom)',
      'MVCC (PostgreSQL): snapshots avoid read locks; writers create new row versions',
      'Pick default for OLTP (often READ COMMITTED); tighten only where bugs appear',
      'Deadlocks: circular lock wait — DB picks victim and aborts one transaction',
      'Long transactions hold versions → bloat and vacuum pressure',
    ],
    mnemonic: 'Stronger isolation = fewer surprises, more conflicts',
    interviewQ: 'Explain phantom reads and how to prevent them',
    interviewA: 'Phantom read: same query twice returns different row sets because another transaction inserted matching rows. Prevent with SERIALIZABLE or range locks (gap locks in MySQL InnoDB REPEATABLE READ). In PostgreSQL REPEATABLE READ, anomalies can still occur for some patterns — SERIALIZABLE uses SSI to detect conflicts. Often fix with explicit locking or idempotent unique constraints.',
    difficulty: Difficulty.advanced,
    tags: ['databases', 'transactions', 'consistency'],
  ),
];
