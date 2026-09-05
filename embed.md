---
layout: embed
permalink: /embed/
sitemap: false
math: false
---
{%- assign club = site.data.club -%}
<div class="embed-card">
  <h2>Mathematics Problem-Solving Club</h2>
  <p>Weekly problem sessions, open to all UTSA students.
  {% include meeting-short.html %}</p>
  <div class="embed-actions">
    <a class="btn" href="{{ '/' | absolute_url }}" target="_blank" rel="noopener">Club website</a>
    <a class="btn btn-quiet" href="{{ '/join/' | absolute_url }}" target="_blank" rel="noopener">Join the mailing list</a>
  </div>
</div>
