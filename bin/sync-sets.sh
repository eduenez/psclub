#!/usr/bin/env bash
# Compile the PSC problem sets and copy the PDFs into assets/sets/.
#
# The .tex sources stay in the (private) teaching repo as the single source of
# truth; this repo holds only the built artifacts. teaching/.gitignore excludes
# *.pdf repo-wide, so the PDFs cannot live beside their sources anyway.
#
# Compilation happens in a scratch directory, never in the source tree: the
# sets are compiled with a filter applied (solutions stripped -- the site
# publishes problems and hints only), and the source must not be mutated.
#
#   ./bin/sync-sets.sh              # all sets
#   ./bin/sync-sets.sh geometry     # one set
#   PSC_SRC=/path/to/ProblemSetsPSC ./bin/sync-sets.sh

set -euo pipefail

SRC="${PSC_SRC:-$HOME/repos/teaching/ProblemSolving/ProblemSetsPSC}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/assets/sets"

# slug:source.tex — must match the SETS table in bin/extract-problems.py.
SETS=(
  "geometry:geometry-problems.tex"
  "assorted-classics:youtube-favorites.tex"
  "linear-algebra:LinAlgProblems.tex"
  "five-minute-gems:five_minute_gems.tex"
  "games-and-strategy:GamesProblems.tex"
  "spring-2026-intro:UTSAPSC_spring2026_problems.tex"
  "all-time-favorites:UTSA_PSC_favorites.tex"
)

[ -d "$SRC" ] || { echo "error: source not found: $SRC" >&2; exit 1; }
mkdir -p "$OUT"

want="${1:-}"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

failed=0
for entry in "${SETS[@]}"; do
  slug="${entry%%:*}"
  tex="${entry#*:}"
  [ -n "$want" ] && [ "$want" != "$slug" ] && continue
  [ -f "$SRC/$tex" ] || { echo "error: missing $SRC/$tex" >&2; failed=1; continue; }

  # Copy the whole source directory so \includegraphics finds its figures.
  rm -rf "$work/build"; mkdir -p "$work/build"
  cp "$SRC"/*.tex "$SRC"/*.png "$SRC"/*.pdf "$SRC"/*.jpg "$SRC"/*.eps "$work/build/" 2>/dev/null || true

  # The site publishes problems and hints, not solutions. Only
  # UTSA_PSC_favorites.tex currently contains a worked solution.
  perl -0pi -e 's/\\begin\{solution\}.*?\\end\{solution\}//gs' "$work/build/$tex"

  # GamesStrategy.png cannot be published. It has AI-generation artifacts
  # rendered into the artwork -- roughly a dozen literal "[cite: 6, 7]"-style
  # strings, plus the garbled captions "Scored m x n beak" and "Pluck owe
  # petals". They are scattered across the whole banner, so retouching is not
  # practical. Drop the banner from the built PDF and keep the header text.
  # Delete this block once the image is regenerated.
  perl -0pi -e 's/^.*\\includegraphics[^\n]*\{GamesStrategy\}.*$//m' "$work/build/$tex"

  # Downsample the banners for the build only. At full size they carry a
  # single set to 6.9 MB, which is a lot to ask of a student on a phone; at
  # 1600px they are still well above what the printed page resolves.
  for banner in UTSA_MathPSC.png five-minute-gems.png; do
    if [ -f "$work/build/$banner" ]; then
      magick "$work/build/$banner" -resize '1600x>' -strip -colors 64 \
        -define png:compression-level=9 "$work/build/$banner"
    fi
  done

  printf '%-22s ' "$slug"
  if (cd "$work/build" && latexmk -pdf -interaction=nonstopmode -halt-on-error \
        -file-line-error "$tex" >"$work/$slug.log" 2>&1); then
    cp "$work/build/${tex%.tex}.pdf" "$OUT/$slug.pdf"
    printf 'ok  (%s)\n' "$(du -h "$OUT/$slug.pdf" | cut -f1 | tr -d ' ')"
  else
    printf 'FAILED\n'
    tail -25 "$work/$slug.log" >&2
    failed=1
  fi
done

[ "$failed" -eq 0 ] || { echo >&2; echo "one or more sets failed to build" >&2; exit 1; }
echo "PDFs in $OUT"
