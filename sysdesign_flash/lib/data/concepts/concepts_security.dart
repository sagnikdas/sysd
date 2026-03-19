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
      'Authenticate and authorize each hop, not just perimeter',
      'Short-lived credentials; rotate secrets automatically',
      'Device compliance checks for corporate access',
      'Log and alert anomalous access patterns',
      'VPN becomes optional transport, not trust boundary',
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
      'Adaptive cost factor increases with hardware (Moore’s law)',
      'Unique salt per user defeats rainbow tables',
      'Argon2 winner of PHC — prefer for new systems',
      'Rate limit and lockout on auth endpoints',
      'Consider delegated auth (OIDC) to avoid password storage',
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
      'Push MFA better than SMS; WebAuthn best for browsers',
      'Backup codes stored hashed like passwords',
      'Risk-based MFA: step-up on new device or sensitive action',
      'Recovery flows are attack surface — strict verification',
      'Enforce MFA for admins and high-privilege APIs',
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
      'Injection: prepared statements, ORM discipline, input validation',
      'Broken access control: test horizontal/vertical privilege escalation',
      'Security misconfiguration: default creds, debug on in prod',
      'Vulnerable dependencies: SCA scanning in CI',
      'SSRF: allowlist egress, disable cloud metadata from app subnets',
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
      'Secrets in VCS history are forever — use scanners (trufflehog)',
      'Inject at runtime via KMS-sealed env or sidecar',
      'Rotate on schedule and on incident',
      'Separate build-time vs runtime secrets',
      'Audit secret access',
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
      'Strong identity for services beyond network location',
      'Certificate rotation must be automated — short-lived certs',
      'Private CA per cluster/environment',
      'Performance cost small vs TLS 1.3 session resumption',
      'Complements JWT for user context at edge',
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
      'Signature rules catch known exploits; tune false positives',
      'Managed rulesets updated by vendor for new CVEs',
      'Bot management distinguishes headless browsers',
      'Geo blocking during targeted attacks',
      'Log sampled blocked requests for tuning',
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
      'TLS for public and internal east-west traffic where feasible',
      'KMS-managed keys with rotation for databases and buckets',
      'Field-level encryption for ultra-sensitive columns (search implications)',
      'HSM or cloud KMS for root keys',
      'Compliance (PCI, HIPAA) drives stricter boundaries',
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
      'RBAC simpler to reason; role explosion if too granular',
      'ABAC flexible with policy engines (OPA, Cedar)',
      'Often combine: RBAC coarse + ABAC fine inside service',
      'Deny by default; explicit grants',
      'Audit policy changes like code',
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
      'CSP stops XSS exfiltration — start report-only mode',
      'HSTS preload for long-lived HTTPS enforcement',
      'Referrer-Policy and Permissions-Policy reduce leakage',
      'Set-Cookie: Secure HttpOnly SameSite=Lax|Strict',
      'Validate headers in security scanners in CI',
    ],
    mnemonic: 'Headers = browser seatbelts',
    interviewQ: 'Mitigate XSS in SPA',
    interviewA: 'CSP with nonce or hash for inline scripts; avoid unsafe-inline. Sanitize any HTML rendering (DOMPurify). Framework auto-escaping for templates. HttpOnly cookies so JS can’t steal session. Subresource Integrity for third-party scripts. Regular dependency audits. CSP reporting to catch violations.',
    difficulty: Difficulty.intermediate,
    tags: ['security', 'web', 'headers'],
  ),
];
