# Paywall & Monetisation Analysis — SysDesign Flash

This document reviews the current payment implementation, explains the landscape of payment options available to a Flutter app, covers Apple/Google platform rules, and walks through geographic pricing strategy so you can make an informed decision.

---

## Part 1 — What Is Currently Built

### Plans and prices (hardcoded fallbacks)

| Plan | SKU | Fallback price | Type |
|---|---|---|---|
| Monthly | `pro_monthly` | $5.99 / month | Recurring subscription |
| Annual | `pro_annual` | $35.99 / year | Recurring subscription |
| Lifetime | `pro_lifetime` | $79.99 one-time | Non-consumable |

### Technology stack

- **`in_app_purchase: ^3.2.3`** — Flutter plugin that wraps Apple StoreKit (iOS) and Google Play Billing (Android). Single API surface for both stores.
- **Supabase Edge Function `verify-purchase`** — server-side receipt verification, called after a purchase completes.
- **Hive** — local cache of tier, plan, expiry date, trial start, purchase token. Acts as the source of truth when the server is unavailable.

### Purchase flow (step by step)

```
User taps "Start 7-day Free Trial"
  → PaywallScreen._startPurchase()
  → subscriptionProvider.purchasePlan(plan)
  → SubscriptionRepository.purchaseByPlan(plan)
  → BillingService.purchaseProduct(product)         ← opens native store sheet
  → wait on _purchaseCompleter (2-min timeout)
  → _onPurchases() resolves the completer
  → verifyWithServer(purchase, fallbackPlan)
      → calls Supabase function 'verify-purchase'
      → caches result in Hive (_cacheVerificationResponse)
      → on failure: local fallback (_cacheLocalPurchase)
  → BillingService.completePurchase(purchase)       ← acknowledges to store
  → router.go('/upgrade-success')
```

### One bug to be aware of

`BillingService.purchaseProduct()` always calls `buyNonConsumable()`. This is correct for the **lifetime** plan (a one-time non-consumable purchase), but **wrong for monthly and annual subscriptions**. Subscriptions must use `buySubscription()` with a `SubscriptionChangeParam`. On the App Store this may still work during testing but will behave incorrectly in production (renewal and cancellation events will not be handled). This needs fixing before going live.

---

## Part 2 — The Payment Landscape for Mobile Apps

There are three broad categories of how you can charge users:

### Category A — Platform In-App Purchases (IAP)

The store (Apple App Store or Google Play) handles the full transaction. Your server receives a receipt/token you verify.

| | Apple App Store | Google Play |
|---|---|---|
| Revenue cut | 30% (15% after 1st year under Small Business Program) | 30% (15% after $1M/year) |
| Payment methods | Apple Pay, cards saved to Apple ID | Google Pay, cards saved to Google account |
| Mandatory for | Selling digital features/content in iOS apps — **no exceptions** | Selling digital features/content in Android apps — **no exceptions** for Play distribution |
| Receipt format | App Store signed receipt (JWS/JWT in StoreKit 2) | Purchase token + order ID |
| Trial support | Yes — free trials, intro offers, promotional offers | Yes — free trials, intro pricing |
| Geographic pricing | Yes — App Store price tiers (170+ currencies) | Yes — Google Play price points per country |
| Refund handling | Apple handles; you can appeal | Google handles; you can appeal |

**Key rule:** Apple requires ALL digital goods and features sold inside iOS apps to go through IAP. Using Stripe or any other payment processor to sell Pro inside an iOS app would get your app rejected or removed.

Google has the same requirement for Android apps distributed on the Play Store. There is a carve-out for apps distributed outside Play (sideloading/APK), but for a mainstream app this is irrelevant.

**Bottom line: IAP is not optional. You must use it for digital feature unlocks on both platforms.**

---

### Category B — Web-Based Payments (Stripe, Razorpay, etc.)

These processors let users pay on a website and then unlock the app. Because the transaction happens outside the app, neither Apple nor Google can require a cut, and you avoid the 15–30% fee.

**How it works in practice:**
1. User visits your website (not the app)
2. Pays via Stripe/Razorpay
3. Your server records the subscription in Supabase
4. User signs in to the app → sync picks up the Pro status

**Apple's explicit rule:** You cannot show a link, button, or mention of a website payment option inside the iOS app. You cannot even tell the user "you can subscribe cheaper on our website." The UI must be neutral — if you don't offer IAP you simply show nothing. (This rule was partially challenged by the Epic v. Apple case and some regulations are evolving in the EU/Japan, but as of 2025 it still applies in most markets including the US.)

**Google's rule (revised 2022):** Google now allows apps to link to external payment for purchases in the Play Store if they use Google's User Choice Billing program. You still pay a reduced fee (~15% instead of 30%) and must offer Play Billing alongside the external option. This is available in select countries and requires program enrollment.

**Where web payments make complete sense:**
- SaaS/B2B scenarios where users sign up on a website first
- Physical goods (Uber, food delivery) — stores explicitly exempt these
- If you build a web app / PWA alongside the mobile app, users can subscribe there
- Enterprise contracts invoiced manually

---

### Category C — Hybrid (IAP + Web)

Many successful apps use both. The mobile app offers only IAP (as required), but the website offers the same plans via Stripe at a lower price (because you keep 97% instead of 70%). Users who subscribe on the web get the same Pro status synced to the app.

This is the model used by Duolingo, Notion, Headspace, and most major subscription apps. It is completely legal and is the standard practice for mature apps.

**Flow for a hybrid model with this app:**
```
Mobile (iOS/Android):  user pays via App Store / Play → receipt verified → Supabase 'subscriptions' table updated → Pro unlocked
Web:                   user pays via Stripe/Razorpay → Stripe webhook → Supabase 'subscriptions' table updated → Pro unlocked on next app sign-in/sync
```

The app itself does not need to know which payment path was used — it just reads the subscription tier from Supabase.

---

## Part 3 — Stripe vs Razorpay vs Others

These are relevant for the web path, or for Android sideloading / future web apps.

### Stripe

| Attribute | Details |
|---|---|
| Fees | 2.9% + $0.30 per transaction (US); varies by country |
| Geographic reach | 47+ countries where you can create a Stripe account |
| Subscription management | Native — Stripe Billing handles recurring, trials, proration, dunning |
| Supported currencies | 135+ currencies |
| Payout | Bank transfer in your country's currency |
| Integration effort | Moderate — Flutter has `flutter_stripe` SDK; server-side webhook needed |
| Best for | Global apps, developer-friendly, excellent docs |
| Indian payments | Works but cards must be international; UPI/NetBanking not supported |

**Stripe's subscription model is the gold standard** for web-based subscriptions. It handles trial periods, upgrade/downgrade, proration (charging the difference mid-cycle), dunning (retrying failed payments), and sends webhook events your server consumes.

### Razorpay

| Attribute | Details |
|---|---|
| Fees | 2% per transaction (India); additional fees for international |
| Geographic reach | Primarily India; limited international acquiring |
| Indian payment methods | UPI, NetBanking, Wallets (Paytm, PhonePe), Cards, EMI, Pay Later |
| Subscription management | Yes — Razorpay Subscriptions handles recurring billing |
| Payout | INR bank transfer |
| Best for | Apps with a significant Indian user base |
| International | Accepts international cards but settlement is in INR |

**If your target market includes Indian users**, Razorpay is important because UPI and NetBanking are how a large portion of Indian users pay. An international card-only checkout (Stripe) will see significantly lower conversion in India.

### RevenueCat (not a processor — a subscription management platform)

| Attribute | Details |
|---|---|
| What it is | SDK + dashboard that sits on top of Apple IAP and Google Play |
| Fees | Free up to $2500 MRR; then 1% of revenue |
| What it solves | Unified receipt verification, webhook delivery, subscriber analytics, A/B testing paywalls, cross-platform entitlements |
| Integration | Replace `in_app_purchase` with `purchases_flutter` SDK; ~1 day |
| Best for | Apps that want managed IAP without maintaining their own Supabase verify-purchase function |

RevenueCat effectively replaces the `verify-purchase` Supabase Edge Function and the `subscription_repository.dart` server-verification logic. It is widely used (Headspace, Buffer, Photoroom) and worth serious consideration given your existing architecture already has Supabase but a relatively thin verify function.

### Comparison table

| | Apple IAP | Google Play IAP | Stripe (web) | Razorpay (web) | RevenueCat |
|---|---|---|---|---|---|
| Store cut | 15–30% | 15–30% | N/A | N/A | 1% (after $2.5k MRR) |
| Processor fee | None (store handles) | None | 2.9%+$0.30 | 2% | None (on top of IAP) |
| Required for in-app? | Yes (iOS) | Yes (Android Play) | No | No | Optional (overlay) |
| Trial support | Yes | Yes | Yes | Yes | Yes (manages IAP trials) |
| Indian UPI/NetBanking | No | No | No | Yes | No |
| Receipt verification | Manual or RevenueCat | Manual or RevenueCat | Stripe webhook | Razorpay webhook | Managed |
| Subscriber analytics | Basic (App Store Connect) | Basic (Play Console) | Stripe dashboard | Razorpay dashboard | Excellent |
| Cross-platform entitlement | You build it | You build it | You build it | You build it | Built-in |

---

## Part 4 — Geographic Pricing

### The problem

A $5.99/month price is unaffordable for users in India, Brazil, Southeast Asia, or Eastern Europe where purchasing power is much lower. Charging the same price globally means:
- Low conversion in emerging markets despite potentially high interest
- You leave money on the table in markets where a lower price still generates real revenue

### How stores handle it: Price Tiers

Both Apple and Google have a tiered pricing system where you set a price in one currency and they suggest equivalent prices in other currencies. You can accept the suggestions or override each market manually.

**Apple App Store:**
- 900 price points across 170+ storefronts
- You set prices per storefront individually or use the automatic price equivalency tool
- Prices update automatically when exchange rates shift (if you opt in)
- Apple pays you in your bank account currency regardless of which currency the user paid in

**Google Play:**
- Similar tiered system; you set a base price and Google suggests local equivalencies
- You can override prices per country in the Play Console
- Google introduced "Pricing Templates" to apply geo-pricing rules across multiple apps

### Purchasing Power Parity (PPP) pricing

The strategy used by apps like JetBrains, Notion, and Duolingo is to set prices roughly proportional to each country's purchasing power relative to the US.

A rough index (price relative to $5.99/month US):

| Region | Suggested multiplier | Approx monthly price |
|---|---|---|
| United States | 1.0× | $5.99 |
| Western Europe (UK, DE, FR) | 0.9–1.0× | €5.49–€5.99 |
| India | 0.15–0.20× | ₹99–₹149 (~$1.20–$1.80) |
| Brazil | 0.25–0.30× | R$14.90–R$17.90 (~$2.50–$3.00) |
| Southeast Asia (ID, PH, VN) | 0.15–0.25× | ~$1.00–$1.50 |
| Eastern Europe (PL, RO, UA) | 0.35–0.50× | ~$2.00–$3.00 |
| Latin America ex-Brazil | 0.30–0.40× | ~$2.00–$2.50 |
| Middle East (AE, SA) | 0.70–0.85× | ~$4.50–$5.00 |
| Australia / Canada | 0.90–1.0× | AU$8.99 / CA$7.99 |

**How to implement in App Store Connect:**
1. Go to your subscription product → Pricing → Per-storefront pricing
2. Select each storefront (country) and override the price using the appropriate tier
3. India storefront: set to the ₹99 or ₹149 tier
4. Use the "Manage pricing" bulk tool to apply changes across multiple storefronts at once

**How to implement in Google Play Console:**
1. Go to your subscription → Pricing → Countries and regions
2. Click each country and override the price
3. Or use "Price templates" to define a rule (e.g., India = 15% of base price) and apply it

### Currency and tax

Both Apple and Google handle currency conversion and tax remittance automatically:
- They collect from the user in local currency
- They remit applicable VAT/GST on your behalf (in countries where the store is the merchant of record)
- You receive the net amount in your bank account currency after the store's cut and applicable withholding taxes

For Stripe (web payments), **you** are responsible for tax handling. In the EU you must collect VAT; in India you need GST registration. Services like Stripe Tax or Paddle (a Merchant of Record service) can handle this automatically.

### Paddle — an alternative worth knowing

Paddle is a Merchant of Record (MoR). Instead of you collecting payment and handling tax, Paddle buys the subscription from you and resells it to customers. They handle all tax globally.

- Fees: ~5% + $0.50 per transaction
- You get a clean payout with no tax complexity
- Useful if you sell via a web app and want zero compliance burden
- Many indie apps use Paddle + IAP (Paddle for web, IAP for in-app)

---

## Part 5 — Recommendations for SysDesign Flash

### Immediate decision: what to launch with

**Recommendation: IAP only (Apple + Google) for v1**

Reasons:
1. The code is already nearly complete — just fix the `buySubscription` bug noted in Part 1
2. IAP is mandatory for in-app purchases anyway
3. The audience (engineers preparing for FAANG interviews) skews US/Europe/India — these are all well-supported IAP markets
4. Setting up Stripe + server webhooks + a web checkout is weeks of additional work
5. RevenueCat can be added later as an overlay without changing the app logic

**Set up geographic pricing from day one:**
- India: ₹99/month (annual: ₹799/year, lifetime: ₹1,999)
- These prices are proven in the Indian developer tools market (comparable: Codeshot, AlgoExpert India pricing)
- US/Europe: keep current fallback prices

### Medium-term: add RevenueCat

When you have paying users and want better analytics + managed entitlements:
- Swap `in_app_purchase` for `purchases_flutter` (RevenueCat's SDK)
- Remove the `verify-purchase` Supabase Edge Function
- RevenueCat webhooks update your Supabase `subscriptions` table via a webhook endpoint
- You get a dashboard showing MRR, churn, trial conversion rate per product, per country

### Long-term: add web checkout (Stripe or Razorpay)

Once you build a web presence (landing page, PWA, or web app):
- US/Europe users: Stripe checkout (higher purchasing power, card-comfortable)
- Indian users: Razorpay (UPI is the dominant payment method, much higher conversion than cards)
- Both update the same Supabase `subscriptions` table via webhook
- Mobile app reads Pro status from Supabase on sign-in — no additional code needed

---

## Part 6 — What to Set Up in Google Play Console (for this app right now)

Since the Android package is `com.sagnikdas.sysd.app.sysdesign_flash`:

### Steps to create subscription products

1. **Play Console → Monetise → Products → Subscriptions → Create subscription**
2. Create 3 products:

   | Product ID | Name | Billing period | Price (USD) |
   |---|---|---|---|
   | `pro_monthly` | SysDesign Flash Pro — Monthly | Monthly | $5.99 |
   | `pro_annual` | SysDesign Flash Pro — Annual | Yearly | $35.99 |
   | `pro_lifetime` | (Do NOT create as subscription — use In-App Product instead) | — | — |

3. For `pro_lifetime` → go to **In-App Products → Managed Products → Create** (non-consumable, one-time purchase)

4. For each subscription, go to **Pricing → Countries/regions → Override** for India and other emerging markets

5. Add a **7-day free trial** to both `pro_monthly` and `pro_annual` (under Base Plan → Add offer → Free trial)

### Fix needed in the Flutter code before launch

In `BillingService.purchaseProduct()`, use `buySubscription()` for subscription products:

```dart
Future<void> purchaseProduct(ProductDetails product, {bool isSubscription = false}) async {
  final purchaseParam = PurchaseParam(productDetails: product);
  final started = isSubscription
      ? await _inAppPurchase.buySubscription(purchaseParam: purchaseParam)
      : await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  if (!started) throw Exception('Could not start purchase flow.');
}
```

And `SubscriptionRepository.purchaseByPlan()` passes `isSubscription: plan != SubscriptionPlan.lifetime`.

---

## Part 7 — Apple App Store Connect (for iOS)

1. **App Store Connect → Your App → Subscriptions → Create Subscription Group**
   - Group name: "Pro"

2. **Create subscriptions** within the group:

   | Product ID | Duration | Price (USD) | Level |
   |---|---|---|---|
   | `pro_monthly` | 1 month | $5.99 | 1 |
   | `pro_annual` | 1 year | $35.99 | 1 |

3. **Create In-App Purchase** (separate from subscriptions):
   - Type: Non-Consumable
   - Product ID: `pro_lifetime`
   - Price: $79.99

4. **Free trial**: In the subscription → Add Introductory Offer → Free → 7 days (for new subscribers only)

5. **Localizations**: Add display names and descriptions (required for App Review)

6. **Per-storefront pricing**: Override India, Brazil, SEA to local-friendly prices

---

## Summary: Decision Matrix

| Question | Answer |
|---|---|
| Can I use Stripe inside the iOS app? | No — App Store rules prohibit it |
| Can I use Stripe inside the Android app? | Technically yes via User Choice Billing (Google program, reduced fee), but complex to implement |
| Should I use Stripe at all? | Yes — but only for a web checkout page, not inside the app |
| Should I use Razorpay? | Yes — if you want Indian web users to pay via UPI |
| Should I use RevenueCat? | Strongly consider it — removes verify-purchase complexity and adds analytics |
| Should I do PPP pricing? | Yes — set India/Brazil/SEA prices from launch. It meaningfully increases conversion |
| What needs fixing before launch? | Fix `buyNonConsumable` → `buySubscription` for monthly/annual plans |
| Can I offer lifetime on both stores? | Yes — as a Non-Consumable In-App Purchase, not a subscription |
