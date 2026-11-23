# inaudible.show

Jekyll site for the *inaudible* podcast.

## Development

```bash
bundle install
bundle exec jekyll serve
```

Production build:

```bash
bundle exec jekyll build
```

Deploys to GitHub Pages via `.github/workflows/jekyll.yml`.

## Image dimensions

Recommended sizes for assets in this theme:

### Site header (top banner)

| Asset | Config / file | Recommended dimensions |
|-------|----------------|------------------------|
| Desktop | `header_image` or default `assets/inaudible_hdr_2026.png` | **1920×300** (wide banner) |
| Desktop (optional srcset) | `header_image_srcset` in `_config.yml` | **960**, **1920**, **3840** px wide, same ~6.4∶1 aspect |
| Mobile | `mobile_header_image` or default `assets/mobile-logo.png` | **768×200** minimum; **1000×250** or **1536×400** @2× |

CSS limits header height to **300px** on desktop and **200px** on mobile (`object-fit: cover`). Design as a wide, shallow banner so crops look good.

### Social / link previews (Open Graph & Twitter)

| Use | Recommended dimensions |
|-----|-------------------------|
| Per-episode `image:` in front matter | **1200×630** (1.91∶1) |
| YouTube fallback (auto from embed) | **1280×720** (16∶9); meta uses YouTube `maxresdefault` |
| Site default | `default_share_image` in `_config.yml` — **1200×630** (`assets/inaudible_1200x630.png`) |

Prefer a dedicated **1200×630** share image over reusing the **1920×300** header; link previews crop to ~1.91∶1.

### Optional front matter on posts

```yaml
image: /assets/episodes/episode-71.jpg   # overrides YouTube thumbnail
youtube_id: dQw4w9WgXcQ                    # optional; auto-detected from embed if omitted
```

Priority: `image` → YouTube thumbnail → `default_share_image`.

### Footer contact email

`assets/email.png` — generated from the site email (see `_plugins/jekyll-email-obfuscator.rb` or committed copy for GitHub Pages). Display size is ~**320×24** logical px; exact file dimensions are not critical.

### Favicon

`assets/favicon.svg` — vector; no fixed size. Browsers render at **16×16–32×32**. For Apple touch icons, add **180×180** PNG if needed.

### Sidebar logos

SVGs such as `assets/smce-logo.svg` — use a comfortable artboard (**280–400** px wide); CSS sets `max-width: 100%` in the sidebar.

### YouTube embeds (in post body)

**16∶9** content (e.g. **1280×720**). Iframes in posts are often **560×315** but scale with the layout.

### Quick reference

| Role | Size |
|------|------|
| Desktop header | 1920×300 |
| Mobile header | 768×200+ |
| Share / `image:` / default share | **1200×630** |
| YouTube thumbnail (automatic) | 1280×720 |

## Posts

- Categories: use **lowercase** kebab-case (e.g. `service`, `mated-relationships`) so `jekyll-archives` does not create duplicate category URLs.
- Excerpts: `<!-- more -->` before media (or after two paragraphs when there is no media).