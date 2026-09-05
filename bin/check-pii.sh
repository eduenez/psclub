#!/usr/bin/env bash
# Fail if anything that looks like a student address reaches this public repo.
#
# The club roster is FERPA-sensitive and lives only in the private teaching
# repo. Git history is permanent, so the guard runs before a push, not after.
#
# The matcher is deliberately structural -- address shapes, not English
# phrases. A guard that cries wolf trains you to skip it, which is worse than
# no guard at all.

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

status=0
report() { printf '\n%s\n' "$1"; status=1; }

# 1. Student addresses anywhere in tracked content or the built site.
hits=$(grep -rInE '[A-Za-z0-9._%+-]+@my\.utsa\.edu' . \
        --exclude-dir=.git --exclude-dir=_site --exclude-dir=.jekyll-cache \
        --exclude-dir=vendor --exclude-dir=.bundle --exclude=check-pii.sh 2>/dev/null || true)
[ -n "$hits" ] && report "FAIL: @my.utsa.edu address present:
$hits"

# 2. Firstname.Lastname@utsa.edu -- the shape a student or staff roster entry
#    takes. The club's own contact address is a deliberate exception.
CONTACT='eduardo\.duenez@utsa\.edu'
hits=$(grep -rInE '[A-Za-z]+\.[A-Za-z]+[0-9]*@utsa\.edu' . \
        --exclude-dir=.git --exclude-dir=_site --exclude-dir=.jekyll-cache \
        --exclude-dir=vendor --exclude-dir=.bundle --exclude=check-pii.sh 2>/dev/null \
       | grep -viE "$CONTACT" || true)
[ -n "$hits" ] && report "FAIL: personal utsa.edu address present (allowed: the club contact):
$hits"

# 3. Roster files, by name, even untracked -- catches a stray copy before it
#    is ever added.
hits=$(find . -path ./.git -prune -o -type f \
        \( -iname '*mailinglist*' -o -iname '*roster*' \) -print 2>/dev/null || true)
[ -n "$hits" ] && report "FAIL: roster-shaped file in the repo:
$hits"

# 4. GamesStrategy.png carries AI-generation artifacts rendered into the
#    artwork -- a dozen literal "[cite: 6, 7]"-style strings and the garbled
#    captions "Scored m x n beak" and "Pluck owe petals". They are raster, not
#    text, so no text search can find them: the only reliable guard is that the
#    image is not embedded anywhere. bin/sync-sets.sh strips it from the built
#    PDF; these two checks prove it stayed stripped.
#    Delete this block once the image is regenerated.
if [ -f assets/sets/games-and-strategy.pdf ] && command -v pdfimages >/dev/null 2>&1; then
  n=$(pdfimages -list assets/sets/games-and-strategy.pdf 2>/dev/null | tail -n +3 | grep -c . || true)
  [ "$n" -ne 0 ] && report "FAIL: games-and-strategy.pdf embeds $n image(s); the
GamesStrategy banner must not be published. Re-run bin/sync-sets.sh."
fi

hits=$(find . -path ./.git -prune -o -type f -iname 'GamesStrategy*' -print 2>/dev/null || true)
[ -n "$hits" ] && report "FAIL: the GamesStrategy artwork is in the repo:
$hits"

if [ "$status" -eq 0 ]; then
  echo "PII guard: clean"
else
  echo
  echo "PII guard FAILED -- do not commit or push."
fi
exit "$status"
