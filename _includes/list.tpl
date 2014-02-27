{% include header.tpl %}

{% for post in list %}
<article{% if forloop.index == 1 and preview %} content-loaded="1"{% endif %}>
  <ht><a href="{{ post.url }}">{{ post.title }}</a></ht>
  {% include meta.tpl %}
  <div class="article-content">
    {% if forloop.index == 1 and preview and post.layout == 'post' %}
    {{ post.content | split:'<!--more-->' |first }}
    ... ... <a href="{{ post.url }}">继续阅读</a>
    {% endif %}
  </div>
</article>
{% endfor %}

{% if list == null %}
<article class="empty">
  <p>该分类下还没有文章</p>
</article>
{% endif %}
