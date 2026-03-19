import '../../domain/models/concept.dart';
import '../../core/theme/app_colors.dart';

const _cat = 'Microservices';
final _color = AppColors.microservices;

final conceptsMicroservices = <Concept>[
  Concept(
    id: 70,
    category: _cat,
    color: _color,
    icon: '🧩',
    title: 'Service Boundaries',
    tagline: 'Split by business capability',
    diagram: '''
  Monolith module boundaries
        │
  Evolve into services when
  independent scaling/deploy needed

  Bad boundary: CRUD over shared DB tables''',
    bullets: [
      'Domain-Driven Design bounded contexts guide cuts',
      'Services should own their data — no shared database writes',
      'Wrong boundaries → chatty RPC and distributed monolith pain',
      'Start modular monolith; extract when team/scale pressure is real',
      'Conway’s law: org structure will mirror architecture',
    ],
    mnemonic: 'Boundary = who owns the nouns',
    interviewQ: 'When to split a microservice?',
    interviewA: 'When a domain has independent scaling needs, deployment cadence, or team ownership boundary. Not for theoretical purity. If two services constantly change together and share DB transactions, merge or fix boundary. Extract after clear seams appear in modular monolith. Measure coordination cost vs operational overhead.',
    difficulty: Difficulty.intermediate,
    tags: ['microservices', 'architecture', 'ddd'],
  ),
  Concept(
    id: 71,
    category: _cat,
    color: _color,
    icon: '📦',
    title: 'Database per Service',
    tagline: 'Loose coupling via data ownership',
    diagram: '''
  Orders DB ── Orders service
  Users DB  ── Users service

  Join via API or async sync — not cross-DB SQL''',
    bullets: [
      'Eliminates hidden coupling through shared tables',
      'Cross-service queries become compositions or materialized views',
      'Transactions across services use sagas, outbox, or eventual consistency',
      'Operational cost: more backups, migrations, and connection pools',
      'Polyglot persistence allowed per service needs',
    ],
    mnemonic: 'No sneaking into neighbor’s database',
    interviewQ: 'Report needs data from 5 services',
    interviewA: 'Don’t join live across services at request time for heavy reports. Use data pipeline: CDC or events into warehouse (BigQuery/Snowflake) for analytics. For operational UI, aggregate via BFF calling parallel APIs with timeouts and caching. Precompute read models for hot dashboards.',
    difficulty: Difficulty.advanced,
    tags: ['microservices', 'databases', 'architecture'],
  ),
  Concept(
    id: 72,
    category: _cat,
    color: _color,
    icon: '🎼',
    title: 'Saga Pattern',
    tagline: 'Multi-step workflows without 2PC',
    diagram: '''
  Book flight → Book hotel → Charge card
  If hotel fails → cancel flight (compensation)

  Orchestration: central coordinator
  Choreography: events between services''',
    bullets: [
      'Avoids distributed two-phase commit — uses compensating transactions',
      'Must model failure at each step idempotently',
      'Orchestration easier to reason; choreography looser coupling',
      'Temporal/Cadence for durable execution with retries',
      'Human-in-the-loop steps need timeouts and escalation',
    ],
    mnemonic: 'Saga = undo chain for distributed checkout',
    interviewQ: 'Choreographed saga lost track of state',
    interviewA: 'Pure choreography hides global state — add process manager or use orchestrator. Persist saga state with correlation id in each message. Idempotent handlers and dedup inbox. Observability with distributed tracing. For money flows, prefer orchestration or workflow engine with visibility and pause/resume.',
    difficulty: Difficulty.advanced,
    tags: ['microservices', 'saga', 'transactions'],
  ),
  Concept(
    id: 73,
    category: _cat,
    color: _color,
    icon: '📤',
    title: 'Outbox Pattern',
    tagline: 'Reliable event publishing',
    diagram: '''
  BEGIN TX
    UPDATE orders SET status='placed'
    INSERT outbox(topic, payload)
  COMMIT

  Poller publishes outbox → broker → DELETE''',
    bullets: [
      'Prevents “DB committed but message lost” dual-write problem',
      'Transactional outbox in same DB as business write',
      'Relay process must handle at-least-once publish — consumers idempotent',
      'Debezium CDC can tail DB instead of polling',
      'Order of outbox processing may matter — single thread per partition',
    ],
    mnemonic: 'Outbox = same transaction as truth',
    interviewQ: 'Double charging after crash between DB and Kafka',
    interviewA: 'Classic dual-write failure. Use outbox table in same transaction as order creation. Async publisher reads outbox to Kafka. Payment consumer dedupes on order id. Alternatively change-data-capture from WAL. Never publish then DB commit without reconciliation job.',
    difficulty: Difficulty.advanced,
    tags: ['microservices', 'messaging', 'consistency'],
  ),
  Concept(
    id: 74,
    category: _cat,
    color: _color,
    icon: '📱',
    title: 'BFF (Backend for Frontend)',
    tagline: 'Tailored API per client',
    diagram: '''
  Mobile BFF ──► aggregates 3 microservices
  Web BFF    ──► different shape / caching

  Core services stay client-agnostic''',
    bullets: [
      'Reduces chatty mobile apps and version skew',
      'Risk: BFF becomes fat orchestrator — keep thin',
      'Can be team-owned per platform',
      'GraphQL sometimes replaces multiple BFFs — trade-offs differ',
      'Auth and rate limits still at edge',
    ],
    mnemonic: 'BFF = translator for your app',
    interviewQ: 'Mobile needs 7 calls to render home',
    interviewA: 'Introduce mobile BFF endpoint assembling parallel internal calls server-side with one round trip. Add caching for semi-static blocks. Consider SSR-style payload for first paint. Long term, evaluate GraphQL or server-driven UI. Ensure BFF doesn’t become a second monolith — strict scope per screen cluster.',
    difficulty: Difficulty.intermediate,
    tags: ['microservices', 'api', 'mobile'],
  ),
  Concept(
    id: 75,
    category: _cat,
    color: _color,
    icon: '🔍',
    title: 'Service Discovery',
    tagline: 'Find healthy instances dynamically',
    diagram: '''
  Service registers with Consul/etcd
  Client resolves name → list of IPs
  Health checks remove bad nodes

  K8s: DNS + kube-proxy / mesh''',
    bullets: [
      'Static IPs don’t work behind autoscaling',
      'Health checks must match real readiness (dependencies up)',
      'DNS TTL trade-offs vs push-based discovery',
      'Service mesh adds mTLS + traffic policy on top',
      'Cache discovery results with fallback on failure',
    ],
    mnemonic: 'Discovery = phone book that updates live',
    interviewQ: 'Kubernetes service discovery at scale',
    interviewA: 'Use ClusterIP DNS (CoreDNS) for in-cluster calls. For gRPC long-lived connections, handle endpoint changes with client-side load balancing (xDS, gRPC resolver). L7 mesh (Istio/Linkerd) provides retries and mTLS. For external clients, use ingress or API gateway with stable DNS. Watch thundering herd on rolling deploys.',
    difficulty: Difficulty.intermediate,
    tags: ['microservices', 'kubernetes', 'networking'],
  ),
  Concept(
    id: 76,
    category: _cat,
    color: _color,
    icon: '🔄',
    title: 'Strangler Fig Pattern',
    tagline: 'Gradually replace legacy',
    diagram: '''
  Router sends % traffic to new service
  ↑ over time 100%

  Legacy monolith shrinks like fig around tree''',
    bullets: [
      'Low-risk migration slice by slice',
      'Feature flags control traffic percentage',
      'Reverse proxy or API gateway routes domains/paths',
      'Dark launch: new path shadow traffic compare results',
      'Retire old code only after metrics match',
    ],
    mnemonic: 'Strangle legacy one endpoint at a time',
    interviewQ: 'Migrate payments out of monolith',
    interviewA: 'Put facade in front of monolith payment module. Implement new payment service behind flag. Start with read-only shadow validation, then 1% writes with reconciliation job, ramp to 100%. Keep monolith code path dormant until stable. Migrate data with dual-write or CDC. Rollback plan: flip flag back.',
    difficulty: Difficulty.intermediate,
    tags: ['microservices', 'migration', 'architecture'],
  ),
  Concept(
    id: 77,
    category: _cat,
    color: _color,
    icon: '🧪',
    title: 'Contract Testing',
    tagline: 'Services agree without integration env',
    diagram: '''
  Consumer test: "I need fields X,Y"
  Provider verifies: response matches pact

  CI fails provider if breaking change''',
    bullets: [
      'Pact-style contracts catch integration breaks in PR',
      'Complement, not replace, a smaller staging environment',
      'Version consumer-driven contracts per deployed pair',
      'For public APIs, schema (OpenAPI) is the contract',
      'Canary deploy with contract verification gate',
    ],
    mnemonic: 'Contract test = handshake in CI',
    interviewQ: 'Staging is flaky — how reduce integration pain?',
    interviewA: 'Adopt contract tests between producer and consumer services so interfaces are validated without full stack. Use testcontainers for critical paths. Shift left with unit tests of serializers against recorded fixtures. Observability in staging to compare prod-like traces. Reduce environment drift with IaC.',
    difficulty: Difficulty.intermediate,
    tags: ['microservices', 'testing', 'ci'],
  ),
  Concept(
    id: 78,
    category: _cat,
    color: _color,
    icon: '📏',
    title: 'API Composition vs Orchestration',
    tagline: 'Who aggregates micro calls?',
    diagram: '''
  Composition (client): app calls A,B,C — chatty

  Orchestration (server): one call internally fans out
  GraphQL/BFF sits here''',
    bullets: [
      'Client-side composition simple early, painful on mobile networks',
      'Server orchestration reduces latency and hides service topology',
      'Partial failure handling: return degraded partial results with per-part errors',
      'Parallel async fan-out with deadline budget',
      'Cache composed responses carefully — invalidate complexity',
    ],
    mnemonic: 'Orchestrate server-side; compose sparingly on client',
    interviewQ: 'GraphQL resolver N+1 in microservices',
    interviewA: 'Use DataLoader batching per request to collapse calls to user service. Set max query depth/complexity. For hot fields, cache at resolver with short TTL. Consider schema stitching vs federation ownership. Trace resolver timings — optimize slow service. Sometimes precompute view models async.',
    difficulty: Difficulty.advanced,
    tags: ['microservices', 'graphql', 'performance'],
  ),
  Concept(
    id: 79,
    category: _cat,
    color: _color,
    icon: '🏗️',
    title: 'Monolith-First',
    tagline: 'Microservices aren’t step one',
    diagram: '''
  Start: modular monolith
  Extract service when:
    - team bottleneck
    - scaling hotspot
    - different release cadence''',
    bullets: [
      'Premature distribution multiplies ops cost without benefit',
      'Clear module boundaries in monolith enable safer extraction',
      'Observability and CI maturity prerequisites for many services',
      'Extract read-heavy or risky domains first',
      'Staff for on-call per service domain',
    ],
    mnemonic: 'Monolith first, microservices when the pain is real',
    interviewQ: 'Startup wants microservices day 1',
    interviewA: 'Advise modular monolith with strict boundaries and good tests — ship faster with one deploy. Microservices add network, partial failures, distributed transactions, and operational load. Extract when a module needs independent scale or team ownership strains coordination. Prove product-market fit before paying distributed taxes.',
    difficulty: Difficulty.beginner,
    tags: ['microservices', 'architecture', 'startups'],
  ),
];
