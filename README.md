# Cinevia — Plataforma de Streaming

Projeto A3 da disciplina de **Banco de Dados** (USJT São Bernardo do Campo, 2026/2).
Professor: Wilson Oliveira de Andrade · SGBD: **PostgreSQL** · Domínio 3: Plataforma de Streaming.

A **Cinevia** é uma plataforma de streaming por assinatura que reúne filmes e séries em um único catálogo, com planos, múltiplos dispositivos, histórico de "continuar assistindo" e avaliações de 0 a 10.

## Integrantes

- Pedro Paulo Paschoal Cosme
- Luis Gustavo Battistini Guimarães
- Fábio Raime Denipóti
- Endrel de Sousa Lima
- Márcio Otávio Lopes Ferreira

## O que o projeto cobre

Todo o ciclo de vida do banco de dados:

1. Modelo conceitual (DER)
2. Modelo lógico normalizado (até a 3FN)
3. Script DDL reexecutável
4. Manipulação de dados (DML), incluindo cenário de concorrência
5. Consultas (DQL)

## Modelo de dados

12 tabelas: `usuario`, `plano_assinatura`, `assinatura`, `dispositivo`, `conteudo`, `filme`, `serie`, `episodio`, `genero`, `conteudo_genero`, `avaliacao` e `historico_visualizacao`.

Padrões aplicados:

- **Especialização:** `conteudo` é o supertipo; `filme` e `serie` são subtipos que reaproveitam a chave primária.
- **Relacionamentos N:N:** conteúdo ↔ gênero (`conteudo_genero`) e usuário ↔ conteúdo (`avaliacao`).
- **Tabela de eventos:** `historico_visualizacao` liga usuário, dispositivo, conteúdo e (opcionalmente) episódio.
- **Integridade:** `PRIMARY KEY`, `UNIQUE` (email e CPF), `CHECK` (tipo de conteúdo, nota de 0 a 10), `DEFAULT`, `ON DELETE CASCADE` e `ON DELETE RESTRICT` (um plano em uso não pode ser apagado).

O diagrama e o dicionário de dados completos estão no documento em [`docs/`](docs/Projeto_A3_Cinevia_Streaming.docx).

## Estrutura do repositório

```
cinevia-streaming/
├── docs/
│   └── Projeto_A3_Cinevia_Streaming.docx   # relatório completo (DER, modelo lógico, dicionário)
├── sql/
│   ├── 01_script_ddl.sql                   # cria todas as tabelas (reexecutável)
│   ├── 02_operacoes_dml.sql                # INSERT, UPDATE, DELETE e transação com FOR UPDATE
│   └── 03_consultas_dql.sql                # 14 consultas (Q1 a Q14)
├── .gitignore
└── README.md
```

## Como executar

Pré-requisito: PostgreSQL instalado.

```bash
# 1. Criar o banco
createdb cinevia

# 2. Criar as tabelas
psql -d cinevia -f sql/01_script_ddl.sql

# 3. (Opcional) Rodar as consultas depois de carregar dados
psql -d cinevia -f sql/03_consultas_dql.sql
```

Ou pelo **pgAdmin**: crie o banco `cinevia`, abra o Query Tool e execute o conteúdo de `01_script_ddl.sql`.

> Os dados utilizados no projeto são fictícios ou de fonte aberta, sem dados pessoais reais (LGPD).

## Próximas etapas

- Carga completa dos dados
- Consultas com `JOIN` e agregações, e índices
- Plano de transações
- Plano de backup testado
- Relatório de administração, segurança e LGPD
