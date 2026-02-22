---
layout: post
title: "Command Pattern em Laravel: encapsulando ações como objetos"
categories: [Programação, Design Patterns, Laravel]
excerpt: Um exemplo prático de como aplicar o padrão Command em Laravel para organizar ações, facilitar filas e agendamentos.
date: 2025-09-16T10:20:00-03:00
---

### O que é o Command Pattern?

O **Command Pattern** é um padrão **comportamental** que transforma uma ação (ou operação) em um objeto.  
Isso permite:  

- Encapsular a lógica de execução  
- Guardar, enfileirar ou desfazer comandos  
- Desacoplar quem solicita a ação de quem realmente a executa  

No Laravel, esse conceito aparece de forma natural nos **Artisan Commands** e nas **Jobs (queues)**.  

### Exemplo prático em Laravel: envio de e-mails

Imagine que sua aplicação precisa enviar e-mails de confirmação de compra.  
Em vez de executar isso diretamente no Controller, você encapsula a ação em um **Command**.  

### Implementando o Command Pattern

#### 1. Criando o Command (Job)
```php
<?php

namespace App\Jobs;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;

class SendConfirmationEmail implements ShouldQueue
{
    use Dispatchable, Queueable;

    public function __construct(
        public User $user
    ) {}

    public function handle(): void
    {
        // lógica fictícia de envio
        \Log::info("Enviando e-mail de confirmação para {$this->user->email}");
    }
}
```

#### 2. Usando o Command no Controller
```php
<?php

namespace App\Http\Controllers;

use App\Jobs\SendConfirmationEmail;
use App\Models\User;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function confirmar(Request $request)
    {
        $user = User::findOrFail($request->input('user_id'));

        // Dispara o "comando"
        SendConfirmationEmail::dispatch($user);

        return response()->json(['status' => 'E-mail de confirmação enfileirado!']);
    }
}
```

### Onde mais aplicar?
- 📌 Histórico de operações – guardar comandos executados.
- 📌 Desfazer ações (Undo) – encapsular também a lógica inversa.
- 📌 Agendamento de tarefas – comandos podem ser programados para o futuro.

### Vantagens
- 🧩 Desacopla a lógica da ação do Controller.
- ⏳ Permite agendamento e enfileiramento de comandos.
- 🛠️ Facilita manutenção e testes (cada comando é uma unidade independente).

---

### 📚 Reflexão para o dia:
**O Command Pattern nos lembra que cada ação pode ser encapsulada, registrada e repetida. Na vida, quais ações você tem feito repetidamente que poderiam ser organizadas como “comandos” mais conscientes?**