# HTML Report Format

The review is one self-contained HTML file in the OS temp directory. It must render offline and behind strict security policies, so it has **no scripts and no external resources**: no CDN, no web fonts, no images by URL. Styling is one inline `<style>` block; diagrams are inline SVG or plain divs.

## Scaffold

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Architecture review for {{repo name}}</title>
<style>
  :root { --ink:#0f172a; --muted:#64748b; --line:#cbd5e1; --paper:#fafaf9;
          --accent:#047857; --leak:#dc2626; --warn:#b45309; --deep:#1e293b; }
  body { margin:0; background:var(--paper); color:var(--ink);
         font:16px/1.5 ui-sans-serif, system-ui, sans-serif; }
  main { max-width:64rem; margin:0 auto; padding:3rem 1.5rem; }
  h1, h2 { font-family:ui-serif, Georgia, serif; }
  article { background:#fff; border:1px solid var(--line); border-radius:8px;
            padding:1.5rem; margin:2.5rem 0; }
  .badge { display:inline-block; font-size:.75rem; padding:.1rem .5rem; border-radius:999px; }
  .strong { background:#d1fae5; color:var(--accent); }
  .explore { background:#fef3c7; color:var(--warn); }
  .speculative { background:#e2e8f0; color:var(--muted); }
  .tag { background:#f1f5f9; color:var(--muted); }
  .files { font:13px/1.4 ui-monospace, monospace; color:var(--muted); }
  .pair { display:grid; grid-template-columns:1fr 1fr; gap:1rem; }
  .pair figure { margin:0; border:1px solid var(--line); border-radius:6px; padding:.75rem; }
  .pair figcaption { font-size:.75rem; text-transform:uppercase; letter-spacing:.08em; color:var(--muted); }
  svg { width:100%; height:300px; }
  svg text { font:11px ui-sans-serif, system-ui; text-transform:uppercase; letter-spacing:.06em; }
  .module { fill:#fff; stroke:var(--ink); }
  .deep-module { fill:var(--deep); stroke:var(--deep); }
  .seam { stroke:var(--muted); stroke-dasharray:4 4; }
  .edge { stroke:var(--ink); marker-end:url(#arrow); }
  .leak { stroke:var(--leak); stroke-width:2; }
  .adr { background:#fffbeb; border-left:3px solid var(--warn); padding:.5rem .75rem; }
</style>
</head>
<body>
<main>
  <header>...</header>
  <section id="candidates">...</section>
  <section id="top-recommendation">...</section>
</main>
</body>
</html>
```

Define the arrow marker once, as the first element in `<body>`, so every `.edge` in every diagram can use it:

```html
<svg width="0" height="0" style="position:absolute"><defs><marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto"><path d="M0,0 L10,5 L0,10 z"/></marker></defs></svg>
```

## Header

Repo name, date, and a compact legend: outlined box = module, dashed line = seam, red line = leakage, filled dark box = deep module. No introduction paragraph. Straight into the candidates.

## Candidate card

The diagrams carry the weight. Prose is sparse, plain, and uses the codebase-design vocabulary without ceremony.

Each candidate is one `<article>` with an `id`:

- **Title**: short, names the deepening (e.g. "Collapse the Order intake chain").
- **Badge row**: strength (`Strong` = `.strong`, `Worth exploring` = `.explore`, `Speculative` = `.speculative`), plus a `.tag` for the dependency category (`in-process`, `local-substitutable`, `ports & adapters`, `mock`).
- **Files**: `.files` list.
- **Before / after diagram**: the centrepiece, a `.pair` of two `<figure>`s. See patterns below.
- **Problem**: one sentence. What hurts.
- **Solution**: one sentence. What changes.
- **Wins**: bullets, 6 words or fewer each. e.g. "Tests hit one interface", "Discount stops leaking", "Delete 3 pass-through modules".
- **ADR callout** (if applicable): one line in an `.adr` box: _"Contradicts ADR-0007, but worth reopening because…"_

No paragraphs of explanation. If the diagram needs a paragraph to be understood, redraw the diagram.

## Diagram patterns

Pick the pattern that fits the candidate. Don't make every diagram look the same.

### Boxes and arrows (dependencies, call flow)

Modules as `<rect class="module">` with a `<text>` label, calls as `<line class="edge">`, leaks as `<line class="leak">`, seams as `<line class="seam">`. Before: the chain of thin boxes with red leak edges. After: one `.deep-module` rect with the former modules as faded labels inside it.

```html
<svg viewBox="0 0 320 300">
  <rect class="module" x="20" y="20" width="120" height="40"/><text x="30" y="45">Handler</text>
  <rect class="module" x="20" y="120" width="120" height="40"/><text x="30" y="145">Validator</text>
  <line class="edge" x1="80" y1="60" x2="80" y2="118"/>
  <line class="leak" x1="140" y1="140" x2="220" y2="200"/>
</svg>
```

### Cross-section (layered shallowness)

Stacked horizontal bands (`<div>`s with a left border, or SVG rects), one per layer a call passes through. Before: six thin layers each doing nothing. After: one thick band labelled with the consolidated responsibility.

### Mass diagram ("interface as wide as implementation")

Two rectangles per module: interface surface on top, implementation below. Before: the interface rectangle is nearly as tall as the implementation (shallow). After: a short interface over a tall implementation (deep).

### Call-graph collapse

Before: a tree of calls as nested boxes. After: the same tree inside one box, the now-internal calls drawn faded (`opacity:.35`).

## Style guidance

- Editorial, not a dashboard. Generous whitespace.
- Colour sparingly: the accent, red for leakage, amber for warnings.
- Diagrams about 300px tall, so before and after sit side by side without scrolling.
- Module labels in small uppercase, so they read as schematic, not as UI.

## Top recommendation section

One larger card. Candidate name, one sentence on why, an anchor link to its card. That's it.

## Tone

Plain English and concise, but the architectural nouns and verbs come from codebase-design. Wins name the gain in its terms: _"locality: bugs concentrate in one module"_, _"leverage: one interface, N call sites"_. Not _"easier to maintain"_ or _"cleaner code"_. No hedging, no throat-clearing. If a sentence could be a bullet, make it a bullet; if a bullet could be cut, cut it.
