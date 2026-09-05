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

We meet to work on problems together — the kind that are stated in a sentence
and take an hour and an argument to settle. No lecture, no prerequisites beyond
curiosity, and no expectation that you solve anything on your own. Bring paper.

**The club is open to every UTSA student**, whatever your major or year.
Undergraduates are also eligible for the [Putnam
Competition](https://www.maa.org/math-competitions/putnam-competition), which
the club prepares for each fall.

## How a meeting goes

Someone puts a problem on the board. We try things — usually the wrong things
first — and talk about why they fail, which is normally where the idea comes
from. Problems are chosen so that the first step is available to anybody in the
room, and the last step is worth showing to somebody else.

Sets are organised in parts of increasing difficulty. The early problems collect
fundamental results worth proving from scratch even when they look familiar; the
middle develops techniques — reflections, loci, transformations, coordinates,
invariants — that reappear across linear algebra, group theory, differential
geometry, and physics; the last are competition-level, and want creativity and a
synthesis of everything before them. Work through in order, or jump ahead to
whatever catches your eye.

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
