-- ============================================================
-- Cinevia - Plataforma de Streaming
-- Projeto A3 - Banco de Dados | SGBD: PostgreSQL
-- Script DDL: remove e recria todas as tabelas (reexecutável)
-- ============================================================

-- ------------------------------------------------------------
-- 1) REMOÇÃO (ordem inversa de dependência)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS historico_visualizacao CASCADE;
DROP TABLE IF EXISTS avaliacao              CASCADE;
DROP TABLE IF EXISTS conteudo_genero        CASCADE;
DROP TABLE IF EXISTS genero                 CASCADE;
DROP TABLE IF EXISTS episodio               CASCADE;
DROP TABLE IF EXISTS serie                  CASCADE;
DROP TABLE IF EXISTS filme                  CASCADE;
DROP TABLE IF EXISTS conteudo               CASCADE;
DROP TABLE IF EXISTS dispositivo            CASCADE;
DROP TABLE IF EXISTS assinatura             CASCADE;
DROP TABLE IF EXISTS plano_assinatura       CASCADE;
DROP TABLE IF EXISTS usuario                CASCADE;

-- ------------------------------------------------------------
-- 2) CRIAÇÃO (ordem de dependência)
-- ------------------------------------------------------------

-- Cadastro do cliente da plataforma
CREATE TABLE usuario (
    id_usuario      SERIAL PRIMARY KEY,
    nome            VARCHAR(150) NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    senha_hash      VARCHAR(255) NOT NULL,          -- somente hash, nunca a senha
    cpf             VARCHAR(14)  NOT NULL UNIQUE,
    data_nascimento DATE         NOT NULL,
    data_cadastro   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Vitrine de planos e preços
CREATE TABLE plano_assinatura (
    id_plano                 SERIAL PRIMARY KEY,
    nome_plano               VARCHAR(50)   NOT NULL,
    preco_mensal             DECIMAL(10,2) NOT NULL,
    limite_telas_simultaneas INT           NOT NULL,
    qualidade_maxima         VARCHAR(20)   NOT NULL,
    permite_download         BOOLEAN       NOT NULL
);

-- Contrato entre um usuário e um plano
CREATE TABLE assinatura (
    id_assinatura        SERIAL PRIMARY KEY,
    id_usuario           INT         NOT NULL,
    id_plano             INT         NOT NULL,
    data_inicio          DATE        NOT NULL,
    data_fim             DATE,                       -- NULL = assinatura em aberto
    status               VARCHAR(20) NOT NULL,       -- 'ATIVA' ou 'CANCELADA'
    renovacao_automatica BOOLEAN     NOT NULL DEFAULT TRUE,
    forma_pagamento      VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,
    FOREIGN KEY (id_plano) REFERENCES plano_assinatura(id_plano)
        ON DELETE RESTRICT                           -- protege o histórico financeiro
);

-- Aparelhos registrados na conta
CREATE TABLE dispositivo (
    id_dispositivo   SERIAL PRIMARY KEY,
    id_usuario       INT          NOT NULL,
    tipo_dispositivo VARCHAR(50)  NOT NULL,
    nome_dispositivo VARCHAR(100) NOT NULL,
    data_registro    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_acesso    TIMESTAMP,                      -- NULL = nunca acessou
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
);

-- Supertipo do catálogo (filmes e séries)
CREATE TABLE conteudo (
    id_conteudo              SERIAL PRIMARY KEY,
    titulo_original          VARCHAR(200) NOT NULL,
    sinopse                  TEXT,
    ano_lancamento           INT          NOT NULL,
    classificacao_indicativa VARCHAR(10)  NOT NULL,  -- L, 10, 12, 14, 16, 18
    idioma_original          VARCHAR(50),
    tipo_conteudo            VARCHAR(20)  NOT NULL
        CHECK (tipo_conteudo IN ('FILME', 'SERIE'))
);

-- Subtipo: dados exclusivos de filmes (reaproveita a chave de conteudo)
CREATE TABLE filme (
    id_conteudo     INT PRIMARY KEY
        REFERENCES conteudo(id_conteudo) ON DELETE CASCADE,
    duracao_minutos INT NOT NULL CHECK (duracao_minutos >= 60),
    diretor         VARCHAR(150)
);

-- Subtipo: dados exclusivos de séries (reaproveita a chave de conteudo)
CREATE TABLE serie (
    id_conteudo     INT PRIMARY KEY
        REFERENCES conteudo(id_conteudo) ON DELETE CASCADE,
    total_temporadas INT         NOT NULL,
    status_producao  VARCHAR(50) NOT NULL            -- 'EM ANDAMENTO' ou 'ENCERRADA'
);

-- Capítulos de uma série
CREATE TABLE episodio (
    id_episodio      SERIAL PRIMARY KEY,
    id_conteudo      INT          NOT NULL,
    numero_temporada INT          NOT NULL,
    numero_episodio  INT          NOT NULL,
    titulo_episodio  VARCHAR(150) NOT NULL,
    duracao_minutos  INT          NOT NULL,
    data_lancamento  DATE,
    FOREIGN KEY (id_conteudo) REFERENCES serie(id_conteudo)
        ON DELETE CASCADE
);

-- Categorias do catálogo
CREATE TABLE genero (
    id_genero   SERIAL PRIMARY KEY,
    nome_genero VARCHAR(50) NOT NULL,
    descricao   TEXT
);

-- Associativa N:N entre conteúdo e gênero
CREATE TABLE conteudo_genero (
    id_conteudo INT NOT NULL,
    id_genero   INT NOT NULL,
    PRIMARY KEY (id_conteudo, id_genero),
    FOREIGN KEY (id_conteudo) REFERENCES conteudo(id_conteudo)
        ON DELETE CASCADE,
    FOREIGN KEY (id_genero) REFERENCES genero(id_genero)
        ON DELETE CASCADE
);

-- Nota e comentário de um usuário sobre um conteúdo (N:N usuário x conteúdo)
CREATE TABLE avaliacao (
    id_avaliacao   SERIAL PRIMARY KEY,
    id_usuario     INT       NOT NULL,
    id_conteudo    INT       NOT NULL,
    nota           INT       NOT NULL CHECK (nota BETWEEN 0 AND 10),
    comentario     TEXT,
    data_avaliacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,
    FOREIGN KEY (id_conteudo) REFERENCES conteudo(id_conteudo)
        ON DELETE CASCADE
);

-- Diário de cada "play" dado na plataforma
CREATE TABLE historico_visualizacao (
    id_historico             SERIAL PRIMARY KEY,
    id_usuario               INT       NOT NULL,
    id_dispositivo           INT       NOT NULL,
    id_conteudo              INT       NOT NULL,
    id_episodio              INT,                    -- nulo quando o usuário assiste a um FILME
    data_hora_inicio         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tempo_assistido_segundos INT       NOT NULL DEFAULT 0,
    concluido                BOOLEAN   NOT NULL DEFAULT FALSE,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,
    FOREIGN KEY (id_dispositivo) REFERENCES dispositivo(id_dispositivo)
        ON DELETE CASCADE,
    FOREIGN KEY (id_conteudo) REFERENCES conteudo(id_conteudo)
        ON DELETE CASCADE,
    FOREIGN KEY (id_episodio) REFERENCES episodio(id_episodio)
        ON DELETE CASCADE
);
