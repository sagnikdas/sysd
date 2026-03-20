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
      'A service boundary defines what a microservice owns — its data, its business rules, and its API. Drawing the right boundaries is the most important decision in microservice architecture, and getting it wrong is expensive to fix',
      'Follow Domain-Driven Design: each service maps to a business capability (orders, payments, inventory), not a technical layer. A service owns its data completely — no sharing database tables between services',
      'The telltale sign of a bad boundary: two services that constantly change together, call each other for every operation, or share a database. That\'s a "distributed monolith" — complexity of microservices without any benefits',
      'Start with a modular monolith (well-separated modules in one codebase) and extract services only when there\'s real pressure: different teams need independent deployment, different scaling needs, or different technology requirements',
      'In interviews, show restraint: "I\'d start with a modular monolith with clear boundaries. When the order team needs to deploy 10x more often than the user team, that\'s when I\'d extract the order module into its own service"',
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
      'Each microservice should own its own database — no service reads or writes to another service\'s tables directly. This prevents hidden coupling where a schema change in one service breaks another',
      'When services need each other\'s data, they call APIs or subscribe to events — never reach into each other\'s databases. This feels slower than a SQL join, but keeps services truly independent and separately deployable',
      'The hardest challenge: transactions spanning services. You can\'t do a single SQL transaction across two databases. Use Sagas (chain of local transactions with compensating rollbacks) or the Outbox pattern instead',
      'This lets each service use the best database for its needs (polyglot persistence): PostgreSQL for orders, Cassandra for activity feeds, Elasticsearch for search — each optimized for its access patterns',
      'In interviews, acknowledge the trade-off: "database-per-service increases operational complexity (more backups, migrations) but eliminates the hidden coupling that makes shared databases a deployment nightmare"',
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
      'A Saga coordinates multi-step business processes across services by chaining local transactions, each with an "undo" action — if any step fails, previous steps are reversed, like an airline canceling your hotel when the flight booking fails',
      'Unlike a database transaction where everything commits atomically, a Saga achieves eventual consistency: each step commits independently, and failures trigger compensations. The system is briefly inconsistent but converges',
      'Orchestration Saga: a central coordinator tells each service what to do step by step. Easier to understand, debug, and monitor — you see the workflow state in one place. The coordinator is a potential bottleneck',
      'Choreography Saga: each service publishes an event when finished, the next service reacts. More loosely coupled, but the overall flow is hidden across services — harder to debug when something goes wrong',
      'In interviews, prefer orchestration for critical business flows where visibility matters. Mention workflow engines like Temporal: "if the orchestrator crashes mid-saga, it resumes exactly where it left off"',
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
      'The Outbox pattern solves the "dual write" problem: when your service needs to update a database AND publish an event, doing both independently risks one succeeding while the other fails',
      'Example: you save an order to the database, then publish an "OrderCreated" event to Kafka. If the app crashes between these steps, the order exists but no event was published — downstream services never learn about it',
      'The fix: write the event to an "outbox" table in the SAME database transaction as the business data. A separate process reads the outbox and publishes to the broker. Since both writes are one transaction, they succeed or fail together',
      'The outbox publisher delivers at-least-once, so consumers must be idempotent. An alternative to polling: use CDC (Debezium) to stream outbox rows to Kafka directly from the database log',
      'In interviews, the outbox pattern is the standard answer to "how do you keep the database and message broker in sync?" Simpler and more reliable than distributed transactions',
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
      'A BFF (Backend for Frontend) aggregates and reshapes data from multiple microservices into exactly what a specific client needs — like a personal assistant who gathers info from different departments and presents a single summary',
      'Without a BFF, a mobile app might need 7 API calls to render the home screen. On a slow mobile connection, this is painfully slow. A BFF makes one server-side call that returns everything in one response',
      'Different clients need different data shapes: mobile needs compact payloads with small images, web needs richer data. A BFF per client type tailors the response without polluting the core APIs',
      'The biggest risk: the BFF grows into a fat orchestrator with business logic, becoming a new monolith. Keep it thin — it should only aggregate, transform, and cache, never validate business rules or own data',
      'In interviews: "the mobile BFF aggregates 5 internal service calls server-side and returns a single optimized payload, reducing round trips from 5 to 1 and cutting page load time in half"',
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
      'Service discovery lets services find each other dynamically without hardcoded IPs — essential when services auto-scale and new instances appear and disappear constantly',
      'Each service registers with a discovery system (Consul, etcd, or Kubernetes DNS) when it starts, and deregisters when it shuts down. Other services query the registry to find available instances',
      'Health checks are critical: the registry pings each instance continuously. If one stops responding, it\'s removed so no traffic is sent to a dead server. Checks should verify actual readiness, not just that the process is running',
      'In Kubernetes, service discovery is built-in via DNS: calling "order-service" automatically resolves to healthy pods. A service mesh (Istio, Linkerd) adds retries, mutual TLS, and traffic routing on top',
      'In interviews: "services register with Kubernetes DNS on startup. Health checks remove unhealthy instances. A service mesh handles mTLS and intelligent routing between services"',
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
      'The Strangler Fig gradually migrates a legacy system by routing traffic one feature at a time — like a vine that grows around a tree until it completely replaces it, rather than cutting the tree down all at once',
      'Instead of a risky "big bang" rewrite, build the new service alongside the old one. A router sends a small percentage of traffic to the new service while the rest continues hitting the old one',
      'Migration in phases: first shadow the new service (receives traffic but responses are compared and discarded). Once results match, shift real traffic: 1% → 10% → 50% → 100%',
      'Only retire old code after the new service handles 100% of traffic with matching metrics (latency, error rate, correctness). Keep the old path dormant as a rollback option',
      'In interviews: "we\'d use the API gateway to route /payments to the new service, starting at 1% with shadow comparison, ramping to 100% over weeks — zero downtime, easy rollback"',
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
      'Contract testing verifies that two services agree on their API format without deploying both together — like checking a plug fits a socket by comparing specs, without physically connecting them',
      'The consumer writes a test saying "I call GET /users/42 and expect name (string) and email (string)." The provider runs this contract against its code. If it fails, the provider knows the change would break the consumer',
      'This catches breaking changes in pull requests before production. Faster and more reliable than integration testing in shared environments where flaky infrastructure causes false failures',
      'For internal microservices, use consumer-driven contracts (Pact). For public APIs, your OpenAPI spec IS the contract — run compatibility checks in CI to ensure no breaking changes',
      'In interviews: "each service runs consumer contract tests in CI. A provider can\'t deploy if it breaks a consumer\'s contract — we catch integration issues in the PR, not in production"',
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
      'When a screen needs data from multiple services, someone has to combine responses. Client-side composition (the app calls 5 APIs) is simple but slow on mobile. Server-side orchestration (a BFF calls them internally) is faster but adds a layer',
      'Server-side wins for mobile: instead of 5 sequential round trips over a slow connection, the server makes 5 parallel calls on a fast internal network and returns one combined response',
      'Partial failure is the tricky part: if 4 of 5 services respond but recommendations times out, return a degraded response with 4 sections and a placeholder — don\'t fail the entire page',
      'Use a deadline budget: if the user timeout is 2 seconds, allocate 1.5s for internal fan-out. Fire all calls in parallel. If a call doesn\'t respond in time, return what you have rather than timing out entirely',
      'In interviews: "a BFF fans out parallel requests with a deadline budget, returning partial results on timeout — the checkout button always works even if recommendations are down"',
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
      'Starting with microservices on day one is like buying a fleet of specialized trucks when a single van would do — you pay for distributed complexity before you have the scale or team size to justify it',
      'A modular monolith gives you most benefits: clean module boundaries, separate concerns, testability — while keeping the simplicity of one deployment, one database, one debugging experience',
      'When to extract a service: a module needs independent scaling, a separate team wants independent deployment, or the module needs different technology. Extract when the pain is real, not theoretical',
      'Prerequisites before going micro: solid CI/CD, container orchestration, distributed tracing, centralized logging, and a team experienced with operational complexity. Without these, microservices create more problems',
      'In interviews: "I\'d build a modular monolith with clear bounded contexts. When the team grows to 30+ engineers and deployment contention becomes the bottleneck, I\'d extract the highest-traffic modules first"',
    ],
    mnemonic: 'Monolith first, microservices when the pain is real',
    interviewQ: 'Startup wants microservices day 1',
    interviewA: 'Advise modular monolith with strict boundaries and good tests — ship faster with one deploy. Microservices add network, partial failures, distributed transactions, and operational load. Extract when a module needs independent scale or team ownership strains coordination. Prove product-market fit before paying distributed taxes.',
    difficulty: Difficulty.beginner,
    tags: ['microservices', 'architecture', 'startups'],
  ),
];
