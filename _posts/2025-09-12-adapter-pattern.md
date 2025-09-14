---
layout: post
title: "Adapter Pattern em Laravel: conectando interfaces diferentes de forma elegante"
categories: [Programação, Design Patterns, Laravel]
excerpt: Um exemplo prático de como aplicar o padrão Adapter em Laravel para integrar sistemas ou serviços que não falam a mesma linguagem.
date: 2025-09-12T15:50:00-03:00
---

### O que é o Adapter Pattern?

O **Adapter Pattern** é um padrão **estrutural** que funciona como um **tradutor** entre duas interfaces incompatíveis.  

Ele permite que classes que normalmente não poderiam trabalhar juntas consigam se comunicar sem alterar o código original.  

Em resumo: você cria um **adaptador** que faz a ponte entre o que sua aplicação espera e o que o serviço externo oferece.  

### Exemplo prático em Laravel: integração com serviços de SMS

Imagine que sua aplicação precisa enviar SMS.  
No início você usou uma biblioteca própria (`LocalSmsService`), mas depois a empresa contratou um provedor externo como **Twilio**.  

O problema: sua aplicação já depende de uma interface própria, e não dá para mudar tudo.  
A solução: aplicar o **Adapter Pattern**.  

### Implementando o Adapter Pattern

#### 1. Interface que a aplicação espera
```php
<?php

namespace App\Contracts;

interface SmsService
{
    public function send(string $to, string $message): bool;
}
```

#### 2. Serviço original da aplicação
```php
<?php

namespace App\Services;

use App\Contracts\SmsService;

class LocalSmsService implements SmsService
{
    public function send(string $to, string $message): bool
    {
        // Simula envio local
        return true;
    }
}
```

#### 3. Biblioteca externa (simulação do Twilio)
```php
<?php

namespace External\Twilio;

class TwilioClient
{
    public function sendMessage(string $phoneNumber, string $text): bool
    {
        // Simula envio via Twilio
        return true;
    }
}
```

#### 4. Criando o Adapter
```php
<?php

namespace App\Adapters;

use App\Contracts\SmsService;
use External\Twilio\TwilioClient;

class TwilioSmsAdapter implements SmsService
{
    public function __construct(
        private TwilioClient $twilio
    ) {}

    public function send(string $to, string $message): bool
    {
        // Traduz a chamada para o formato esperado pelo Twilio
        return $this->twilio->sendMessage($to, $message);
    }
}
```

#### 5. Usando no Controller
```php
<?php

namespace App\Http\Controllers;

use App\Services\LocalSmsService;
use App\Adapters\TwilioSmsAdapter;
use External\Twilio\TwilioClient;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function enviar(Request $request)
    {
        $service = $request->input('service', 'local');

        $sms = $service === 'twilio'
            ? new TwilioSmsAdapter(new TwilioClient())
            : new LocalSmsService();

        $sms->send('+5511999999999', 'Olá, este é um teste!');

        return response()->json(['status' => 'Mensagem enviada!']);
    }
}
```

### Vantagens
- 🔌 Integração com serviços externos sem mudar o código existente.
- 🛠️ Facilita substituição de implementações no futuro.
- 🧩 Mantém o sistema coeso e desacoplado.

---

### 📚 Reflexão para o dia:
**Na vida, assim como no código, muitas vezes precisamos de "adaptadores" — maneiras de traduzir nossa linguagem para sermos compreendidos pelos outros. Em que situação você poderia se adaptar melhor hoje para facilitar a comunicação?**