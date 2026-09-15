# WWCA Website — Runbook

Project handoff / reference sheet. Last verified 2026-09-15.

Wyoming Weapons Collectors Association — built for the 38th Annual Memorial
Weekend Gun Show, Riverton WY, May 29–30, 2027. Static site on GitHub Pages,
edited through a Decap CMS panel, signed in via a small Cloudflare Worker.

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
| **OAuth worker** | https://wwca-auth.bcreates440.workers.dev |
| **GitHub account** | bcreates440 — owns the repo; every editor needs Write access on it |
| **Cloudflare account** | bcreates440@gmail.com — subdomain `bcreates440.workers.dev` |
| **GitHub OAuth App** | "WWCA Website Editor" — Client ID `Ov23lihrVHNljikNVeGW` |
| **Callback URL on file** | `https://wwca-auth.bcreates440.workers.dev/callback` — must match the worker exactly or login breaks |
| **Client secret** | Not recorded anywhere. Lives only as the Cloudflare Worker secret `GITHUB_CLIENT_SECRET`. Lost it? Regenerate on the OAuth App page, then `wrangler secret put GITHUB_CLIENT_SECRET` from `oauth-worker/`. |

---

## How it fits together

GitHub Pages hosts and builds the site for free but can't run any code of its
own — that's the one gap the Cloudflare Worker exists to fill. Everything
else is standard Jekyll.

**Signing in to the editor:**

```
Editor (/admin/)  →  Worker (wwca-auth.workers.dev)  →  GitHub (login + approve app)  →  Editor (signed in)
```

The worker's only job is this handshake: send the browser to GitHub, take
back the code GitHub issues, exchange it for a token, hand the token to the
editor. It never touches page content.

**Publishing a change:**

```
Editor ("Publish")  →  GitHub repo (new commit on main)  →  GitHub Pages (rebuilds, ~1 min)
```

Same path whether the commit comes from the editor or from a manual
`git push`. There is no separate deploy step — a push to `main` is a publish.

---

## File map

Jekyll builds everything except the two folders marked below, which are
deliberately kept out of git.

```
wwca-site/
├── _content/          the 8 pages — front matter + section "blocks"
├── _data/              site.yml, officers.yml, nav.yml — shared facts
├── _includes/         header, footer, block templates, jsonld
├── _layouts/          page.html — the one shell every page uses
├── css/styles.css     the whole site's styling, one file
├── images/            web-optimised photos — tracked in git
├── admin/             config.yml (CMS schema) + index.html
├── oauth-worker/      the Cloudflare Worker's own source
├── check.rb           *** run this before trusting any manual edit ***
├── README-EDITING.md  the in-repo how-to, aimed at a non-technical editor
├── images-original/           NOT in git — camera originals, local backup only
└── STRIDE-BACKUP-do-not-edit/ NOT in git — frozen old Stride Events copies
```

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
   WWCA Website Editor app — one click.

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

Ten commits, in order, each one keeping the site rendering identically to
the last before moving on.

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

---

## If it breaks

**Editor login fails**
- Confirm the worker's still deployed: `npx wrangler deployments list` in `oauth-worker/`
- Confirm both secrets are set: `npx wrangler secret list`
- Confirm the OAuth App's callback URL still exactly matches `.../callback`

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

Lighthouse: 100 / 100 / 100 / 100 · 10 commits · 8 pages · 12 section types

Bring this file to a fresh Claude session along with whatever's going
wrong — it has everything needed to pick the project back up cold.
