# Cinevia — Banco de Dados de uma Plataforma de Streaming

**Projeto A3 · Banco de Dados** · Universidade São Judas Tadeu (USJT) — São Bernardo do Campo · 2026/2
**Professor:** Wilson Oliveira de Andrade · **SGBD:** PostgreSQL · **Domínio 3:** Plataforma de Streaming

A **Cinevia** é uma plataforma de streaming por assinatura que reúne filmes e séries em um único catálogo, com planos de diferentes preços, múltiplos dispositivos por usuário, histórico de "continuar assistindo" e avaliações de 0 a 10. Este repositório contém o banco de dados completo da plataforma: do modelo conceitual às consultas, incluindo segurança de acesso e transações.

## Integrantes

- Pedro Paulo Paschoal Cosme
- Luis Gustavo Battistini Guimarães
- Fábio Raime Denipóti
- Endrel de Sousa Lima
- Márcio Otávio Lopes Ferreira

## Resumo da entrega

| Etapa | O que foi feito | Arquivo |
| --- | --- | --- |
| Modelo conceitual | DER com especialização e relacionamentos N:N | `docs/` (Figura 1) |
| Modelo lógico | Esquema relacional normalizado até a 3FN e dicionário de dados | `docs/` |
| DDL | Criação das 12 tabelas, reexecutável | `sql/01_script_ddl.sql` |
| Carga de dados | 215 registros fictícios, cobrindo casos de borda (NULL, usuário sem avaliação etc.) | `sql/01b_carga_dados.sql` |
| DML | INSERT, UPDATE, DELETE, testes de integridade e cenário de concorrência | `sql/02_operacoes_dml.sql` |
| DQL I | 14 consultas sobre uma única tabela | `sql/03_consultas_dql.sql` |
| DQL II | 22 consultas com JOIN, GROUP BY, HAVING e funções de agregação | `sql/04_consultas_dql2.sql` |
| Subconsultas, view, DCL e TCL | 10 subconsultas, 1 view, 1 papel com GRANT/REVOKE e 7 passos de transação | `sql/05_Subconsultas_Views_DCL_TCL.sql` |
| Relatório | Documento completo com método, decisões e validação | `docs/Projeto_A3_Cinevia_Streaming.docx` |

## Modelo de dados

O banco tem **12 tabelas**: `usuario`, `plano_assinatura`, `assinatura`, `dispositivo`, `conteudo`, `filme`, `serie`, `episodio`, `genero`, `conteudo_genero`, `avaliacao` e `historico_visualizacao`.

**Padrões aplicados**

- **Especialização:** `conteudo` é o supertipo (título, ano, classificação); `filme` e `serie` são subtipos que reaproveitam a chave primária. Isso evita repetição de dados e colunas vazias.
- **Relacionamentos N:N:** conteúdo ↔ gênero (tabela `conteudo_genero`) e usuário ↔ conteúdo (tabela `avaliacao`).
- **Tabela de eventos:** `historico_visualizacao` liga usuário, dispositivo, conteúdo e, opcionalmente, episódio, e guarda o ponto em que a pessoa parou.
- **Normalização (3FN):** cada informação fica em um só lugar. Por exemplo, o preço mensal existe apenas em `plano_assinatura`.

**Regras de integridade no próprio banco**

| Regra | Onde | Efeito |
| --- | --- | --- |
| `UNIQUE` | e-mail e CPF do usuário | Não permite cadastro duplicado |
| `CHECK` | nota da avaliação | Aceita apenas valores de 0 a 10 |
| `CHECK` | tipo do conteúdo | Aceita apenas `FILME` ou `SERIE` |
| `ON DELETE RESTRICT` | plano de assinatura | Um plano em uso não pode ser apagado |
| `ON DELETE CASCADE` | dados do usuário | Apagar o usuário remove assinaturas, dispositivos, avaliações e histórico (atende pedidos de eliminação de dados da LGPD) |

O diagrama e o dicionário de dados completos estão no relatório em [`docs/`](docs/Projeto_A3_Cinevia_Streaming.docx).

## Destaques técnicos

- **Concorrência:** quando uma renovação automática e um cancelamento acontecem ao mesmo tempo, a transação trava a linha da assinatura com `SELECT ... FOR UPDATE`. A segunda operação espera o `COMMIT` da primeira e já enxerga o status atualizado, então uma assinatura cancelada não é renovada por engano.
- **Segurança e privacidade:** a view `vw_assinaturas_suporte` mostra ao atendimento os dados de assinatura **sem** `senha_hash`, `cpf` e `data_nascimento`. O papel `suporte` recebe `GRANT SELECT` apenas na view, nunca nas tabelas. O script também demonstra o `REVOKE`.
- **Transações:** cadastrar um filme exige gravar em duas tabelas (`conteudo` e `filme`). O script mostra o problema do "registro órfão" sem transação e como `BEGIN`, `COMMIT`, `ROLLBACK` e `SAVEPOINT` garantem que ou tudo é gravado ou nada é.
- **Reexecutável:** o DDL remove e recria as tabelas, e a carga limpa e recarrega tudo, então o ambiente sempre pode ser refeito do zero.

## Estrutura do repositório

```
cinevia-streaming/
├── docs/
│   └── Projeto_A3_Cinevia_Streaming.docx   # relatório completo (DER, modelo lógico, dicionário, consultas)
├── sql/
│   ├── 01_script_ddl.sql                   # cria as 12 tabelas (reexecutável)
│   ├── 01b_carga_dados.sql                 # carga de dados fictícios (reexecutável)
│   ├── 02_operacoes_dml.sql                # INSERT, UPDATE, DELETE e transação com FOR UPDATE
│   ├── 03_consultas_dql.sql                # 14 consultas simples
│   ├── 04_consultas_dql2.sql               # 22 consultas: JOIN, GROUP BY, HAVING, agregações
│   └── 05_Subconsultas_Views_DCL_TCL.sql   # subconsultas, view, DCL e TCL
├── .gitignore
└── README.md
```

## Como executar

**Pré-requisito:** PostgreSQL instalado e um usuário com permissão para criar banco e papéis (por exemplo, `postgres`). O script 05 cria o papel `suporte`, o que exige essa permissão.

Os scripts devem ser executados **na ordem numérica**:

```bash
# 1. Criar o banco
createdb -U postgres cinevia

# 2. Criar as tabelas
psql -U postgres -d cinevia -f sql/01_script_ddl.sql

# 3. Carregar os dados fictícios
psql -U postgres -d cinevia -f sql/01b_carga_dados.sql

# 4. Operações de manipulação de dados
psql -U postgres -d cinevia -f sql/02_operacoes_dml.sql

# 5. Consultas
psql -U postgres -d cinevia -f sql/03_consultas_dql.sql
psql -U postgres -d cinevia -f sql/04_consultas_dql2.sql

# 6. Subconsultas, view, permissões e transações
psql -U postgres -d cinevia -f sql/05_Subconsultas_Views_DCL_TCL.sql
```

Pelo **pgAdmin**: crie o banco `cinevia`, abra o Query Tool e execute o conteúdo de cada arquivo, também na ordem numérica. No script 05, alguns testes são feitos em execuções separadas (cada "Run" do Query Tool), conforme indicado nos comentários do próprio arquivo.

**Observações importantes**

- O script `02_operacoes_dml.sql` **altera** os dados. Para voltar ao estado original, execute novamente `01_script_ddl.sql` e `01b_carga_dados.sql`.
- Linhas comentadas com `-- ` dentro dos scripts são testes que **dão erro de propósito** (por exemplo, nota 11 ou apagar um plano em uso). Descomente e execute à parte para ver a mensagem de erro e a regra de integridade em ação.
- O papel `suporte` é um objeto do servidor e permanece após o script. Para refazer o teste do zero: `DROP OWNED BY suporte; DROP ROLE suporte;`.

## Volume dos dados

A carga contém **215 registros** distribuídos assim:

| Tabela | Registros | Tabela | Registros |
| --- | --- | --- | --- |
| `usuario` | 12 | `episodio` | 43 |
| `plano_assinatura` | 4 | `genero` | 12 |
| `assinatura` | 11 | `conteudo_genero` | 28 |
| `dispositivo` | 15 | `avaliacao` | 22 |
| `conteudo` | 15 | `historico_visualizacao` | 38 |
| `filme` | 10 | `serie` | 5 |

## Validação

Todos os scripts foram executados em um PostgreSQL 16, na ordem acima e sobre o esquema e a carga deste repositório, sem nenhum erro. O script 05 também foi reexecutado em seguida, sem erros, e a limpeza do Passo 7 devolve a base ao estado anterior à demonstração de transações.

## LGPD

Todos os dados do projeto são **fictícios**: nomes, e-mails e CPFs de exemplo, e hashes de senha inventados. Não há dados pessoais reais. O modelo foi pensado com a LGPD em mente: senha guardada apenas como hash, view sem dados sensíveis para o atendimento, acesso por papel com o mínimo de permissões e exclusão em cascata para pedidos de eliminação de dados.

## Escopo e limitações

Itens fora do escopo desta entrega:

- Índices adicionais para otimizar as consultas mais frequentes.
- Plano de backup e restauração testado.
- Relatório separado de administração e segurança do banco.

Os arquivos `.dump`, `.backup` e `.bak` estão no `.gitignore`, pois backups podem conter dados reais.
