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
      'Resources are nouns; HTTP methods express intent',
      'Use correct status codes — 201 created, 409 conflict, 422 validation',
      'HATEOAS optional; hypermedia rare in mobile JSON APIs',
      'Version via URL (/v1) or header — pick one org-wide convention',
      'Pagination: cursor > offset for large unstable datasets',
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
      'Spec-first or code-first — both work if CI enforces compatibility',
      'Breaking: removing fields, changing types, tightening validation',
      'Non-breaking: optional fields, new endpoints, additive enums with unknown handling',
      'Publish docs from same artifact consumers trust',
      'Pair with Pact or schema diff tools in PR checks',
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
      'Network retries are normal — design mutating endpoints accordingly',
      'PUT to a URL replaces resource; repeating yields same final resource',
      'POST create twice without key → two resources — dangerous for orders',
      'Conditional requests: If-Match ETag avoids lost updates',
      'Document which endpoints support retry and for how long',
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
      'Clients fetch exactly what they need — fewer round trips',
      'Risk: expensive queries — enforce complexity limits, timeouts, persisted queries',
      'N+1 problem: solve with DataLoader batching per request',
      'Caching harder than REST URLs — CDN at edge less natural',
      'Subscriptions need WebSocket infra and auth story',
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
      'OAuth2 is authorization framework — not authentication alone (add OpenID Connect)',
      'Scopes limit token power — principle of least privilege',
      'Prefer opaque tokens + introspection or short-lived JWT + rotation for APIs',
      'Never put secrets in mobile apps — use PKCE for public clients',
      'CORS, CSRF, and token storage differ for SPAs vs mobile',
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
      'Offset pagination simple but degrades (DB scans skipped rows)',
      'Keyset on indexed column avoids large skips — best for infinite scroll',
      'Expose stable sort keys in cursor to prevent duplicates/skips when data mutates',
      'Return next_cursor + has_more — avoid total count on huge tables',
      'Rate-limit deep crawlers scraping via offset',
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
      'Direct-to-cloud upload offloads bandwidth from app servers',
      'Presign short TTL; validate content-type and size server-side before sign',
      'Virus scan / moderation via async pipeline after upload completes',
      'Multipart upload for large files — resume on failure',
      'Never trust client MIME — inspect magic bytes server-side',
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
      'Stable machine-readable codes for clients to branch logic',
      'Human message for developers; don’t leak stack traces in prod',
      'Include request_id for support correlation',
      'RFC 7807 Problem Details for HTTP APIs — standard shape',
      'Map domain errors to status codes consistently in one layer',
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
      'Verify signatures (HMAC-SHA256 with shared secret) and timestamp to block replays',
      'Respond quickly — process async via queue; retries come on timeout/failure',
      'Idempotency on event id to handle duplicate deliveries',
      'Expose manual replay tools for debugging',
      'Version webhook payloads with backward compatibility',
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
      'Centralize TLS termination, JWT validation, and tenant routing',
      'Rate limits and quotas at edge protect origins',
      'Transform protocols (REST↔gRPC) possible but adds complexity',
      'Don’t hide domain logic in gateway — keep it thin',
      'Observability: trace ids propagated to services',
    ],
    mnemonic: 'Gateway = bouncer + receptionist',
    interviewQ: 'What belongs in API gateway vs service?',
    interviewA: 'Gateway: authentication, coarse authorization, rate limiting, routing, canary weights, request logging, CORS. Service: business rules, fine-grained authz, data access. Avoid fat aggregation in gateway that becomes a monolith. Use BFF pattern when mobile needs differ strongly from web.',
    difficulty: Difficulty.intermediate,
    tags: ['api', 'gateway', 'architecture'],
  ),
];
