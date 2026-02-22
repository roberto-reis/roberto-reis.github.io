---
layout: post
title: "Proxy Pattern em Laravel: controle e otimização com objetos substitutos"
categories: [Programação, Design Patterns, Laravel]
excerpt: "Um exemplo prático de como aplicar o padrão Proxy em Laravel para controlar acesso e otimizar chamadas com cache."
date: 2025-09-29T06:50:00-03:00
---

## O que é o Proxy Pattern?

O **Proxy Pattern** é um padrão **estrutural** que cria um **objeto substituto (proxy)** para controlar o acesso a outro objeto real.  

Esse intermediário pode:
- Controlar acesso (segurança, permissões)  
- Adicionar cache para melhorar performance  
- Adiar a inicialização de objetos pesados  

No Laravel, um bom exemplo é o uso de **cache em torno de serviços**.  

## Exemplo prático em Laravel: cache de repositório

Imagine que temos um repositório que busca dados no banco.  
Mas essas consultas são frequentes e poderiam ser otimizadas com cache.  

O Proxy entra como uma “camada no meio” entre o Controller e o repositório real.  

## Implementando o Proxy Pattern

#### 1. Criando a interface
```php
<?php

namespace App\Contracts;

interface UserRepository
{
    public function getById(int $id);
}
```

#### 2. Repositório real (objeto original)
```php
<?php

namespace App\Repositories;

use App\Contracts\UserRepository;
use App\Models\User;

class EloquentUserRepository implements UserRepository
{
    public function getById(int $id)
    {
        return User::find($id);
    }
}
```

#### 3. Criando o Proxy com cache
```php
<?php

namespace App\Repositories;

use App\Contracts\UserRepository;
use Illuminate\Support\Facades\Cache;

class CachedUserRepository implements UserRepository
{
    public function __construct(
        private UserRepository $repository
    ) {}

    public function getById(int $id)
    {
        return Cache::remember("user:{$id}", 60, function () use ($id) {
            return $this->repository->getById($id);
        });
    }
}
```

#### 4. Usando no Controller
```php
<?php

namespace App\Http\Controllers;

use App\Repositories\EloquentUserRepository;
use App\Repositories\CachedUserRepository;

class UserController extends Controller
{
    public function show(int $id)
    {
        // Define que vamos acessar via Proxy (com cache)
        $repository = new CachedUserRepository(
            new EloquentUserRepository()
        );

        $user = $repository->getById($id);

        return response()->json($user);
    }
}
```

## Vantagens
- Melhora a performance (com cache).
- Facilita controle de acesso (por exemplo, checar permissões no proxy).
- Adiciona lógica extra sem alterar o objeto original.

---

### 📚 Reflexão para o dia: 
O Proxy Pattern nos lembra que, muitas vezes, precisamos de filtros e camadas antes de acessar algo importante. Na sua vida, que “proxies” você poderia criar para proteger sua energia e seu foco do que não merece sua atenção imediata?