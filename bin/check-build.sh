#!/usr/bin/env bash
# Structural checks on the built site. Run after `jekyll build`.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

SITE="${1:-_site}"
BASE="${2:-/psclub}"
status=0
report() { printf 'FAIL: %s\n' "$1"; status=1; }

[ -d "$SITE" ] || { echo "no build at $SITE -- run jekyll build first"; exit 1; }

# A stub page whose slug matches no record in _data/sets.yml renders a loud
# marker instead of a blank page. Catch it here rather than in production.
grep -rl 'BUILD ERROR' "$SITE" >/dev/null 2>&1 \
  && report "a set page has no matching slug in _data/sets.yml"

# Project sites break in exactly one way: a link that works locally and 404s
# in production because it lost the baseurl. Every absolute path must carry it.
bad=$(grep -rhoE '(href|src)="/[^"]*"' --include='*.html' "$SITE" \
      | grep -vE "^(href|src)=\"$BASE" | sort -u || true)
[ -n "$bad" ] && report "absolute URLs missing the $BASE prefix:
$bad"

# Every set in the data must have a page and a PDF, and vice versa.
#
# `-rdate` is load-bearing. Ruby 4 happens to have Date loaded already, but
# Ruby 3.3 -- which is what CI runs -- does not, and `permitted_classes: [Date]`
# then dies on an uninitialized constant. That failure used to leave $slugs
# empty, which made every PDF look orphaned and buried the real cause under
# seven bogus errors. Hence the guard immediately below: this list going empty
# is a broken check, never a passing one.
if ! slugs=$(ruby -rdate -ryaml -e '
  YAML.load_file("_data/sets.yml", permitted_classes: [Date]).each { |s| puts s["slug"] }' 2>&1); then
  printf 'FAIL: could not read _data/sets.yml:\n%s\n' "$slugs"
  exit 1
fi
if [ -z "$slugs" ]; then
  echo "FAIL: _data/sets.yml parsed to zero sets -- the file is empty or malformed."
  exit 1
fi

for slug in $slugs; do
  [ -f "$SITE/problems/$slug/index.html" ] || report "no page built for set '$slug'"
  [ -f "$SITE/assets/sets/$slug.pdf" ]     || report "no PDF for set '$slug' -- run bin/sync-sets.sh"
done
for pdf in "$SITE"/assets/sets/*.pdf; do
  [ -e "$pdf" ] || continue
  slug=$(basename "$pdf" .pdf)
  echo "$slugs" | grep -qx "$slug" || report "orphan PDF with no set record: $slug.pdf"
done

# The problem counts on the site come from the data; if the data is stale
# relative to the .tex sources the site quietly lies about what is in a set.
# Regenerate to a temp file and diff -- never over the file being checked.
if [ -d "${PSC_SRC:-$HOME/repos/teaching/ProblemSolving/ProblemSetsPSC}" ]; then
  tmp=$(mktemp)
  if ! python3 bin/extract-problems.py --out "$tmp" >/dev/null 2>&1; then
    report "bin/extract-problems.py does not run"
  elif ! diff -q "$tmp" _data/sets.yml >/dev/null 2>&1; then
    report "_data/sets.yml is stale -- run bin/extract-problems.py and commit the result"
  fi
  rm -f "$tmp"
fi

[ "$status" -eq 0 ] && echo "build checks: clean"
exit "$status"
