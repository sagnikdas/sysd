import '../../domain/models/concept.dart';
import '../../core/theme/app_colors.dart';

const _cat = 'API Design';
final _color = AppColors.apiDesign;

final conceptsApi = <Concept>[
  Concept(
    id: 41,
    category: _cat,
    color: _color,
    icon: '🌐',
    title: 'REST Principles',
    tagline: 'Resources, verbs, statelessness',
    diagram: '''
  GET    /users/42        → 200 + JSON
  POST   /users           → 201 Location
  PUT    /users/42        → replace
  PATCH  /users/42        → partial
  DELETE /users/42        → 204

  Stateless: each request carries auth + context''',
    bullets: [
      'REST is the most common API style: you model everything as resources (nouns like /users, /orders) and use HTTP methods as verbs (GET = read, POST = create, PUT = replace, DELETE = remove). It\'s intuitive because it maps to how the web already works',
      'Using the right HTTP status codes makes your API predictable: 200 (success), 201 (created), 400 (bad request), 404 (not found), 409 (conflict), 422 (validation failed), 500 (server error). Clients rely on these to handle responses correctly',
      'Version your API from day one (e.g., /v1/users). Mobile apps can\'t be force-updated — old versions will call your API for months. Breaking changes go in /v2 while /v1 stays backward-compatible',
      'For listing endpoints, prefer cursor-based pagination over offset pagination. Offset (page=5) breaks when new items are inserted — users see duplicates. Cursors (after=last_id) are stable even as data changes',
      'In interviews, demonstrate REST fluency by using correct verbs and status codes. Mention statelessness: each request carries everything the server needs (auth token, context), making horizontal scaling straightforward',
    ],
    mnemonic: 'REST = HTTP done politely',
    interviewQ: 'PUT vs PATCH?',
    interviewA: 'PUT is idempotent full replacement of the resource — client sends entire representation. PATCH is partial update (often JSON Merge Patch or JSON Patch). PATCH may not be idempotent depending on semantics. For large resources, PATCH reduces bandwidth. Document concurrency control (ETags) for both.',
    difficulty: Difficulty.beginner,
    tags: ['api', 'rest', 'http'],
  ),
  Concept(
    id: 42,
    category: _cat,
    color: _color,
    icon: '📋',
    title: 'OpenAPI & Contracts',
    tagline: 'Machine-readable API specs',
    diagram: '''
  openapi.yaml
       │
       ├── codegen clients (TypeScript, Kotlin)
       ├── mock servers for frontend
       └── contract tests in CI

  Breaking change: required field added? → major version''',
    bullets: [
      'OpenAPI (formerly Swagger) is a machine-readable specification for your API — a blueprint that describes every endpoint, parameter, and response format. It can auto-generate client SDKs, server stubs, and documentation',
      'The main value is preventing accidental breaking changes. A breaking change (removing a field, changing a type, making an optional field required) will crash existing clients. Non-breaking changes (adding optional fields, new endpoints) are safe',
      'Use CI tools (OpenAPI diff, Pact) to automatically flag breaking changes in pull requests before they reach production. Critical for mobile apps that can\'t be instantly updated',
      'The spec should be the single source of truth — generate docs, mock servers, and client SDKs from the same file. When the spec and the code disagree, bugs hide',
      'In interviews, mention API contracts for microservice communication: "each service publishes an OpenAPI spec, and we run contract tests in CI to catch breaking changes before deployment"',
    ],
    mnemonic: 'OpenAPI = API blueprint everyone reads',
    interviewQ: 'How do you prevent breaking mobile clients?',
    interviewA: 'Version APIs; never remove or repurpose fields without deprecation window. Use OpenAPI diff in CI to flag breaking changes. Optional new fields with defaults. Feature flags for server behavior. Mobile apps lag — support N-2 versions. Contract tests between consumer and provider catch drift early.',
    difficulty: Difficulty.intermediate,
    tags: ['api', 'openapi', 'documentation'],
  ),
  Concept(
    id: 43,
    category: _cat,
    color: _color,
    icon: '🔄',
    title: 'Idempotent HTTP Methods',
    tagline: 'Safe retries on the wire',
    diagram: '''
  GET/HEAD  → safe (no side effects)
  PUT/DELETE → idempotent (repeat = same state)
  POST      → not idempotent by default

  Use Idempotency-Key header on POST for payments''',
    bullets: [
      'An idempotent HTTP method gives the same result whether you call it once or ten times — critical because network retries happen constantly. GET, PUT, and DELETE are naturally idempotent; POST is not',
      'PUT replaces the entire resource: calling PUT /users/42 with the same body ten times still results in one user with that data. POST /users, however, could create ten users — a serious bug for orders or payments',
      'To make POST endpoints safe to retry, use an Idempotency-Key header: the client generates a unique ID per request, and the server returns the cached result on duplicate keys instead of creating a second resource',
      'Conditional requests add another safety layer: the client sends an If-Match header with the resource\'s ETag. If another client modified it since, the server rejects the update with 412 — preventing lost updates',
      'In interviews, always address retry safety for mutating endpoints: "POST /orders includes an idempotency key so retries can\'t create duplicates, and PUT /orders/{id} uses ETags to prevent lost updates"',
    ],
    mnemonic: 'Idempotent = press elevator button twice, same result',
    interviewQ: 'Make POST /transfers safe to retry',
    interviewA: 'Require Idempotency-Key header; store in Redis/DB with status for 24–72h. First request processes; duplicates return same 200/201 with original body. Use DB unique constraint on (user_id, client_request_id) as belt-and-suspenders. Ledger entries must be generated once inside the idempotent block.',
    difficulty: Difficulty.intermediate,
    tags: ['api', 'http', 'reliability'],
  ),
  Concept(
    id: 44,
    category: _cat,
    color: _color,
    icon: '🧩',
    title: 'GraphQL Trade-offs',
    tagline: 'Flexible queries, operational complexity',
    diagram: '''
  Client sends query shape
        │
        ▼
  Server resolves fields (N+1 risk)
        │
  Batching/DataLoader
  Depth/complexity limits''',
    bullets: [
      'GraphQL lets clients request exactly the fields they need in a single query — like ordering a la carte instead of a fixed menu. This avoids over-fetching (getting 50 fields when you need 3) and under-fetching (needing a second request)',
      'The biggest advantage is reducing round trips: instead of calling /user/42, then /user/42/posts, then /user/42/friends, one GraphQL query fetches all three — a big win on slow mobile networks',
      'The biggest risk is that clients can write expensive queries that join deeply nested data, overwhelming your servers. Protect with query depth limits, complexity scoring, timeouts, and persisted queries',
      'Caching is harder than REST because every query is a POST to the same URL with a different body — traditional CDN caching by URL doesn\'t work. You need application-level caching or normalized client caches',
      'In interviews, use GraphQL when you have many clients with different data needs. Stick with REST for simple CRUD or when heavy CDN caching is critical. Mention the N+1 problem and DataLoader as the standard fix',
    ],
    mnemonic: 'GraphQL = buffet; REST = fixed menu',
    interviewQ: 'When avoid GraphQL?',
    interviewA: 'Simple CRUD with stable mobile screens, heavy public caching needs, or team lacks operational maturity. GraphQL shines with many clients and evolving fields. If abuse is likely, add query cost analysis, allowlists for production, and rate limits per operation. Federation adds org complexity — start monolith schema.',
    difficulty: Difficulty.intermediate,
    tags: ['api', 'graphql', 'backend'],
  ),
  Concept(
    id: 45,
    category: _cat,
    color: _color,
    icon: '🔐',
    title: 'OAuth2 & API Security',
    tagline: 'Delegated authorization',
    diagram: '''
  User ──► Auth server (login)
              │
         access token (JWT/opaque)
              │
         Client ──► Resource API
              Authorization: Bearer ...''',
    bullets: [
      'OAuth2 is how an app gets permission to access a user\'s data on another service without getting their password — like giving a valet a special key that only starts the car but can\'t open the trunk',
      'Important distinction: OAuth2 is for authorization (what can this app do?), not authentication (who is this user?). For user identity, add OpenID Connect on top, which provides an ID token with user info',
      'Scopes limit what a token can do (e.g., read:email but not write:profile). Short-lived access tokens (15-60 minutes) limit damage if stolen. Refresh tokens get new access tokens without re-authenticating',
      'For mobile and browser apps (public clients), never embed secrets in the code — anyone can decompile it. Use PKCE (Proof Key for Code Exchange), which proves the app that started the auth flow is the same one completing it',
      'In interviews: "OAuth2 with PKCE for the mobile client, short-lived JWTs for API authorization, scopes for least privilege, and refresh token rotation to limit exposure from stolen tokens"',
    ],
    mnemonic: 'OAuth = valet key, not master key',
    interviewQ: 'JWT in localStorage — okay?',
    interviewA: 'Risky for XSS — attacker reads token. Prefer httpOnly secure cookies with CSRF protections for browser apps, or short-lived JWT in memory with refresh rotation. Mobile: secure storage (Keychain/Keystore). Always validate audience, issuer, expiry, and algorithm (no alg:none). Revocation needs blocklist or short TTL.',
    difficulty: Difficulty.intermediate,
    tags: ['api', 'oauth2', 'security'],
  ),
  Concept(
    id: 46,
    category: _cat,
    color: _color,
    icon: '📄',
    title: 'Pagination Patterns',
    tagline: 'Offset, cursor, keyset',
    diagram: '''
  Offset: ?limit=20&offset=40
  → skips rows — slow on huge offsets, duplicates on live data

  Cursor: ?after=opaque_token
  → stable-ish for feeds

  Keyset: ?created_lt=t&limit=20
  → WHERE created < t ORDER BY created DESC''',
    bullets: [
      'Pagination controls how users browse large datasets page by page. The three approaches — offset, cursor, and keyset — differ in simplicity, performance, and stability when data changes',
      'Offset pagination (?page=5&limit=20) is simplest: "skip 80 rows, return 20." But it degrades at scale — page 5000 forces the database to scan 100,000 rows. It also breaks when new items are inserted, causing duplicates or missed items',
      'Cursor-based pagination uses an opaque token encoding the last item\'s ID to fetch the next page. The database jumps directly to that point — no scanning skipped rows — making it fast regardless of depth',
      'Return the next cursor and a "has_more" flag with each page. Avoid returning a total count on large tables — COUNT(*) on millions of rows is expensive and usually unnecessary for the user experience',
      'In interviews, use offset for simple admin panels with small datasets, and cursor-based pagination for any user-facing feed or infinite scroll. The cursor should be opaque (base64 encoded) so clients can\'t tamper with it',
    ],
    mnemonic: 'Big data scrolls with cursors, not page numbers',
    interviewQ: 'Design pagination for 100M-row table',
    interviewA: 'Keyset pagination on primary key or (created_at, id) tie-breaker. Index supports ORDER BY. Return opaque cursor encoding last values. For filters, composite index matching WHERE + ORDER. Avoid COUNT(*) — approximate counts or separate rollup. Export use cases get async batch jobs, not interactive pages.',
    difficulty: Difficulty.advanced,
    tags: ['api', 'databases', 'performance'],
  ),
  Concept(
    id: 47,
    category: _cat,
    color: _color,
    icon: '📤',
    title: 'File Upload APIs',
    tagline: 'Presigned URLs and resumable uploads',
    diagram: '''
  Client ──► API: want upload
  API ──► Presigned PUT URL (S3/GCS)
  Client ──► Object storage directly

  Benefits: API servers don’t stream bytes''',
    bullets: [
      'For file uploads, avoid streaming bytes through your API servers — generate a presigned URL that lets the client upload directly to cloud storage (S3, GCS). This offloads bandwidth and keeps your API servers free',
      'The flow: client requests an upload URL → your API validates and returns a short-lived presigned URL → client uploads directly to S3 → your API gets notified on completion and processes the file',
      'For large files (videos, backups), use multipart uploads: the file is split into chunks uploaded in parallel. If the connection drops, only the failed chunk needs retrying — not the entire file',
      'Security is critical: validate file type and size before generating the presigned URL, scan for malware after upload, and never trust the client-declared content type — inspect the file\'s actual bytes server-side',
      'In interviews, the presigned URL pattern is the standard answer for "how would you handle file uploads at scale?" It separates upload traffic from API traffic and scales independently',
    ],
    mnemonic: 'Presign = temporary backstage pass to storage',
    interviewQ: 'Users upload 4GB videos — sketch the flow',
    interviewA: 'Client requests upload session; API returns multipart presigned URLs + uploadId. Client uploads parts parallel; completes multipart. Metadata row in DB with state pending→processing→ready. Worker transcodes, generates thumbnails, scans malware. CDN serves final object. Clean up abandoned multipart uploads with lifecycle rules.',
    difficulty: Difficulty.intermediate,
    tags: ['api', 'storage', 'aws'],
  ),
  Concept(
    id: 48,
    category: _cat,
    color: _color,
    icon: '⚠️',
    title: 'Error Models',
    tagline: 'Consistent problem+json responses',
    diagram: '''
  400 { "code": "INVALID_EMAIL",
         "message": "...",
         "field": "email" }

  409 { "code": "USERNAME_TAKEN" }

  500 { "code": "INTERNAL",
         "request_id": "abc" }''',
    bullets: [
      'A well-designed API returns structured errors with a machine-readable code (INVALID_EMAIL), a human-readable message, and a request ID for debugging — not just a raw 500 with a stack trace',
      'Machine-readable error codes let clients handle specific cases: if code is USERNAME_TAKEN, show "try another username." Without structured codes, clients must parse messages, which break when you change the wording',
      'Always include a request_id in error responses — it lets support find the exact server logs when a user reports "something went wrong." This saves hours of debugging',
      'Never expose internal details (stack traces, SQL queries, file paths) in production errors — they leak security information. Log full details server-side, return only the code and a safe message to the client',
      'In interviews, mention consistent error structure: use HTTP status codes for the category (4xx = client fault, 5xx = server fault), and a standardized JSON body with code, message, and request_id for details',
    ],
    mnemonic: 'Errors are data — structure them',
    interviewQ: 'How should validation errors look?',
    interviewA: 'Return 422 or 400 with structured list: field path, code, message. Support i18n via error codes client maps. Don’t vary shape between endpoints. Log server-side with same request_id. For public APIs, document every error code in OpenAPI. Avoid leaking whether an email exists (auth endpoints) via subtle differences.',
    difficulty: Difficulty.beginner,
    tags: ['api', 'errors', 'ux'],
  ),
  Concept(
    id: 49,
    category: _cat,
    color: _color,
    icon: '🔁',
    title: 'Webhooks',
    tagline: 'Server-to-server callbacks',
    diagram: '''
  Provider ──POST──► your /webhooks/x
              HMAC signature
              retry on 5xx

  Your endpoint: verify, enqueue, 200 fast''',
    bullets: [
      'Webhooks are server-to-server callbacks — when an event happens (payment completed, form submitted), the provider sends an HTTP POST to your URL with the event data. Instead of polling "any updates?", updates come to you',
      'Your webhook endpoint must respond quickly (under 5 seconds). Don\'t process inline — store the raw payload in a queue and return 200 immediately. If your endpoint is slow, the provider retries, potentially flooding you',
      'Security: verify that the webhook actually came from the provider using HMAC signatures. The provider signs the payload with a shared secret; you compute the same signature and compare. Also check timestamps to prevent replay attacks',
      'Webhooks are delivered at-least-once — providers retry on failure, so duplicates happen. Deduplicate using the event ID: before processing, check if you\'ve already handled that event_id',
      'In interviews: "treat webhook payloads like queue messages — verify, persist, acknowledge fast, process async, deduplicate by event ID." This handles retries, duplicates, and provider outages gracefully',
    ],
    mnemonic: 'Webhook = phone call; don’t stay on the line',
    interviewQ: 'Webhook endpoint timing out under load',
    interviewA: 'Return 200 after persisting raw payload to queue or DB, not after full processing. Workers handle business logic. Scale consumers horizontally. Increase provider timeout if configurable. Add signature verification in middleware before heavy work. Monitor age of unprocessed events.',
    difficulty: Difficulty.intermediate,
    tags: ['api', 'webhooks', 'integration'],
  ),
  Concept(
    id: 50,
    category: _cat,
    color: _color,
    icon: '🧱',
    title: 'API Gateway',
    tagline: 'Edge auth, routing, and policy',
    diagram: '''
  Client ──► API Gateway ──► Service A
                │            Service B
                ├ authn/z
                ├ rate limit
                ├ WAF
                └ request logging''',
    bullets: [
      'An API Gateway is a single entry point between clients and backend services — like a reception desk that checks IDs, directs visitors to the right department, and logs who came in',
      'It handles cross-cutting concerns in one place: TLS termination, authentication (validating JWT tokens), rate limiting, routing (/users → user-service, /orders → order-service), and request logging',
      'The golden rule: keep the gateway thin. It handles auth, routing, and rate limiting — never business logic. If your gateway starts validating order amounts or computing prices, it becomes a monolith bottleneck',
      'The gateway is where you add observability: inject trace IDs into every request so you can follow a user\'s request through all downstream services. Essential for debugging in a microservice architecture',
      'In interviews, mention the API gateway early when designing microservices. Know the boundary: "authentication and coarse rate limiting at the gateway, fine-grained authorization and business rules inside each service"',
    ],
    mnemonic: 'Gateway = bouncer + receptionist',
    interviewQ: 'What belongs in API gateway vs service?',
    interviewA: 'Gateway: authentication, coarse authorization, rate limiting, routing, canary weights, request logging, CORS. Service: business rules, fine-grained authz, data access. Avoid fat aggregation in gateway that becomes a monolith. Use BFF pattern when mobile needs differ strongly from web.',
    difficulty: Difficulty.intermediate,
    tags: ['api', 'gateway', 'architecture'],
  ),
];
