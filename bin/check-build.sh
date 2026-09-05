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
slugs=$(ruby -ryaml -e '
  YAML.load_file("_data/sets.yml", permitted_classes: [Date]).each { |s| puts s["slug"] }')
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
if [ -d "${PSC_SRC:-$HOME/repos/teaching/ProblemSolving/ProblemSetsPSC}" ]; then
  if ! python3 bin/extract-problems.py >/dev/null 2>&1; then
    report "bin/extract-problems.py does not run"
  elif ! git diff --quiet -- _data/sets.yml 2>/dev/null; then
    report "_data/sets.yml is stale -- re-run bin/extract-problems.py and commit"
    git checkout -- _data/sets.yml 2>/dev/null || true
  fi
fi

[ "$status" -eq 0 ] && echo "build checks: clean"
exit "$status"
