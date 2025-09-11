---
layout: post
title: "Introdução aos Padrões de Projeto: aprendendo a pensar como um arquiteto de software"
categories: [Programação, Design Patterns]
excerpt: Um guia introdutório para entender o que são padrões de projeto, por que usá-los e como eles podem transformar a forma de escrever código.
date: 2025-09-11T12:08:00-03:00
---

### O que são padrões de projeto?

Padrões de projeto são **soluções reutilizáveis para problemas recorrentes de design de software**.  
Eles não são blocos de código prontos para copiar e colar, mas **abstrações de boas práticas** que já se provaram eficazes ao longo do tempo.

Imagine-os como “atalhos mentais”: em vez de reinventar a roda a cada projeto, você reconhece o problema e aplica um padrão já consolidado.

### Por que aprender padrões de projeto?

- 📌 **Organização do código** — trazem clareza e previsibilidade.  
- 📌 **Reutilização** — permitem resolver problemas semelhantes de forma padronizada.  
- 📌 **Facilidade de manutenção** — reduzem duplicação e aumentam a legibilidade.  
- 📌 **Comunicação entre desenvolvedores** — quando você diz "usei um Singleton", qualquer programador experiente já entende o que foi feito.  

### Tipos de padrões de projeto

Segundo o clássico *Design Patterns: Elements of Reusable Object-Oriented Software* (o famoso *Gang of Four*), os padrões são divididos em três grandes grupos:

1. **Criacionais** – lidam com a forma como objetos são criados.  
   Exemplos: Singleton, Factory Method, Builder.  

2. **Estruturais** – ajudam a compor classes e objetos.  
   Exemplos: Adapter, Composite, Decorator.  

3. **Comportamentais** – focam na interação entre objetos.  
   Exemplos: Observer, Strategy, Command.  

### Exemplo simples: Singleton em PHP

Um dos padrões mais famosos é o **Singleton**, que garante que uma classe tenha apenas uma instância durante a execução da aplicação.

```php

<?php

class Config
{
    private static ?Config $instance = null;
    private array $settings = [];

    private function __construct() {} // impede new externo

    public static function getInstance(): Config
    {
        if (self::$instance === null) {
            self::$instance = new Config();
        }
        return self::$instance;
    }

    public function set(string $key, mixed $value): void
    {
        $this->settings[$key] = $value;
    }

    public function get(string $key): mixed
    {
        return $this->settings[$key] ?? null;
    }
}

$config = Config::getInstance();
$config->set('db_host', 'localhost');

echo Config::getInstance()->get('db_host');

```

---

### 📚 Reflexão para o dia:

**Assim como na vida aprendemos com a experiência dos outros, na programação podemos nos apoiar em padrões já testados. Quais problemas você tem enfrentado no seu código que poderiam ser resolvidos com um padrão de projeto?**
