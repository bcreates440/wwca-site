# WWCA Website — How to Edit It

Eight plain HTML pages. No build step, no framework, no database. Open a file in
any text editor, change the words, save, upload. That is the whole system.

---

## What's in this folder

| File | What it is |
|---|---|
| `index.html` | Home |
| `show.html` | 2027 show details, schedule, raffles, lodging |
| `vendors.html` | Table rates, the 245 cap, vendor rules, volunteering |
| `membership.html` | Dues, benefits, how to join |
| `youth.html` | Youth shooting range and the NWTF partnership |
| `gallery.html` | Photo gallery |
| `about.html` | Mission, officers, board, non-profit standing |
| `contact.html` | Officers, phone numbers, mailing address, venue |
| `_template.html` | Blank page to copy when adding a 9th page |
| `sitemap.xml` | Tells Google which pages exist |
| `robots.txt` | Points search engines at the sitemap |
| `check.sh` | Catches mistakes before you upload (see below) |
| `COPY-A-PAGE.bat` | Puts a page's HTML on your clipboard |
| `images/` | Logo, hero, poster, and 25 show photographs — **web-optimised** |
| `images-original/` | The full-size originals. Not used by the site. Keep as a backup. |

### About the images

The photos came off a phone at 4032px wide and were being displayed at about
400px. The homepage alone was pulling **14.4 MB**. They have been resized and
recompressed to **2.58 MB for the whole site** — the homepage is now 1.26 MB.

Nothing on screen looks any different; there were simply four times more pixels
in the files than any screen could show.

If you add a new photo, resize it to about **1000px on its longest edge** before
you put it in `images/`. A 3 MB phone photo will undo this.

Note: the hero background is now `images/hero.jpg` (it was `hero.png` — a photo
saved as a PNG, which made it five times bigger than it needed to be).

Every page is **fully self-contained** — the styling is inside each file, so you
can paste one page into a website builder and it just works.

---

## The first place to look in any page

Open any `.html` file and scroll to just after `<body>`. There is a block like this:

```html
<!-- =========================================================================
     EDIT: SHOW FACTS ON THIS PAGE
       Dates ............ "May 29-30, 2027"  - page head, Details table, JSON-LD
       Show hours ....... Details table, "Weekend schedule" list
       Admission ........ "Admission" card
     ========================================================================= -->
```

It lists every date, price and time on that page and where each one appears.
Read it first and you will not miss a copy of something.

---

## Common jobs

### Change a date, price or phone number

Use your editor's Find and Replace **across all files in this folder**. Numbers
appear in more than one place on purpose (a phone number is in the page body,
the footer, and the machine-readable data for Google).

Watch out for phone numbers — they appear in two formats and **both** must change:

```html
<a href="tel:+13073494914">(307) 349-4914</a>
      ^^^^^^^^^^^^^^ this one                ^^^^^^^^^^^^^^ and this one
```

### Fill in 2027 admission and table prices

These were deliberately left unpriced, because the board had not set them and
the association moved to rented tables after the 2026 show.

- Admission: `show.html`, search for `KEEP-UNTIL-PRICED`
- Table rates: `vendors.html`, search for `KEEP-UNTIL-PRICED`

In both places you will find a comment holding the 2026 figures, already
formatted. Delete the "to be announced" paragraph, un-comment the list, put the
real numbers in.

### Add a photo to the gallery

1. Put the image file in `images/`.
2. Open `gallery.html`, find any `<figure>` block, copy it.
3. Change the `src`, the `alt` text and the caption.

Always write real `alt` text describing what is in the picture — it is what
blind visitors hear and what Google reads. "Gun show photo" is a wasted line;
"Overhead view of the Fremont Center show floor" is not.

### Update the officers after an election

`about.html` (two sections: Officers and Board of Directors) and `contact.html`.
On **both** pages there is also a block of machine-readable data near the top,
inside `<script type="application/ld+json">` — update the names there to match,
or Google will keep showing the old ones.

### Roll the site over to the next show

After the 2027 show, work through this list:

1. **Dates** — find `May 29` and `2027` across all files.
2. **Show number** — find `38th Annual`, change to `39th Annual`.
3. **Stride links** — find `strideevents.com`. All three links contain `/2027/`
   in the URL and will need the new year's links pasted in.
4. **Countdown** — `index.html`, near the bottom, the line with
   `new Date("2027-05-29T09:00:00-06:00")`.
5. **Prices** — admission on `show.html`, tables on `vendors.html`.
6. **Deadline** — find `March 15, 2027` (appears several times on `vendors.html`).
7. **Poster** — replace `images/poster-2027.jpg` with the new one, then find
   `poster-2027.jpg` across all files.
8. **Future dates table** — `show.html`, "Save these dates".
9. **Youth results** — `youth.html`, the "Top marksmen" table.
10. **Photos** — add the new year's pictures to `gallery.html`.
11. **Sitemap** — update the `<lastmod>` dates in `sitemap.xml`.
12. **Run `check.sh`** (below).

---

## Changing how the site looks

All the colours, fonts and spacing are defined once at the top of the style
block in each page:

```css
:root{
  --navy:#14264F;  --red:#C8202E;  --cream:#F7F5F0;
  --font:system-ui, ...;
  --wrap:1180px;
}
```

Change `--red` and every button, heading accent and link on that page changes
with it.

### The one catch with self-contained pages

Because each page carries its own copy of the styling, **a style change has to be
copied into all 8 files.** Three blocks are byte-identical in every page:

- `SITE STYLES` — everything between the `===== SITE STYLES v1` comment and
  `===== END SITE STYLES`
- `SITE HEADER` — the logo and navigation bar
- `SITE FOOTER` — the whole footer

To change one of them: edit it in a single page, then copy that block over the
top of the same block in the other seven.

The header has **one intentional difference** per page — the current page's nav
link carries `aria-current="page"`, which draws the red underline. When you copy
the header across, move that attribute to the right link for each page.

Then run `check.sh`, which exists precisely to catch the file you forgot.

---

## Before you upload: run the check

```sh
sh check.sh
```

It verifies:

- the three shared blocks really are identical in all 8 pages
- no external stylesheet or script crept in (which would break the self-contained rule)
- every image referenced actually exists in `images/`
- every internal link points at a real file
- exactly one `<h1>` per page
- no two pages share a title or description
- every page is listed in `sitemap.xml`

It prints `ALL CHECKS PASSED` or tells you exactly which file is wrong.

---

## Adding a new page

1. Copy `_template.html` and rename it (e.g. `sponsors.html`).
2. Fill in the placeholders in the `<head>` — title, description, canonical URL.
3. Write the content. The template lists every layout block you can use.
4. Add a link to it in the `SITE HEADER` nav **on all 8 pages**, and in the
   `SITE FOOTER` "Explore" list **on all 8 pages**.
5. Add a `<url>` entry to `sitemap.xml`.
6. Run `check.sh`.

---

## The SEO that is already in place

You do not need to maintain any of this, but it is worth knowing it is there:

- A unique title and description per page, written for humans.
- Open Graph tags, so a link pasted into Facebook shows the poster and a proper
  headline instead of a bare URL.
- Machine-readable event data (`JSON-LD`) on `show.html` giving Google the show
  name, dates, venue and ticket link — this is what can make the show appear in
  Google's event listings. **Keep the dates in it in sync with the page.**
- Organization data on `index.html` with the address, phone and Facebook link.
- The association's name, address and phone identical in the footer of all 8
  pages. Search engines use that consistency to rank local results, so if the
  address changes, change it everywhere.
- Every image has descriptive alt text and explicit dimensions.
- `sitemap.xml` and `robots.txt`.

All eight pages score **100 for SEO, accessibility and best practices** in Google
Lighthouse. If you make a big change, it is worth re-running that in Chrome
(F12 → Lighthouse) to make sure it stayed there.

---

## Uploading to a website builder

### Two versions of every page

There are two copies of each page, and which one you want depends entirely on
whether your host lets you upload an images folder.

| | Where | Photos | Page size |
|---|---|---|---|
| **BAKED** | `baked/*.html` | built into the HTML | 0.18 – 1.33 MB |
| **PLAIN** | `*.html` | in the `images/` folder | ~30 KB |

**Use BAKED when there is nowhere to upload images** — a builder that only gives
you a box to paste HTML into, like Stride. Every photo is encoded directly into
the file, so the page carries its own pictures and there is nothing else to
upload. That is why the files are big.

**Use PLAIN on real web hosting**, where you can upload the `images/` folder
next to the pages. The pages load faster, the photos are cached between pages,
and a photo can be swapped without touching the HTML.

Both look identical on screen and both score 100 in Lighthouse.

### Getting the code onto your clipboard

Double-clicking a `.html` file opens it in a browser and shows you the finished
page, not the code. To get the code instead:

**Double-click `COPY-A-PAGE.bat`**, press a number, press Enter. That page's
HTML is now on your clipboard — switch to your builder and press Ctrl+V.

It defaults to the **BAKED** version. Press `B` to switch to PLAIN. It stays
open so you can copy the next page straight after; `0` quits.

From a terminal you can skip the menu:

```
COPY-A-PAGE.bat show           (baked)
COPY-A-PAGE.bat show plain     (plain)
```

(Or by hand: right-click the file → Open with → Notepad, then Ctrl+A, Ctrl+C.)

### Re-baking after you edit a page

The baked copies are generated **from** the plain ones. If you edit a plain page,
its baked twin is now out of date. Ask Claude to re-bake, or just remember that
`baked/` is output — never edit anything in there by hand, your changes will be
overwritten the next time it is regenerated.

### Full page vs. embed box

Each `.html` file is a **complete document** — it starts with `<!doctype html>`
and carries its own `<head>` and styling.

- If your builder has a **"custom HTML page"** or **"code page"** slot, paste the
  whole thing. That is what these files are built for.
- If your builder only gives you a **small embed or widget box** that drops code
  inside an existing page, a full document will not work there. You would need a
  body-only version of each page instead — ask and it can be generated from
  these files in a few minutes.

### Images

The `images/` folder must be uploaded too, and it must sit **alongside** the HTML
files so that `images/logo.png` resolves. If your builder gives images different
URLs, find and replace `images/` with whatever prefix it hands you.
