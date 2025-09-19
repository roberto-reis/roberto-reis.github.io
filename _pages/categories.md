---
layout: page
permalink: /categories/
title: Categorias
---


<div id="archives">
{% for category in site.categories %}
  <div class="archive-group">
    {% capture category_name %}{{ category | first }}{% endcapture %}
    <div id="#{{ category_name | slugize }}"></div>    
    <h3 class="category-head">{{ category_name }}</h3>
    <a name="{{ category_name | slugize }}"></a>
    {% for post in site.categories[category_name] %}
    <article class="archive-item">
      <h4><a href="{{ site.baseurl }}{{ post.url }}">{% if post.title and post.title != "" %}{{post.title}}{% else %}{{post.excerpt |strip_html}}{%endif%}</a></h4>
    </article>
    {% endfor %}
  </div>
{% endfor %}
</div>

<script>
  document.addEventListener("DOMContentLoaded", function() {
    var hash = decodeURIComponent(window.location.hash.replace('#', ''));
    if (hash) {
      // Oculta todos os grupos de categoria
      document.querySelectorAll('.archive-group').forEach(function(group) {
        group.style.display = 'none';
      });
      
      // Mostra apenas o grupo da categoria do hash
      var target = document.querySelector('.category-head');
      
      document.querySelectorAll('.category-head').forEach(function(head) {
        if (head.textContent.trim().toLowerCase() === hash.toLowerCase()) {
          head.parentElement.style.display = 'block';
          // rola até a categoria
          // head.scrollIntoView({behavior: "smooth"});
        }
      });
    }
  });
</script>