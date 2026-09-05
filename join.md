---
layout: page
title: Join the mailing list
subtitle: One message a week at most, and you can leave at any time.
permalink: /join/
description: >-
  Sign up for the UTSA Mathematics Problem-Solving Club mailing list to get
  meeting times, problem sets, and Putnam Competition announcements.
---
{%- assign list = site.data.club.list -%}

The mailing list is how the club announces meeting times and rooms, sends out
each problem set, and passes along Putnam Competition deadlines. It is the only
thing you need to sign up for.

{%- if list.self_subscribe %}

<p style="margin-top:1.5rem">
  <a class="btn" href="{{ list.subscribe_url }}">Subscribe to the mailing list</a>
</p>

You will be asked to confirm by email. **Click the link in that confirmation
message** — until you do, you are not on the list. That step is what keeps the
list free of addresses nobody meant to add.

{%- else %}

To join, email <a href="mailto:{{ list.address }}?subject=Subscribe%20to%20the%20PSC%20mailing%20list">{{ list.address }}</a>
with the subject "Subscribe" and we will add you before the next meeting.

{%- endif %}

## What you are signing up for

- Meeting announcements — day, time, and room.
- The problem set for each meeting, as a PDF.
- Putnam Competition registration deadlines each fall.

Nothing else. The list is not used for departmental announcements, recruiting,
or anything a club has no business sending you.

## Leaving the list

{%- if list.self_subscribe %}
Every message carries an unsubscribe link in its footer. You can also manage
your subscription at any time from
<a href="{{ list.subscribe_url }}">the list page</a>. No one is notified and
nobody will ask why.
{%- else %}
Reply to any message with "unsubscribe", or email
<a href="mailto:{{ site.data.club.contact.email }}">{{ site.data.club.contact.email }}</a>.
You will be removed the same week.
{%- endif %}

## Your address

Your email address is used to send you the things listed above and for nothing
else. It is never published, sold, or shared outside the club, and the list
archive is not public — subscribers cannot browse each other's addresses.

If you would rather not sign up at all, every problem set is on
[the problems page]({{ '/problems/' | relative_url }}) with no sign-up of any
kind, and you are welcome at a meeting without telling anyone in advance.

Questions go to
[{{ site.data.club.contact.name }}](mailto:{{ site.data.club.contact.email }}).
