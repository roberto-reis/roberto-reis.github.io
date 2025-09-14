---
layout: post
title: "Builder Pattern em Laravel: construindo objetos complexos de forma organizada"
categories: [Programação, Design Patterns, Laravel]
excerpt: Um exemplo prático de como aplicar o padrão Builder em Laravel para criar objetos passo a passo sem complicar o código.
date: 2025-09-14T16:15:00-03:00
---

### O que é o Builder Pattern?

O **Builder Pattern** é um padrão de projeto **criacional** que permite **construir objetos complexos passo a passo**, separando a lógica de construção da representação final.  

Isso é útil quando o objeto possui **muitos parâmetros opcionais** ou precisa ser montado em etapas diferentes.  

Em vez de um construtor gigante cheio de parâmetros, o Builder oferece uma forma **fluida e legível** de criar instâncias.  

### Exemplo prático em Laravel: geração de relatórios

Imagine que você precisa gerar relatórios em PDF.  
Cada relatório pode ter várias seções: **cabeçalho, corpo, rodapé, gráficos, tabelas**… mas nem todos os relatórios terão tudo isso.  

Com o **Builder Pattern**, podemos montar relatórios personalizados sem complicar.  

### Implementando o Builder Pattern

#### 1. Criando o produto final
```php
<?php

namespace App\Reports;

class Report
{
    public string $header = '';
    public string $body = '';
    public string $footer = '';

    public function output(): string
    {
        return "{$this->header}\n{$this->body}\n{$this->footer}";
    }
}
```

#### 2. Definindo o Builder
```php
<?php

namespace App\Reports;

interface ReportBuilder
{
    public function setHeader(string $text): self;
    public function setBody(string $text): self;
    public function setFooter(string $text): self;
    public function build(): Report;
}
```

#### 3. Criando um Builder concreto
```php
<?php

namespace App\Reports;

class PdfReportBuilder implements ReportBuilder
{
    private Report $report;

    public function __construct()
    {
        $this->report = new Report();
    }

    public function setHeader(string $text): self
    {
        $this->report->header = "PDF Header: {$text}";
        return $this;
    }

    public function setBody(string $text): self
    {
        $this->report->body = "PDF Body: {$text}";
        return $this;
    }

    public function setFooter(string $text): self
    {
        $this->report->footer = "PDF Footer: {$text}";
        return $this;
    }

    public function build(): Report
    {
        return $this->report;
    }
}
```

#### 4. Usando o Builder no Controller
```php
<?php

namespace App\Http\Controllers;

use App\Reports\PdfReportBuilder;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function gerar(Request $request)
    {
        $builder = new PdfReportBuilder();

        $report = $builder
            ->setHeader("Relatório Financeiro")
            ->setBody("Corpo do relatório com dados e gráficos...")
            ->setFooter("Confidencial - 2025")
            ->build();

        return response()->json([
            'conteudo' => $report->output()
        ]);
    }
}
```

### Vantagens
- 🧱 Permite criar objetos complexos passo a passo.
- 📖 Código mais legível e expressivo.
- 🔄 Flexibilidade para criar diferentes variações de um mesmo objeto.

---

### 📚 Reflexão para o dia:
**Assim como o Builder nos ensina a construir objetos complexos passo a passo, na vida também podemos encarar grandes projetos em pequenas etapas. O que você pode começar a construir hoje, mesmo que seja apenas o primeiro passo?**