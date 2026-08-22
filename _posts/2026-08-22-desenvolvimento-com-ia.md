---
layout: post
title: "Desenvolvimento com IA: RAG, agentes, skills e engenharia de contexto"
categories: [Desenvolvimento, Engenharia de Software, IA, LLMs]
excerpt: "Entenda como RAG, agentes, skills, subagentes, harness, desenvolvimento orientado por especificações e loops de validação se conectam no desenvolvimento de software com IA."
date: 2026-08-22T13:00:00-03:00
---

O desenvolvimento de software com Inteligência Artificial está evoluindo rapidamente.

No começo, a interação com modelos de linguagem era relativamente simples:

```text
Desenvolvedor → Prompt → IA → Resposta
```

Hoje, já falamos sobre **Agents, Skills, Subagents, RAG, Harness, Spec-Driven Development, Loop Engineering e Graph Engineering**.

À primeira vista, parece apenas uma coleção de novos termos.

Mas cada conceito resolve um problema diferente.

Neste artigo, vamos entender cada um deles de maneira simples e, principalmente, descobrir **como eles se conectam no desenvolvimento de software com IA**.

---

## 1. RAG — Retrieval-Augmented Generation

**RAG** significa **Retrieval-Augmented Generation**, ou Geração Aumentada por Recuperação.

A ideia é simples:

> Antes de responder, a IA procura informações relevantes em uma fonte externa e utiliza essas informações como contexto.

Um modelo de linguagem possui conhecimento adquirido durante seu treinamento, mas não conhece automaticamente os documentos privados da sua empresa, a documentação interna ou todos os detalhes do seu projeto.

É aí que entra o RAG.

Imagine que você pergunte:

> "Como funciona o módulo de autenticação deste sistema?"

Um sistema utilizando RAG poderia fazer:

```text
Pergunta do desenvolvedor
        ↓
Busca informações relevantes
        ↓
Documentação
Código-fonte
Base de conhecimento
        ↓
Recupera os trechos relevantes
        ↓
Envia para o LLM
        ↓
Resposta contextualizada
```

O RAG ficou especialmente popular para criação de chatbots conectados a documentos, PDFs, wikis corporativas e bases de conhecimento.

### Uma forma simples de lembrar

**RAG = buscar conhecimento antes de responder.**

---

## 2. Agents — Agentes de IA

Um **Agent** vai além de simplesmente responder perguntas.

Ele recebe um objetivo e pode decidir quais ações precisa executar para alcançá-lo.

Por exemplo:

> "Implemente um filtro de usuários por status."

Em vez de simplesmente gerar um exemplo de código, um Coding Agent pode:

1. analisar o projeto;
2. localizar os arquivos envolvidos;
3. entender a arquitetura;
4. criar ou modificar arquivos;
5. executar comandos;
6. rodar os testes;
7. analisar erros;
8. corrigir o código.

O fluxo começa a parecer com:

```text
Objetivo
   ↓
Analisar
   ↓
Planejar
   ↓
Executar ação
   ↓
Observar resultado
   ↓
Decidir próximo passo
   ↓
Executar novamente
```

Isso muda bastante nossa relação com a IA.

Antes tínhamos principalmente:

```text
Prompt → Resposta
```

Agora podemos ter:

```text
Objetivo → Ações → Feedback → Novas ações → Resultado
```

### Uma forma simples de lembrar

**Agent = IA capaz de trabalhar em direção a um objetivo.**

---

## 3. Subagents — Agentes especializados

Conforme as tarefas ficam maiores, um único agente pode ter trabalho demais para realizar.

Uma solução é dividir o problema entre **Subagents**.

Imagine que precisamos analisar uma aplicação inteira.

O agente principal poderia dividir o trabalho:

```text
                 AGENT PRINCIPAL
                       │
          ┌────────────┼────────────┐
          ↓            ↓            ↓
     Backend Agent  Test Agent  Security Agent
          │            │            │
          └────────────┼────────────┘
                       ↓
                Resultado final
```

Cada Subagent recebe uma responsabilidade específica.

Por exemplo:

**Backend Agent**

Analisa regras de negócio e arquitetura.

**Test Agent**

Analisa cobertura e qualidade dos testes.

**Security Agent**

Procura possíveis problemas de segurança.

Depois, o agente principal consolida os resultados.

Isso permite **especialização, isolamento de contexto e até paralelização do trabalho**.

### Uma forma simples de lembrar

**Subagent = agente especializado que recebe parte do trabalho.**

---

## 4. Skills — Habilidades reutilizáveis

Se Agents são os trabalhadores, podemos pensar nas **Skills como suas especializações ou manuais de trabalho**.

Uma Skill contém instruções reutilizáveis para determinada atividade.

Por exemplo, poderíamos criar:

```text
skills/

├── laravel/
│   └── SKILL.md
│
├── code-review/
│   └── SKILL.md
│
└── testing/
    └── SKILL.md
```

Uma Skill de Laravel poderia definir:

```text
Utilize FormRequest para validações.

Mantenha Controllers pequenos.

Coloque regras de negócio em Actions.

Utilize Pest para testes.

Respeite os limites dos módulos.
```

Quando o Agent precisar desenvolver naquela aplicação, essas instruções ajudam a orientar seu comportamento.

Isso evita colocar todas as regras possíveis em um único prompt gigantesco.

### Uma forma simples de lembrar

**Skill = conhecimento ou instruções reutilizáveis que ensinam ao Agent como executar determinado trabalho.**

---

## 5. Harness — O ambiente ao redor da IA

Esse é um conceito extremamente importante para entender os Coding Agents modernos.

Um LLM sozinho trabalha basicamente com:

```text
Texto entrando
      ↓
     LLM
      ↓
Texto saindo
```

Mas como ele consegue abrir arquivos?

Executar testes?

Usar Git?

Rodar comandos no terminal?

Buscar documentação?

Aplicar uma Skill?

É aí que entra o **Harness**.

O Harness é a infraestrutura construída ao redor do modelo para permitir que ele trabalhe.

Podemos visualizar assim:

```text
┌─────────────────────────────────┐
│            AI HARNESS           │
│                                 │
│          ┌─────────┐            │
│          │   LLM   │            │
│          └─────────┘            │
│                                 │
│  Arquivos      Terminal         │
│  Git           Skills           │
│  MCP           Ferramentas      │
│  Contexto      Permissões       │
│  Testes        Memória          │
│                                 │
└─────────────────────────────────┘
```

Isso explica por que dois Coding Agents utilizando modelos semelhantes podem apresentar resultados bastante diferentes.

O modelo importa.

Mas **o ambiente construído ao redor dele também importa muito**.

### Uma analogia

Podemos pensar assim:

**LLM = cérebro**

**Harness = ambiente de trabalho + ferramentas disponíveis para esse cérebro**

### Uma forma simples de lembrar

**Harness = infraestrutura que permite ao Agent realmente trabalhar.**

---

## 6. Spec-Driven Development

Conforme os Agents ficaram melhores em escrever código, surgiu outro problema:

**Como explicar exatamente o que queremos que eles construam?**

É aqui que entra o **Spec-Driven Development**.

Em vez de começar diretamente pela implementação, começamos pela especificação.

Por exemplo, em vez de:

> "Crie autenticação."

Podemos definir:

```text
Feature: Autenticação

Objetivo:
Permitir que usuários realizem login.

Requisitos:
- autenticação utilizando e-mail e senha;
- bloquear após 5 tentativas inválidas;
- registrar tentativas de login;
- retornar 401 para credenciais inválidas.

Testes:
- login válido;
- senha inválida;
- usuário inexistente;
- usuário bloqueado.
```

A implementação passa a seguir um processo mais estruturado:

```text
Ideia
 ↓
Requisitos
 ↓
Especificação
 ↓
Plano
 ↓
Tarefas
 ↓
Implementação
 ↓
Testes
 ↓
Validação
```

A especificação funciona como um **contrato entre o desenvolvedor e o Agent**.

Quanto mais clara for a definição do problema, menor tende a ser o espaço para a IA inventar decisões que não deveriam ser tomadas por ela.

### Uma forma simples de lembrar

**Spec-Driven Development = definir claramente o que deve ser construído antes de construir.**

---

## 7. Loop Engineering

Agora temos uma especificação e um Agent capaz de implementar.

Mas existe outro problema.

E se a primeira implementação estiver errada?

É aí que entra o conceito de **Loop Engineering**.

Em vez de:

```text
Implementar
    ↓
Entregar
```

criamos um ciclo:

```text
Implementar
    ↓
Testar
    ↓
Validar
    ↓
Está correto?
   /        \
 NÃO        SIM
  ↓          ↓
Corrigir   Finalizar
  ↓
Testar novamente
  │
  └──────────────↺
```

Imagine um Agent trabalhando em uma aplicação Laravel.

Ele implementa uma funcionalidade e executa:

```bash
php artisan test
```

Resultado:

```text
2 failed
18 passed
```

O trabalho ainda não terminou.

O Agent analisa os erros, modifica o código e executa novamente:

```text
1 failed
19 passed
```

Analisa novamente, corrige e executa:

```text
20 passed
```

Dependendo do projeto, o loop ainda poderia executar outras validações:

```text
Testes
  ↓
Lint
  ↓
Análise estática
  ↓
Testes de arquitetura
  ↓
Validação da Spec
```

A grande ideia é criar **feedback verificável** para que o Agent consiga perceber quando está errado e tentar novamente.

### Uma forma simples de lembrar

**Loop Engineering = construir ciclos de execução, validação, feedback e correção.**

---

## 8. Graph Engineering

Graph Engineering é um conceito mais recente e ainda menos padronizado que os anteriores.

A ideia é representar não apenas informações, mas principalmente **as relações entre elas**.

Imagine uma aplicação.

Não queremos que a IA saiba apenas que existem estes arquivos:

```text
PortfolioController.php

RebalanceamentoAction.php

CalcularPesoAction.php

Portfolio.php

RebalanceamentoTest.php
```

Queremos que ela compreenda as relações:

```text
PortfolioController
        │
       uses
        ↓
RebalanceamentoAction
        │
       uses
        ↓
CalcularPesoAction
        │
      updates
        ↓
    Portfolio
        ↑
        │
    tested by
        │
RebalanceamentoTest
```

Agora temos um **grafo**.

Isso pode ajudar o Agent a responder perguntas muito mais interessantes, como:

> "Se eu alterar essa Action, quais partes do sistema podem ser afetadas?"

Em projetos grandes, compreender essas relações pode ser tão importante quanto encontrar os arquivos individualmente.

### Uma forma simples de lembrar

**Graph Engineering = estruturar e explorar as relações entre as informações de um sistema.**

---

## Como esses conceitos se conectam?

Agora chegamos à parte mais interessante.

Esses conceitos não precisam competir entre si.

Na verdade, eles podem trabalhar juntos.

Imagine que queremos implementar uma nova funcionalidade.

Primeiro definimos:

```text
SPEC
↓
O que precisa ser construído?
```

O Agent recebe o trabalho:

```text
AGENT
↓
Quem executará?
```

Ele utiliza Skills:

```text
SKILLS
↓
Como deve trabalhar?
```

Pode buscar informações usando RAG:

```text
RAG
↓
Qual conhecimento precisa recuperar?
```

Pode delegar análises:

```text
SUBAGENTS
↓
Quem pode executar partes especializadas?
```

Tudo isso acontece dentro de um Harness:

```text
HARNESS
↓
Quais ferramentas e controles estão disponíveis?
```

Durante a implementação:

```text
LOOP ENGINEERING
↓
Implementar → Testar → Validar → Corrigir ↺
```

E um grafo pode ajudá-lo a compreender:

```text
GRAPH ENGINEERING
↓
Como as partes do sistema estão relacionadas?
```

Podemos representar tudo assim:

```text
                     DESENVOLVEDOR
                           │
                           ↓
                         SPEC
                           │
                           ↓
                 ┌─────────────────┐
                 │     HARNESS     │
                 │                 │
                 │      AGENT      │
                 │                 │
                 └────────┬────────┘
                          │
             ┌────────────┼────────────┐
             ↓            ↓            ↓
           SKILLS        RAG       SUBAGENTS
             │            │            │
             └────────────┼────────────┘
                          ↓
                   GRAPH / CONTEXTO
                          │
                          ↓
                     IMPLEMENTAR
                          ↓
                       TESTAR
                          ↓
                       VALIDAR
                          │
                    erro? │
                          ↓
                       CORRIGIR
                          │
                          └──────↺
```

---

## O papel do desenvolvedor está mudando

Talvez essa seja a consequência mais interessante de todos esses conceitos.

Durante muito tempo, desenvolver software significava principalmente:

```text
Entender problema
      ↓
Escrever código
      ↓
Testar
      ↓
Corrigir
      ↓
Entregar
```

Com Coding Agents cada vez mais capazes, parte desse trabalho pode ser executada pela IA.

O desenvolvedor passa a trabalhar também em outro nível:

```text
Definir problema
      ↓
Criar especificação
      ↓
Fornecer contexto
      ↓
Definir arquitetura e regras
      ↓
Criar critérios de validação
      ↓
Agent implementa
      ↓
Agent testa ↔ corrige
      ↓
Desenvolvedor revisa
```

Isso não significa que saber programar deixou de ser importante.

Na realidade, ocorre quase o contrário.

Quanto mais autonomia damos aos Agents, mais importante se torna saber **avaliar arquitetura, qualidade, segurança, testes e decisões técnicas**.

O desenvolvedor deixa de pensar somente:

> "Como vou escrever esse código?"

E passa também a pensar:

> "Como estruturo o ambiente para que um Agent consiga produzir esse código corretamente e de maneira repetível?"

---

## Resumindo

| Conceito              | Pense como                  |
| --------------------- | --------------------------- |
| **RAG**               | Buscar conhecimento         |
| **Agent**             | Trabalhador                 |
| **Subagent**          | Especialista                |
| **Skill**             | Competência/manual          |
| **Harness**           | Ambiente de trabalho        |
| **Spec-Driven**       | Contrato/especificação      |
| **Loop Engineering**  | Testar, aprender e corrigir |
| **Graph Engineering** | Mapa de relações            |

No fim, todos esses conceitos apontam para uma mesma evolução:

```text
IA que responde
      ↓
IA que entende contexto
      ↓
IA que usa ferramentas
      ↓
IA que executa tarefas
      ↓
IA que testa seu próprio trabalho
      ↓
IA que corrige e tenta novamente
```

Estamos deixando uma fase em que a IA era principalmente uma **ferramenta de geração de código** e entrando em uma fase em que ela começa a funcionar como parte de um **sistema de engenharia de software**.

E, nesse novo cenário, aprender a escrever bons prompts continua sendo útil — mas já não é suficiente.

O próximo passo é aprender a projetar **contexto, especificações, ferramentas, Skills, Agents e loops de validação** para que a IA consiga trabalhar de maneira cada vez mais confiável.
