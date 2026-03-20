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
      'The CAP theorem says a distributed system can only guarantee two of three things: every read returns the latest data (Consistency), every request gets a response (Availability), or the system survives network failures (Partition tolerance)',
      'Since network failures are unavoidable in distributed systems, Partition tolerance is mandatory. So your real choice is: during a network split, do you prioritize correct data (CP) or staying online (AP)?',
      'CP systems (like HBase, traditional banks) refuse to serve requests during a partition rather than risk returning stale data. You get an error, but never a wrong answer',
      'AP systems (like Cassandra, DynamoDB) stay available during a partition but may return stale data temporarily. Once the partition heals, all nodes sync up (eventual consistency)',
      'In interviews, state the trade-off clearly: "I\'d choose CP for financial data where a wrong balance is unacceptable, and AP for social feeds where showing a slightly stale post is fine"',
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
      'PACELC extends CAP by asking: even when the network is healthy, do you prioritize fast responses (low Latency) or correct data (Consistency)? CAP only covers failure scenarios — PACELC covers normal operation too',
      'The name reads as: if Partition, choose Availability or Consistency; Else, choose Latency or Consistency. It captures the full spectrum of trade-offs in distributed databases',
      'PA/EL systems like DynamoDB and Cassandra always favor speed — available during failures, low latency during normal times. Great for apps where "fast and eventually correct" beats "slow and always correct"',
      'PC/EC systems like HBase always favor correctness — consistent during failures and normal operation. Good for financial systems where every read must be accurate, even at the cost of higher latency',
      'In interviews, PACELC shows deeper understanding than CAP alone. Use it to justify your database choice: "I\'d pick Cassandra (PA/EL) for our activity feed because low latency matters more than perfect consistency"',
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
      'Eventual consistency means that after you update data, different copies across servers may briefly show different values — but given a little time, they all converge to the same correct value, like a news broadcast reaching different time zones at slightly different times',
      'It\'s faster than strong consistency because the system doesn\'t wait for every copy to update before responding. You write to one server, get an instant confirmation, and the update propagates in the background',
      'The "eventual" window is usually milliseconds to a few seconds. During that gap, a user might read stale data — e.g., a like count showing 99 instead of 100 briefly',
      'Perfectly acceptable for social feeds, likes, product catalogs, and analytics — nobody notices a 1-second delay. NOT acceptable for bank balances, inventory counts, or authentication where stale data causes real harm',
      'In interviews, name the consistency model explicitly: "the feed uses eventual consistency since a 1-second delay is fine, but the payment ledger needs strong consistency because a stale balance could allow overspending"',
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
      'Consistency models form a spectrum: strong consistency guarantees every read sees the latest write (like a shared Google Doc), while weak/eventual consistency allows temporarily stale reads (like an email that takes seconds to appear in all inboxes)',
      'Strong consistency requires all servers to agree before responding, which is slower but safer. Achieved through consensus algorithms like Raft — used in systems where correctness matters more than speed',
      'In between, there are useful middle grounds: causal consistency ensures you see events in cause-and-effect order (you can\'t see a reply before the original message), and session consistency guarantees you always see your own writes',
      'Some databases (DynamoDB, Cassandra) let you choose consistency per query — strong reads cost more and are slower, eventual reads are cheap and fast. This lets you pick the right level for each use case',
      'In interviews, show nuance by using different consistency levels for different parts of the same system: "strong for the payment ledger, session consistency for user profiles, eventual for the activity feed"',
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
      'Consensus algorithms solve a fundamental problem: how do multiple servers agree on the same value (like "who is the leader?" or "was this committed?") even when some servers crash or lose connectivity?',
      'Raft is the most widely used today (in etcd, CockroachDB, Consul). It works by electing a leader who coordinates all decisions — simpler to understand and implement than the older Paxos algorithm',
      'The key idea is quorum — a majority of nodes must agree before a decision is committed. With 3 nodes, you tolerate 1 failure; with 5 nodes, 2 failures. This is why clusters typically have an odd number of nodes',
      'When the leader crashes, followers detect missing heartbeats, start an election, and vote for a new leader. The system is briefly unavailable during election (typically milliseconds) but data is never lost',
      'In interviews, you rarely implement Raft — but mention it when explaining how etcd or CockroachDB achieve strong consistency. Know that it requires a majority, so 3-node and 5-node clusters are common',
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
      'In many distributed systems, one node needs to be "in charge" to coordinate writes or decisions — leader election is the process of choosing that node, and picking a new one if it crashes',
      'The leader sends periodic heartbeats ("I\'m still alive") to followers. If followers don\'t hear a heartbeat within a timeout window, they assume the leader is dead and start an election',
      'The most dangerous failure is "split-brain" — two nodes both believe they\'re the leader due to a network partition. This can cause data corruption as both accept conflicting writes',
      'Fencing tokens prevent split-brain: each leader gets a monotonically increasing number, and the storage layer rejects requests from any leader with an older token. Only the latest elected leader can make changes',
      'In interviews, you usually don\'t build leader election yourself — mention using ZooKeeper or etcd as a coordination service, or relying on database-level leader election (PostgreSQL with Patroni)',
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
      'Vector clocks track the order of events across multiple servers when there\'s no shared global clock — like each person in different time zones keeping a log of "what I did" and "what I heard from others" to figure out who did what first',
      'Each node maintains a counter for itself and every other node. When it writes locally, it increments its own counter. When it receives data from another node, it merges by taking the maximum of each counter',
      'To determine ordering: if every counter in clock A is ≤ clock B, then A happened before B. If neither dominates, the events were concurrent — two nodes modified data without knowing about each other',
      'Concurrent events mean a conflict that needs resolution: merge both versions (union for shopping carts), or use last-writer-wins (simpler but may lose data). The right strategy depends on your data type',
      'In interviews, vector clocks show up when discussing conflict resolution in databases like DynamoDB. The simpler alternative (Lamport timestamps) gives ordering but can\'t detect true concurrency — vector clocks can',
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
      'When a single business action (like placing an order) spans multiple services, you need all to succeed together or all to roll back — that\'s a distributed transaction',
      'Two-Phase Commit (2PC) works like a wedding: the coordinator asks each service "do you commit?" (prepare phase), and only if ALL say yes does it tell them to proceed. If any says no, everyone rolls back',
      'The problem with 2PC: it\'s slow and blocking — if the coordinator crashes mid-commit, all services are stuck waiting. This is why modern microservices favor the Saga pattern instead',
      'A Saga breaks the transaction into a chain of local steps, each with an "undo" action. Book flight → Book hotel → Charge card. If charging fails, the saga compensates by canceling the hotel, then the flight, in reverse order',
      'In interviews, use Sagas for microservice workflows. Mention two flavors: orchestration (a central coordinator directs the flow — easier to debug) vs choreography (services react to events independently — more loosely coupled)',
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
      'An idempotent operation produces the same result no matter how many times you repeat it — like pressing an elevator button twice still calls the same elevator. The opposite: pressing "Place Order" twice creates two orders',
      'Idempotency matters because networks are unreliable. If a payment request times out, the client retries — without idempotency, the user gets charged twice. This is one of the most common bugs in distributed systems',
      'The standard fix: the client generates a unique key (UUID) per operation and sends it with the request. The server checks if it\'s seen that key before — if yes, return the previous result instead of processing again',
      'HTTP methods have built-in expectations: GET and DELETE are naturally idempotent, but POST (creating) is not. For non-idempotent endpoints like payments, add an Idempotency-Key header',
      'In interviews, mention idempotency whenever you design a payment flow, order system, or any endpoint with side effects. It\'s a fundamental building block for reliable distributed systems',
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
      'There are three delivery guarantees: at-most-once (send and forget — might lose messages), at-least-once (retry until confirmed — might duplicate), and exactly-once (each message processed once — the holy grail)',
      'True exactly-once is theoretically impossible in distributed systems because you can never be 100% sure a message was received without risking a duplicate on retry. But you can get effectively-once',
      'Effectively-once = at-least-once delivery + idempotent consumers. You retry messages until confirmed (so none are lost), and the consumer ignores duplicates using a unique message ID it has already seen',
      'At-most-once is fine for metrics or logs where losing a few data points is tolerable. At-least-once with dedup is the pragmatic default for almost everything else, including payments and orders',
      'In interviews, show sophistication: "exactly-once is effectively achieved through at-least-once delivery with idempotent processing on the consumer side" rather than claiming true exactly-once exists',
    ],
    mnemonic: 'Exactly-once = at-least-once + dedup on the consumer side',
    interviewQ: 'Design a billing event pipeline — ensure no duplicate charges',
    interviewA: 'At-least-once delivery (Kafka) + idempotent consumer. Each billing event has a unique event_id. Consumer: check event_id in processed_events table before charging. Use DB transaction: INSERT event_id + process charge atomically. If event_id exists, skip (idempotent). Kafka consumer commits offset only after successful processing. Dead letter queue for poison messages.',
    difficulty: Difficulty.advanced,
    tags: ['distributed-systems', 'messaging', 'reliability'],
  ),
];
