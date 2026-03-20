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
      'SQL databases (PostgreSQL, MySQL) store data in structured tables with predefined columns, like a spreadsheet. NoSQL databases (MongoDB, DynamoDB) store data in flexible formats like JSON documents, where each record can have different fields',
      'SQL shines when your data has clear relationships (users have orders, orders have items) and you need guarantees — like ensuring a bank transfer debits one account and credits another atomically (ACID transactions)',
      'NoSQL shines when you need massive write throughput, flexible schemas that evolve frequently, or horizontal scaling across many servers. It trades away joins and strict consistency for speed and flexibility',
      'The real-world answer is usually both: PostgreSQL for user accounts and transactions (where correctness matters), and Cassandra or DynamoDB for activity feeds and analytics (where speed and scale matter)',
      'In interviews, never say "just use NoSQL because it scales." Identify access patterns first — "our product catalog fits a document store, but our order ledger needs relational ACID guarantees"',
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
      'PostgreSQL is the most versatile relational database — think of it as the "Swiss army knife" that handles structured data with strong guarantees: if a transaction succeeds, the data is correct and durable, period',
      'ACID transactions are the superpower: Atomicity (all-or-nothing), Consistency (data rules always hold), Isolation (concurrent users don\'t interfere), Durability (committed data survives crashes). This is why banks and auth systems rely on relational databases',
      'SQL gives you powerful querying: join multiple tables, aggregate data, filter complex conditions — all in a single query. This flexibility is hard to replicate in NoSQL where you must design your schema around specific queries upfront',
      'PostgreSQL scales reads with replicas and speeds lookups with indexes (B-tree for most queries, specialized indexes for full-text search and geospatial data). Extensions like PostGIS add domain-specific capabilities',
      'In interviews, PostgreSQL is a safe default for any system where data integrity matters. Know its limits: a single node handles most workloads, replicas help reads, but for massive write throughput you\'ll need sharding or a different database',
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
      'Cassandra is a distributed database designed for massive write throughput — like having dozens of filing clerks who all accept new paperwork simultaneously without needing a manager to coordinate',
      'Unlike PostgreSQL with one primary server, Cassandra is masterless: every node is equal, can accept reads and writes, and there\'s no single point of failure. Lose a node, and the rest keep working seamlessly',
      'You can tune consistency per query: write to just ONE node (fastest, risk of data loss), a QUORUM/majority (balanced), or ALL nodes (slowest, strongest guarantee). This flexibility lets you optimize each operation differently',
      'It excels at write-heavy workloads — time-series data, IoT sensor readings, activity feeds, and messaging — because writes are append-only and compaction happens in the background',
      'In interviews, reach for Cassandra when the problem involves "millions of writes per second" or "data that grows continuously." Avoid it when you need complex joins or strong consistency across the entire dataset',
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
      'MongoDB stores data as JSON-like documents where each document can have different fields — like a folder of resumes where each person includes different sections',
      'The main benefit is schema flexibility: you can add new fields without migrating the entire database. Great for prototyping and applications where data structures evolve frequently',
      'Instead of joining separate tables, you embed related data directly in the document. A user document contains their address and orders nested inside — one read fetches everything',
      'The trade-off: without strict schemas, data quality depends on application discipline. Cross-document operations historically lacked ACID guarantees (multi-document transactions added in v4.0 but add complexity)',
      'In interviews, MongoDB fits content management systems, product catalogs, and user profiles — anywhere data is heterogeneous and read patterns are document-centric. Avoid it for heavy cross-collection joins',
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
      'Redis is an in-memory database that stores data as key-value pairs with sub-millisecond response times — like a dictionary you keep in RAM instead of on disk. It handles 100,000+ operations per second per node',
      'What makes Redis special is its rich data structures beyond simple key-value: hashes (mini objects), lists (queues), sets (unique collections), sorted sets (leaderboards), and streams (event logs). Each has purpose-built operations',
      'Common use cases: caching (store hot data from your main DB), session storage (user login state), rate limiting (track request counts), leaderboards (sorted sets with scores), and pub/sub (real-time messaging between services)',
      'Although in-memory, Redis offers persistence: periodic snapshots (RDB) and append-only file (AOF) that logs every write. This lets you recover after a restart, though it\'s not as durable as a traditional database',
      'In interviews, Redis appears in almost every system design as the caching layer. Know that it scales horizontally via Redis Cluster and use it as your answer for "how to make this faster"',
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
      'A database index is like a book\'s index — instead of reading every page to find what you want, you look up the term in a sorted index that points directly to the right page. Without an index, the database must scan every row',
      'The default index type (B-tree) keeps data sorted, enabling fast lookups for both exact matches (WHERE id = 42) and range queries (WHERE date BETWEEN X AND Y). Lookup time is O(log N) — fast even with millions of rows',
      'The trade-off: indexes speed up reads but slow down writes because every INSERT or UPDATE must also update the index. They also consume disk space. Add indexes on columns you query frequently, not on every column',
      'Column order matters in composite indexes: an index on (country, city) helps queries filtering by country, or by both, but NOT by city alone. Think of it like a phone book sorted by last name then first name',
      'In interviews, when asked "why did the query get slow?", your first answer should be "check the index." Mention EXPLAIN ANALYZE as the tool to verify whether the database is using the index or doing a full table scan',
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
      'Read replicas continuously copy data from the primary database so you can spread read traffic across multiple machines — the primary handles all writes, replicas serve read queries, multiplying your read capacity',
      'Replication lag is the key challenge: replicas may be milliseconds to seconds behind the primary. A user who updates their profile and immediately reloads might see old data if their read hits a lagging replica',
      'Fixing stale reads: route the user\'s session to the primary for a few seconds after a write (read-your-writes), or use a synchronous replica that\'s always up-to-date (slower writes, but guaranteed fresh reads)',
      'Replicas also serve as a safety net: if the primary crashes, a replica can be promoted to become the new primary (failover). Tools like Patroni or cloud services like RDS automate this process',
      'In interviews, use separate connection pools for reads and writes — the write pool points to the primary, the read pool to replicas behind a load balancer. This is the standard architecture for read-heavy applications',
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
      'There are two main ways to split data across shards: hash-based (run the key through a hash function for even distribution, like dealing cards) and range-based (split by value ranges, like sorting mail by zip code)',
      'Hash sharding distributes data evenly but makes range queries painful — "find all orders from January" might hit every shard. Range sharding keeps related data together but risks hotspots — all recent data piles on one shard',
      'Choosing a shard key is one of the most consequential decisions in system design. A bad key is extremely expensive to change because resharding requires migrating billions of rows while the system is live',
      'Cross-shard operations (joins, aggregations) become your biggest pain point. Design your data model so the most common queries only need one shard. For cross-shard queries, fan out in the application layer and merge results',
      'In interviews, always discuss shard key selection: high cardinality (many unique values), even distribution (no hotspots), and query alignment (common queries hit a single shard). user_id is often the best default',
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
      'DynamoDB organizes data with two keys: the partition key (which server stores this row — like which filing cabinet) and the sort key (how items are ordered within that partition — like alphabetical within a drawer)',
      'The partition key is critical: DynamoDB distributes data and throughput based on it. If too many requests hit the same partition key (a "hot key"), that partition throttles even if other partitions are idle',
      'The sort key enables efficient range queries within a partition. For example, partition key USER#123 with sort keys ORDER#001, ORDER#002 lets you query "all orders for user 123" efficiently',
      'Single-table design is a DynamoDB pattern where you store different entity types in one table by encoding the type in the sort key (e.g., USER#123 + PROFILE, USER#123 + ORDER#001). This colocates related data for single-query retrieval',
      'In interviews, the most common DynamoDB question is "why is the table throttling?" — the answer is almost always a hot partition key. Solve it by adding randomness to write-heavy keys or redesigning access patterns',
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
      'When multiple users access a database simultaneously, isolation levels control how much they can see of each other\'s unfinished work — like deciding whether a library visitor can see a book someone else is still editing',
      'Lower isolation (READ COMMITTED) is the most common default: you only see data that\'s been fully committed, but two identical queries in the same transaction might return different results if another transaction commits between them',
      'Higher isolation (SERIALIZABLE) makes transactions behave as if they ran one at a time — no surprises, but more conflicts and slower throughput. Use it selectively for critical operations like financial transfers',
      'PostgreSQL uses MVCC (Multi-Version Concurrency Control): instead of blocking readers while writing, it keeps multiple versions of each row. Readers see a snapshot and are never blocked by writers — this is why PostgreSQL handles concurrency so well',
      'In interviews, show you understand the trade-off: "I\'d use READ COMMITTED as the default, and upgrade to SERIALIZABLE only for the money-transfer endpoint where phantom reads could cause double-spending"',
    ],
    mnemonic: 'Stronger isolation = fewer surprises, more conflicts',
    interviewQ: 'Explain phantom reads and how to prevent them',
    interviewA: 'Phantom read: same query twice returns different row sets because another transaction inserted matching rows. Prevent with SERIALIZABLE or range locks (gap locks in MySQL InnoDB REPEATABLE READ). In PostgreSQL REPEATABLE READ, anomalies can still occur for some patterns — SERIALIZABLE uses SSI to detect conflicts. Often fix with explicit locking or idempotent unique constraints.',
    difficulty: Difficulty.advanced,
    tags: ['databases', 'transactions', 'consistency'],
  ),
];
