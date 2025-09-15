---
layout: post
title: "Observer Pattern em Laravel: reagindo a eventos de forma desacoplada"
categories: [Programação, Design Patterns, Laravel]
excerpt: Um exemplo prático de como aplicar o padrão Observer em Laravel para notificar múltiplos componentes quando algo acontece.
date: 2025-09-15T10:55:00-03:00
---

### O que é o Observer Pattern?

O **Observer Pattern** é um padrão **comportamental** que define uma relação de **um-para-muitos** entre objetos.  
Quando o estado de um objeto muda, todos os seus observadores são notificados automaticamente.  

Em outras palavras: é como se você tivesse um “evento” e vários “ouvintes” que reagem a ele.  

No Laravel, isso é aplicado com o sistema de **Events e Listeners**.

### Exemplo prático em Laravel: novos usuários

Imagine que você quer executar várias ações quando um usuário se cadastra no sistema:  

- Enviar um e-mail de boas-vindas  
- Registrar log da criação  
- Notificar o time de suporte  

Em vez de encher o `UserController` com essas responsabilidades, aplicamos o **Observer Pattern**.  

### Implementando o Observer Pattern

#### 1. Criando o evento
```php
<?php

namespace App\Events;

use App\Models\User;
use Illuminate\Foundation\Events\Dispatchable;

class UserRegistered
{
    use Dispatchable;

    public function __construct(
        public User $user
    ) {}
}
```

#### 2. Criando os observers (listeners)
```php
<?php

namespace App\Listeners;

use App\Events\UserRegistered;

class SendWelcomeEmail
{
    public function handle(UserRegistered $event): void
    {
        // lógica de envio de e-mail
        \Log::info("Enviando e-mail para {$event->user->email}");
    }
}

class LogUserCreation
{
    public function handle(UserRegistered $event): void
    {
        \Log::info("Usuário criado: {$event->user->id}");
    }
}

class NotifySupportTeam
{
    public function handle(UserRegistered $event): void
    {
        \Log::info("Notificando suporte: novo usuário {$event->user->email}");
    }
}
```

#### 3. Registrando no EventServiceProvider
```php
<?php

namespace App\Providers;

use App\Events\UserRegistered;
use App\Listeners\{SendWelcomeEmail, LogUserCreation, NotifySupportTeam};
use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;

class EventServiceProvider extends ServiceProvider
{
    protected $listen = [
        UserRegistered::class => [
            SendWelcomeEmail::class,
            LogUserCreation::class,
            NotifySupportTeam::class,
        ],
    ];
}
```

#### 4. Disparando o evento no Controller
```php
<?php

namespace App\Http\Controllers;

use App\Events\UserRegistered;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function store(Request $request)
    {
        $user = User::create($request->only(['name', 'email', 'password']));

        event(new UserRegistered($user));

        return response()->json(['message' => 'Usuário criado com sucesso!']);
    }
}
```

### Vantagens
- 🔔 Permite que múltiplos componentes reajam a um mesmo evento.
- 🛠️ Facilita manutenção e desacoplamento.
- 📦 O Controller fica limpo e focado em sua responsabilidade.

---

### 📚 Reflexão para o dia:
**Assim como no código um evento pode gerar várias reações, na vida nossas ações também ecoam em diferentes direções. Que tipo de impacto você tem gerado nos outros com as suas atitudes?**
