# UTSA Mathematics Problem-Solving Club

Source for <https://supernumero.us/psclub/>.

```bash
bundle install
bundle exec jekyll serve --livereload --baseurl /psclub
```

Then <http://localhost:4000/psclub/>.

## Common tasks

| Task | Command |
|---|---|
| Change the meeting time, room, or mailing list | edit `_data/club.yml` |
| Rebuild the problem PDFs | `./bin/sync-sets.sh [slug]` |
| Re-read problem metadata from the LaTeX | `python3 bin/extract-problems.py` |
| Add a problem set | four steps, and two tables must agree — see [CLAUDE.md](CLAUDE.md) |
| Check before pushing | `./bin/check-pii.sh && bundle exec jekyll build && ./bin/check-build.sh` |

The `.tex` sources live in the private `teaching` repo, not here; set `PSC_SRC`
if it is not at `~/repos/teaching/ProblemSolving/ProblemSetsPSC`.

`check-build.sh` inspects the *built* site, so `jekyll build` has to run first — on
its own it exits 1 with `no build at _site`. Run the whole sequence under the Ruby
CI pins (3.3); a newer local Ruby passes things CI rejects, which has bitten before:

```bash
RBENV_VERSION=3.3.12 PATH="$HOME/.rbenv/shims:$PATH" \
  bash -c './bin/check-pii.sh && bundle exec jekyll build && ./bin/check-build.sh'
```

After pushing, confirm the **deploy** job went green, not just `build`:
`gh run list --workflow=build.yml`.

Editing `_data/club.yml` also updates the card embedded on the official UTSA
department page — see `handoff/utsa-clubs-page.md`.

Conventions and the reasoning behind them: [CLAUDE.md](CLAUDE.md).
