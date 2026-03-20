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
      'A message queue is a buffer between two services — like a mailbox where the sender drops off a letter and leaves, and the recipient picks it up whenever they\'re ready. Neither has to wait for the other',
      'Without queues, Service A calls Service B directly and waits. If B is slow or down, A is stuck. With a queue, A drops the work in and moves on — B processes it when available',
      'Queues absorb traffic spikes: if 10,000 requests arrive in a burst, the queue holds them while workers process at a steady pace. Monitor queue depth — a growing queue means workers can\'t keep up',
      'Multiple workers can consume from the same queue to process jobs in parallel (competing consumers). If ordering matters, use a single partition so messages are processed in sequence, but this limits throughput',
      'In interviews, use queues whenever the response doesn\'t need to be immediate: sending emails, processing uploads, generating reports. Return a 202 Accepted with a job ID and process asynchronously',
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
      'Pub/Sub broadcasts an event to every interested listener simultaneously — like a radio station sending to all tuned-in radios, versus a queue which is like a single phone call to one person at a time',
      'The key difference from a queue: with a queue, each message is processed by one consumer. With pub/sub, each message is delivered to ALL subscribers. When an order is placed, inventory, email, and analytics all get notified independently',
      'Subscribers are independent of each other — if the email service is slow, it doesn\'t block the inventory service from processing the same event. Each works at its own pace with its own copy',
      'Messages are typically delivered at-least-once, meaning duplicates are possible. Every subscriber must be idempotent — processing the same event twice should be harmless (e.g., checking "did I already send this email?")',
      'In interviews, use pub/sub when multiple services need to react to the same event. Use a queue when one worker processes each job. Kafka blends both: topics act as pub/sub, but consumer groups within a topic share work like a queue',
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
      'Kafka is a distributed event streaming platform that stores messages in an ordered, append-only log — like a recorded broadcast that anyone can rewind and replay, unlike a queue where messages disappear after being consumed',
      'Throughput scales by splitting a topic into partitions. Messages with the same key always land in the same partition, preserving their order — but there\'s no ordering guarantee across different partitions',
      'Consumer groups let multiple consumers share the load: each partition is assigned to exactly one consumer in the group. If a consumer crashes, its partitions are redistributed to surviving members (rebalancing)',
      'A killer feature is replayability: consumers track their position (offset) in the log and can rewind to reprocess historical events. This enables rebuilding search indexes, fixing data pipeline bugs, or adding new consumers that process past events',
      'In interviews, use Kafka for high-throughput event streams (clicks, logs, orders) where you need durability and replay. Know that ordering is per-partition only, and choose your partition key around the entity that needs ordering',
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
      'A Dead Letter Queue (DLQ) is a special queue where messages go after failing to process multiple times — like an "undeliverable mail" pile at the post office, where someone can inspect what went wrong and try again',
      'Without a DLQ, a poison message (one that always causes an error) blocks the entire queue forever — the system retries endlessly, processing nothing else. A DLQ isolates bad messages so the rest of the queue keeps flowing',
      'Common causes of DLQ messages: a producer changed the message format (schema drift), the message contains malformed data, or a downstream dependency is down. Each DLQ message is evidence of a bug or misconfiguration',
      'You need tooling around your DLQ: dashboards showing DLQ depth and growth rate, the ability to inspect message payloads, and a "replay" button to reprocess messages after fixing the underlying issue',
      'In interviews, always mention DLQs when designing async pipelines. Alert on DLQ depth — a spike right after a deployment usually means the new code broke message compatibility. Replaying still requires idempotent consumers',
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
      'Guaranteeing message order across a distributed system is expensive and limits throughput — like forcing everyone through a single checkout lane ensures order but creates a bottleneck',
      'The practical approach: guarantee ordering only where it matters, and only for related messages. Partition by a business key (user_id, account_id) so all events for one user are processed in order, while different users run in parallel',
      'When messages arrive out of order, use version numbers or timestamps on each message. The consumer checks: "is this newer than what I have?" If not, it ignores the stale update instead of overwriting newer data',
      'Global ordering (one single worldwide queue) is almost never worth the throughput cost. Ask: "which entity needs events in order?" Order events per account, not globally across all accounts',
      'In interviews, show you understand the cost: "I\'d partition the order-events topic by order_id so all updates for one order are processed sequentially, but different orders run in parallel for throughput"',
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
      'An idempotency key is a unique identifier the client attaches to a request so the server can recognize retries and return the same result without processing again — like a receipt number that prevents a refund from being issued twice',
      'This is essential because networks are unreliable: a payment request might succeed on the server but the response is lost in transit. The client retries, and without an idempotency key, the user gets charged twice',
      'How it works: the client generates a UUID for each logical operation. The server stores the mapping of key to result in Redis (with a TTL like 24 hours). On retry, it finds the key and returns the stored result without re-executing',
      'Idempotency keys are particularly critical on mobile where connections drop frequently. Stripe, PayPal, and most payment APIs require them — no one wants to double-charge a customer',
      'In interviews, add idempotency keys to any POST endpoint with side effects (payments, order creation). They\'re your primary defense against the "retry caused a duplicate" class of bugs',
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
      'Every messaging system makes a promise about delivery: at-most-once (might lose messages), at-least-once (might duplicate), or exactly-once (each message processed once). The choice defines your reliability and complexity',
      'At-most-once is fire-and-forget — fast but unreliable. Fine for metrics or ephemeral data. Never acceptable for payments, orders, or anything where losing a message means losing money',
      'At-least-once retries until acknowledged — no messages are lost, but duplicates can happen. This is the practical default for most systems. Pair with idempotent consumers using dedup keys to handle duplicates gracefully',
      'Exactly-once sounds ideal but requires tight coordination between the broker and your database. Kafka supports it in narrow scenarios, but most teams avoid the complexity and use at-least-once with idempotent consumers instead',
      'In interviews, state your strategy clearly: "I\'d use at-least-once delivery with idempotent consumers. Each message has a unique event_id, and the consumer checks a dedup table before processing — turning duplicates into harmless no-ops"',
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
      'In event-driven architecture, services communicate by publishing events (facts about what happened) rather than calling each other directly — like posting on a bulletin board instead of sending individual letters to every department',
      'The main benefit is loose coupling: when a new team wants to react to "OrderPlaced" events, they just subscribe — the order service doesn\'t need any changes. Teams build and deploy independently',
      'Events should describe what happened (OrderPlaced, UserSignedUp), not tell another service what to do. This keeps the publisher unaware of its consumers, making the system more flexible and resilient',
      'The downside is debuggability: when something goes wrong, there\'s no single call stack to trace. You need distributed tracing (attaching trace IDs to events) and a schema registry to prevent breaking changes to event formats',
      'In interviews, use event-driven architecture when multiple services must react to the same business event. Mention choreography for simple flows and orchestration (a central coordinator) for complex multi-step workflows',
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
      'Backpressure is a system telling its upstream "slow down, I can\'t keep up" — like a sink draining slower than the faucet fills it. Without backpressure, work piles up until the system crashes from memory exhaustion',
      'The dangerous pattern: a fast producer pushes messages into an unbounded queue. Everything looks fine until the consumer falls behind, the queue grows to gigabytes, and the server runs out of memory and crashes',
      'Effective strategies: use bounded queues that reject when full, return HTTP 429 with a Retry-After header telling clients when to try again, or scale consumers up to match the incoming rate',
      'At the broker level, prefetch limits control how many unprocessed messages a consumer pulls at once. This prevents a slow consumer from grabbing more work than it can handle while starving other consumers',
      'In interviews, mention backpressure when designing any ingestion pipeline. The key metric is the age of the oldest unprocessed message — if it keeps growing, your consumers are falling behind',
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
      'RabbitMQ is a traditional message broker where messages flow through an exchange (mail sorter) that routes them to queues (inboxes) based on rules. Workers then pull from queues and process messages one by one',
      'Three exchange types: direct (exact routing key match — "send billing events to billing queue"), fanout (broadcast to all queues — "notify everyone about a new user"), and topic (pattern matching — "orders.*.created" matches any region)',
      'Durability is opt-in: mark both the queue and messages as durable so they survive a broker restart. Without durability, a server crash loses unprocessed messages. With it, RabbitMQ writes to disk before acknowledging',
      'Manual acknowledgment is critical: a worker only acknowledges a message after successfully processing it. If the worker crashes mid-processing, the unacked message is redelivered to another worker — preventing message loss',
      'In interviews, RabbitMQ is a good choice for traditional task queues with routing flexibility (emails, notifications, background jobs). For high-throughput event streaming with replay capability, Kafka is usually the better fit',
    ],
    mnemonic: 'Exchange = mail sorter; queue = inbox',
    interviewQ: 'Fanout vs topic exchange?',
    interviewA: 'Fanout copies every message to all bound queues — use for broadcast (cache invalidation). Topic exchange matches routing keys with patterns (orders.*.created) — use for selective routing. Direct exchange is exact routing key match. Choose based on how many distinct consumers need each message.',
    difficulty: Difficulty.intermediate,
    tags: ['messaging', 'rabbitmq', 'amqp'],
  ),
];
