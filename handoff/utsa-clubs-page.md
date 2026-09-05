# For the UTSA web team

Three options for the Problem-Solving Club entry on
<https://sciences.utsa.edu/mathematics/students/clubs.html>, in order of
preference. Any one of them is a **one-time** install — none needs to be
revisited when meeting times change.

The club site stands on its own at <https://supernumero.us/psclub/>; everything
below is a convenience for visitors who start on the department page.

---

## Option 1 — iframe (preferred)

Paste this once. The card it shows is served from the club site, so the meeting
time, room, and links stay current without anyone editing this page again.

```html
<iframe src="https://supernumero.us/psclub/embed/"
        width="100%" height="200" style="border:0"
        loading="lazy" title="UTSA Mathematics Problem-Solving Club"></iframe>
```

The card is fixed-height by design: a cross-origin frame cannot negotiate its
own size, so the content is written to fit 200px at every width from 320px up.

## Option 2 — static HTML callout

If iframes are not permitted. Self-contained: no JavaScript, no external
stylesheet, no web fonts. **This version needs a new request whenever the
meeting time changes**, which is the trade-off for not using Option 1.

```html
<div style="border:1px solid #e0ddd4;border-top:3px solid #800020;border-radius:3px;padding:18px 20px;margin:16px 0;background:#fdfcfa;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif">
  <h3 style="margin:0 0 6px;font-size:1.15rem;color:#5e0018">UTSA Mathematics Problem-Solving Club</h3>
  <p style="margin:0 0 12px;font-size:.9rem;color:#5f5f58;line-height:1.5">
    Weekly problem sessions in the Department of Mathematics. Open to all UTSA
    students; undergraduates are eligible for the Putnam Competition.
  </p>
  <p style="margin:0">
    <a href="https://supernumero.us/psclub/" style="display:inline-block;background:#800020;color:#fff;font-size:.875rem;padding:8px 16px;border-radius:3px;text-decoration:none">Club website</a>
    <a href="https://supernumero.us/psclub/join/" style="display:inline-block;color:#800020;font-size:.875rem;padding:8px 16px;text-decoration:none;border:1px solid #e0ddd4;border-radius:3px;margin-left:6px">Join the mailing list</a>
  </p>
</div>
```

## Option 3 — prose and links only

If the editor strips markup.

> **Problem-Solving Club.** The club meets weekly to work through competition
> and enrichment problems together. It is open to all UTSA students, and
> undergraduates are eligible for the Putnam Competition. Meeting times, past
> problem sets, and the mailing list sign-up are at
> <https://supernumero.us/psclub/>.

---

## Notes

- The club site is maintained by club members and is not an official
  publication of the University; it says so in its own footer.
- It uses no UTSA logo, wordmark, or Roadrunner — the palette only.
- Nothing on the club site collects information from visitors except the
  mailing-list sign-up, which is opt-in and confirmed by email.
