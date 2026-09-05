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
| Check before pushing | `./bin/check-pii.sh && ./bin/check-build.sh` |

The `.tex` sources live in the private `teaching` repo, not here; set `PSC_SRC`
if it is not at `~/repos/teaching/ProblemSolving/ProblemSetsPSC`.

Editing `_data/club.yml` also updates the card embedded on the official UTSA
department page — see `handoff/utsa-clubs-page.md`.

Conventions and the reasoning behind them: [CLAUDE.md](CLAUDE.md).
