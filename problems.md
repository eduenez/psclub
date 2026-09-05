---
layout: page
title: Problem sets
subtitle: Everything the club has worked through, free to download.
permalink: /problems/
description: >-
  The archive of problem sets from the UTSA Mathematics Problem-Solving Club —
  geometry, linear algebra, games and strategy, and five-minute gems.
---

Problems only. The club works them out together at meetings, so the sets carry
topic and attribution as a starting point but no solutions. Every set is a PDF
you can print and bring with you.

{% assign by_term = site.data.sets | group_by: "term" %}
{%- for group in by_term %}
<h2 class="term-heading">{{ group.name }}</h2>
<ul class="set-list">
  {%- for set in group.items %}
  <li>
    <h3><a href="{{ '/problems/' | append: set.slug | append: '/' | relative_url }}">{{ set.title }}</a></h3>
    <p class="set-meta">{{ set.count }} problems · <a href="{{ '/assets/sets/' | append: set.slug | append: '.pdf' | relative_url }}">PDF</a></p>
    <p>{{ set.blurb }}</p>
  </li>
  {%- endfor %}
</ul>
{%- endfor %}
