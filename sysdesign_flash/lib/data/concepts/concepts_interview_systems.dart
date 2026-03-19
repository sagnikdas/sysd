import '../../domain/models/concept.dart';
import '../../core/theme/app_colors.dart';

const _cat = 'Interview Systems';
final _color = AppColors.interviewSystems;

final conceptsInterviewSystems = <Concept>[
  Concept(
    id: 119,
    category: _cat,
    color: _color,
    icon: '🐦',
    title: 'Design Twitter / News Feed',
    tagline: 'Fan-out on write vs read',
    diagram: '''
  Post ──► for each follower? (push — celeb problem)
       or
  Pull ──► merge on read (slow for heavy readers)

  Hybrid: push to active, pull for long tail''',
    bullets: [
      'Clarify scale: DAU, tweet rate, fan-out distribution',
      'Celebrities: don’t push millions — fan-out on read for them',
      'Timeline cache per user in Redis; background fan-out workers',
      'Global: multi-region with eventual consistency acceptable for feed',
      'Search and trends are separate heavy subsystems',
    ],
    mnemonic: 'Feed = who fans out the post?',
    interviewQ: 'Justin Bieber tweets — your push model dies',
    interviewA: 'Detect high fan-out accounts; for them skip push and merge their tweets at read time into follower timelines. Cap fan-out queue depth with shedding. Use ranked feed later — not strictly chronological. Store tweet ids, hydrate tweet bodies from object store. Rate limit posting. Monitor hot keys in cache.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'feed', 'social'],
  ),
  Concept(
    id: 120,
    category: _cat,
    color: _color,
    icon: '📸',
    title: 'Design Instagram',
    tagline: 'Photos, feed, stories',
    diagram: '''
  Upload ──► object storage (S3)
         ──► CDN for delivery
         ──► async transcoding thumbs

  Feed similar to Twitter hybrid fan-out''',
    bullets: [
      'Images/video: multi-res transcoding pipeline, CDN edge cache',
      'Metadata in graph DB or relational for follows',
      'Stories: higher churn TTL content — separate lower-latency path',
      'Search by hashtag — inverted index',
      'Integrity: perceptual hashing for abuse',
    ],
    mnemonic: 'Instagram = storage + graph + feed',
    interviewQ: 'Resize images for many clients',
    interviewA: 'Generate standard variants (thumb, medium, full) async via queue; store URIs in DB. CDN with Accept-CH or client hints optional. On-the-fly resizing at CDN edge if provider supports. Lazy generation on first request with cache. Original archived in cold storage for reprocessing.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'media', 'cdn'],
  ),
  Concept(
    id: 121,
    category: _cat,
    color: _color,
    icon: '🚗',
    title: 'Design Uber',
    tagline: 'Matching, maps, real-time',
    diagram: '''
  Riders & drivers location streams
       │
  Spatial index (geohash / quadtree)
       │
  Dispatch service picks nearest ETA''',
    bullets: [
      'Real-time location: WebSocket/mobile push; batched updates',
      'Supply/demand pricing surge algorithm separate',
      'Trips: state machine — requested, matched, ongoing, completed',
      'Payments and receipts: idempotent charging, outbox events',
      'Maps routing external API with caching',
    ],
    mnemonic: 'Uber = moving dots + matching engine',
    interviewQ: 'Match rider to driver in 2s globally',
    interviewA: 'Partition world into cells; each cell has in-memory index of available drivers from recent heartbeats. Query neighboring cells for nearest N by road ETA using routing service with cache. Precompute heat maps for repositioning drivers. Handle split-brain with sticky session to dispatch shard. Fallback list if top match declines.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'geo', 'realtime'],
  ),
  Concept(
    id: 122,
    category: _cat,
    color: _color,
    icon: '💬',
    title: 'Design WhatsApp',
    tagline: 'Chat, delivery, privacy',
    diagram: '''
  Client ──► gateway ──► chat service
                    │
              message store (per conv shard)
                    │
              push notification if offline''',
    bullets: [
      'Per-conversation ordering with sequence numbers',
      'E2E encryption: server stores ciphertext blobs only',
      'Delivery receipts: separate small events',
      'Presence and last seen: low-latency KV with TTL',
      'Media offload to object storage like Instagram',
    ],
    mnemonic: 'Chat = ordered messages + push + presence',
    interviewQ: 'Guarantee message order in group chat',
    interviewA: 'Single leader per conversation shard assigns monotonic seq. Clients display by seq; gap detection triggers sync. Handle partition: choose availability with possible temporary fork — reconcile with CRDT or last-writer-wins with server timestamp. At-least-once delivery with client dedup keys.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'messaging', 'chat'],
  ),
  Concept(
    id: 123,
    category: _cat,
    color: _color,
    icon: '🎬',
    title: 'Design Netflix',
    tagline: 'Streaming, CDN, recommendations',
    diagram: '''
  Encode ladder (many bitrates)
       │
  Origin ──► Open Connect CDN (ISP edge)
       │
  Client adaptive bitrate (ABR)''',
    bullets: [
      'Chunked video (HLS/DASH) for ABR switching',
      'CDN placement closer than cloud region — ISP embed appliances',
      'DRM and license servers separate trust boundary',
      'Viewing history feeds recommendation offline + nearline features',
      'Personalized home rows — not one global catalog sort',
    ],
    mnemonic: 'Netflix = encodes + edge + player smarts',
    interviewQ: 'Reduce buffering on variable networks',
    interviewA: 'ABR chooses lower bitrate on throughput drops; buffer health heuristics. Multiple CDN origins with failover. TCP vs QUIC experiments. Preposition popular content on edge based on predictions. Measure QoE not just average bitrate. Edge compute for manifest personalization.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'video', 'cdn'],
  ),
  Concept(
    id: 124,
    category: _cat,
    color: _color,
    icon: '📁',
    title: 'Design Dropbox',
    tagline: 'Sync, dedup, conflicts',
    diagram: '''
  Client watches filesystem
       │
  Chunk files ──► hash ──► upload missing chunks
       │
  Server metadata graph per user''',
    bullets: [
      'Content-defined chunking for deduplication across users',
      'Metadata per file version; block storage for chunks',
      'Conflict: last-writer-wins or user-merge for text',
      'LAN sync for office speed optional',
      'Trash and version history retention policies',
    ],
    mnemonic: 'Dropbox = chunks + metadata tree',
    interviewQ: 'Two offline edits same file',
    interviewA: 'Detect divergent versions on sync; surface conflict copies to user or merge for line-based text. Vector clocks or version vectors per file help identify causality. Server authoritative timestamp as tie-break only if business accepts. Mobile may prefer server-wins for photos with rename.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'storage', 'sync'],
  ),
  Concept(
    id: 125,
    category: _cat,
    color: _color,
    icon: '🔎',
    title: 'Design Google Search',
    tagline: 'Crawl, index, rank',
    diagram: '''
  Crawler frontier ──► fetch ──► parse
       │
  Inverted index: term → doc list
       │
  PageRank / ML rank on top hits''',
    bullets: [
      'Distributed crawler respects robots.txt and rate limits',
      'Sharding index by term range or document',
      'Snippets from cached text; not live fetch on query',
      'Spell correct, synonyms — query understanding pipeline',
      'Ads system separate auction from organic rank',
    ],
    mnemonic: 'Search = crawl + invert + rank',
    interviewQ: 'Shard inverted index at scale',
    interviewA: 'Partition by term: high-frequency terms on dedicated shards with replicas; long tail terms co-located. Doc shards alternative for distributed scoring. Two-phase query: fetch postings from term shards, merge in coordinator. Cache hot queries. BM25 + signals in ranking layer. Compression for postings lists.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'search', 'scale'],
  ),
  Concept(
    id: 126,
    category: _cat,
    color: _color,
    icon: '🔗',
    title: 'Design URL Shortener',
    tagline: 'Keys, redirects, analytics',
    diagram: '''
  POST long URL ──► generate short key (base62)
       │
  GET /abc ──► 302 Location: long
       │
  Counter or random + uniqueness check''',
    bullets: [
      'Key generation: atomic counter (single point) or random with collision retry',
      '302 vs 301 affects analytics and SEO',
      'Rate limit creation; scan for malware targets',
      'Click analytics async fire-and-forget',
      'Custom aliases reserved namespace',
    ],
    mnemonic: 'Shortener = KV with HTTP redirect',
    interviewQ: 'Generate short URLs without collisions',
    interviewA: 'Pre-generate random 62^7 keys in batch from DB sequence sharded across allocators. Or base62 encode snowflake ID. UNIQUE constraint on key; retry on collision. Avoid predictable keys for security. Cache hot mappings in Redis. Optional signed URLs for private short links.',
    difficulty: Difficulty.intermediate,
    tags: ['interview', 'api', 'scaling'],
  ),
  Concept(
    id: 127,
    category: _cat,
    color: _color,
    icon: '🕷️',
    title: 'Design Web Crawler',
    tagline: 'Polite, distributed frontier',
    diagram: '''
  URL frontier (priority queue)
       │
  Workers respect per-host rate
       │
  Dedup bloom + persistent seen set''',
    bullets: [
      'Politeness: delay per domain IP; respect robots',
      'Distributed: assign URL ranges to workers; avoid duplicate fetch',
      'DNS cache and connection pooling',
      'Content hash dedup of pages',
      'Deep web and JS rendering optional expensive tier',
    ],
    mnemonic: 'Crawler = polite ant colony',
    interviewQ: 'Avoid overloading small sites',
    interviewA: 'Central scheduler tracks per-host last fetch time and crawl-delay from robots.txt. Token bucket per domain. Prioritize high-value domains. Distributed workers pull from Kafka partitioned by hash(host) for locality. Backoff on 429/5xx. Monitor global QPS per ASN.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'crawler', 'distributed'],
  ),
  Concept(
    id: 128,
    category: _cat,
    color: _color,
    icon: '🎫',
    title: 'Design Ticket Booking (BookMyShow)',
    tagline: 'Seats, contention, fairness',
    diagram: '''
  User selects seat ──► hold (TTL) in Redis
       │
  Payment success ──► confirm in DB transaction
       │
  Release hold on timeout''',
    bullets: [
      'Seat map: row-level locking or optimistic locking with version',
      'Holds expire to prevent inventory lockup',
      'Idempotent payment webhook confirms booking',
      'Waitlist if sold out — notify async',
      'Read replicas not for seat availability — use primary or strong consistency',
    ],
    mnemonic: 'Booking = hold seat like grocery cart timer',
    interviewQ: 'Two users book same seat',
    interviewA: 'Use transaction with SELECT FOR UPDATE on seat row or unique constraint insert on (show_id, seat_id). Optimistic retry on conflict. Redis hold with Lua atomic check-and-set before DB commit path. Never trust client — server validates. Load test thundering herd on onsale.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'transactions', 'ecommerce'],
  ),
  Concept(
    id: 129,
    category: _cat,
    color: _color,
    icon: '🛒',
    title: 'Design E-commerce Checkout',
    tagline: 'Cart, inventory, payments',
    diagram: '''
  Cart (session) ──► inventory reservation
        │
  Payment intent ──► PSP ──► webhook confirm
        │
  Saga: cancel reservation if payment fails''',
    bullets: [
      'Inventory: oversell prevention — reservation token with TTL',
      'Payment idempotency keys mandatory',
      'Order service orchestrates saga with outbox',
      'Tax/shipping calculation edge cases',
      'Fraud scoring parallel path',
    ],
    mnemonic: 'Checkout = reservation + money + saga',
    interviewQ: 'Payment succeeds but order not created',
    interviewA: 'Reconciliation job matches PSP settlements to orders; repair or refund. Webhook processing must be idempotent with stored event id. Outbox pattern ties order row + outbox in same TX before calling payment. Compensating refund if downstream fails after charge. Audit log for support.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'ecommerce', 'payments'],
  ),
  Concept(
    id: 130,
    category: _cat,
    color: _color,
    icon: '💾',
    title: 'Design Distributed Cache',
    tagline: 'Memcached vs Redis cluster',
    diagram: '''
  Client consistent hash → node
  Node failure → remapped keys churn

  Replication vs client multiget shards''',
    bullets: [
      'Consistent hashing minimizes key movement on add/remove node',
      'Cache stampede: lock/single-flight/probabilistic early refresh',
      'TTL jitter against synchronized expiry',
      'Eviction policy LRU/LFU depends on workload',
      'Never sole source of truth — persistence elsewhere',
    ],
    mnemonic: 'Cache = fast forgetful scratchpad',
    interviewQ: 'Thundering herd on hot key expiry',
    interviewA: 'Mutex per key in app (single-flight), or request coalescing layer. Stale-while-revalidate serves old value while one worker refreshes. Random TTL jitter. Precompute on schedule for known hot keys. CDN layer for truly public data. Consider local in-process L1 + shared L2.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'caching', 'redis'],
  ),
  Concept(
    id: 131,
    category: _cat,
    color: _color,
    icon: '🚦',
    title: 'Design a Rate Limiter',
    tagline: 'Distributed token bucket',
    diagram: '''
  API gateway ──► Redis INCR + TTL / Lua token bucket
       │
  Headers: remaining, reset

  Per user, per IP, per API key tiers''',
    bullets: [
      'Central Redis for global accuracy; local leaky bucket for soft',
      'Synchronize clock skew awareness',
      'Return 429 + Retry-After',
      'Separate write-heavy vs read-heavy limits',
      'Config service to tune limits live',
    ],
    mnemonic: 'Rate limiter = traffic lights API',
    interviewQ: 'Precise global 100 req/min per user',
    interviewA: 'Redis sliding window with ZSET of timestamps or Lua atomic token bucket per user key. Expire keys to bound memory. Handle Redis failure: fail open vs closed product decision. Edge POP local counters with small overshoot vs central sync. Test at scale with parallel clients.',
    difficulty: Difficulty.intermediate,
    tags: ['interview', 'rate-limiting', 'system-design'],
  ),
  Concept(
    id: 132,
    category: _cat,
    color: _color,
    icon: '🔔',
    title: 'Design Notification System',
    tagline: 'Multi-channel fan-out',
    diagram: '''
  Event ──► notification service
              │
        template + prefs filter
              │
    ┌─────────┼─────────┐
    push    email     sms''',
    bullets: [
      'User preference matrix per channel and category',
      'Queue per channel with different workers (SMTP, FCM)',
      'Idempotency on notification id',
      'Digest mode batches high-frequency alerts',
      'Unsubscribe and compliance (CAN-SPAM)',
    ],
    mnemonic: 'Notifications = fan-out with user prefs',
    interviewQ: 'Email provider throttles us',
    interviewA: 'Multiple provider failover; backoff queue; prioritize transactional over marketing. Shard sending across IPs with good reputation. Honor rate limits with token bucket per provider. Retry DLQ for failures. Warm up new IPs gradually. Separate streams so marketing slowdown doesn’t block password reset.',
    difficulty: Difficulty.intermediate,
    tags: ['interview', 'messaging', 'scale'],
  ),
  Concept(
    id: 133,
    category: _cat,
    color: _color,
    icon: '📰',
    title: 'Design News Feed Ranking',
    tagline: 'Not chronological',
    diagram: '''
  Candidate generation (1000s)
       │
  Lightweight ranker
       │
  Heavy ML rerank top K''',
    bullets: [
      'Retrieve friends’ posts + ads + suggestions within latency budget',
      'Features: engagement history, recency, author affinity',
      'Online experimentation A/B',
      'Diversity and fatigue rules',
      'Cache ranked slice for scroll continuation',
    ],
    mnemonic: 'Ranking = retrieve then prune then score',
    interviewQ: 'Ranking latency budget 200ms',
    interviewA: 'Two-stage: cheap inverted index + linear model for 500→50, then small NN on 50→10 in parallel microservices with deadline. Precompute heavy user embeddings offline. Approximate nearest neighbor for similar posts. Fallback to chronological if timeout. Measure p99 tail.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'ml', 'feed'],
  ),
  Concept(
    id: 134,
    category: _cat,
    color: _color,
    icon: '📍',
    title: 'Design Yelp / Nearby Places',
    tagline: 'Geo queries at scale',
    diagram: '''
  Stores geohash indexed
       │
  Query: bounding box or radius
       │
  Filter + rank by distance/reviews''',
    bullets: [
      'Geohash prefix queries on sorted set',
      'Quadtree for variable density urban vs rural',
      'Replica per region; partial data for global chains',
      'Review spam detection async',
      'Photos CDN like Instagram',
    ],
    mnemonic: 'Yelp = geo index + reviews',
    interviewQ: 'Find 20 coffee shops within 2km fast',
    interviewA: 'Geohash cells covering circle; query Redis/ES with those prefixes; exact distance filter after. Precomputed popular area tiles cached. For huge result sets, limit candidates by density. Secondary sort by rating + distance score. Shard by region. Consider S2/H3 cells for uniform areas.',
    difficulty: Difficulty.intermediate,
    tags: ['interview', 'geo', 'search'],
  ),
  Concept(
    id: 135,
    category: _cat,
    color: _color,
    icon: '📝',
    title: 'Design Google Docs',
    tagline: 'OT, CRDTs, presence',
    diagram: '''
  Edits as operations with positions
       │
  OT transforms concurrent ops
       │
  WebSocket sync; snapshot checkpoints''',
    bullets: [
      'Operational Transform or CRDT (Yjs) for merge',
      'Central document server sequences ops',
      'Periodic snapshot + op log replay for fast join',
      'Presence cursors ephemeral',
      'Access control per doc share links',
    ],
    mnemonic: 'Collaborative doc = ordered ops + merge math',
    interviewQ: 'Offline edits converge without conflicts',
    interviewA: 'CRDT text type (RGA/YATA) converges automatically; OT with central server transforms ops against history. Client buffers offline ops; on reconnect send batch; server returns transformed ops for others. Snapshot + vector clock to know divergence. Size limits per doc; compress op log.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'collaboration', 'crdt'],
  ),
  Concept(
    id: 136,
    category: _cat,
    color: _color,
    icon: '⏱️',
    title: 'Design Distributed Job Scheduler',
    tagline: 'Cron at scale',
    diagram: '''
  Scheduler picks due jobs ──► queue
       │
  Workers execute with at-least-once
       │
  Lease/lock prevents double run''',
    bullets: [
      'Time wheel or sorted set of next_run in Redis/DB',
      'Horizontal schedulers need leader election or sharded time ranges',
      'Exactly-once execution impossible — idempotent jobs',
      'Retry backoff; DLQ for failures',
      'Observability on job lag',
    ],
    mnemonic: 'Scheduler = fancy alarm clock cluster',
    interviewQ: 'Job must not run twice on two schedulers',
    interviewA: 'Acquire DB advisory lock or DynamoDB conditional lock per job id with lease TTL. Only lease holder dispatches. If worker dies, lease expires and retry. Cron dedup key includes scheduled time. At-least-once delivery to queue; consumer idempotent. Use existing system (Temporal) for complex workflows.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'distributed', 'jobs'],
  ),
  Concept(
    id: 137,
    category: _cat,
    color: _color,
    icon: '🏆',
    title: 'Design Real-Time Leaderboard',
    tagline: 'Sorted sets, sharding',
    diagram: '''
  UPDATE score ──► Redis ZADD leaderboard:game1

  Top 100: ZREVRANGE O(log N + K)

  Global scale: shard by game_id''',
    bullets: [
      'Redis sorted sets classic for leaderboards',
      'Periodic rollup to DB for durability snapshot',
      'Tie-break by timestamp in score encoding',
      'Anti-cheat validation async',
      'Pub/sub for live UI updates',
    ],
    mnemonic: 'Leaderboard = always-sorted set',
    interviewQ: 'Billion scores — Redis too big',
    interviewA: 'Shard leaderboard per game or region; aggregate top-K periodically. Approximate algorithms (count-min, HyperLogLog) for display tiers. For global rank, use fractional cascading or segment trees in custom service. Cold storage in warehouse for history; hot set in memory only.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'gaming', 'redis'],
  ),
  Concept(
    id: 138,
    category: _cat,
    color: _color,
    icon: '🚪',
    title: 'Design API Gateway',
    tagline: 'Edge for microservices',
    diagram: '''
  Auth, rate limit, routing, WAF
       │
  /v1/users ──► user-service
  /v1/orders ──► order-service''',
    bullets: [
      'Terminate TLS; inject tracing headers',
      'JWT validation at edge; fine authz in service',
      'Request/response transformation versioning',
      'Circuit breaking to unhealthy origins',
      'Analytics and audit log',
    ],
    mnemonic: 'Gateway = airport security + gates',
    interviewQ: 'Gateway becomes bottleneck',
    interviewA: 'Scale gateway horizontally statelessly; anycast or LB. Offload auth crypto to hardware or fewer validations (introspection cache). Move heavy transforms to BFF. Use connection pooling to origins. Profile CPU — regex routes expensive. Consider service mesh for east-west leaving gateway thinner.',
    difficulty: Difficulty.intermediate,
    tags: ['interview', 'gateway', 'microservices'],
  ),
  Concept(
    id: 139,
    category: _cat,
    color: _color,
    icon: '💳',
    title: 'Design Payment System',
    tagline: 'Ledger, idempotency, reconciliation',
    diagram: '''
  Double-entry ledger rows
       │
  PSP webhook ──► idempotent apply
       │
  Nightly reconcile PSP vs ledger''',
    bullets: [
      'Ledger immutable append; corrections as adjusting entries',
      'Strong consistency on balance updates per account shard',
      'PCI scope reduction — tokenize cards with provider',
      'Multi-currency with FX service',
      'Dispute and chargeback workflows',
    ],
    mnemonic: 'Payments = ledger + idempotency + lawyers',
    interviewQ: 'Double charge investigation',
    interviewA: 'Trace idempotency keys and PSP payment intent ids in ledger. Immutable event log. Reconciliation job flags duplicates. Refund duplicate with audit. Root cause often webhook retry without idempotency. Partition tolerance: choose consistency for money — not eventual for balances.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'payments', 'finance'],
  ),
  Concept(
    id: 140,
    category: _cat,
    color: _color,
    icon: '📡',
    title: 'Design IoT Telemetry Pipeline',
    tagline: 'Ingest firehose',
    diagram: '''
  Devices MQTT/HTTP ──► ingest tier
       │
  Kafka ──► stream processing
       │
  TSDB + cold storage''',
    bullets: [
      'Device auth with per-device keys and rotation',
      'Batch uplink payloads to save connections',
      'Downlink commands separate channel with QoS',
      'Schema registry for protobuf/Avro',
      'Alerting on derived metrics',
    ],
    mnemonic: 'IoT = many small noisy speakers',
    interviewQ: '10M devices each send 1 msg/sec',
    interviewA: 'Regional ingest endpoints; Kafka with millions of partitions impractical — aggregate at edge gateway into wider batches per region. Partition by device_id hash. Cold path to object storage (Parquet) for analytics. Hot path to TSDB (Influx, Timescale) downsampled. Backpressure devices on overload.',
    difficulty: Difficulty.advanced,
    tags: ['interview', 'iot', 'streaming'],
  ),
  Concept(
    id: 141,
    category: _cat,
    color: _color,
    icon: '⚙️',
    title: 'Design Distributed Config Service',
    tagline: 'Feature flags and dynamic config',
    diagram: '''
  Admin UI ──► config service ──► clients poll/long-poll
       │
  Version + hash; rollback instant

  etcd/Consul for strongly consistent core''',
    bullets: [
      'Never take down prod for flag change',
      'Client SDK caches with TTL + push invalidation',
      'Audit who changed what',
      'Gradual rollout percentage per cohort',
      'Kill switch for bad deploy',
    ],
    mnemonic: 'Config service = remote control knobs',
    interviewQ: 'Config push to 50k servers without storm',
    interviewA: 'Clients pull with jittered intervals; server returns 304 if unchanged. Use CDN-like edge cache for read scaling. Long polling or server-sent events for urgent flags. Namespace flags by service. Protect admin API with MFA. Store versioned history for rollback. Avoid giant payloads — diff patches.',
    difficulty: Difficulty.intermediate,
    tags: ['interview', 'config', 'reliability'],
  ),
  Concept(
    id: 142,
    category: _cat,
    color: _color,
    icon: '🧱',
    title: 'Design Pastebin',
    tagline: 'Text storage, TTL, abuse',
    diagram: '''
  POST content ──► store blob (S3) + metadata (DB)
       │
  GET /abc ──► CDN cache if public
       │
  Expire job deletes after TTL''',
    bullets: [
      'Short URLs like shortener; collision-resistant keys',
      'Private pastes require signed URLs or auth',
      'Scan for secrets/malware; rate limit creation',
      'Syntax highlighting static client-side',
      'Legal takedown process',
    ],
    mnemonic: 'Pastebin = S3 + metadata + expiry',
    interviewQ: 'Public pastes viral — cost spike',
    interviewA: 'CDN cache GET aggressively for public; origin only on miss. Object storage cheap; egress expensive — negotiate CDN pricing. Rate limit per IP; CAPTCHA. Separate hot path read from write. DDoS at edge. Optional login for higher limits. Lifecycle policy to Glacier after TTL.',
    difficulty: Difficulty.intermediate,
    tags: ['interview', 'storage', 'cdn'],
  ),
];
