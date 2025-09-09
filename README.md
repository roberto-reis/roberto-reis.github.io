
# Blog pessoal sobre estudos de programação, finanças/investimentos e filosofia estoica

Este é um blog pessoal criado para compartilhar meus estudos e aprendizados nas áreas de **programação**, **finanças/investimentos** e também um pouco sobre **filosofia estoica**. Utiliza o tema [Reverie](https://github.com/amitmerchant1990/reverie), baseado em [Jekyll](https://jekyllrb.com/), e pode ser facilmente hospedado no [GitHub Pages](https://pages.github.com).

## Descrição

Aqui você encontrará artigos, tutoriais, dicas e reflexões sobre desenvolvimento de software, tecnologias, investimentos, educação financeira, filosofia estoica e temas relacionados.

---

## Como executar o projeto localmente

Siga os passos abaixo para rodar o blog em sua máquina:

### 1. Pré-requisitos

- [Ruby](https://www.ruby-lang.org/pt/)
- [Bundler](https://bundler.io/)
- [Jekyll](https://jekyllrb.com/)

No Linux, instale com:

```bash
sudo apt update
sudo apt install ruby-full build-essential zlib1g-dev
sudo gem install bundler jekyll
```

### 2. Instalar dependências

No diretório do projeto, execute:

```bash
sudo bundle install
```

### 3. Rodar o servidor local

Execute:

```bash
bundle exec jekyll serve
```

O blog estará disponível em [http://localhost:4000](http://localhost:4000).

---

## Estrutura do Projeto

- **_posts/**: artigos do blog (em Markdown)
- **_config.yml**: configurações do Jekyll e do tema
- **images/**: imagens usadas no blog
- **README.md**: este arquivo

---

## Categorias

Os posts podem ser categorizados por temas, como por exemplo:

```md
categories: [Programação, Finanças, Filosofia Estoica]
```

Acesse as categorias em: `/categories/`

---

## Publicando novos artigos

Crie arquivos Markdown em `_posts/` seguindo o padrão: `ano-mes-dia-titulo.md` e inclua o bloco de front-matter no início.

Exemplo:

```md
---
title: "Meu primeiro post"
date: 2025-08-03
categories: [Programação]
---
Conteúdo do post...
```

---

## Licença

MIT

---

> Dúvidas ou sugestões? Fique à vontade para abrir uma issue ou entrar em contato!