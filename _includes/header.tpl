<header>
	<h1>{% if page.title %}<a href="/" class="minor">{{ site.title }}</a> / {{ page.title }}{% else %}{{ site.title }}{% endif %}</h1>
	{% if page.title == null %}<p class="additional">{{ site.tagline }}</p>{% endif %}
</header>
