import '../../domain/models/concept.dart';
import '../../core/theme/app_colors.dart';

const _cat = 'Messaging';
final _color = AppColors.messaging;

final conceptsMessaging = <Concept>[
  Concept(
    id: 31,
    category: _cat,
    color: _color,
    icon: '📬',
    title: 'Message Queues',
    tagline: 'Decouple producers and consumers',
    diagram: '''
  Producer ──► [ Queue ] ──► Consumer
                 │
            buffer when
            consumer slow

  vs sync RPC:
  Producer ───────────────► Service (blocked)''',
    bullets: [
      'Async handoff: producer enqueues and returns; worker processes later',
      'Buffers traffic spikes — queue depth is a metric to alert on',
      'Enables retries, DLQ, and multiple consumers with competing consumption',
      'Ordering: single partition preserves order; multiple consumers may interleave',
      'Backpressure: when queue grows, scale consumers or throttle producers',
    ],
    mnemonic: 'Queue = mailbox between services',
    interviewQ: 'When do you choose a queue over synchronous HTTP?',
    interviewA: 'When the caller doesn’t need an immediate result, or downstream is slow/unreliable. Example: email send, thumbnail generation, billing reconciliation. Queue smooths spikes and isolates failures. If you need a reply in the same request, use RPC. Combine both: accept job via API, return 202 + job id, process via queue.',
    difficulty: Difficulty.beginner,
    tags: ['messaging', 'queues', 'async'],
  ),
  Concept(
    id: 32,
    category: _cat,
    color: _color,
    icon: '📡',
    title: 'Pub/Sub',
    tagline: 'Fan-out events to many subscribers',
    diagram: '''
       publish "order.created"
              │
              ▼
         ┌─────────┐
         │  Topic  │
         └────┬────┘
    ┌────┬────┴────┬────┐
    ▼    ▼         ▼    ▼
   Sub1 Sub2     Sub3  Sub4
 (email)(search)(analytics)''',
    bullets: [
      'Topic = channel; subscribers are independent — one slow subscriber doesn’t block others',
      'Contrast with queue: competing consumers share work; pub/sub duplicates to each subscriber',
      'Use for domain events, cache invalidation broadcasts, real-time notifications',
      'Delivery semantics usually at-least-once — subscribers must be idempotent',
      'Kafka: topic + consumer groups blend pub/sub with load-balanced consumption',
    ],
    mnemonic: 'Pub/Sub = one announcement, many listeners',
    interviewQ: 'Pub/sub vs message queue for order events?',
    interviewA: 'Pub/sub when several systems must react to the same event (inventory, search index, CRM) without coupling. A work queue is better when many jobs need exactly one processor (e.g. payment capture workers). Kafka topics with multiple consumer groups give pub/sub semantics per group while each group load-shares partitions.',
    difficulty: Difficulty.beginner,
    tags: ['messaging', 'pubsub', 'events'],
  ),
  Concept(
    id: 33,
    category: _cat,
    color: _color,
    icon: '🪵',
    title: 'Kafka Basics',
    tagline: 'Distributed commit log',
    diagram: '''
  Topic: orders
  Partition 0: [o1][o2][o4]  ← ordered
  Partition 1: [o3][o5]

  Producer picks key → hash → partition
  Consumer group: each partition → one consumer in group''',
    bullets: [
      'Append-only log: high throughput, replayable history, durable retention',
      'Partitions scale throughput; key controls ordering per partition only',
      'Consumer groups track offsets — rebalance on member join/leave',
      'Compaction optional for changelog topics (keep latest key)',
      'Operational cost: ZooKeeper/KRaft, monitoring lag, disk planning',
    ],
    mnemonic: 'Kafka = durable tape everyone can rewind',
    interviewQ: 'How does Kafka provide ordering?',
    interviewA: 'Ordering is per partition only. Messages with the same key land in the same partition and keep production order. Global ordering needs a single partition (limits throughput). Design partition key around the entity that must be ordered (e.g. user_id for user actions). Cross-partition ordering is not guaranteed.',
    difficulty: Difficulty.intermediate,
    tags: ['messaging', 'kafka', 'streaming'],
  ),
  Concept(
    id: 34,
    category: _cat,
    color: _color,
    icon: '💀',
    title: 'Dead Letter Queues',
    tagline: 'Park poison messages safely',
    diagram: '''
  Queue ──► Consumer (fails N times)
              │
              └──► DLQ (inspect, replay, discard)

  Alert on DLQ depth — signals bad deploy or bad data''',
    bullets: [
      'After max retries, move message to DLQ instead of infinite loops',
      'DLQ messages need tooling: replay, inspect payload, root-cause dashboards',
      'Often caused by schema drift, bad JSON, or downstream timeout',
      'Separate DLQ per critical pipeline for clearer ownership',
      'Idempotency still required on replay to avoid duplicate side effects',
    ],
    mnemonic: 'DLQ = timeout corner for bad messages',
    interviewQ: 'What do you monitor on async pipelines?',
    interviewA: 'Queue depth, consumer lag, age of oldest message, DLQ rate, processing latency percentiles, and error ratio. Spike in DLQ after deploy suggests incompatible message format. Alert on sustained lag — consumers too slow or stuck. Track poison messages by correlation id to find bad producers.',
    difficulty: Difficulty.intermediate,
    tags: ['messaging', 'reliability', 'operations'],
  ),
  Concept(
    id: 35,
    category: _cat,
    color: _color,
    icon: '🔢',
    title: 'Message Ordering',
    tagline: 'Per-key vs global order',
    diagram: '''
  Same key K → same shard → order preserved
  K1: m1 m2 m3
  K2: m4 m1  (interleaved with K1 at system level)

  Global order: single pipe → bottleneck''',
    bullets: [
      'Distributed systems rarely guarantee global ordering cheaply',
      'Partition by business key when order matters (account, device)',
      'Out-of-order handling: version fields, last-write-wins cautiously, CRDTs',
      'FIFO queues help single consumer; multiple consumers break strict FIFO without locks',
      'Cross-service sagas may complete steps out of order — design compensations',
    ],
    mnemonic: 'Order is expensive — buy only what you need',
    interviewQ: 'User updates arrive out of order — how do you handle it?',
    interviewA: 'Include monotonic version or timestamp per entity; ignore stale updates server-side. Or serialize updates per user through a single partition/actor. For financial correctness, use database row versioning (optimistic locking) or event sourcing with deterministic reducers. Never rely on wall clocks across nodes.',
    difficulty: Difficulty.advanced,
    tags: ['messaging', 'ordering', 'consistency'],
  ),
  Concept(
    id: 36,
    category: _cat,
    color: _color,
    icon: '🔑',
    title: 'Idempotency Keys',
    tagline: 'Safe retries for payments and writes',
    diagram: '''
  Client: POST /pay  Idempotency-Key: uuid-1
  Server stores uuid-1 → result

  Retry same key → return same response (no double charge)

  New purchase → new key''',
    bullets: [
      'Clients generate stable key per logical operation; server dedupes within TTL window',
      'Store mapping key → response status + body in fast store (Redis) or DB unique index',
      'Essential for at-least-once delivery and mobile flaky networks',
      'Keys are not authentication — still need authz',
      'Combine with request hashing for true duplicate detection where needed',
    ],
    mnemonic: 'Same key → same outcome',
    interviewQ: 'How do you prevent double charging on webhook retries?',
    interviewA: 'Require idempotency key from client or derive from provider event id. Persist processed event ids in a table with unique constraint — second insert fails and you return 200 with original outcome. For Stripe-style APIs, document TTL (e.g. 24h) for key storage. Make settlement logic atomic with ledger entries.',
    difficulty: Difficulty.intermediate,
    tags: ['messaging', 'api', 'payments'],
  ),
  Concept(
    id: 37,
    category: _cat,
    color: _color,
    icon: '✅',
    title: 'Delivery Guarantees',
    tagline: 'At-most, at-least, exactly once',
    diagram: '''
  At-most-once:  send and forget — may lose
  At-least-once: ack after process — may duplicate
  Exactly-once:  end-to-end only with idempotent sinks + dedup

  Brokers ≠ exactly-once alone — consumers must cooperate''',
    bullets: [
      'At-least-once + idempotent handlers is the pragmatic default',
      'Exactly-once in Kafka: transactional producer + read-process-write with offsets — still tricky',
      'Distributed transactions across broker and DB are heavy — avoid when possible',
      'Dedup table or natural keys turn duplicates into no-ops',
      'Measure duplicate rate after failures to validate design',
    ],
    mnemonic: 'Exactly-once is a system property, not a checkbox',
    interviewQ: 'Does Kafka give exactly-once delivery?',
    interviewA: 'Kafka offers exactly-once semantics between producer and broker for writes, and transactional messaging in constrained setups. End-to-end exactly-once still requires your consumer to commit offsets and side effects atomically or use idempotent writes. Most teams implement at-least-once delivery with idempotent consumers and dedup keys.',
    difficulty: Difficulty.advanced,
    tags: ['messaging', 'kafka', 'consistency'],
  ),
  Concept(
    id: 38,
    category: _cat,
    color: _color,
    icon: '⚡',
    title: 'Event-Driven Architecture',
    tagline: 'Services react to facts, not calls',
    diagram: '''
  Service A emits events ──► Event bus
                              │
            ┌─────────────────┼─────────────────┐
            ▼                 ▼                 ▼
        Service B        Service C        Data lake

  Choreography vs orchestration (central coordinator)''',
    bullets: [
      'Loose coupling: new subscriber without changing publisher (with schema governance)',
      'Events should be facts (OrderPlaced) not commands to a specific service',
      'Need schema registry, versioning, and deprecation policy',
      'Debugging is harder — distributed tracing (trace context in messages) required',
      'Sagas coordinate long workflows via events and compensations',
    ],
    mnemonic: 'Events = newspaper; services subscribe to sections',
    interviewQ: 'Choreography vs orchestration?',
    interviewA: 'Choreography: services react to events independently — simpler locally, harder to see global flow. Orchestration: central saga/orchestrator sends commands — clearer workflow, risk of bottleneck and failure modes. Hybrid: orchestrator for critical money flows, choreography for analytics. Use workflow engine (Temporal) for complex compensations.',
    difficulty: Difficulty.intermediate,
    tags: ['messaging', 'architecture', 'microservices'],
  ),
  Concept(
    id: 39,
    category: _cat,
    color: _color,
    icon: '🧯',
    title: 'Backpressure',
    tagline: 'Slow down when downstream is full',
    diagram: '''
  Fast producer ──► [||||| queue grows |||||] ──► slow consumer

  Fixes:
  - block / nack producer
  - drop (lossy) with metrics
  - scale consumers
  - shed load at edge''',
    bullets: [
      'Unbounded in-memory queues hide problems until OOM — prefer bounded buffers',
      'Reactive streams: request(N) pulls data at consumer rate',
      'HTTP: 429/503 with Retry-After signals clients to slow down',
      'Message brokers: prefetch limits stop consumers biting more than they chew',
      'Monitor age of oldest message — SLO on freshness',
    ],
    mnemonic: 'Backpressure = telling upstream to chill',
    interviewQ: 'Our ingestion API overwhelms workers — what do you change?',
    interviewA: 'Put a bounded queue between API and workers; return 503 when full or use admission control (token bucket per tenant). Lower broker prefetch. Auto-scale workers on queue depth. For bursty sources, add Kinesis/SQS buffering. Long term, partition workloads and isolate noisy neighbors.',
    difficulty: Difficulty.intermediate,
    tags: ['messaging', 'performance', 'reliability'],
  ),
  Concept(
    id: 40,
    category: _cat,
    color: _color,
    icon: '🐰',
    title: 'RabbitMQ & AMQP',
    tagline: 'Classic broker routing',
    diagram: '''
  Exchange (topic/direct/fanout)
        │
    bindings (routing keys)
        │
   ┌────┴────┐
   ▼         ▼
 Queue A   Queue B
   │         │
 Worker    Worker''',
    bullets: [
      'Exchange routes messages to queues by type and routing rules',
      'Durable queues + persistent messages survive broker restart (with caveats)',
      'Ack modes: manual ack after process prevents message loss on crash',
      'TTL and DLX (dead-letter exchange) for expiry and failure paths',
      'Clustering for HA; understand mirrored queues vs quorum queues in modern RabbitMQ',
    ],
    mnemonic: 'Exchange = mail sorter; queue = inbox',
    interviewQ: 'Fanout vs topic exchange?',
    interviewA: 'Fanout copies every message to all bound queues — use for broadcast (cache invalidation). Topic exchange matches routing keys with patterns (orders.*.created) — use for selective routing. Direct exchange is exact routing key match. Choose based on how many distinct consumers need each message.',
    difficulty: Difficulty.intermediate,
    tags: ['messaging', 'rabbitmq', 'amqp'],
  ),
];
