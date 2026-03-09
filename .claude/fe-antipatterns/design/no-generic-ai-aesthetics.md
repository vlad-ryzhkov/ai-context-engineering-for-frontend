# Anti-Pattern: Generic AI Aesthetics

**Category:** design
**Grep signature:** `font-family.*Inter\|from-purple\|cookie.cutter\|modern.*clean`

---

## Problem

AI-generated UI defaults to a recognizable "AI slop" aesthetic:

- Neutral sans-serif fonts (Inter, Roboto, Arial)
- Purple-to-blue gradients on white backgrounds
- Uniform card grids with identical spacing
- Bootstrap-style `py-16 px-4` rhythms everywhere
- "Hero + 3 cards + CTA" layouts regardless of content

The result is visually indistinguishable from a hundred other generated pages. It communicates nothing about the product's identity.

---

## Banned Fonts (as primary display font)

| Font | Why banned |
|------|-----------|
| `Inter` | Default for every AI-generated UI. Zero differentiation. |
| `Roboto` | Material Design default. Signals no design intent. |
| `Arial` | Web fallback only. Never a design choice. |
| `system-ui` (sole stack) | Acceptable as body fallback, banned as display intent. |

**Fix:** Commit to a named font pairing that matches the aesthetic direction.

```css
/* ❌ BANNED */
font-family: Inter, system-ui, sans-serif;

/* ✅ Brutalist editorial */
font-family: 'Space Grotesk', monospace;

/* ✅ High-fashion editorial */
font-family: 'Playfair Display', 'EB Garamond', serif;

/* ✅ Retro-futuristic */
font-family: 'Orbitron', 'Share Tech Mono', monospace;

/* ✅ Clean technical (acceptable Inter usage — body only, display is different) */
/* display: 'Space Mono' — body: Inter */
```

---

## Banned Color Schemes

| Pattern | Why banned |
|---------|-----------|
| `bg-gradient-to-r from-purple-600 to-blue-500` | Every AI chatbot landing page. Zero signal. |
| `bg-white` + `text-gray-600` as sole palette | No visual identity. |
| Flat white background with no treatment | Lazy default, not an intentional choice. |

**Fix:** Commit to a named palette with rationale.

```jsx
// ❌ BANNED
<div className="bg-gradient-to-r from-purple-600 to-blue-500 text-white">

// ✅ Brutalist (high contrast, raw)
<div className="bg-black text-yellow-400 border-4 border-yellow-400">

// ✅ Editorial (muted, typographic)
<div className="bg-stone-100 text-stone-900">

// ✅ Retro terminal
<div className="bg-zinc-950 text-green-400 font-mono">

// ✅ Warm editorial
<div className="bg-amber-50 text-neutral-900">
```

---

## Banned Layout Patterns

| Pattern | Why banned |
|---------|-----------|
| `grid-cols-3` equal card grid as default | Predictable, no hierarchy |
| `py-16 px-4` on every section | Bootstrap muscle memory, not design |
| Hero → 3 feature cards → CTA → Footer | Generic SaaS template #1 |
| Full-width gradient hero with centered `h1` + `p` + button | Generic SaaS template #2 |

**Fix:** Use asymmetry, hierarchy, and named composition principles.

```jsx
// ❌ BANNED — cookie-cutter equal grid
<div className="grid grid-cols-3 gap-6 py-16 px-4">
  {features.map(f => <Card key={f.id} {...f} />)}
</div>

// ✅ Asymmetric editorial grid
<div className="grid grid-cols-12 gap-4">
  <div className="col-span-7">{/* featured item, larger */}</div>
  <div className="col-span-5 grid grid-rows-2 gap-4">{/* 2 supporting items */}</div>
</div>
```

---

## What IS an Acceptable Aesthetic Direction

Must be a named, describable aesthetic with clear rules:

| Direction | Typography | Color | Composition |
|-----------|-----------|-------|-------------|
| **Brutalist** | Heavy weight, uppercase, monospace | High contrast, raw black/yellow or black/white | Dense, overlapping, bordered |
| **Editorial** | Serif display, generous tracking | Muted neutrals, single accent | Whitespace-heavy, typographic hierarchy |
| **Retro-Futuristic** | Monospace, scanlines | Dark bg, neon accent (green, cyan, amber) | Terminal-inspired, grid-heavy |
| **Glassmorphism-lite** | Light weight sans, large sizes | Frosted translucency, color behind | Layered cards, blurred backdrops |
| **Swiss/International** | Helvetica Neue, tight grid | Limited palette, strong red or black | Mathematical grid, aligned axes |
| **Organic/Warm** | Rounded sans, humanist | Warm neutrals, terracotta, clay | Flowing sections, soft radii |

**FORBIDDEN direction:** "Modern and clean" — this is NOT a direction. It is the absence of a decision.

---

## Good Example (React)

```tsx
// design-brief:
// Purpose: Landing page for a developer CLI tool
// Tone: Confident, technical, slightly irreverent
// Constraints: Dark-mode first, monospace accent
// Differentiation: Retro-terminal — dark background, amber/green monospace, scanline texture

export function LandingHero() {
  return (
    <section className="bg-zinc-950 min-h-screen flex items-center relative overflow-hidden">
      {/* Scanline overlay — texture, not decoration */}
      <div className="absolute inset-0 bg-[repeating-linear-gradient(0deg,transparent,transparent_2px,rgba(0,255,0,0.03)_2px,rgba(0,255,0,0.03)_4px)] pointer-events-none" />

      <div className="relative z-10 max-w-5xl mx-auto px-8 py-24 grid grid-cols-12 gap-8 items-start">
        <div className="col-span-8">
          <p className="text-green-400 font-mono text-sm tracking-widest uppercase mb-4">
            $ version 2.0.0 — stable
          </p>
          <h1 className="font-mono text-6xl font-bold text-amber-400 leading-tight mb-6">
            Ship faster.<br />
            Break nothing.
          </h1>
          <p className="text-zinc-400 text-xl leading-relaxed max-w-xl mb-10">
            Context engineering for teams who care about output quality.
          </p>
          <div className="flex gap-4">
            <button className="bg-amber-400 text-zinc-950 font-mono font-bold px-8 py-3 hover:bg-amber-300 transition-colors">
              GET STARTED
            </button>
            <button className="border border-zinc-600 text-zinc-400 font-mono px-8 py-3 hover:border-zinc-400 hover:text-zinc-200 transition-colors">
              VIEW DOCS
            </button>
          </div>
        </div>

        <div className="col-span-4 font-mono text-xs text-green-400 bg-zinc-900 border border-zinc-700 p-6 leading-relaxed">
          <p className="text-zinc-500 mb-2"># quick start</p>
          <p><span className="text-amber-400">$</span> npx init-context</p>
          <p><span className="text-amber-400">$</span> /component-gen react AuthForm</p>
          <p><span className="text-zinc-500">✓ generated 12 files</span></p>
          <p><span className="text-zinc-500">✓ types: PASS</span></p>
          <p><span className="text-zinc-500">✓ lint: PASS</span></p>
        </div>
      </div>
    </section>
  )
}
```

---

## References

- Skill: `.claude/skills/component-gen/SKILL.md` (use `--design` flag)
- All anti-patterns: `.claude/fe-antipatterns/_index.md`
