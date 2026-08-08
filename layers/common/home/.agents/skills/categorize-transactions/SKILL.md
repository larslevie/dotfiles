---
name: categorize-transactions
description: Categorize uncategorized Actual Budget transactions by piggybacking on Actual's native rules engine, with an LLM layer for what rules miss and review before applying. Use when the user wants to auto-categorize transactions, clean up uncategorized Actual transactions, or after a Lunchflow sync (`just sync`).
---

# Categorize Actual Budget transactions

For the local Actual Budget in `~/actual-budget`. Two layers:
- **Layer 1 — native Actual rules** (created via `createRule`, visible/editable in the
  Actual UI). These auto-apply on every import, so most newly-synced transactions arrive
  already categorized. Scripts + `@actual-app/api` live in `~/actual-budget`; run from there.
- **Layer 2 — you (the model)**: classify what rules didn't catch, into the budget's
  existing categories. Confident, recurring merchants get promoted into a new native rule
  so the rules layer handles them next time.

Always review with the user before writing. Re-running is safe — only touches uncategorized.

## Workflow

1. **Scan** (from `~/actual-budget`): `node categorize/scan.mjs`. Writes
   `categorize/scan-output.json`: `categories` (valid targets), `ruleMatched` (uncategorized
   txns a native rule matches — usually few, since rules ran on import), `needLLM`, `summary`.

2. **Classify `needLLM`.** For each, pick a category by `id` from `categories`, using
   `payee`, `imported_payee`, `amount` (cents; negative=outflow, positive=inflow), `accountName`.
   Confidence high | medium | low; low → leave uncategorized.
   - **Transfers & card payments are NOT spending.** Payee containing autopay / RAUTOPAY /
     "online transfer" / "DDA to DDA" / Zelle / Venmo cashout / balance-transfer promo entries,
     or a positive amount on a credit-card account, are transfers. Do not categorize them —
     recommend recording them as Actual transfers between accounts instead.
   - **Investment contributions** (e.g. Betterment) → transfers to an off-budget investment
     account, not a spending category.

3. **Review.** Show the user counts grouped by category, plus the skipped transfers and
   low-confidence items with reasons, and the new rules you propose to author.

4. **Apply on approval.** Build `categorize/decisions.json` as `[{id, categoryId, categoryName}]`
   for the txns to categorize (include any `ruleMatched` too — native rules do NOT apply
   retroactively to already-imported transactions). Then `node categorize/apply.mjs`.

5. **Author rules** for confident recurring merchants: add `{category, patterns:[...]}`
   (optionally `matches:[...]` for regex) to `categorize/rules-seed.json`, then
   `node categorize/seed-rules.mjs` (idempotent). Future imports categorize them automatically.

## Helpers in `~/actual-budget/categorize/`
- `scan.mjs` — evaluate native rules against uncategorized backlog.
- `seed-rules.mjs` + `rules-seed.json` — create native Actual rules (idempotent).
- `build-decisions.mjs` + `llm-classify.json` — optional: codify merchant→category picks
  as a reusable map instead of hand-classifying each run. Emits decisions.json + a review.
- `apply.mjs` — write categories from decisions.json, then sync.
- `categories.mjs` — ensure the category taxonomy exists (idempotent).

## Notes & known limits
- Native rules apply on **import**, not retroactively. To categorize an existing backlog you
  must write categories explicitly (steps 1–4). New syncs arrive pre-categorized.
- **Bulk transfer conversion via the API is unreliable for many identical-amount transactions**
  (Actual's transfer auto-matching mints only some mirrors). For a large identical backlog
  (e.g. weekly investment contributions), finish in the Actual UI: multi-select the
  transactions → set payee to "Transfer: <account>". A native rule handles future single imports fine.
- Splits (`is_parent`), existing transfers (`transfer_id`), and starting balances are excluded.
