<p class="meta">
  <span class="datetime">
    {{ post.date | date: "%Y-%m-%d" }}
  </span>
  &nbsp&nbsp Tags: 
  {% for tag in post.tags %}
  <a href="/tags/{{ tag }}" class="tag">
    {{ tag }}
  </a>
  {% endfor %}
  {% if site.custom.category %}
  posted in [
  {% if post.category %}
  <a href="/category/{{ post.category }}" class="category">
    {{ site.custom.category[post.category] }}
  </a>]
  {% else %}
  <a href="/" class="category">Default
  </a>]
  {% endif %}
  {% endif %}
</p>
