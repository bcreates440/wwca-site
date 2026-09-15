#!/bin/sh
# ---------------------------------------------------------------------------
# WWCA site sanity check.
#
# Each page is self-contained, which means the STYLES, HEADER and FOOTER blocks
# are duplicated in all 8 files. That is fine until someone edits one copy and
# forgets the other seven. This script catches exactly that, plus the other
# things that quietly break a static site.
#
# Run it from inside the site folder:   sh check.sh
# ---------------------------------------------------------------------------
cd "$(dirname "$0")" || exit 1
PAGES="index show vendors membership youth gallery about contact"
fail=0
say_fail() { echo "FAIL: $1"; fail=1; }

# --- 1. shared blocks identical across all 8 pages -------------------------
# The header has one intentional per-page difference (aria-current on the
# current page's link), so it is compared with that attribute stripped out.
for block in STYLES HEADER FOOTER; do
  ref=""; refp=""; bad=0
  for p in $PAGES; do
    h=$(sed -n "/===== SITE $block/,/===== END SITE $block/p" "$p.html" \
        | sed 's/ aria-current="page"//' | md5sum | cut -d' ' -f1)
    if [ -z "$ref" ]; then ref="$h"; refp="$p"
    elif [ "$h" != "$ref" ]; then
      say_fail "$p.html SITE $block differs from $refp.html - copy the block across"
      bad=1
    fi
  done
  [ "$bad" -eq 0 ] && echo "ok:   SITE $block identical in all 8 pages"
done

# --- 2. genuinely self-contained (the whole point of the build) ------------
files=""; for p in $PAGES; do files="$files $p.html"; done
if grep -l 'rel="stylesheet"' $files 2>/dev/null | grep -q .; then
  say_fail "an external stylesheet link crept in - pages must stay self-contained"
else
  echo "ok:   no external stylesheets"
fi
if grep -l '<script[^>]*src=' $files 2>/dev/null | grep -q .; then
  say_fail "an external script tag crept in - pages must stay self-contained"
else
  echo "ok:   no external scripts"
fi

# --- 3. every referenced image actually exists ----------------------------
# Only real references: src="images/..." attributes and the CSS url("images/...").
bad=0
for p in $PAGES _template; do
  [ -f "$p.html" ] || continue
  for img in $(grep -o '\(src="\|url("\)images/[^"]*' "$p.html" \
               | sed 's/.*"//' | sort -u); do
    [ -f "$img" ] || { say_fail "$p.html references missing $img"; bad=1; }
  done
done
[ "$bad" -eq 0 ] && echo "ok:   every referenced image exists"

# --- 4. every internal link points at a real file -------------------------
bad=0
for p in $PAGES; do
  for lnk in $(grep -o 'href="[a-z_]*\.html' "$p.html" | sed 's/href="//' | sort -u); do
    [ -f "$lnk" ] || { say_fail "$p.html links to missing $lnk"; bad=1; }
  done
done
[ "$bad" -eq 0 ] && echo "ok:   every internal link resolves"

# --- 5. exactly one <h1> per page -----------------------------------------
bad=0
for p in $PAGES; do
  n=$(grep -c '<h1' "$p.html")
  [ "$n" -eq 1 ] || { say_fail "$p.html has $n <h1> tags (should be exactly 1)"; bad=1; }
done
[ "$bad" -eq 0 ] && echo "ok:   exactly one <h1> per page"

# --- 6. unique title and meta description per page ------------------------
dupes=$(grep -h '<title>' $files | sort | uniq -d)
[ -n "$dupes" ] && say_fail "duplicate <title> across pages: $dupes"
dupes=$(grep -h 'name="description"' $files | sort | uniq -d)
[ -n "$dupes" ] && say_fail "duplicate meta description across pages"
echo "ok:   titles and descriptions checked"

# --- 7. every page is in the sitemap --------------------------------------
bad=0
for p in $PAGES; do
  grep -q "$p.html" sitemap.xml || { say_fail "$p.html missing from sitemap.xml"; bad=1; }
done
[ "$bad" -eq 0 ] && echo "ok:   sitemap lists all 8 pages"

# --- 8. stale show content ------------------------------------------------
# "2026" is legitimate in history and copyright lines, so this only warns.
if grep -l '37th Annual Memorial Weekend' $files >/dev/null 2>&1; then
  echo "warn: '37th Annual' appears - confirm it reads as history, not the next show"
fi

echo
if [ "$fail" -eq 0 ]; then echo "ALL CHECKS PASSED"; else echo "SOME CHECKS FAILED"; fi
exit $fail
