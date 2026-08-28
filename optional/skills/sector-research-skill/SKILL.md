---
name: sector-research-skill
description: Use this skill when the user asks to analyze an investment sector/theme, build a public-company universe, rank candidates, and optionally create/update multiple Notion Assets pages using the structured asset template.
---

# Sector Research Skill

## Core Rules

- Do not fabricate companies, tickers, suppliers, customers, valuation metrics, market sizes, or thesis claims.
- Prefer primary sources and official filings/IR material; label source quality and uncertainty.
- Search Notion Assets before deciding create vs update for every company.
- Ask confirmation before creating/updating multiple Notion pages or making bulk changes.
- For existing assets, default to appending a dated sector update; never silently overwrite existing thesis/memo content.
- Keep domains narrow and specific; do not tag every adjacent theme.
- If primary sources are unavailable for an asset, either skip it or mark confidence Low.

## When To Use

Use when the user asks for:

- Sector/theme research, e.g. `AI optical transceivers`, `Japan robotics`, `nuclear supply chain`.
- Creating a watchlist from a sector.
- Comparing many companies in an ecosystem.
- Supplier/customer maps across an industry.
- Ranking sector candidates and creating multiple Notion Assets pages.

For one company only, use `asset-research-skill` instead.

## Required Clarification

Ask only blocking questions. Clarify if missing/ambiguous:

- Sector/theme and boundaries.
- Geography/market scope.
- Public companies only vs private ecosystem names allowed.
- Maximum number of companies/pages to create.
- Intent: watchlist, ranking, supplier map, valuation screen, earnings review, or deep-dive batch.
- Whether to create Notion pages after shortlist approval.

If the user gives a clear theme and no limit, assume public listed companies, global scope where relevant, and start with a shortlist of 5–10 candidates before asking for write confirmation.

## Workflow

### 1. Scope The Sector

Define:

- Sector thesis / demand driver.
- Value chain boundaries.
- Included/excluded subsegments.
- Geography, currency, and market focus.
- Known anchor customers/suppliers/regulators.

### 2. Build Initial Universe

Use source hierarchy:

Tier 1 — Primary:
- Company annual reports / 10-K / 20-F / securities reports.
- Quarterly results, investor presentations, transcripts.
- Official company websites and IR pages.
- Regulatory filings.

Tier 2 — Industry/ecosystem:
- Competitor filings.
- Supplier/customer disclosures.
- Government/regulatory docs.
- Credible industry reports.

Tier 3 — Secondary:
- News articles, analyst summaries, specialist blogs, market-data sites.

For each candidate capture:

- Company name, ticker, exchange, country, currency.
- Role in value chain.
- Why it is relevant to the theme.
- Main customers/suppliers/partners when source-backed.
- Market cap and revenue scale with source/date.
- Source confidence: Low / Medium / High.

### 3. Search Notion Assets First

For every shortlisted candidate:

1. Search Assets / Investments DB by company name and ticker.
2. If clear match: retrieve properties; read page body only if needed for update/comparison.
3. If multiple matches: stop and ask user to choose.
4. If no match: mark as create candidate.

Output a create/update/skip table before any writes.

### 4. Sector Map

Produce a concise sector overview:

- Value chain map.
- Demand drivers and cyclicality.
- Competitive structure and concentration.
- Customer/supplier power.
- Regulation/geopolitics.
- Technology shifts.
- Key risks and red flags.
- Source log.

### 5. Rank Candidates

Rank with an evidence-first scoring grid:

- Theme relevance: 0–20.
- Business quality / moat: 0–15.
- Financial quality: 0–15.
- Growth/catalysts: 0–15.
- Valuation / margin of safety: 0–15.
- Balance sheet / dilution risk: 0–10.
- Source confidence: 0–10.

Final score: 0–100 with confidence Low / Medium / High.

### 6. Parallel Asset Research

For 3+ assets, use subagents when helpful to avoid context bloat:

- Launch one subagent per asset or per small group.
- Instruct each subagent to return only structured facts, sources, bull/bear, valuation assumptions, exit triggers, and uncertainties.
- Main agent remains responsible for final synthesis, Notion writes, and avoiding duplicates.
- Do not let subagents write to Notion directly unless explicitly instructed and safe.

Subagent return format:

```md
## Asset
- Name / ticker / exchange / country / currency
- Business role in sector
- Key facts with sources
- Customers / suppliers / ecosystem with source quality
- Financial snapshot
- Valuation snapshot
- Bull case
- Bear case
- Buy modelisation assumptions
- Exit thesis / news to watch
- Proposed Notion properties
- Source log
- Confidence / unknowns
```

### 7. Propose Notion Changes

Before bulk writes, show:

```md
## Proposed Notion changes

Sector/theme:

Pages to create:
- Company — ticker — proposed Status/Market/Market Cap/Domain/Score

Pages to update:
- Company — ticker — properties to update — content action

Pages skipped / low confidence:
- Company — reason

Content format:
- Structured asset template with real columns and real Notion tables

Confirm?
```

Stop for confirmation before creating/updating multiple pages.

### 8. Write To Notion

For each confirmed asset:

- Use `asset-research-skill` Notion Assets Page Layout.
- Create real Notion `column_list`, `column`, `table`, and `table_row` blocks where supported.
- Include a real supplier/customer/ecosystem `table` block; do not use a dense paragraph or plain markdown pipe table unless the API genuinely cannot create table blocks.
- Include a numeric `Buy Modelisation / Market-cap scenarios` `table` block with starting-point, bear/base/bull, valuation, and action/trigger rows. Each scenario must flow logically from revenue basis → margin/profitability → valuation multiple/method → implied market-cap range. The `Implied market cap` cells must contain only market-cap ranges, not prose; put caveats and buy/hold/sell logic in `Action / trigger`.
- If page creation rejects nested table blocks, create the page first and then append the real tables with `Append block children`.
- Include `Exit thesis / News to watch`.
- Include `Sources` with tier labels, URLs, and uncertainty notes.
- Set only confirmed properties.

For existing assets:

- Default action: append dated sector update.
- Do not replace full memo unless user explicitly confirms replacement.
- Do not silently overwrite properties if user did not confirm them.

## Output Requirements

- Be concise but evidence-dense.
- Separate facts, assumptions, and interpretation.
- Cite source names/URLs next to important claims when possible.
- Include universe coverage limits and remaining unknowns.
- State confidence for sector overview and each asset.

## Stop Conditions

Stop and ask if:

- Sector boundaries are ambiguous enough to produce the wrong universe.
- Primary sources cannot be found for core candidates.
- Notion has multiple likely matches for a company.
- User requests broad/bulk Notion writes without confirmation.
- Requested action would overwrite, archive, delete, or materially replace existing content.
