---
layout: post
title: "System Design: Como Escalar Leituras para 50.000 Requisições por Segundo"
categories: [Tecnologia, Desenvolvimento, System Design, Arquitetura de Software]
excerpt: "Entenda como escalar uma aplicação para suportar 50.000 requisições por segundo utilizando Cache, Redis, Read Replicas, Load Balancer e escalabilidade horizontal."
date: 2026-11-08 20:10:00 -03:00
---

# System Design: Escalando Leituras para 50.000 Requisições por Segundo

Imagine que você desenvolveu uma aplicação que começou pequena, atendendo algumas centenas de usuários diariamente.

Com o crescimento do negócio, milhares de pessoas começam a acessar a plataforma simultaneamente.

Até que surge um novo desafio:

**Como fazer uma aplicação suportar 50.000 requisições por segundo sem sobrecarregar o banco de dados?**

Esse é um problema clássico de **System Design**, mais especificamente de **Scaling Reads (Escalabilidade de Leituras)**.

Neste artigo, vamos entender como resolver esse problema utilizando técnicas de arquitetura de software, exemplos práticos e uma aplicação desenvolvida com Laravel e MySQL.

---

## 1. O que significa escalar leituras?

Escalar leituras significa aumentar a capacidade de uma aplicação de atender consultas aos dados sem comprometer seu desempenho.

Imagine uma API responsável por consultar informações de produtos.

```http
GET /api/produtos/123
```

Internamente, a aplicação executa:

```sql
SELECT * FROM produtos WHERE id = 123;
```

Em uma aplicação pequena, essa arquitetura funciona perfeitamente.

Mas imagine que a mesma API comece a receber:

- 100 requisições por segundo;
- 1.000 requisições por segundo;
- 10.000 requisições por segundo;
- 50.000 requisições por segundo.

Se cada requisição executar uma consulta no banco, teremos potencialmente **50.000 consultas por segundo**.

Isso representa:

| Período | Requisições |
|---|---:|
| 1 segundo | 50.000 |
| 1 minuto | 3.000.000 |
| 1 hora | 180.000.000 |
| 1 dia | 4.320.000.000 |

Esses valores consideram uma carga constante de 50.000 RPS durante todo o período.

**O problema não é apenas a quantidade de requisições, mas o trabalho necessário para processar cada uma delas.**

---

## 2. O problema de utilizar apenas um banco de dados

Vamos começar com uma arquitetura simples:

```text
         Usuários
             |
             | 50.000 RPS
             v
      +--------------+
      | API Laravel  |
      +--------------+
             |
             | Consultas SQL
             v
      +--------------+
      |    MySQL     |
      |   Primary    |
      +--------------+
```

Todas as requisições chegam à aplicação, que consulta o mesmo banco de dados.

Conforme a demanda aumenta, podemos enfrentar:

- Alto consumo de CPU;
- Aumento de operações de disco;
- Excesso de conexões simultâneas;
- Consultas lentas;
- Aumento da latência;
- Timeouts;
- Indisponibilidade do serviço.

O banco de dados passa a ser um **gargalo (bottleneck)**.

### Por que não aumentar apenas o servidor?

Uma alternativa seria aumentar a capacidade da máquina:

- Mais memória RAM;
- Mais CPUs;
- Discos mais rápidos.

Essa técnica é conhecida como **Vertical Scaling (Escalabilidade Vertical)**.

Entretanto, existe um limite físico e financeiro para o quanto podemos aumentar um único servidor.

Por isso, precisamos considerar outras estratégias.

---

## 3. Primeira solução: Cache com Redis

Uma das maneiras mais eficientes de reduzir a quantidade de leituras no banco é utilizar **cache**.

A ideia é simples:

> Se uma informação já foi consultada recentemente, por que consultar o banco novamente?

Imagine que milhares de usuários consultem o mesmo produto.

Sem cache, cada requisição executaria uma consulta SQL.

Com cache, podemos armazenar temporariamente o resultado em memória.

### Como funciona o Cache-Aside?

O padrão **Cache-Aside**, também chamado de Lazy Loading, funciona assim:

1. A aplicação recebe uma requisição.
2. Consulta o Redis.
3. Se o dado existir, retorna diretamente do cache.
4. Se não existir, consulta o banco de dados.
5. Armazena o resultado no Redis.
6. Retorna o resultado ao usuário.

```text
          Cliente
             |
             v
        API Laravel
             |
             v
        Redis Cache
             |
       +-----+-----+
       |           |
     HIT          MISS
       |           |
       v           v
    Retorna       MySQL
    do Cache       |
                   v
              Busca dados
                   |
                   v
              Atualiza Redis
                   |
                   v
                Retorna
```

### Exemplo prático com Laravel

O Laravel possui integração nativa com diferentes sistemas de cache, incluindo Redis.

```php
public function show(int $id)
{
    return Cache::remember(
        "produto:{$id}",
        300,
        fn () => Produto::findOrFail($id)
    );
}
```

Nesse exemplo:

- `produto:{$id}` é a chave do cache.
- `300` representa o TTL de 300 segundos.
- A função consulta o banco somente quando não existe um valor válido no cache.

**TTL (Time To Live)** é o tempo durante o qual um dado permanece válido no cache.

### Qual seria o impacto em 50.000 RPS?

Vamos considerar um cenário hipotético com **95% de Cache Hit Rate**.

Cache Hit Rate é a porcentagem de consultas atendidas diretamente pelo cache.

| Destino | Requisições por segundo |
|---|---:|
| Redis (95%) | 47.500 |
| MySQL (5%) | 2.500 |
| Total | 50.000 |

O cálculo é:

```text
50.000 × 0,95 = 47.500 Cache Hits

50.000 × 0,05 = 2.500 Cache Misses
```

Com essa estratégia, reduzimos potencialmente as consultas ao banco de 50.000 para 2.500 por segundo.

Isso representa uma **redução de 95% nas leituras ao banco** nesse cenário simplificado.

### Atenção à invalidação de cache

Cache também apresenta desafios.

Imagine que o preço de um produto foi atualizado no banco, mas o Redis ainda possui o valor antigo.

Nesse caso, a aplicação pode retornar uma informação desatualizada.

Uma solução é invalidar o cache após a atualização:

```php
$produto->update([
    'preco' => 199.90
]);

Cache::forget("produto:{$produto->id}");
```

Em sistemas distribuídos, é importante coordenar a atualização do banco e a invalidação do cache para reduzir inconsistências.

Outro problema é o **Cache Stampede**, quando muitas requisições tentam reconstruir simultaneamente uma mesma entrada expirada.

Podemos mitigar esse problema com locks distribuídos, expiração escalonada e estratégias de atualização antecipada.

---

## 4. Segunda solução: Read Replicas

Mesmo utilizando Redis, ainda podemos ter milhares de consultas por segundo chegando ao banco.

Uma solução é utilizar **Read Replicas (Réplicas de Leitura)**.

A ideia consiste em separar as operações de escrita das operações de leitura.

### Como funciona?

Temos um banco principal, conhecido como **Primary**, responsável pelas escritas.

Também criamos bancos secundários, chamados de **Replicas**, responsáveis por atender consultas.

```text
              API Laravel
                   |
           +-------+-------+
           |               |
         WRITE            READ
           |               |
           v               v
      +---------+     +-----------+
      | Primary |     | Read      |
      | MySQL   |     | Router    |
      +---------+     +-----------+
           |               |
           |           +---+---+
           |           |       |
           |           v       v
           |        Replica  Replica
           |           1       2
           |
           +------ Replicação ----->
```

O banco principal recebe as alterações e replica os dados para os bancos secundários.

Assim, podemos distribuir a carga de leitura entre várias instâncias.

### Exemplo com 2.500 consultas por segundo

Imagine que, após implementar o Redis, ainda temos 2.500 consultas por segundo.

Se utilizarmos cinco réplicas e distribuirmos a carga igualmente:

```text
2.500 / 5 = 500 consultas por segundo
```

Cada réplica receberia aproximadamente 500 consultas por segundo.

Isso não significa que cada réplica necessariamente suporta esse volume. Precisamos considerar hardware, índices, complexidade das consultas e outros fatores.

### Configuração no Laravel

O Laravel permite configurar conexões separadas para leitura e escrita.

Exemplo simplificado em `config/database.php`:

```php
'mysql' => [
    'driver' => 'mysql',

    'read' => [
        'host' => [
            'mysql-replica-1',
            'mysql-replica-2',
        ],
    ],

    'write' => [
        'host' => [
            'mysql-primary',
        ],
    ],

    'sticky' => true,

    // Demais configurações da conexão...
],
```

A opção `sticky` ajuda a direcionar leituras posteriores a uma escrita para a conexão de escrita durante a mesma requisição.

Ela não garante consistência entre requisições diferentes.

### O problema do Replication Lag

Um conceito importante é o **Replication Lag**, ou atraso de replicação.

Imagine o seguinte cenário:

1. O usuário atualiza seu endereço.
2. O banco Primary confirma a alteração.
3. O usuário consulta seu cadastro.
4. A consulta é direcionada para uma réplica.
5. A réplica ainda não recebeu a atualização.

Nesse caso, o usuário pode visualizar o endereço antigo.

Esse comportamento está relacionado à **consistência eventual (Eventual Consistency)**.

Por isso, nem toda leitura deve necessariamente ser direcionada para uma réplica.

Operações que exigem consistência imediata podem precisar consultar o Primary.

---

## 5. Terceira solução: Load Balancer

Até agora, reduzimos a carga sobre o banco de dados.

Mas existe outro problema:

**E se a própria aplicação Laravel não conseguir processar 50.000 requisições por segundo?**

Imagine uma única instância recebendo todas as requisições.

Mesmo com Redis e Read Replicas, a CPU e a memória dessa instância podem se tornar gargalos.

Para resolver isso, podemos utilizar um **Load Balancer (Balanceador de Carga)**.

### Como funciona?

O Load Balancer recebe as requisições e distribui entre várias instâncias da aplicação.

```text
               50.000 RPS
                    |
                    v
            +---------------+
            | Load Balancer |
            +---------------+
                    |
          +---------+---------+
          |         |         |
          v         v         v
       API 01    API 02    API 03
       Laravel   Laravel   Laravel
          |         |         |
          +---------+---------+
                    |
                    v
              Redis Cache
                    |
                    v
              Read Replicas
```

Existem diferentes algoritmos de distribuição, como:

- **Round Robin:** distribui requisições sequencialmente entre os servidores.
- **Least Connections:** prioriza servidores com menos conexões ativas.
- **Weighted Round Robin:** distribui proporcionalmente à capacidade configurada de cada servidor.

### Quantas instâncias precisamos?

Suponha que um teste de carga demonstre que cada instância da aplicação consegue processar 5.000 RPS mantendo a latência desejada.

Nesse cenário:

```text
50.000 / 5.000 = 10 instâncias
```

Precisaríamos de aproximadamente 10 instâncias para atender essa carga nominal.

Entretanto, uma arquitetura de produção deve considerar margem de segurança, picos, falhas e capacidade durante a substituição de instâncias.

**A capacidade real deve ser medida com testes de carga, e não presumida apenas pela quantidade de servidores.**

---

## 6. Quarta solução: Horizontal Scaling

A utilização de várias instâncias da aplicação é um exemplo de **Horizontal Scaling (Escalabilidade Horizontal)**.

Diferentemente da escalabilidade vertical, em que aumentamos os recursos de uma máquina, na horizontal adicionamos novas máquinas.

| Vertical Scaling | Horizontal Scaling |
|---|---|
| Aumenta CPU e RAM | Adiciona servidores |
| Mais simples inicialmente | Exige arquitetura distribuída |
| Limitado à capacidade da máquina | Permite distribuir a carga |
| Pode manter um ponto único de falha | Pode oferecer maior disponibilidade |

### Aplicações Stateless

Para escalar horizontalmente, é recomendável que as instâncias da API sejam **stateless**, ou seja, não dependam de estado armazenado exclusivamente na memória ou no disco local de um servidor.

Por exemplo, imagine que um usuário faça login na API 01, mas sua próxima requisição seja direcionada para a API 03.

Se a sessão estiver armazenada apenas na API 01, teremos problemas.

Uma alternativa é utilizar armazenamento compartilhado, como Redis, para sessões quando a aplicação depende delas.

Isso permite que diferentes instâncias atendam o mesmo usuário.

---

## 7. Quinta solução: Database Indexing

Antes de adicionar novas réplicas, precisamos garantir que as consultas estejam otimizadas.

Uma consulta SQL mal planejada pode consumir muitos recursos mesmo em um banco de dados poderoso.

Imagine uma tabela com milhões de produtos.

```sql
SELECT *
FROM produtos
WHERE categoria_id = 10;
```

Se não existir um índice adequado, o banco pode precisar examinar uma quantidade muito grande de registros.

Podemos criar um índice:

```sql
CREATE INDEX idx_produtos_categoria
ON produtos (categoria_id);
```

Com um índice apropriado, o banco pode localizar os registros com mais eficiência.

Entretanto, índices também possuem custos:

- Consomem espaço em disco;
- Precisam ser mantidos durante escritas;
- Podem aumentar o custo de INSERT, UPDATE e DELETE.

Por isso, devemos analisar as consultas reais utilizando ferramentas como:

```sql
EXPLAIN
SELECT *
FROM produtos
WHERE categoria_id = 10;
```

**Escalar um banco de dados sem otimizar suas consultas pode significar apenas distribuir ineficiências entre mais servidores.**

---

## 8. Sexta solução: CDN

Nem todas as requisições precisam chegar à aplicação.

Imagine que milhares de usuários estejam solicitando imagens de produtos, arquivos JavaScript, CSS ou conteúdos públicos que podem ser armazenados temporariamente.

Uma **CDN (Content Delivery Network)** pode entregar esses conteúdos a partir de servidores distribuídos geograficamente.

```text
            Usuário
               |
               v
              CDN
               |
         +-----+-----+
         |           |
       HIT          MISS
         |           |
         v           v
      Retorna      Origem
      conteúdo       |
                     v
                 Resposta
```

Com isso, reduzimos:

- Tráfego na aplicação;
- Latência para os usuários;
- Consumo de recursos dos servidores de origem.

Também é possível armazenar respostas HTTP cacheáveis na CDN, desde que as políticas de cache e os requisitos de privacidade sejam corretamente configurados.

---

## 9. Arquitetura completa para 50.000 RPS

Agora vamos combinar as técnicas estudadas.

Uma arquitetura possível seria:

```text
                   USUÁRIOS
                  50.000 RPS
                       |
                       v
                +-------------+
                |     CDN     |
                +-------------+
                       |
                       v
                +-------------+
                | Load        |
                | Balancer    |
                +-------------+
                       |
             +---------+---------+
             |         |         |
             v         v         v
           API 01    API 02    API 03
           Laravel   Laravel   Laravel
             |         |         |
             +---------+---------+
                       |
                       v
                +-------------+
                | Redis       |
                | Cache       |
                +-------------+
                       |
                 Cache Miss
                       |
                       v
                +-------------+
                | Read Router |
                +-------------+
                       |
             +---------+---------+
             |         |         |
             v         v         v
          Replica 1 Replica 2 Replica 3
             ^         ^         ^
             |         |         |
             +---------+---------+
                       |
                  Replicação
                       |
                +-------------+
                | MySQL       |
                | Primary     |
                +-------------+
                       ^
                       |
                    Escritas
```

O diagrama apresenta o caminho principal das leituras de forma simplificada. As escritas são direcionadas ao Primary, que replica as alterações para as réplicas.

O Redis também precisa ser dimensionado adequadamente e pode utilizar replicação, alta disponibilidade e particionamento, dependendo da necessidade.

### Distribuição hipotética de carga

Vamos considerar:

- 50.000 requisições por segundo chegando à API;
- 95% de Cache Hit Rate no Redis;
- 5 réplicas de leitura;
- 10 instâncias da aplicação.

| Componente | Carga estimada |
|---|---:|
| API | 50.000 RPS |
| Redis | 50.000 consultas/s |
| Cache Hits | 47.500/s |
| Cache Misses | 2.500/s |
| Cada réplica | 500 consultas/s |
| Cada instância API | 5.000 RPS |

Essa distribuição considera um modelo simplificado, sem contabilizar tráfego atendido pela CDN, múltiplas consultas por requisição, desequilíbrios de carga ou outras operações.

Esses valores são apenas um ponto de partida para o dimensionamento.

---

## 10. Como saber se a arquitetura realmente suporta 50.000 RPS?

Uma arquitetura aparentemente bem projetada não garante desempenho.

Precisamos realizar **Load Testing (Testes de Carga)**.

Uma ferramenta bastante utilizada é o **k6**.

Com ela, podemos simular usuários acessando a aplicação e analisar métricas de desempenho.

### Métricas importantes

**Throughput:** quantidade de requisições processadas por segundo.

**Latency:** tempo necessário para processar uma requisição.

**p95:** indica que 95% das requisições apresentam latência igual ou inferior ao valor medido.

**p99:** indica que 99% das requisições apresentam latência igual ou inferior ao valor medido.

**Error Rate:** porcentagem de requisições que falharam.

**Cache Hit Rate:** porcentagem de consultas atendidas pelo cache.

### Exemplo de objetivo de desempenho

Podemos estabelecer requisitos como:

| Métrica | Objetivo hipotético |
|---|---|
| Throughput | 50.000 RPS |
| Latência p95 | Menor que 200 ms |
| Latência p99 | Menor que 500 ms |
| Taxa de erro | Menor que 0,1% |
| Cache Hit Rate | Maior ou igual a 95% |

Esses números são metas de exemplo, não padrões universais.

O teste deve validar o comportamento da aplicação sob carga sustentada e durante picos.

Também precisamos monitorar CPU, memória, conexões de banco, utilização de Redis e atraso de replicação.

---

## 11. Cuidados importantes em sistemas de alta escala

Alguns problemas merecem atenção especial.

### Cache Stampede

Muitas requisições consultam simultaneamente uma chave que acabou de expirar.

Todas tentam buscar os mesmos dados no banco, gerando um pico inesperado.

**Solução:** locks, expiração escalonada e atualização antecipada do cache.

### Hot Keys

Algumas chaves do Redis recebem uma quantidade muito maior de acessos do que outras.

Isso pode concentrar carga em um único nó.

**Solução:** identificar as chaves mais acessadas e avaliar distribuição, cache local e replicação de leitura.

### Replication Lag

As réplicas podem apresentar dados desatualizados.

**Solução:** definir requisitos de consistência e direcionar leituras críticas ao Primary quando necessário.

### Connection Exhaustion

Muitas instâncias da aplicação podem abrir conexões demais com o banco.

**Solução:** controlar os pools de conexões e avaliar proxies ou mecanismos de pooling compatíveis com o banco e a infraestrutura.

### Single Point of Failure

Se todos os servidores dependerem de uma única instância Redis sem redundância, sua indisponibilidade pode afetar toda a aplicação.

**Solução:** implementar alta disponibilidade, failover e estratégias adequadas de degradação.

---

## 12. Qual estratégia utilizar primeiro?

Nem sempre precisamos implementar todas essas soluções.

O ideal é evoluir a arquitetura conforme os gargalos identificados.

| Problema identificado | Possível solução |
|---|---|
| Consultas SQL lentas | Índices e otimização |
| Muitas consultas repetidas | Redis |
| Banco sobrecarregado por leituras | Read Replicas |
| Aplicação com CPU elevada | Horizontal Scaling |
| Tráfego estático elevado | CDN |
| Muitas conexões ao banco | Connection Pooling |
| Volume de dados muito grande | Particionamento ou Sharding |
| Picos inesperados | Auto Scaling e controle de tráfego |

**Sharding** é uma técnica mais avançada, utilizada para distribuir diferentes subconjuntos dos dados entre bancos.

Ela não deve ser confundida com Read Replicas: réplicas normalmente mantêm cópias dos mesmos dados, enquanto shards armazenam partes distintas deles.

---

## Conclusão

Escalar uma aplicação para suportar **50.000 requisições por segundo** não significa simplesmente contratar um servidor mais poderoso.

É necessário compreender como as requisições percorrem a arquitetura e identificar os principais gargalos.

Aprendemos que:

- **Redis** reduz consultas repetidas ao banco.
- **Read Replicas** distribuem a carga de leitura.
- **Load Balancer** distribui o tráfego entre instâncias.
- **Horizontal Scaling** permite adicionar capacidade de processamento.
- **Database Indexing** melhora a eficiência das consultas.
- **CDN** reduz o tráfego que chega aos servidores de origem.
- **Load Testing** permite validar se a arquitetura atende aos requisitos.

O principal aprendizado de System Design é que não existe uma arquitetura universal para atender determinado número de requisições.

Uma API que consulta produtos em cache possui características muito diferentes de uma API que executa relatórios financeiros complexos.

Por isso, o dimensionamento depende do comportamento da aplicação, da distribuição das leituras, dos requisitos de consistência e das metas de latência.

O melhor caminho é começar com uma arquitetura simples, medir o desempenho, identificar gargalos e evoluir conforme a necessidade.

---

### 📚 Reflexão para o dia

**Escalabilidade não é sobre quantos servidores temos, mas sobre como distribuímos o trabalho e eliminamos gargalos.**
Em System Design, a melhor solução nem sempre é adicionar mais infraestrutura. Muitas vezes, é evitar que uma operação desnecessária aconteça milhares de vezes.