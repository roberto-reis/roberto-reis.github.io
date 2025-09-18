---
layout: post
title: "O que é NoSQL? Bancos de dados não relacionais"
categories: [Tecnologia, Bancos de Dados]
excerpt: Uma introdução prática ao NoSQL, os bancos de dados não relacionais criados para lidar com escalabilidade e flexibilidade de dados.
date: 2025-09-18T17:05:00-03:00
---

Se o **SQL** é a base dos bancos relacionais, o **NoSQL** surgiu como resposta a novos desafios:  
grandes volumes de dados, velocidade e flexibilidade.  

Mas afinal, o que significa **NoSQL**?

## O que é NoSQL?
NoSQL significa **“Not Only SQL”** (Não apenas SQL).  
São bancos de dados **não relacionais**, que não seguem o modelo de tabelas tradicionais.  

Eles foram criados para cenários onde a escalabilidade e a variedade dos dados são prioridade.

Exemplos de bancos NoSQL: **MongoDB, Redis, Cassandra, Neo4j, DynamoDB**.

## Tipos de bancos NoSQL
Existem diferentes modelos de armazenamento:

- **Documentos** → dados em formato JSON/BSON.  
  *Exemplo: MongoDB, CouchDB*  

- **Chave-valor** → cada item é armazenado como par chave/valor.  
  *Exemplo: Redis, DynamoDB*  

- **Colunar** → dados organizados por colunas ao invés de linhas.  
  *Exemplo: Cassandra, HBase*  

- **Grafos** → foca nas relações entre entidades (nós e arestas).  
  *Exemplo: Neo4j, ArangoDB*  

## Exemplo prático (MongoDB)
Diferente do SQL, não precisamos definir a estrutura antes.  
Basta inserir um documento:

```javascript
db.usuarios.insertOne({
  nome: "Roberto Reis",
  email: "roberto@email.com",
  interesses: ["filmes", "viagem", "música"]
});
```

### Consultar
```javascript
db.usuarios.find({ nome: "Roberto Reis" });
```

### Atualizar

```javascript
db.usuarios.updateOne(
  { nome: "Roberto Reis" },
  { $set: { email: "roberto.novo@email.com" } }
);
```

### Deletar

```javascript
db.usuarios.deleteOne({ nome: "Roberto Reis" });
```

## Vantagens do NoSQL

- Escalabilidade horizontal nativa.
- Flexibilidade de esquema.
- Alta performance em dados massivos.
- Ideal para big data, redes sociais, IoT e aplicações em tempo real.

## Desvantagens do NoSQL

- Menos padronização (cada banco tem sua sintaxe).
- Muitas vezes usam consistência eventual (BASE).
- JOINs e relatórios complexos limitados.
- Alguns têm menos maturidade em ferramentas e transações ACID.

## Conclusão

O NoSQL não substitui o SQL — ele complementa.<br>
Enquanto bancos relacionais brilham na consistência, o NoSQL se destaca em cenários de escala e flexibilidade.<br>
O segredo é escolher a ferramenta certa para o problema certo.