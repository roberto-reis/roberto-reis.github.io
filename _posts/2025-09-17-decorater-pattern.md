---
layout: post
title: "Decorator Pattern em Laravel: estendendo funcionalidades sem alterar o código original"
categories: [Programação, Design Patterns, Laravel]
excerpt: Um exemplo prático de como aplicar o padrão Decorator em Laravel para adicionar responsabilidades dinamicamente a objetos.
date: 2025-09-17T10:50:00-03:00
---

### O que é o Decorator Pattern?

O **Decorator Pattern** é um padrão **estrutural** que permite **adicionar comportamentos ou responsabilidades a objetos de forma dinâmica**, sem modificar sua classe base.  

Isso é útil quando você quer estender funcionalidades sem criar heranças infinitas ou mexer no código original.  

### Exemplo prático em Laravel: sistema de notificação

Imagine que você tem um sistema de notificações.  
No início, só enviava e-mails.  
Agora, o time quer enviar também SMS e notificações no Slack.  

Em vez de mudar a classe original, podemos usar o **Decorator Pattern** para adicionar esses novos comportamentos.  

### Implementando o Decorator Pattern

#### 1. Criando a interface base
```php
<?php

namespace App\Contracts;

interface Notifier
{
    public function send(string $message): void;
}
```
#### 2. Criando o componente concreto
```php
<?php

namespace App\Services;

use App\Contracts\Notifier;

class EmailNotifier implements Notifier
{
    public function send(string $message): void
    {
        \Log::info("📧 Enviando email: {$message}");
    }
}
```

#### 3. Criando a classe base para os Decorators
```php
<?php

namespace App\Services\Decorators;

use App\Contracts\Notifier;

abstract class NotifierDecorator implements Notifier
{
    public function __construct(
        protected Notifier $notifier
    ) {}
}
```

#### 4. Criando os Decorators concretos
```php
<?php

namespace App\Services\Decorators;

class SmsNotifier extends NotifierDecorator
{
    public function send(string $message): void
    {
        $this->notifier->send($message);
        \Log::info("📱 Enviando SMS: {$message}");
    }
}

class SlackNotifier extends NotifierDecorator
{
    public function send(string $message): void
    {
        $this->notifier->send($message);
        \Log::info("💬 Enviando Slack: {$message}");
    }
}
```

#### 5. Usando no Controller
```php
<?php

namespace App\Http\Controllers;

use App\Services\EmailNotifier;
use App\Services\Decorators\{SmsNotifier, SlackNotifier};
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function enviar(Request $request)
    {
        $notifier = new EmailNotifier();

        // Adiciona dinamicamente novos canais
        $notifier = new SmsNotifier($notifier);
        $notifier = new SlackNotifier($notifier);

        $notifier->send("Novo pedido confirmado!");

        return response()->json(['status' => 'Notificações enviadas!']);
    }
}
```

### Vantagens
- 🎯 Adiciona funcionalidades sem alterar a classe original.
- 🔄 Permite compor dinamicamente diferentes comportamentos.
- 🧩 Evita herança múltipla e duplicação de código.

---

### 📚 Reflexão para o dia:
**O Decorator nos mostra que podemos adicionar novas camadas de valor sem precisar mudar a essência. Na sua vida, que “decoradores” positivos você poderia acrescentar hoje para enriquecer sua atuação no mundo?**