# WWCA Website — How to Edit It

There are three ways to change this website. Almost always you want the first.

| | Who it is for | How |
|---|---|---|
| **The website editor** | Anyone | Go to **wwcashow.com/edit/**, sign in with GitHub, click the words or pictures you want to change, press **Publish**. |
| **The advanced editor** | Anyone, for the odd setting the first one doesn't show | **wwcashow.com/admin/** - a form for every setting. Same sign-in. |
| **The files** | Someone comfortable with a text editor | Edit the files in this folder and push to GitHub. |

Whichever you use, the website rebuilds itself and is live about a minute later.
There is nothing to upload.

---

## Using the website editor

Open **/edit/** and sign in. You'll see your real page.

### Changing words and pictures

- **Click any words** and type. Press **Enter** when you're done, or **Esc** to
  cancel.
- **Click any picture** and choose **Replace picture**. The editor makes it the
  right size for you, so a photo straight off your phone is fine.
- After a new picture, fill in (or check) its **description** - that's what a
  blind visitor hears and what Google reads.
- Anything you can't click - a link's destination, a colour choice - is in the
  **settings panel** on the right, which opens when you click the section.

### Sections

A page is a stack of sections. Point at one and a small toolbar appears:
**Move up**, **Move down**, **Duplicate**, **Remove**, **Settings**, and
**+ Add section below** (which shows every kind of section to pick from).

### Pages, menu and contact details

- **Page** (top left) switches pages. **+ Add a page...** at the bottom of that
  list makes a new one and can put it in the menu for you.
- **Page settings** is the page's title and description for Google, with a
  preview of how it will look there. **Delete this page** is at the bottom.
- **Site-wide...** is everything that appears on every page: contact details,
  the menu, and so on.

### Publishing

Nothing goes live until you press **Publish**. Until then your changes are kept
on your computer - close the tab and they'll be offered back to you next time.
**Undo** takes back any step.

If something's missing (an empty heading, a picture without a description),
Publish tells you what and takes you to it.

Changed something by mistake after publishing? **History** shows every earlier
version of the page. Look at one, press **Restore this version**, then Publish.

### The shortcuts

Inside any piece of writing you can type these, and they fill themselves in
from **Site-wide details**:

| Type this | You get |
|---|---|
| `[[phone]]` | (307) 349-4914 |
| `[[email]]` | WWCA@wyoming.com |
| `[[org]]` | Wyoming Weapons Collectors Association |
| `[[address]]` | P.O. Box 204, Lander, WY 82520-0204 |
| `[[venue]]` | Fremont County Fairgrounds |
| `[[dates]]` | May 29-30, 2027 |
| `[[cap]]` | 245 |
| `[[year]]` / `[[ordinal]]` | 2027 / 38th |
| `[[tickets]]` `[[vendors]]` `[[join]]` | the three Stride Events links |

Use them wherever you can. It means next year's changes happen in one place
instead of forty.

### Photographs

In the website editor, pictures are resized for you. **In the advanced editor
they aren't**: resize a photo to about 1000px on its longest edge before you
upload it there. A straight-off-the-phone photo is roughly ten times bigger
than the page needs and will make the site slow.

Either way, give every picture a description that says what's in it. Be
specific and skip generic filler.

---

## What changed, and why

The site used to be eight separate HTML files, each carrying its own copy of the
styling, the header and the footer. Changing a phone number meant finding it in
twenty places across nine files.

Now:

| | Where it lives |
|---|---|
| All styling | `css/styles.css` — one file |
| Header and footer | `_includes/header.html`, `_includes/footer.html` — one copy each |
| Phone, address, show dates, Stride links | `_data/site.yml` — one place |
| Officers and directors | `_data/officers.yml` — used by two pages |
| The navigation menu | `_data/nav.yml` — feeds the top menu and the footer |
| The words on each page | `_content/` — one file per page |

The copyright year in the footer and the "days until the doors open" counter
work themselves out. Nobody has to remember them.

---

## The folders

```
_content/     the eight pages - the words
_data/        facts used across the whole site
_includes/    header, footer, and the section designs
_layouts/     the shape every page shares
admin/        the website editor
css/          all the styling
images/       every photograph on the site
_site/        the built website (created automatically - never edit this)
```

Two folders are **not** part of the website and are deliberately kept out of
GitHub:

- `images-original/` — the full-size camera originals, kept as a backup
- `STRIDE-BACKUP-do-not-edit/` — the old Stride Events copies, frozen

---

## Editing the files directly

### Preview it on your own computer

```
bundle exec jekyll serve
```

Then open **http://localhost:4000**. It rebuilds as you save.

### Before you push: run the check

```
ruby check.rb
```

It prints `ALL CHECKS PASSED` or tells you exactly what is wrong. It checks:

- **that the editor will not delete anything** (see the warning below)
- every `[[shortcut]]` was filled in
- every photograph referenced actually exists
- every internal link goes to a real page
- exactly one main heading per page
- no two pages share a title or description
- every page is listed in `sitemap.xml`

### ⚠ The one rule when editing files by hand

**The website editor rewrites a page from the field list in
`admin/config.yml`.** If you add a new setting to a page by hand and do not add
it to `admin/config.yml`, then the next time someone saves that page in the
editor, **your setting is silently deleted**.

`ruby check.rb` catches exactly this. Run it.

---

## Common jobs

### Roll the site over to the next show

Nearly all of this is now one screen. In **Site-wide details**:

1. **Which show this is** — 38th becomes 39th
2. **Show year**, **Show dates**, **First day of the show**
3. **The three Stride Events links** — paste the new year's URLs
4. **Table limit**, if it changed

Then:

5. **Poster** — upload the new one and point `share_image` at it
6. **Future dates table** — the "Save these dates" section on the 2027 Show page
7. **Youth results** — the "Top marksmen" table on the Youth page
8. **Photos** — add the new year's pictures to the Gallery page
9. **`sitemap.xml`** — update the `<lastmod>` dates
10. Run `ruby check.rb`

### Fill in the 2027 admission and table prices

These were deliberately left unpriced — the board had not set them, and the
association moved to rented tables after the 2026 show.

- **Admission**: 2027 Show page → the "Admission" card
- **Table rates**: Vendors page → the "What a table costs" card

Both cards have a **Note to future editors** containing the 2026 figures and
the word `KEEP-UNTIL-PRICED`. Replace the card text with the real numbers and
clear that note.

### Update the officers after an election

**Site-wide details → Officers & Board.** Both the About page and the Contact
page follow automatically.

One thing does not: the machine-readable copy Google reads, in
`_includes/jsonld/about.html`. Update the names there too, or Google keeps
showing the old board.

### Add a new page

1. **Pages → New Page** in the editor.
2. Set the **File name** (`sponsors`) and **Web address** (`/sponsors.html`).
3. Fill in the tab title and search description, then build it from sections.
4. Add it to **Site-wide details → Navigation menu** so people can find it.
5. Add it to `sitemap.xml`.

---

## Changing how the site looks

Everything is set at the top of `css/styles.css`:

```css
:root{
  --navy:#14264F;  --red:#C8202E;  --cream:#F7F5F0;
  --font:system-ui, ...;
  --wrap:1180px;
}
```

Change `--red` and every button, heading accent and link changes with it,
across the whole site.

One catch: `css/styles.css` refers to the hero photo as `../images/hero.jpg`.
Paths in a stylesheet are relative to the stylesheet, not the page. If you ever
move that file, that line needs fixing.

---

## The SEO that is already in place

You do not need to maintain any of this, but it is worth knowing it is there:

- A unique title and description per page, written for humans.
- Open Graph tags, so a link pasted into Facebook shows the poster and a proper
  headline instead of a bare URL.
- Machine-readable event data (`JSON-LD`) giving Google the show name, dates,
  venue and ticket link — this is what can put the show in Google's event
  listings. **Keep the dates in it in step with the page.**
- The association's name, address and phone identical in the footer of every
  page — now guaranteed, because there is only one footer.
- Every photograph has descriptive alt text.
- `sitemap.xml` and `robots.txt`.

All eight pages scored **100 for SEO, accessibility and best practices** in
Google Lighthouse before the restructure, and render identically after it.
