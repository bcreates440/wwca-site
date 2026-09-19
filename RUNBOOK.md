# WWCA Website — Runbook

Project handoff / reference sheet. Last verified 2026-09-19.

Wyoming Weapons Collectors Association — built for the 38th Annual Memorial
Weekend Gun Show, Riverton WY, May 29–30, 2027. Static site on GitHub Pages,
edited through a Decap CMS panel, signed in via a Cloudflare Worker shared
across every client site's editor (this one and others) — see
[client-sites-auth](https://github.com/bcreates440/client-sites-auth). New
client sites now start from [client-site-template](https://github.com/bcreates440/client-site-template)
instead of copying this repo.

**Status:** Site live · Editor live & tested · Domain not yet pointed · 2027
prices not yet set

---

## Quick reference

Everything needed to find or touch any part of the system. Nothing secret is
written down here — where a real secret exists, this says where it lives
instead.

| | |
|---|---|
| **Live site (current)** | https://bcreates440.github.io/wwca-site/ |
| **Live site (future)** | wyomingweaponscollectors.com — domain not pointed yet, see [Pending tasks](#pending-tasks) |
| **Editor** | https://bcreates440.github.io/wwca-site/admin/ |
| **GitHub repo** | https://github.com/bcreates440/wwca-site — public, branch `main` |
| **OAuth worker** | https://client-sites-auth.bcreates440.workers.dev — shared with other client sites, source at [bcreates440/client-sites-auth](https://github.com/bcreates440/client-sites-auth), not in this repo |
| **GitHub account** | bcreates440 — owns the repo; every editor needs Write access on it |
| **Cloudflare account** | bcreates440@gmail.com — subdomain `bcreates440.workers.dev` |
| **GitHub OAuth App** | "Client Sites Editor" — Client ID `Ov23liS5WT0Vsuo6CDze` — shared, not WWCA-specific |
| **Callback URL on file** | `https://client-sites-auth.bcreates440.workers.dev/callback` — must match the worker exactly or login breaks |
| **Client secret** | Not recorded anywhere. Lives only as a secret on the `client-sites-auth` Cloudflare Worker. Lost it? Regenerate on the OAuth App page, then `npx wrangler secret put GITHUB_CLIENT_SECRET --name client-sites-auth` from anywhere. |

---

## How it fits together

GitHub Pages hosts and builds the site for free but can't run any code of its
own — that's the one gap the Cloudflare Worker exists to fill. Everything
else is standard Jekyll.

**Signing in to the editor:**

```
Editor (/admin/)  →  Worker (client-sites-auth.workers.dev)  →  GitHub (login + approve app)  →  Editor (signed in)
```

The worker's only job is this handshake: send the browser to GitHub, take
back the code GitHub issues, exchange it for a token, hand the token to the
editor. It never touches page content, and it has no idea which repo it's
signing someone into — that's enforced by GitHub's own collaborator
permissions on this repo, which is what makes it safe to share the same
worker across every client site.

**Publishing a change:**

```
Editor ("Publish")  →  GitHub repo (new commit on main)  →  GitHub Pages (rebuilds, ~1 min)
```

Same path whether the commit comes from the editor or from a manual
`git push`. There is no separate deploy step — a push to `main` is a publish.

---

## File map

Jekyll builds everything except the folders and files marked below.
`images-original/` and `STRIDE-BACKUP-do-not-edit/` are kept out of git
entirely; `RUNBOOK.md` is tracked but excluded from the Jekyll *build* via
`_config.yml` — it used to leak onto the live site as `/RUNBOOK.html` before
that exclusion was added.

```
wwca-site/
├── _content/          the 6 pages — front matter + section "blocks"
├── _data/              site.yml, officers.yml, nav.yml — shared facts
├── _includes/         header, footer, block templates, jsonld
├── _layouts/          page.html — the one shell every page uses
├── css/styles.css     the whole site's styling, one file
├── images/            web-optimised photos — tracked in git
├── admin/             config.yml (CMS schema) + index.html
├── check.rb           *** run this before trusting any manual edit ***
├── README-EDITING.md  the in-repo how-to, aimed at a non-technical editor
├── RUNBOOK.md          this file — in git, excluded from the built site
├── images-original/           NOT in git — camera originals, local backup only
└── STRIDE-BACKUP-do-not-edit/ NOT in git — frozen old Stride Events copies
```

The 6 pages are index, show, vendors, membership, about, contact — see
`_data/nav.yml` for the exact list. Vendors and Youth are one page
(`vendors.html`, youth content under the `#youth` anchor); there's no
separate Gallery page — photos live in a carousel on the home page at
`index.html#gallery`.

---

## Editing — two ways in

Which one to use depends on whether it's a change to the words, or a change
to how the site is built.

### Content changes
Prices, dates, officers, photos, wording — anything a non-technical editor
should be able to do alone.

1. Open `/admin/`, sign in with GitHub
2. Open a page, edit the section
3. Click **Publish**
4. Live in about a minute

### Structural changes
A new kind of section, a template change, anything that touches
`_includes/` or `admin/config.yml`.

1. Edit the files directly
2. Run `ruby check.rb` — must say `ALL CHECKS PASSED`
3. `git commit` & `git push`
4. GitHub Pages rebuilds automatically

**Local preview** (needs Ruby, which isn't on PATH by default in a fresh
PowerShell window — Ruby 3.3 lives at `C:\Ruby33-x64` on this machine):

```powershell
$env:PATH = "C:\Ruby33-x64\bin;" + $env:PATH
bundle exec jekyll serve
# then open http://localhost:4000
```

---

## Adding an editor

The `/admin/` link alone does nothing for someone without repo access —
Decap checks real GitHub permissions.

1. They create a free GitHub account and **verify the email** — the next
   step's invite won't complete until they do.
2. You add them at github.com/bcreates440/wwca-site/settings/access →
   **Add people** → their username or email.
3. Give them **Write** access, not Admin — enough to edit and publish, not
   to change repo settings.
4. They accept the email invite, then open `/admin/` and click
   **Login with GitHub**. First time, GitHub also asks *them* to approve the
   Client Sites Editor app — one click.

---

## Things that will bite you

Non-obvious facts, in order of how much they'll hurt.

**Rule #1 — Decap deletes what its schema doesn't know about.**
The editor rewrites a whole page from the field list in `admin/config.yml`
every time it saves. Add a field to a block's template without adding it to
that schema, and the next save through the editor silently throws it away.
This is what `check.rb` exists to catch — it walks every page and fails
loudly if any field isn't described. Run it after any manual template
change, before pushing.

- **CSS path** — `css/styles.css` refers to the hero photo as
  `../images/hero.jpg`. A stylesheet's `url()` is relative to the stylesheet,
  not the page — move that file and this line needs fixing.
- **Table rows** — rows in a Table block are one pipe-separated string each
  (`1st | Connor K. | Pellet rifle`), not nested arrays. That's deliberate —
  it's what lets Decap's plain list widget edit them at all.
- **nav.yml** — `_data/nav.yml` holds its list under an `items:` key rather
  than as a bare list — Decap can't edit a file whose top level is a list.
- **Shortcuts** — typing `[[phone]]`, `[[email]]`, `[[venue]]`, `[[cap]]`,
  `[[tickets]]` etc. inside body text pulls the real value from
  `_data/site.yml` via `_includes/md.html`. Don't hand-type a fact that
  already has a shortcut — it's how one edit updates the whole site.
- **No Netlify** — Decap's own docs no longer list Netlify as an OAuth
  provider — that's why this uses a Cloudflare Worker instead of the more
  commonly-documented Netlify proxy.
- **Token expiry** — the GitHub OAuth App has **"Expire user access tokens"
  unchecked**, on purpose — the worker only implements the first token
  exchange, not GitHub's refresh flow. Check that box and logins start
  silently failing after 8 hours.
- **Gallery vs. carousel** — two different photo block types. "Photo gallery"
  grids photos with captions underneath (still used for the youth range
  photos on `vendors.html`). "Photo carousel" is the newer type — same photo
  fields, but no caption field and it scrolls instead of gridding (used for
  the homepage's Photo Gallery section). Same underlying photo list shape,
  different template — don't add a `caption:` to a carousel block, it has no
  field for it.
- **Cross-page anchors** — `vendors.html#youth` and `index.html#gallery` are
  linked from several other pages (show, membership, about). If you rename
  either section's `id:` in the editor, grep the repo for the old anchor
  before publishing, or those links silently land at the top of the page
  instead of the right section.
- **Editing live while someone pushes from a terminal** — the CMS editor and
  a manual `git push` both write straight to `main`. Do them at the same
  time and you get a real git merge to resolve, not just a `check.rb`
  failure. Happened once already (2026-09-16) — four editor autosaves landed
  mid-session and had to be merged back in by hand.

---

## Pending tasks

- **Domain** — wyomingweaponscollectors.com still points at the old Joomla
  site. Next action: repo → Settings → Pages → add custom domain, then two
  DNS records at the registrar. Same-day change, not urgent.
- **2027 prices** — admission and table rates aren't set — the board hasn't
  decided, and the table-rental contract is still unsettled. Marked
  `KEEP-UNTIL-PRICED` on the Admission card (show.html) and the "What a
  table costs" card (vendors.html). 2026 figures are in the card's
  editor-only comment for reference.
- **Client access** — WWCA's own editor hasn't been added as a repo
  collaborator yet. See "Adding an editor" above once they have a GitHub
  account.

---

## Every year: rolling over to the next show

The full checklist lives in `README-EDITING.md` at the repo root — it's
written for a non-technical editor and covers dates, the Stride Events
links, prices, the poster, the "save these dates" table, youth results and
the sitemap. Most of it now happens in **Site-wide details** inside the
editor rather than in individual files.

---

## Build history

The meaningful milestones, in order — each one kept the site rendering
identically to the last before moving on. Day-to-day content edits made
through `/admin/` aren't listed individually.

**Foundation**
- `c36a4e4` Snapshot of the original hand-built, self-contained HTML
- `dd5046a` Extracted the duplicated style block into one `css/styles.css`

**Jekyll conversion**
- `f6306ea` One shared header, footer and page layout

**Block content model**
- `b033224` Built the section-block system; converted 3 of 8 pages
- `90a2132` Converted contact, youth, vendors
- `792562f` Converted show and index — all 8 pages block-based

**CMS + login**
- `b2110b0` Added the Decap CMS schema and `check.rb`
- `ffed1d0` Verified a CMS save round-trips with zero data loss
- `df32be6` Added the Cloudflare Worker for GitHub OAuth
- `bc987fc` Pointed the site at the deployed worker — login tested live

**Nav & page consolidation**
- `4512adf` Added this runbook as a project handoff sheet
- `f2ea66a` Trimmed the nav from 8 pages to 6 — dropped Home (the logo
  covers it), merged Vendors + Youth into one page, replaced the standalone
  Gallery page with a caption-free carousel on the home page; also fixed the
  Tickets button wrapping onto its own row under the nav links
- `539536f` Merged four concurrent live-editor saves to `index.html` back
  into `main` alongside the above — see "Editing live while someone pushes
  from a terminal" under [Things that will bite you](#things-that-will-bite-you)

**Shared infrastructure**
- `e967b92` Migrated the editor's login off WWCA's own `wwca-auth` worker
  onto a shared worker (`client-sites-auth`) used by other client sites too;
  the old worker and its `oauth-worker/` folder in this repo are retired

---

## If it breaks

**Editor login fails**
- Confirm the shared worker's still deployed: `npx wrangler deployments list --name client-sites-auth`
- Confirm both secrets are set: `npx wrangler secret list --name client-sites-auth`
- Confirm the OAuth App's callback URL still exactly matches `.../callback`
- These affect every client site sharing the worker, not just WWCA — see
  [client-sites-auth](https://github.com/bcreates440/client-sites-auth)'s own
  README for its full troubleshooting steps.

**Site won't update**
- Check the build log: repo → Actions or Deployments tab
- A red build usually means a Jekyll/Liquid syntax error in the last commit

**A field vanished**
- Almost always: it's missing from `admin/config.yml`
- Run `ruby check.rb` locally — it names the exact field

**Local preview won't start**
- Ruby isn't on PATH by default — see the command block under Editing
- Then `bundle exec jekyll serve`

---

Lighthouse: 100 / 100 / 100 / 100 · 6 pages · 13 section types

Bring this file to a fresh Claude session along with whatever's going
wrong — it has everything needed to pick the project back up cold.
