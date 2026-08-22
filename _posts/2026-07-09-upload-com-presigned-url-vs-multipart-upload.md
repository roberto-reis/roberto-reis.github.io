---
layout: post
title: "Upload com Presigned URL vs Multipart Upload: entenda as diferenças e quando utilizar cada abordagem"
categories: [Desenvolvimento, AWS, Backend]
excerpt: "Conheça as diferenças entre o upload utilizando Presigned URL e o Multipart Upload com Presigned URL no Amazon S3. Veja como cada abordagem funciona, suas vantagens e quando utilizar cada uma."
date: 2026-07-09T19:45:00-03:00
---

## Introdução

Ao desenvolver aplicações que realizam upload de arquivos para o Amazon S3, uma das decisões mais importantes é definir **como esses arquivos serão enviados**.

A AWS oferece duas estratégias bastante utilizadas:

- **Upload utilizando Presigned URL**
- **Multipart Upload com Presigned URL**

Embora ambas permitam que o cliente envie arquivos diretamente para o S3 sem passar pelo backend, elas possuem objetivos diferentes.

Neste artigo vamos entender como cada uma funciona, suas vantagens, limitações e quando escolher cada abordagem.

---

## O que é uma Presigned URL?

Uma **Presigned URL** é uma URL temporária gerada pelo backend que concede permissão para que um cliente execute uma operação específica no Amazon S3 durante um período determinado.

Na maioria dos casos, essa operação é um **upload (PUT)**.

O grande benefício é que **o arquivo não passa pelo backend**, reduzindo consumo de memória, processamento e banda.

O fluxo é bastante simples.

```text
               Solicita URL

Cliente ─────────────────────► Backend

Cliente ◄───────────────────── Backend
        Presigned URL

                Upload

Cliente ─────────────────────► Amazon S3

Cliente ─────────────────────► Backend
        Confirma upload
```

---

## Exemplo de Upload com Presigned URL

Imagine que um usuário deseja enviar um PDF de **15 MB**.

### 1. Cliente solicita uma URL

```http
POST /uploads/presign
```

Resposta:

```json
{
  "uploadUrl": "https://bucket.s3.amazonaws.com/documentos/contrato.pdf?...",
  "key": "documentos/contrato.pdf"
}
```

---

### 2. Cliente envia o arquivo

```http
PUT https://bucket.s3.amazonaws.com/documentos/contrato.pdf?...assinatura...
```

O upload acontece diretamente no Amazon S3.

---

### 3. Cliente confirma

```http
POST /uploads/confirm
```

O backend registra o arquivo no banco de dados.

Todo o processo acontece utilizando **apenas uma requisição de upload**.

---

## Vantagens da Presigned URL

- Implementação simples.
- Excelente desempenho.
- Backend não recebe o arquivo.
- Baixo consumo de recursos.
- Ideal para imagens, PDFs e documentos.

---

## Limitações

Como o arquivo é enviado em uma única requisição, caso a conexão seja interrompida perto do final do upload, será necessário reenviar o arquivo inteiro.

```text
Upload

█████████████████████░░ 95%

❌ Internet caiu

↓

Recomeçar do zero
```

Para arquivos pequenos isso normalmente não é um problema.

Já para arquivos de vários gigabytes, pode ser bastante inconveniente.

---

# O que é Multipart Upload?

O **Multipart Upload** resolve justamente esse problema.

Ao invés de enviar o arquivo inteiro em uma única requisição, ele é dividido em diversas partes menores.

Cada parte é enviada individualmente ao Amazon S3.

No final, o próprio S3 monta automaticamente o arquivo completo.

```text
Arquivo (900 MB)

        │

        ▼

 ┌───────────────┐
 │ Parte 1 100MB │
 └───────────────┘

 ┌───────────────┐
 │ Parte 2 100MB │
 └───────────────┘

 ┌───────────────┐
 │ Parte 3 100MB │
 └───────────────┘

        ...

        ▼

     Amazon S3

        ▼

Arquivo Final
```

---

## Fluxo do Multipart Upload

O processo possui mais etapas.

### 1. Criar o upload

O backend chama:

```
CreateMultipartUpload
```

O Amazon S3 retorna um **UploadId**.

---

### 2. Gerar Presigned URLs

O backend gera uma URL para cada parte.

Exemplo:

```text
Parte 1

↓

Presigned URL #1

Parte 2

↓

Presigned URL #2

Parte 3

↓

Presigned URL #3
```

---

### 3. Cliente divide o arquivo

Suponha um vídeo de **900 MB**.

```text
900 MB

↓

100 MB

100 MB

100 MB

...

100 MB
```

---

### 4. Cliente envia as partes

As partes podem ser enviadas em paralelo.

```text
Parte 1 ─────► Amazon S3

Parte 2 ─────► Amazon S3

Parte 3 ─────► Amazon S3

Parte 4 ─────► Amazon S3
```

Isso reduz bastante o tempo total do upload.

---

### 5. Receber os ETags

Cada upload retorna um **ETag**.

Esses identificadores serão utilizados para finalizar o upload.

---

### 6. Finalizar

O backend chama:

```
CompleteMultipartUpload
```

Enviando:

- UploadId
- Número da parte
- ETag

O Amazon S3 monta automaticamente o arquivo final.

---

## O que acontece se a internet cair?

Essa é a principal vantagem do Multipart Upload.

### Upload tradicional

```text
Parte única

█████████████████████░░ 95%

❌ Conexão perdida

↓

Reenviar tudo
```

### Multipart Upload

```text
Parte 1 ✔

Parte 2 ✔

Parte 3 ✔

Parte 4 ❌

↓

Reenviar apenas a Parte 4
```

As partes enviadas anteriormente permanecem armazenadas.

---

## Comparação entre as duas abordagens

| Característica | Presigned URL | Multipart Upload |
|----------------|---------------|------------------|
| Número de uploads | 1 | Vários |
| Número de URLs | 1 | Uma por parte |
| Complexidade | Baixa | Média |
| Upload paralelo | Não | Sim |
| Recuperação após falha | Não | Sim |
| Reenvio parcial | Não | Sim |
| Ideal para arquivos pequenos | Sim | Sim |
| Ideal para arquivos grandes | Não | Sim |

---

## Quando utilizar cada um?

### Utilize Presigned URL quando:

- enviar imagens;
- enviar PDFs;
- documentos;
- planilhas;
- arquivos pequenos ou médios;
- desejar uma implementação simples.

---

### Utilize Multipart Upload quando:

- enviar vídeos;
- backups;
- arquivos de centenas de MB;
- arquivos de vários GB;
- houver possibilidade de conexões instáveis;
- desejar melhor desempenho utilizando uploads paralelos.

---

## Qual escolher?

Não existe uma única resposta.

Uma estratégia bastante comum é:

| Tamanho do arquivo | Estratégia |
|--------------------|------------|
| Até 100 MB | Presigned URL |
| Entre 100 MB e 500 MB | Avaliar o cenário |
| Acima de 500 MB | Multipart Upload |
| Arquivos de vários GB | Multipart Upload |

Esses valores não são regras, mas uma referência bastante utilizada em aplicações modernas.

---

## Conclusão

Tanto a **Presigned URL** quanto o **Multipart Upload** seguem o mesmo princípio: permitir que o cliente envie arquivos diretamente ao Amazon S3, reduzindo a carga sobre o backend e melhorando a escalabilidade da aplicação.

A diferença está na forma como o upload é realizado.

A **Presigned URL tradicional** é simples e atende muito bem uploads de arquivos pequenos e médios.

Já o **Multipart Upload** adiciona robustez, permitindo uploads paralelos, recuperação após falhas e melhor desempenho para arquivos grandes.

Ao escolher a estratégia adequada para cada cenário, sua aplicação ganha em desempenho, confiabilidade e experiência do usuário.

---

### 📚 Reflexão para o dia

"Nem sempre a solução mais sofisticada é a melhor. Uma boa arquitetura é aquela que equilibra simplicidade e robustez, escolhendo a ferramenta certa para cada problema. Entender quando utilizar cada abordagem é tão importante quanto saber implementá-las."