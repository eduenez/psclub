---
layout: page
title: UTSA Mathematics Problem-Solving Club
show_title: false
description: >-
  Weekly problem sessions in the UTSA Department of Mathematics. Open to every
  UTSA student, whatever your major or year.
---

<h1>Problem-Solving Club</h1>
<p class="subtitle">Department of Mathematics · The University of Texas at San Antonio</p>

{%- assign putnam = site.data.club.putnam -%}
{%- if putnam %}
<a class="putnam-ad" href="{{ '/putnam/' | relative_url }}">
  <span class="putnam-ad-tag">Register now</span>
  <span class="putnam-ad-text"><strong>Putnam Competition &mdash; {{ putnam.date }}.</strong>
  Open to all undergraduates. UTSA&rsquo;s sign-up deadline is {{ putnam.deadline }}.</span>
  <span class="putnam-ad-go" aria-hidden="true">&rarr;</span>
</a>
{%- endif %}

<img class="hero" src="{{ '/assets/img/hero.png' | relative_url }}"
     alt="Engraved illustration: a winding mountain path, a round table of coins, pigeons in pigeonholes, a ladder against a wall, and a broken stick — each a problem the club has worked on."
     width="1200" height="655">

<blockquote class="epigraph">
  <p>Mathematics is not a spectator sport.</p>
  <cite>George Pólya</cite>
</blockquote>

<p class="meeting">{% include meeting.html %}</p>

<p>
  <a class="btn" href="{{ '/join/' | relative_url }}">Join the mailing list</a>
  <a class="btn btn-quiet" href="{{ '/problems/' | relative_url }}">Browse the problems</a>
</p>

We meet to figure out problems together that require reasoning and ingenuity.
There is no lecture, and the main prerequisite is intellectual curiosity. Bring
paper — we provide the chalk.

**The club is open to every UTSA student**, regardless of major or undergraduate /
graduate standing.
Undergraduates are eligible to compete in the [Putnam Mathematical
Competition]({{ '/putnam/' | relative_url }}), an annual North American contest
held in early December.{% if putnam %} The next one is on **{{ putnam.date }}**
and registration is open now.{% endif %}

## How a meeting goes

Handouts of suggested problems are distributed.
Students and faculty mentors try things out in groups; early mistakes are the
norm; they often pave the way to a solution. Many problems are chosen so that the
first step is very accessible but the last step teaches a valuable lesson.

## Recent problem sets

<ul class="set-list">
{%- for set in site.data.sets limit: 3 %}
  <li>
    <h3><a href="{{ '/problems/' | append: set.slug | append: '/' | relative_url }}">{{ set.title }}</a></h3>
    <p class="set-meta">{{ set.term }} · {{ set.count }} problems</p>
    <p>{{ set.blurb }}</p>
  </li>
{%- endfor %}
</ul>

<p><a href="{{ '/problems/' | relative_url }}">All {{ site.data.sets.size }} problem sets →</a></p>
