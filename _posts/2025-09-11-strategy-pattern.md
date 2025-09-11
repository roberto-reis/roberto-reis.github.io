---
layout: post
title: "Strategy Pattern em Laravel: escolhendo a melhor estratégia em tempo de execução"
categories: [Programação, Design Patterns, Laravel]
excerpt: Um exemplo prático de como aplicar o padrão Strategy em Laravel para tornar seu código mais flexível e desacoplado.
date: 2025-09-11T18:01:00-03:00
---

### O que é o Strategy Pattern?

O **Strategy Pattern** é um padrão **comportamental** que permite **definir uma família de algoritmos, encapsulá-los e torná-los intercambiáveis**.  

Em vez de encher o código de `ifs` ou `switch`, você cria diferentes estratégias (classes) e escolhe qual usar em tempo de execução.  

---

### Exemplo prático em Laravel: cálculo de frete

Imagine que você precisa calcular o frete em um e-commerce.  
Existem várias formas de calcular:  

- **Correios**  
- **Transportadora**  
- **Frete fixo**  

Ao invés de lotar o Controller de condicionais, aplicamos o Strategy Pattern.  

---

### Implementando o Strategy Pattern

#### 1. Criando a interface da estratégia
```php
<?php

namespace App\Contracts;

interface ShippingStrategy
{
    public function calculate(float $weight, string $destination): float;
}
```

#### 2. Criando estratégias concretas
```php
<?php

namespace App\Services\Shipping;

use App\Contracts\ShippingStrategy;

class CorreiosShipping implements ShippingStrategy
{
    public function calculate(float $weight, string $destination): float
    {
        return 20 + ($weight * 2); // cálculo fictício
    }
}

class TransportadoraShipping implements ShippingStrategy
{
    public function calculate(float $weight, string $destination): float
    {
        return 50 + ($weight * 1.5);
    }
}

class FixedShipping implements ShippingStrategy
{
    public function calculate(float $weight, string $destination): float
    {
        return 30; // frete fixo
    }
}
```

#### 3. Criando o contexto que usa a estratégias
```php
<?php

namespace App\Services\Shipping;

use App\Contracts\ShippingStrategy;

class ShippingCalculator
{
    public function __construct(
        private ShippingStrategy $strategy
    ) {}

    public function calculate(float $weight, string $destination): float
    {
        return $this->strategy->calculate($weight, $destination);
    }
}
```
#### 4. Usando o Strategy no Controller
```php
<?php

namespace App\Http\Controllers;

use App\Services\Shipping\{CorreiosShipping, TransportadoraShipping, FixedShipping, ShippingCalculator};
use Illuminate\Http\Request;

class ShippingController extends Controller
{
    public function calcular(Request $request)
    {
        $method = $request->input('method', 'correios');
        $weight = $request->input('weight', 5);
        $destination = $request->input('destination', 'São Paulo');

        $strategy = match ($method) {
            'correios' => new CorreiosShipping(),
            'transportadora' => new TransportadoraShipping(),
            'fixo' => new FixedShipping(),
            default => new CorreiosShipping(),
        };

        $calculator = new ShippingCalculator($strategy);
        $cost = $calculator->calculate($weight, $destination);

        return response()->json(['frete' => $cost]);
    }
}
```
### Vantagens
- 🔄 Fácil trocar a lógica de cálculo sem mexer no restante do código.
- 📦 Novas estratégias podem ser adicionadas sem alterar o Controller.
- 🧩 Elimina condicionais repetitivas (if/else, switch).

---

### 📚 Reflexão para o dia:
**Assim como no código podemos escolher diferentes estratégias para resolver um problema, na vida também temos várias formas de agir diante das situações. Qual “estratégia” você poderia mudar hoje para alcançar um resultado melhor?**