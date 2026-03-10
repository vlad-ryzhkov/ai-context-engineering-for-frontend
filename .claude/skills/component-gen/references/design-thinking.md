# Design Thinking — Phase 0 [`--design` only]

**Before generating styles**, scan project for existing design tokens:

1. Glob `tailwind.config.*` → if found, extract `theme.extend.colors` and `theme.extend.fontFamily`
2. Glob `src/**/*.css` + `src/**/*.scss` for `--` CSS custom properties → extract palette tokens
3. Use discovered tokens as base palette. Override only if user explicitly requests a new palette.

Answer all four questions in a short `<!-- design-brief -->` comment block at the top of the primary output file:

```text
Purpose:         What does this UI do / what problem does it solve?
Tone:            What emotion should it evoke? (e.g., "confident + minimal", "playful + energetic")
Constraints:     Brand tokens, palette restrictions, motion budget. (List discovered tokens here)
Differentiation: What named aesthetic direction? (e.g., brutalist, editorial, retro-futuristic, glassmorphism-lite)
                 FORBIDDEN to answer "modern and clean" — that is not a direction.
                 If description contains "modern and clean": MUST pick ONE named direction:
                 Swiss Typography, Apple-esque Glassmorphism, Scandinavian Flat, Brutalist Editorial,
                 Retro-Futuristic, Maximalist Chaos, Organic/Natural, Luxury/Refined,
                 High-Fashion Editorial (serif-heavy), Art Deco / Geometric.
```

If the description is too vague to answer Differentiation → ask ONE clarifying question.
