---
name: asset-research-skill
description: Use this skill when the user asks to analyze, create, or update an investment asset/company in Notion Assets / Investments. Produces professional-grade, evidence-backed asset research and then creates or updates the matching Notion asset page after confirmation.
---

# Asset Research: $ARGUMENTS

## Arguments

Expected invocation:

```text
/asset-research-skill <asset/company/ticker> [intent/context]
```

Treat `$ARGUMENTS` as the user's requested asset identity and task context. Parse it before asking clarifying questions.

Examples:
- `/asset-research-skill Disco Corp 6146.T update thesis`
- `/asset-research-skill NVIDIA NVDA valuation refresh`
- `/asset-research-skill TSMC supplier/customer map`

If `$ARGUMENTS` includes a company name, ticker, exchange, country, or intent, carry those values into Step 1 below and do not ask for them again unless the identity remains ambiguous.

## Core Rules

- Do not fabricate figures, suppliers, customers, valuation metrics, or thesis claims.
- Prefer primary sources over secondary sources.
- Label source quality and uncertainty.
- Search Notion Assets first before deciding create vs update.
- Never silently overwrite an existing thesis or memo.
- Ask confirmation before creating/updating Notion properties or page content.
- Default content action for existing assets: append a dated research update.
- When writing/replacing an Assets / Investments page body, **must use the Notion Assets Page Layout / database visual template** below, with real Notion `column_list`, `column`, `table`, and `table_row` blocks wherever supported. Do not use a plain prose memo or markdown-style tables as the default Notion body.

## Notion Assets Schema

Use `notion-os-schema.md` and `config/notion-os.schema.json`.

Assets / Investments properties:
- `Name` — title
- `Status` — `Watchlist`, `IN`, `SELL`, `SKIP`
- `Market` — `Japan`, `Korea`, `USA`, `EU`, `China`, `Taiwan`
- `Market Cap` — text, e.g. `1B JPY`, `600m TWD`
- `Domain` — multi-select: `Semi-Conductor`, `DataCenter`, `Nuclear`, `Military`, `Optic`, `Photonic`, `AI`, `Robotics`, `Energy`, `Software`, `Healthcare`
- `Score` — number `0` to `100`
- `Last edited time` — last edited time

## Workflow

### 1. Clarify Asset Identity

Identify:
- Company name
- Ticker
- Exchange / country
- Currency
- User’s intent: new research, update, compare, earnings review, supplier/customer map, or valuation refresh

Ask only if ambiguity could cause researching the wrong company.

### 2. Search Notion First

Use Notion MCP:
1. Search Assets / Investments DB by company name and ticker.
2. If found, retrieve properties.
3. Read existing page content only if needed to update or compare thesis.
4. If creating/rebuilding an Assets page, inspect 1–2 existing Assets pages first to copy the proven database page style and supported block shapes.

Decision:
- No match → create workflow.
- Clear match → update workflow.
- Multiple matches → ask user to choose.

### 3. Research Source Hierarchy

Prioritize:

Tier 1 — Primary sources:
- Annual reports / 10-K / 20-F / securities reports
- Quarterly results and investor presentations
- Earnings transcripts
- Company website and official IR material
- Regulatory filings

Tier 2 — Industry and ecosystem:
- Competitor filings
- Supplier/customer disclosures
- Company-originated press releases distributed through PRNewswire (`https://www.prnewswire.com/`), especially for named supplier/customer awards, partnerships, contracts, and ecosystem evidence. Treat as stronger than generic news when the release is clearly issued by the company, but label date/relationship-currentness uncertainty.
- Industry reports
- Market size/regulatory docs

Tier 3 — Secondary sources:
- News articles
- Analyst summaries
- Specialist blogs
- Social media

Track sources using `templates/source-log.md`.

### 4. Analyze

Cover:
- Business model and revenue segments
- Customers and suppliers
- Competitive advantage / moat
- Financial performance and quality
- Balance sheet / dilution / cash flow
- Market structure and cyclicality
- Valuation and comparables
- Catalysts
- Risks and red flags
- Bull/base/bear cases

### 5. Score

Use `templates/scoring-rubric.md`.

Final score is 0–100 with confidence: Low / Medium / High.

### 6. Draft Memo

Use `templates/investment-memo.md` for research coverage, but when writing to Notion Assets **must use the user's database visual template / Notion Assets Page Layout below** rather than a long prose memo.

Memo must include:
- Executive summary
- Company overview
- Financial analysis
- Industry / market
- Supply chain / ecosystem
- Investment thesis
- Valuation
- Catalysts
- Risks
- Red flags
- Open questions
- Final view
- Source log

### 6.1 Notion Assets Page Layout

For newly created Assets / Investments pages, and for any confirmed material rewrite/recreate of an existing asset body, use the database's visual default-template style. This is mandatory for Notion writes, not optional. Do **not** write markdown pipe tables as plain paragraphs when a real Notion table block can be created.

Implementation requirement:
- Build the page body with real Notion blocks matching this template.
- Prefer the proven Assets database style used by existing pages: `heading_1` sections, `divider`, real `table` blocks, and `bulleted_list_item` blocks. Use `column_list`/`column` only if the MCP accepts them reliably; do not block the write solely because columns are unavailable when the existing database style is heading-based.
- For supplier/ecosystem and valuation sections, create real `table` blocks containing `table_row` children.
- Treat MCP tool schemas as not always exhaustive: even if `Append block children` appears to list only paragraph/bullet types, first try the full Notion block shape for `heading_1`, `divider`, `table`, and nested `table_row` children. This is the known working path for the Assets database.
- Use `Update page properties` / `patch-page` with a `properties` object for `Name`, `Status`, `Market`, `Market Cap`, `Domain`, and `Score` even if the visible wrapper schema does not list `properties`; this is known to work with the MCP.
- If the MCP rejects a full block shape, inspect an existing Assets page's block structure and mirror it before considering any fallback.
- Only fall back to paragraph/bullet approximations if the available integration genuinely cannot create these block types after attempting the supported Notion block shape. If forced to fall back, explicitly state the limitation and offer to convert later.

Default page body structure:

1. Top thesis section in the proven Assets style:
   - `heading_1`: `What do they do ?`
   - Concise business description, product/revenue segments, why it matters.
   - `heading_1`: `Bull Case`
   - Bullets with source-backed upside drivers.
   - `heading_1`: `Bear Case`
   - Bullets with source-backed downside drivers / red flags.
2. `heading_1`: `List of Suppliers`
   - `divider`
   - Use a real Notion `table` block. Do **not** leave this section as one dense paragraph.
   - Minimum table: 3 columns with a header row:
     - `Company name`
     - `Relation`
     - `Power / evidence`
   - Recommended rows: named customers, suppliers, distributors, partners, ecosystem players, and one `Unknown / not confirmed` row when a side of the supply chain is not source-backed.
   - Include only source-backed names. If supplier-side names are unknown, say so in the table; do not fabricate.
3. `heading_1`: `Buy Modelisation / Market-cap scenarios`
   - Use a real Notion `table` block. Do **not** leave this section as a long prose paragraph.
   - The modelisation must be numerically logical: each case should flow from revenue basis → gross margin → profitability/EBITDA or operating income → valuation multiple/method → implied market-cap range.
   - Minimum table: 7 columns with a header row:
     - `Case`
     - `Revenue basis`
     - `Gross margin`
     - `Profitability`
     - `Sales multiple` or valuation method
     - `Implied market cap`
     - `Action / trigger`
   - Include bear/base/bull/extreme-bull scenarios where appropriate.
   - Include a `Starting point` row showing current market cap, latest revenue/run-rate, current sales multiple, and source/uncertainty notes.
   - In scenario rows, `Revenue basis` must contain a concrete revenue or run-rate range (e.g. `$700–800m run-rate`, `FY2027 $1.0–1.2B`) and the valuation method must use a concrete multiple or method (e.g. `6–8x sales`, `15–20x EBITDA`).
   - The `Implied market cap` column must contain **only a market-cap range**, not prose (e.g. `$4.2–6.4B`, `¥80–100B`). Put interpretation, buy/hold/sell logic, and caveats in `Action / trigger`, not in `Implied market cap`.
   - Avoid fake precision. Use ranges when inputs are uncertain and label unverified assumptions in `Action / trigger` or nearby notes.
   - Include concrete buy-zone logic (e.g. market-cap levels or valuation thresholds) and downgrade/exit thresholds tied to results.
4. `heading_1`: `Exit thesis / News to watch`
   - Bullets for specific events/results that would invalidate or downgrade the thesis.
5. `heading_1`: `Sources`
   - Bullets with source tier, source name, what it supports, and URL.
   - Include uncertainty notes for time-sensitive market data and unconfirmed ecosystem details.

When creating pages via Notion MCP, create the page first, update properties with `patch-page`, then append real blocks with `Append block children` using Notion-compatible block objects. For tables, place nested rows under `table.children` and each row as `type: "table_row"` with `table_row.cells` arrays of rich-text arrays. Avoid appending plain-text markdown tables like `A | B | C` unless the MCP genuinely rejects real `table` blocks after trying the known working shape.

### 7. Propose Notion Changes

Before writing, show:

```md
## Proposed Notion changes

Mode: Create new asset / Update existing asset

Properties:
- Name:
- Status:
- Market:
- Market Cap:
- Domain:
- Score:

Content action:
- Create full memo / Append dated update / Replace full memo / Properties only

Confirm?
```

### 8. Write to Notion After Confirmation

Create workflow:
- Create asset page in Assets / Investments DB.
- Set proposed properties.
- Add content using the Notion Assets Page Layout above, with real columns and real tables. Treat the visual template as required for page-body creation.

Update workflow:
- Update confirmed properties only.
- Default to appending a dated research update.
- Replace full memo only if user explicitly confirms replacement.
- For material rewrites/recreates requested by the user, create or replace with the structured Notion Assets Page Layout above using real columns and real tables.

## Output Requirements

- Be concise but evidence-dense.
- Cite source names/URLs next to important claims when possible.
- Separate facts, assumptions, and interpretation.
- Include remaining unknowns and confidence.

## Stop Conditions

Stop and ask if:
- Asset identity is ambiguous.
- Primary sources cannot be found.
- Notion has multiple likely matching assets.
- User asks for an irreversible or broad update.
