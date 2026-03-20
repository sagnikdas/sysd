import '../../domain/models/concept.dart';
import '../../core/theme/app_colors.dart';

const _cat = 'Security';
final _color = AppColors.security;

final conceptsSecurity = <Concept>[
  Concept(
    id: 80,
    category: _cat,
    color: _color,
    icon: '🔐',
    title: 'Zero Trust',
    tagline: 'Never trust, always verify',
    diagram: '''
  Every request: identity + device posture + least privilege
  No "inside the VPN = safe"

  Micro-segmentation + continuous auth''',
    bullets: [
      'Zero Trust means "never assume a request is safe just because it comes from inside your network." Every request must prove identity and authorization — like requiring ID at every door, not just the front entrance',
      'Traditional security trusts everything inside the VPN. Zero Trust eliminates this because attackers who breach the perimeter get free access. Instead, every service verifies every request independently',
      'Key practices: short-lived credentials that auto-rotate, mutual TLS between services (both sides verify identity), least-privilege access, and device compliance checks before granting access',
      'Zero Trust requires strong identity infrastructure: every service has a cryptographic identity, every request carries an authenticated token, and every access decision is logged for anomaly detection',
      'In interviews: "internal services authenticate via mTLS and authorize via policy engine — we don\'t trust network location. Even if an attacker compromises one service, they can\'t access others without valid credentials"',
    ],
    mnemonic: 'Zero trust = everyone shows ID every door',
    interviewQ: 'How does Zero Trust change network design?',
    interviewA: 'Replace flat internal networks with identity-aware proxies (BeyondCorp style). Services authenticate via mTLS or signed tokens. Policy engine evaluates user, device, resource sensitivity. Segment east-west traffic. Assume breach — limit blast radius with least privilege IAM and micro-segmentation.',
    difficulty: Difficulty.intermediate,
    tags: ['security', 'networking', 'enterprise'],
  ),
  Concept(
    id: 81,
    category: _cat,
    color: _color,
    icon: '🧂',
    title: 'Password Hashing',
    tagline: 'bcrypt, scrypt, Argon2',
    diagram: '''
  Store: salt + slow hash(password + salt)
  Never: MD5/SHA1 for passwords

  Pepper (server secret) + per-user salt''',
    bullets: [
      'Never store passwords as plain text or simple hashes (MD5, SHA-1). Use a purpose-built, slow hashing algorithm (bcrypt, Argon2) that makes brute-force cracking prohibitively expensive — turning a seconds-long crack into years',
      'A "salt" is a unique random string added to each password before hashing. Without it, two users with password "hello123" produce the same hash — a pre-computed table cracks them all instantly. Unique salts force individual cracking',
      'Modern password hashing (Argon2, bcrypt) is intentionally slow with a configurable "cost factor" you increase over time as hardware gets faster. What takes 100ms today should still take 100ms in 5 years',
      'Layer additional protections: rate limit login attempts (max 5 per minute per account), implement account lockout, and require MFA for sensitive accounts. The best defense is delegating auth via OAuth so you never store passwords',
      'In interviews: "passwords hashed with Argon2 and unique per-user salt. Login endpoints rate-limited. We encourage OAuth login to avoid storing passwords. If the database leaks, cracking is impractical due to the slow hash"',
    ],
    mnemonic: 'Passwords get salted slow hash stew',
    interviewQ: 'User database leaked — are we safe?',
    interviewA: 'If properly salted Argon2/bcrypt with high cost, offline cracking is slow but not impossible for weak passwords. Force password reset, notify users, offer MFA. Rotate session tokens. Check HIBP for credential stuffing. If plaintext or unsalted MD5 — assume total compromise; mandatory reset and legal review.',
    difficulty: Difficulty.beginner,
    tags: ['security', 'auth', 'crypto'],
  ),
  Concept(
    id: 82,
    category: _cat,
    color: _color,
    icon: '🪪',
    title: 'MFA & WebAuthn',
    tagline: 'Something you have + know',
    diagram: '''
  TOTP app ──► shared secret time codes
  WebAuthn ──► phishing-resistant keys (platform/roaming)

  SMS OTP: weakest MFA — SIM swap risk''',
    bullets: [
      'Multi-Factor Authentication requires proving identity with two methods — something you know (password) plus something you have (phone, security key). Even if an attacker steals the password, they can\'t log in without the second factor',
      'MFA methods ranked by security: SMS codes (weakest — vulnerable to SIM swap), authenticator app TOTP (better — harder to intercept), push notifications (good), and hardware security keys/WebAuthn (best — phishing-resistant)',
      'Risk-based MFA adds intelligence: don\'t ask for MFA on every login from a recognized device. Step up when something is unusual — new device, new country, sensitive action. This balances security with convenience',
      'Recovery flows (lost phone, lost key) are a major attack surface. Backup codes should be stored hashed like passwords. Account recovery should require strict identity verification — weak recovery undermines even strong MFA',
      'In interviews: "MFA mandatory for admin accounts and sensitive operations. We support TOTP apps and WebAuthn. Risk-based step-up triggers MFA for unusual login patterns. Recovery codes are hashed and single-use"',
    ],
    mnemonic: 'MFA = second lock on the door',
    interviewQ: 'Phishing bypassed our MFA',
    interviewA: 'TOTP and push MFA can be phished via real-time relay attacks. Move high-value users to WebAuthn/FIDO2 security keys which bind to origin. Combine with device posture and IP reputation. Educate users on domain verification. For enterprises, phishing-resistant MFA is now baseline recommendation.',
    difficulty: Difficulty.intermediate,
    tags: ['security', 'auth', 'mfa'],
  ),
  Concept(
    id: 83,
    category: _cat,
    color: _color,
    icon: '🕵️',
    title: 'OWASP Top Risks',
    tagline: 'Injection, broken auth, XSS…',
    diagram: '''
  SQL injection: "' OR 1=1 --"
  XSS: <script> steal cookie
  SSRF: server calls internal metadata URL

  Defense: param queries, encode output, network egress controls''',
    bullets: [
      'The OWASP Top 10 is a curated list of the most critical web security risks. Most real-world breaches exploit one of these common vulnerabilities, not exotic zero-days',
      'Injection (SQLi) is the classic: attackers slip malicious code into user inputs that your app executes. Prevention: always use parameterized queries — never concatenate user input into SQL strings',
      'Broken access control means a user can access another user\'s data or perform admin actions. Test both horizontal escalation (user A accessing B\'s data) and vertical escalation (regular user performing admin actions)',
      'SSRF (Server-Side Request Forgery) tricks your server into making requests to internal resources — an attacker might access cloud metadata and leak credentials. Prevent by allowlisting egress destinations and blocking internal IPs',
      'In interviews: "parameterized queries for injection prevention, authorization enforced at the service layer, dependency scanning in CI, and OWASP Top 10 review during design reviews"',
    ],
    mnemonic: 'OWASP = hacker greatest hits album',
    interviewQ: 'Prevent SQL injection in our API',
    interviewA: 'Use parameterized queries or ORM bindings — never string-concat user input into SQL. Least privilege DB users (no DDL). Input validation allowlists. WAF as secondary layer. Static analysis and code review on data access layer. Log and alert on suspicious patterns. Regular dependency updates.',
    difficulty: Difficulty.beginner,
    tags: ['security', 'owasp', 'web'],
  ),
  Concept(
    id: 84,
    category: _cat,
    color: _color,
    icon: '🎭',
    title: 'Secrets Management',
    tagline: 'No keys in git or images',
    diagram: '''
  Vault / AWS Secrets Manager
       │
  Runtime fetch + short TTL
  Rotation automated

  .env in repo ❌''',
    bullets: [
      'Secrets (API keys, database passwords, encryption keys) must never be in code repositories, env files committed to git, or Docker images — once a secret enters version control, it\'s in the history forever',
      'Use a secrets manager (HashiCorp Vault, AWS Secrets Manager) to store and inject secrets at runtime. Your application fetches secrets on startup — the secret never appears in code, config files, or build artifacts',
      'Rotate secrets automatically on a schedule (e.g., every 90 days) and immediately after any security incident. Short-lived credentials (tokens that expire in hours) limit the damage window if compromised',
      'Run secret scanning tools (truffleHog, GitGuardian) in CI to catch accidental commits. If a secret is committed, revoke it immediately — don\'t just remove the file, git history preserves it',
      'In interviews: "secrets managed in Vault, injected at runtime via KMS environment variables. We rotate every 90 days, scan for accidental commits in CI, and audit secret access logs"',
    ],
    mnemonic: 'Secrets rotate like tires',
    interviewQ: 'Engineer pasted AWS key in Slack',
    interviewA: 'Immediately revoke key in IAM, issue new credentials, scan git history and logs for usage. Enable CloudTrail alerts on root key usage. Run secret scanner on repos. Educate on secure sharing (Vault, 1Password for teams). Implement OIDC federation for CI instead of long-lived keys. Post-incident review.',
    difficulty: Difficulty.intermediate,
    tags: ['security', 'devops', 'aws'],
  ),
  Concept(
    id: 85,
    category: _cat,
    color: _color,
    icon: '🛡️',
    title: 'mTLS',
    tagline: 'Mutual TLS service-to-service',
    diagram: '''
  Client cert + server cert
  Both sides verify chain to CA

  Mesh (Istio) automates cert rotation''',
    bullets: [
      'Mutual TLS means both sides of a connection present certificates and verify each other — normal TLS only verifies the server. Like both parties showing ID at a meeting, not just the host',
      'In microservices, mTLS solves "who is calling me?": without it, any process on the network can call any service. With mTLS, services have cryptographic identities — a rogue container can\'t impersonate the payment service',
      'Certificate management is the challenge: every service needs a valid certificate, and certificates must be rotated frequently. A service mesh like Istio automates this entirely — issuing and rotating certificates without code changes',
      'mTLS authenticates services (which service is calling?), while JWTs carry user context (which user\'s request?). They complement each other: mTLS ensures the calling service is legitimate, JWT carries permissions',
      'In interviews: "all internal traffic uses mTLS via our service mesh, so no service can be impersonated. We complement with JWT tokens for user-level authorization passed from the API gateway"',
    ],
    mnemonic: 'mTLS = both sides show passport',
    interviewQ: 'JWT between services vs mTLS',
    interviewA: 'JWT carries user identity claims; easy to forward but verify signature and audience carefully. mTLS authenticates the service process itself — stops rogue pods. Best practice: mTLS at L4/L7 between services + signed JWT for authorization context propagated inside. Don’t trust network alone in K8s flat networks.',
    difficulty: Difficulty.advanced,
    tags: ['security', 'tls', 'kubernetes'],
  ),
  Concept(
    id: 86,
    category: _cat,
    color: _color,
    icon: '🧱',
    title: 'WAF & Bot Defense',
    tagline: 'Filter malicious HTTP at edge',
    diagram: '''
  Request ──► WAF rules (OWASP CRS)
         ──► Bot score
         ──► Rate limit
         ──► Origin''',
    bullets: [
      'A WAF (Web Application Firewall) inspects incoming HTTP requests and blocks malicious patterns before they reach your application — like a spam filter for web traffic that catches SQL injection, XSS, and known exploits',
      'WAFs use signature-based rules matching known attack patterns and managed rulesets updated automatically when new vulnerabilities are discovered. This protects against known threats without custom code',
      'Bot defense goes beyond basic WAFs: it distinguishes real users from scrapers, credential stuffers, and headless browsers using JavaScript execution, mouse movement, and device fingerprinting',
      'The main challenge is false positives: legitimate requests that look like attacks. Start in monitor-only mode, review what would be blocked, whitelist known-good patterns, then switch to blocking',
      'In interviews: "HTTP traffic flows through CDN → WAF (blocks attacks and bots) → API gateway (rate limiting, auth) → services. We tune WAF rules per endpoint and monitor false positive rates"',
    ],
    mnemonic: 'WAF = spam filter for HTTP',
    interviewQ: 'WAF blocking legitimate traffic',
    interviewA: 'Start in monitor-only mode, review false positives, whitelist paths and parameters carefully. Use rule exclusions for known good patterns (JSON payloads, mobile SDK headers). Lower sensitivity on APIs with auth. Correlate with app logs via request id. Version rule changes; canary WAF policies per route.',
    difficulty: Difficulty.intermediate,
    tags: ['security', 'waf', 'edge'],
  ),
  Concept(
    id: 87,
    category: _cat,
    color: _color,
    icon: '🔍',
    title: 'Encryption at Rest & Transit',
    tagline: 'Protect data on disk and wire',
    diagram: '''
  Transit: TLS 1.2+ everywhere
  At rest: AES-256 disk encryption (cloud default)
  App-level: envelope encryption for PII fields''',
    bullets: [
      'Data should be encrypted in two states: in transit (moving between services — protected by TLS) and at rest (stored on disk — protected by encryption). If either is unencrypted, stolen data is readable',
      'Encryption in transit (TLS 1.2+) protects data on the network. Without it, anyone who can see traffic (compromised router, cloud insider) can read your data. Use TLS everywhere, not just for external traffic',
      'Encryption at rest protects stored data: database files, S3 objects, backups. For sensitive fields (credit cards, SSNs), add application-level encryption so even database admins can\'t read raw values',
      'Key management is the hard part: use a cloud KMS to generate, store, and rotate encryption keys. Never hardcode keys. Separate key management from data — if someone steals the database, they shouldn\'t get the keys',
      'In interviews: "TLS everywhere including internal traffic, disk encryption for all storage, field-level encryption for PII with KMS-managed keys rotated quarterly — satisfying PCI-DSS and HIPAA requirements"',
    ],
    mnemonic: 'Moving or sleeping — encrypt it',
    interviewQ: 'HIPAA on our Postgres',
    interviewA: 'Encrypt disk (RDS encryption), TLS to DB, least privilege IAM, audit logs, VPC isolation, no PHI in logs. BAA with cloud provider. Backup encryption. Key rotation via KMS. Access via IAM database auth or strong password vault. Consider column-level encryption for highly sensitive fields with trade-offs on queries.',
    difficulty: Difficulty.intermediate,
    tags: ['security', 'compliance', 'encryption'],
  ),
  Concept(
    id: 88,
    category: _cat,
    color: _color,
    icon: '🎯',
    title: 'RBAC vs ABAC',
    tagline: 'Role-based vs attribute-based access',
    diagram: '''
  RBAC: user has role "editor" → can edit posts

  ABAC: allow if department=eng AND clearance>=secret
  Fine-grained, complex policies''',
    bullets: [
      'RBAC (Role-Based Access Control) grants permissions through roles: "editors can edit posts, admins can delete users." Simple and works well when permissions map cleanly to job functions',
      'ABAC (Attribute-Based Access Control) makes decisions based on any attribute: user department, resource sensitivity, time of day. Far more flexible but more complex to manage',
      'RBAC breaks down when you need fine-grained rules: "users can only edit their own posts" or "managers can approve expenses under \$10K." These don\'t fit neatly into roles, leading to "role explosion"',
      'A practical approach: RBAC for coarse access (admin, editor, viewer) at the API gateway, and ABAC for fine-grained decisions inside services. Always default to deny — require explicit grants',
      'In interviews: "start with RBAC since our model is straightforward. If we later need rules like regional managers seeing only their region\'s data, add a policy engine (OPA/Cedar) for attribute-based decisions"',
    ],
    mnemonic: 'RBAC = job title; ABAC = full context',
    interviewQ: 'When switch from RBAC to ABAC?',
    interviewA: 'When access depends on many dynamic attributes (resource owner, region, data classification, time window) and role matrix becomes unmaintainable. ABAC with policy-as-code enables centralized review. Start RBAC for MVP; introduce ABAC/policy engine when rules sprawl. Test policies with table-driven unit tests.',
    difficulty: Difficulty.advanced,
    tags: ['security', 'authorization', 'architecture'],
  ),
  Concept(
    id: 89,
    category: _cat,
    color: _color,
    icon: '📋',
    title: 'Security Headers',
    tagline: 'Browser defenses via HTTP',
    diagram: '''
  Content-Security-Policy: restrict script sources
  HSTS: force HTTPS
  X-Frame-Options / frame-ancestors: clickjacking
  SameSite cookies: CSRF mitigation''',
    bullets: [
      'Security headers are instructions your server sends to browsers telling them how to behave — like safety rules at a construction site. They defend against XSS, clickjacking, and protocol downgrade without changing application code',
      'Content-Security-Policy (CSP) tells the browser which sources can run scripts or load resources. This blocks XSS because injected scripts from unauthorized sources are refused, even if your code has a vulnerability',
      'HSTS (Strict Transport Security) forces browsers to always use HTTPS, preventing downgrade attacks where an attacker intercepts the initial HTTP request before it redirects to HTTPS',
      'Cookie security flags protect session tokens: Secure (only over HTTPS), HttpOnly (JavaScript can\'t access — prevents XSS cookie theft), and SameSite=Lax or Strict (prevents cross-site request forgery)',
      'In interviews: "HSTS, CSP in report-then-enforce mode, Secure/HttpOnly/SameSite cookies, and automated security header validation in CI. This catches XSS and CSRF at the browser layer"',
    ],
    mnemonic: 'Headers = browser seatbelts',
    interviewQ: 'Mitigate XSS in SPA',
    interviewA: 'CSP with nonce or hash for inline scripts; avoid unsafe-inline. Sanitize any HTML rendering (DOMPurify). Framework auto-escaping for templates. HttpOnly cookies so JS can’t steal session. Subresource Integrity for third-party scripts. Regular dependency audits. CSP reporting to catch violations.',
    difficulty: Difficulty.intermediate,
    tags: ['security', 'web', 'headers'],
  ),
];
