---
layout: post
title: "Factory Method em Laravel: criando objetos de forma flexível"
categories: [Programação, Design Patterns, Laravel]
excerpt: Um exemplo prático de como aplicar o padrão Factory Method no Laravel para organizar e flexibilizar a criação de objetos.
date: 2025-09-11T15:26:00-03:00
---

### O que é o Factory Method?

O **Factory Method** é um padrão de projeto **criacional** que propõe a criação de um método especializado para instanciar objetos, em vez de usar `new` diretamente no código.  

Isso permite **flexibilidade, desacoplamento** e facilita a **substituição ou extensão** de classes sem precisar alterar quem usa essas instâncias.

### Exemplo prático em Laravel: sistema de pagamento

Imagine que você está desenvolvendo um sistema de venda de passagens no Laravel (👀 exemplo real para nós devs).  
Você precisa integrar diferentes **gateways de pagamento** (Stripe, Mercado Pago, Pagar.me, etc).  

Se o código instanciar diretamente cada classe, a manutenção fica complicada. É aí que entra o Factory Method.

### Implementando o Factory Method

#### 1. Definindo uma interface comum
```php
<?php

namespace App\Contracts;

interface PaymentGateway
{
    public function charge(float $amount): string;
}
```

#### 2. Criando implementações concretas
```php
<?php

namespace App\Services\Payments;

use App\Contracts\PaymentGateway;

class StripePayment implements PaymentGateway
{
    public function charge(float $amount): string
    {
        // integração fictícia
        return "Pagamento de {$amount} processado com Stripe.";
    }
}

class MercadoPagoPayment implements PaymentGateway
{
    public function charge(float $amount): string
    {
        // integração fictícia
        return "Pagamento de {$amount} processado com Mercado Pago.";
    }
}
```

#### 3. Criando a Factory

```php
<?php

namespace App\Factories;

use App\Contracts\PaymentGateway;
use App\Services\Payments\MercadoPagoPayment;
use App\Services\Payments\StripePayment;
use InvalidArgumentException;

class PaymentFactory
{
    public static function make(string $gateway): PaymentGateway
    {
        return match ($gateway) {
            'stripe' => new StripePayment(),
            'mercadopago' => new MercadoPagoPayment(),
            default => throw new InvalidArgumentException("Gateway {$gateway} não suportado"),
        };
    }
}
```

#### 4. Usando no Controller
```php
<?php

namespace App\Http\Controllers;

use App\Factories\PaymentFactory;
use Illuminate\Http\Request;

class CheckoutController extends Controller
{
    public function pagar(Request $request)
    {
        $gateway = $request->input('gateway', 'stripe'); 
        $amount = $request->input('amount', 100);

        $payment = PaymentFactory::make($gateway);
        $result = $payment->charge($amount);

        return response()->json(['message' => $result]);
    }
}
```

### Vantagens

- 🔌 Fácil adicionar novos gateways sem mexer no Controller.
- 🛠️ Reduz duplicação de código.
- 🧩 Mantém o código aberto para extensão, mas fechado para modificação (princípio OCP da SOLID).

---

### 📚 Reflexão para o dia:

**Na programação e na vida, muitas vezes precisamos de “fábricas”: pontos centrais que nos ajudam a criar algo de forma organizada, sem bagunça. O que você tem criado de forma improvisada que poderia se beneficiar de um método mais estruturado?**