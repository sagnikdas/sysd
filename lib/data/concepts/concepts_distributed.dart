import '../../domain/models/concept.dart';
import '../../core/theme/app_colors.dart';

const _cat = 'Distributed Systems';
final _color = AppColors.distributedSystems;

final conceptsDistributed = <Concept>[
  Concept(
    id: 11,
    category: _cat,
    color: _color,
    icon: '🔺',
    title: 'CAP Theorem',
    tagline: 'Pick two: Consistency, Availability, Partition tolerance',
    diagram: '''
        Consistency
           /\\
          /  \\
         / CP \\
        /______\\
       /\\      /\\
      / CA\\  / AP \\
     /______\\/______\\
  Availability  Partition
                Tolerance

  Network partitions WILL happen
  → Real choice: CP or AP''',
    bullets: [
      'C (Consistency): every read gets the most recent write',
      'A (Availability): every request gets a non-error response',
      'P (Partition tolerance): system works despite network splits',
      'In distributed systems, P is mandatory → choose between C and A',
      'CP systems: HBase, MongoDB — return error if partition, but consistent',
    ],
    mnemonic: 'CAP = pick 2, but P is forced → really C vs A',
    interviewQ: 'Design a distributed bank — which CAP trade-off?',
    interviewA: 'CP — bank accounts require strong consistency (can\'t show wrong balance or allow double-spend). During a partition, refuse writes rather than risk inconsistency. Use Raft consensus for replication. Accept brief unavailability over incorrect balances. ATM withdrawals use offline limits as degraded mode.',
    difficulty: Difficulty.intermediate,
    tags: ['distributed-systems', 'consistency', 'theory'],
  ),
  Concept(
    id: 12,
    category: _cat,
    color: _color,
    icon: '🔄',
    title: 'PACELC Theorem',
    tagline: 'CAP extended: what happens when there\'s no partition?',
    diagram: '''
  if Partition:
    choose Availability or Consistency
           (PA or PC)

  else (normal operation):
    choose Latency or Consistency
           (EL or EC)

  Examples:
  DynamoDB → PA/EL (fast, eventual)
  HBase    → PC/EC (slow, consistent)
  Cassandra → PA/EL (tunable)''',
    bullets: [
      'PACELC extends CAP to address normal (non-partition) operation',
      'Even without partitions, there\'s a latency vs consistency trade-off',
      'PA/EL: prioritize availability and low latency (DynamoDB, Cassandra)',
      'PC/EC: prioritize consistency always (HBase, traditional RDBMS)',
      'PA/EC: available during partition, consistent otherwise (MongoDB)',
    ],
    mnemonic: 'PACELC = if Partition → A or C, Else → L or C',
    interviewQ: 'Design DynamoDB\'s behavior — explain the consistency model',
    interviewA: 'DynamoDB is PA/EL. During partition: remains available, serves potentially stale reads (eventual consistency). Normal operation: prioritizes low latency with eventual consistency by default, but offers strong consistency reads (2x cost, reads from leader). Writes use quorum (W=2 of 3 replicas). Conflict resolution via vector clocks and last-writer-wins.',
    difficulty: Difficulty.advanced,
    tags: ['distributed-systems', 'consistency', 'theory'],
  ),
  Concept(
    id: 13,
    category: _cat,
    color: _color,
    icon: '⏳',
    title: 'Eventual Consistency',
    tagline: 'All replicas converge... eventually',
    diagram: '''
  Write "price=10" to Node A

  T=0ms   A=10  B=5   C=5
  T=50ms  A=10  B=10  C=5
  T=100ms A=10  B=10  C=10
           ↑ eventually consistent

  Read from C at T=50ms → stale (5)
  Read from C at T=100ms → correct (10)''',
    bullets: [
      'After a write, replicas may temporarily return stale data',
      'Given enough time with no new writes, all replicas converge',
      'Faster than strong consistency — no need to wait for all replicas',
      'Acceptable for: social feeds, likes, product catalogs, analytics',
      'Not acceptable for: bank balances, inventory counts, auth tokens',
    ],
    mnemonic: 'Eventually = "give it a moment, they\'ll all agree"',
    interviewQ: 'Design a shopping cart — is eventual consistency acceptable?',
    interviewA: 'Yes — shopping carts are a classic eventual consistency use case (Amazon\'s Dynamo paper). Users rarely see conflicts. If two sessions add items concurrently, merge both (union). Cart is a CRDT (add-wins set). Only at checkout do we need strong consistency for inventory check. Show "item may be unavailable" rather than blocking the cart experience.',
    difficulty: Difficulty.intermediate,
    tags: ['distributed-systems', 'consistency'],
  ),
  Concept(
    id: 14,
    category: _cat,
    color: _color,
    icon: '💪',
    title: 'Strong vs Weak Consistency',
    tagline: 'Accuracy vs latency — the fundamental trade-off',
    diagram: '''
  Strong (Linearizable):
  Write X=5 ──→ All reads return 5
  (block until all replicas ACK)

  Weak (Eventual):
  Write X=5 ──→ Some reads may return old value
  (return immediately, replicate async)

  Spectrum:
  Strong ← Causal ← Session ← Eventual → Weak
  (slow)                              (fast)''',
    bullets: [
      'Strong: reads always reflect latest write — requires consensus (Raft/Paxos)',
      'Weak/Eventual: reads may be stale — faster, higher availability',
      'Causal: respects cause-effect ordering (if A causes B, see A before B)',
      'Session: within a session, read-your-writes guaranteed',
      'Tunable: some DBs let you choose per-query (DynamoDB, Cassandra)',
    ],
    mnemonic: 'Strong = slow but safe, Weak = fast but stale',
    interviewQ: 'Design a real-time chat read receipt — which consistency level?',
    interviewA: 'Causal consistency. If User A sends a message and User B reads it, the read receipt must reflect that B saw A\'s message (causal ordering). Strong consistency is overkill and too slow for chat. Eventual consistency risks showing "read" before the message is delivered. Use vector clocks or Lamport timestamps to track causality across chat servers.',
    difficulty: Difficulty.intermediate,
    tags: ['distributed-systems', 'consistency'],
  ),
  Concept(
    id: 15,
    category: _cat,
    color: _color,
    icon: '🗳️',
    title: 'Consensus Algorithms (Raft, Paxos)',
    tagline: 'How distributed nodes agree on a value',
    diagram: '''
  Raft: Leader-based consensus

  ┌────────┐
  │ Leader │──→ AppendEntries
  └───┬────┘
  ┌───┼────────┐
  ▼   ▼        ▼
┌───┐┌───┐  ┌───┐
│ F ││ F │  │ F │  Followers
└───┘└───┘  └───┘

  1. Client → Leader
  2. Leader → replicate to majority
  3. Majority ACK → commit
  4. Leader → respond to client''',
    bullets: [
      'Consensus: getting N nodes to agree on a value despite failures',
      'Raft: leader-based, easier to understand — used in etcd, CockroachDB',
      'Paxos: older, more complex — used in Google Spanner, Chubby',
      'Requires majority (quorum): 3 nodes tolerate 1 failure, 5 tolerate 2',
      'Leader election: on leader failure, followers vote for new leader (term++)',
    ],
    mnemonic: 'Raft = Reliable And Fault Tolerant — leader replicates, majority commits',
    interviewQ: 'Design a distributed config store (like etcd)',
    interviewA: 'Use Raft consensus across 5 nodes (tolerate 2 failures). Leader handles all writes, replicates log entries to followers. Reads can go to any node (with lease-based reads for consistency) or only to leader (strongly consistent). Snapshots for log compaction. Watch API for config change notifications. Linearizable reads via read index protocol.',
    difficulty: Difficulty.advanced,
    tags: ['distributed-systems', 'consensus', 'raft'],
  ),
  Concept(
    id: 16,
    category: _cat,
    color: _color,
    icon: '👑',
    title: 'Leader Election',
    tagline: 'One node rules — until it doesn\'t',
    diagram: '''
  Normal:
  ┌────────┐    ┌───┐
  │ Leader │◄──►│ F │
  └────────┘    └───┘
       ▲        ┌───┐
       └───────►│ F │
                └───┘
  Leader fails:
  ┌────────┐    ┌───┐
  │ DEAD ✗ │    │ F │ → "I'll be leader!"
  └────────┘    └───┘
                ┌───┐
                │ F │ → "Vote for me!"
                └───┘''',
    bullets: [
      'Leader election picks one node to coordinate (writes, decisions)',
      'Heartbeats: leader sends periodic pings; followers detect failure on timeout',
      'Split-brain: two nodes think they\'re leader — use fencing tokens to prevent',
      'Raft election: randomized timeout → candidate requests votes → majority wins',
      'External: use a lock service (ZooKeeper, etcd) for election coordination',
    ],
    mnemonic: 'Heartbeat stops → Election starts → Majority votes → New leader',
    interviewQ: 'Design a distributed lock service — how to prevent split-brain?',
    interviewA: 'Use fencing tokens: each leader gets a monotonically increasing token. Storage layer rejects requests with older tokens. ZooKeeper approach: ephemeral znodes with sequential IDs — lowest ID is leader. On leader disconnect, znode is deleted, next in line becomes leader. TTL-based leases prevent stale leaders from acting.',
    difficulty: Difficulty.advanced,
    tags: ['distributed-systems', 'consensus', 'fault-tolerance'],
  ),
  Concept(
    id: 17,
    category: _cat,
    color: _color,
    icon: '🕐',
    title: 'Vector Clocks',
    tagline: 'Track causality across distributed nodes',
    diagram: '''
  Node A    Node B    Node C

  [1,0,0]
    │  write X=1
    ├──────→[1,1,0]
    │         │  write X=2
    │         ├──────→[1,1,1]
  [2,0,0]    │         │
    │ write Y │         │
    │         │         │
  Conflict: [2,0,0] vs [1,1,1]
  → concurrent writes, need resolution''',
    bullets: [
      'Vector clock: array of counters, one per node [A:n, B:n, C:n]',
      'On local write: increment own counter',
      'On receive: merge (take max of each entry) + increment own',
      'If all entries in V1 ≤ V2: V1 happened-before V2 (causal)',
      'If neither dominates: concurrent writes → conflict resolution needed',
    ],
    mnemonic: 'Each node counts its own writes; compare vectors to detect conflicts',
    interviewQ: 'Design conflict resolution in DynamoDB',
    interviewA: 'DynamoDB uses vector clocks to detect concurrent writes. On conflict: return all conflicting versions to the client (siblings). Client resolves (e.g., merge shopping carts). Alternative: last-writer-wins using wall clock (simpler but loses data). DynamoDB actually uses a simplified version — each item has a version number, and conditional writes prevent conflicts at the API level.',
    difficulty: Difficulty.advanced,
    tags: ['distributed-systems', 'clocks', 'conflict-resolution'],
  ),
  Concept(
    id: 18,
    category: _cat,
    color: _color,
    icon: '🔗',
    title: 'Distributed Transactions (2PC, Saga)',
    tagline: 'Atomicity across multiple services',
    diagram: '''
  2PC (Two-Phase Commit):
  Coordinator → Prepare? → All vote YES
  Coordinator → Commit!  → All commit

  Saga Pattern:
  ┌───┐   ┌───┐   ┌───┐
  │ T1│──→│ T2│──→│ T3│  (success path)
  └───┘   └───┘   └───┘
    ↓       ↓       ↓
  ┌───┐   ┌───┐   ┌───┐
  │ C1│←──│ C2│←──│ C3│  (compensate)
  └───┘   └───┘   └───┘''',
    bullets: [
      '2PC: coordinator asks all participants to prepare, then commit — blocking, slow',
      'Saga: sequence of local transactions with compensating actions on failure',
      'Choreography saga: services emit events, each reacts independently',
      'Orchestration saga: central orchestrator directs the sequence',
      '2PC: strong consistency but single point of failure; Saga: eventual consistency',
    ],
    mnemonic: '2PC = vote then commit; Saga = do-undo chain',
    interviewQ: 'Design a payment flow across Order, Payment, and Inventory services',
    interviewA: 'Orchestration Saga: OrderService creates order (pending) → PaymentService charges card → InventoryService reserves stock → OrderService confirms. On payment failure: compensate by releasing inventory. On inventory failure: refund payment. Use an event log (Kafka) for reliability. Idempotency keys on each step to handle retries safely.',
    difficulty: Difficulty.advanced,
    tags: ['distributed-systems', 'transactions', 'microservices'],
  ),
  Concept(
    id: 19,
    category: _cat,
    color: _color,
    icon: '🔑',
    title: 'Idempotency',
    tagline: 'Same request, same result — no matter how many times',
    diagram: '''
  Without idempotency:
  POST /pay {amt: 100}  → charge \$100
  POST /pay {amt: 100}  → charge \$100 (again!)
  Network retry = double charge!

  With idempotency key:
  POST /pay {key: "abc", amt: 100} → charge \$100
  POST /pay {key: "abc", amt: 100} → return cached result
  Safe to retry!''',
    bullets: [
      'Idempotent: f(x) = f(f(x)) — multiple executions produce same result',
      'HTTP: GET, PUT, DELETE are idempotent; POST is not by default',
      'Implementation: client sends unique idempotency key, server deduplicates',
      'Server stores: key → response mapping with TTL (e.g., 24h in Redis)',
      'Critical for: payments, order creation, any non-reversible action',
    ],
    mnemonic: 'Idempotent = "do it again, nothing changes"',
    interviewQ: 'Design a retry-safe payments API',
    interviewA: 'Client generates UUID idempotency key per payment attempt. Server: check Redis for key → if exists, return stored result. If not: begin DB transaction, insert key + "processing" status, charge payment, update status to "completed", store response. On retry: return stored response. TTL: 24h. Race condition: use DB advisory lock on key to prevent concurrent processing of same key.',
    difficulty: Difficulty.intermediate,
    tags: ['api-design', 'reliability', 'payments'],
  ),
  Concept(
    id: 20,
    category: _cat,
    color: _color,
    icon: '📬',
    title: 'Exactly-Once Delivery',
    tagline: 'The hardest problem in distributed systems',
    diagram: '''
  At-Most-Once:
  Send → maybe lost → ¯\\_(ツ)_/¯
  (fire and forget)

  At-Least-Once:
  Send → ACK? → retry → retry
  (may duplicate)

  Exactly-Once (effectively):
  Send → ACK? → retry (with dedup)
  Consumer deduplicates by message ID''',
    bullets: [
      'True exactly-once is impossible in distributed systems (FLP result)',
      'At-most-once: no retries — fast but may lose messages',
      'At-least-once: retry until ACK — may duplicate messages',
      'Effectively-once: at-least-once + idempotent consumer (deduplication)',
      'Kafka: exactly-once semantics via idempotent producer + transactional consumers',
    ],
    mnemonic: 'Exactly-once = at-least-once + dedup on the consumer side',
    interviewQ: 'Design a billing event pipeline — ensure no duplicate charges',
    interviewA: 'At-least-once delivery (Kafka) + idempotent consumer. Each billing event has a unique event_id. Consumer: check event_id in processed_events table before charging. Use DB transaction: INSERT event_id + process charge atomically. If event_id exists, skip (idempotent). Kafka consumer commits offset only after successful processing. Dead letter queue for poison messages.',
    difficulty: Difficulty.advanced,
    tags: ['distributed-systems', 'messaging', 'reliability'],
  ),
];
