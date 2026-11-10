-- ============================================================
-- Cinevia - Plataforma de Streaming
-- Carga de dados de exemplo (fictícios) para o banco inteiro
-- Execute DEPOIS do 01_script_ddl.sql e ANTES de todos os outros.
-- Pode ser reexecutado: limpa as tabelas e recarrega tudo.
-- Os dados foram pensados para que TODAS as consultas dos
-- arquivos 03, 04 e 05 devolvam linhas (inclusive os casos de
-- NULL, usuários sem avaliação, sem assinatura ativa etc.).
-- ============================================================

BEGIN;

-- Limpa tudo e zera os contadores (SERIAL). CASCADE cuida das chaves estrangeiras.
TRUNCATE TABLE historico_visualizacao, avaliacao, conteudo_genero, genero,
               episodio, serie, filme, conteudo, dispositivo, assinatura,
               plano_assinatura, usuario
RESTART IDENTITY CASCADE;

-- ------------------------------------------------------------
-- 1) usuario, plano_assinatura, genero, conteudo
-- ------------------------------------------------------------

INSERT INTO usuario (id_usuario, nome, email, senha_hash, cpf, data_nascimento, data_cadastro) VALUES
    (1, 'Ana Beatriz Lima', 'ana.lima@exemplo.com', '$2b$12$hashficticio000000000001', '000.000.001-01', '1992-03-14', '2025-02-10 09:15:00'),
    (2, 'Bruno Carvalho', 'bruno.carvalho@exemplo.com', '$2b$12$hashficticio000000000002', '000.000.002-02', '1988-07-21', '2025-02-28 18:40:00'),
    (3, 'Carla Mendes', 'carla.mendes@exemplo.com', '$2b$12$hashficticio000000000003', '000.000.003-03', '1995-11-05', '2025-06-10 21:05:00'),
    (4, 'Diego Ferreira', 'diego.ferreira@exemplo.com', '$2b$12$hashficticio000000000004', '000.000.004-04', '1985-01-30', '2025-09-15 14:22:00'),
    (5, 'Eduarda Rocha', 'eduarda.rocha@exemplo.com', '$2b$12$hashficticio000000000005', '000.000.005-05', '1999-04-17', '2026-01-10 10:00:00'),
    (6, 'Felipe Santos', 'felipe.santos@exemplo.com', '$2b$12$hashficticio000000000006', '000.000.006-06', '1997-08-09', '2026-02-01 19:30:00'),
    (7, 'Gabriela Alves', 'gabriela.alves@exemplo.com', '$2b$12$hashficticio000000000007', '000.000.007-07', '1990-12-25', '2026-03-15 08:45:00'),
    (8, 'Henrique Costa', 'henrique.costa@exemplo.com', '$2b$12$hashficticio000000000008', '000.000.008-08', '1983-05-02', '2025-03-28 16:10:00'),
    (9, 'Isabela Martins', 'isabela.martins@exemplo.com', '$2b$12$hashficticio000000000009', '000.000.009-09', '1994-10-11', '2025-07-05 11:25:00'),
    (10, 'João Pedro Nunes', 'joao.nunes@exemplo.com', '$2b$12$hashficticio000000000010', '000.000.010-10', '2001-09-30', '2026-05-20 20:00:00'),
    (11, 'Karina Duarte', 'karina.duarte@exemplo.com', '$2b$12$hashficticio000000000011', '000.000.011-11', '2003-06-19', '2026-08-14 13:50:00'),
    (12, 'Lucas Ribeiro', 'lucas.ribeiro@exemplo.com', '$2b$12$hashficticio000000000012', '000.000.012-12', '2004-11-02', '2026-10-30 22:15:00');

INSERT INTO plano_assinatura (id_plano, nome_plano, preco_mensal, limite_telas_simultaneas, qualidade_maxima, permite_download) VALUES
    (1, 'Básico', 19.9, 1, 'HD', FALSE),
    (2, 'Padrão', 29.9, 2, 'Full HD', TRUE),
    (3, 'Premium', 44.9, 4, '4K', TRUE),
    (4, 'Família', 59.9, 6, '4K', TRUE);

INSERT INTO genero (id_genero, nome_genero, descricao) VALUES
    (1, 'Ação', 'Perseguições, lutas e muita adrenalina'),
    (2, 'Comédia', 'Histórias leves para rir'),
    (3, 'Drama', 'Narrativas intensas e emotivas'),
    (4, 'Romance', 'Relações amorosas no centro da trama'),
    (5, 'Terror', 'Suspense sobrenatural e medo'),
    (6, 'Suspense', 'Tensão e reviravoltas'),
    (7, 'Ficção Científica', 'Futuro, tecnologia e universos alternativos'),
    (8, 'Família', 'Conteúdo para assistir em conjunto'),
    (9, 'Animação', 'Desenhos e animações'),
    (10, 'Documentário', 'Histórias reais'),
    (11, 'Crime', 'Investigações e submundo'),
    (12, 'Musical', 'Histórias contadas através da música');

INSERT INTO conteudo (id_conteudo, titulo_original, sinopse, ano_lancamento, classificacao_indicativa, idioma_original, tipo_conteudo) VALUES
    (1, 'O Último Verão', 'Um reencontro de amigos de infância revela segredos de uma temporada inesquecível.', 2022, '12', 'Português', 'FILME'),
    (2, 'Cartas de Amor em Lisboa', 'Uma tradutora descobre cartas antigas que mudam sua vida.', 2019, '12', 'Português', 'FILME'),
    (3, 'Operação Sombra', 'Um agente é caçado pela própria agência após uma missão fracassada.', 2023, '16', 'Inglês', 'FILME'),
    (4, 'A Casa do Penhasco', 'Uma família se muda para uma casa isolada com um passado sombrio.', 2021, '16', 'Inglês', 'FILME'),
    (5, 'Risos no Escuro', 'Uma queda de energia transforma um jantar em uma noite caótica.', 2020, '14', 'Português', 'FILME'),
    (6, 'Estrela do Sertão', 'Uma menina atravessa o sertão em busca da estrela que caiu perto de casa.', 2024, 'L', 'Português', 'FILME'),
    (7, 'Rota Final', 'Uma equipe de resgate cruza a fronteira em uma corrida contra o tempo.', 2025, '18', 'Inglês', 'FILME'),
    (8, 'Amor e Tempestade', 'Dois estranhos ficam presos em uma ilha durante uma tempestade.', 2017, '12', 'Francês', 'FILME'),
    (9, 'O Código Perdido', 'Uma cientista decifra uma mensagem enviada do futuro.', 2026, '12', NULL, 'FILME'),
    (10, 'Noite de Pipoca', 'Três irmãos tentam organizar a maior sessão de cinema do bairro.', 2016, '10', 'Português', 'FILME'),
    (11, 'Fronteira Norte', 'Policiais de uma cidade de fronteira enfrentam uma rede de contrabando.', 2021, '16', 'Português', 'SERIE'),
    (12, 'Código Aurora', 'Uma equipe de pesquisa descobre um sinal que não deveria existir.', 2023, '14', 'Inglês', 'SERIE'),
    (13, 'Sabores do Brasil', 'Uma viagem pela culinária de cada região do país.', 2019, 'L', 'Português', 'SERIE'),
    (14, 'Corações em Conflito', 'Duas famílias rivais se unem quando seus filhos se apaixonam.', 2020, '12', 'Português', 'SERIE'),
    (15, 'Madrugada', 'Moradores de um prédio vivem fenômenos estranhos sempre às três da manhã.', 2024, '18', 'Português', 'SERIE');

-- ------------------------------------------------------------
-- 2) assinatura, dispositivo, filme, serie
-- ------------------------------------------------------------

INSERT INTO assinatura (id_assinatura, id_usuario, id_plano, data_inicio, data_fim, status, renovacao_automatica, forma_pagamento) VALUES
    (1, 1, 1, '2025-02-10', '2025-05-09', 'CANCELADA', FALSE, 'Cartão de crédito'),
    (2, 1, 2, '2025-05-10', NULL, 'ATIVA', TRUE, 'Cartão de crédito'),
    (3, 2, 3, '2025-03-01', NULL, 'ATIVA', TRUE, 'Cartão de crédito'),
    (4, 3, 1, '2025-06-15', NULL, 'ATIVA', FALSE, 'Pix'),
    (5, 4, 2, '2025-09-20', NULL, 'ATIVA', TRUE, 'Boleto'),
    (6, 5, 2, '2026-01-12', NULL, 'ATIVA', FALSE, 'Cartão de crédito'),
    (7, 6, 2, '2026-02-03', NULL, 'ATIVA', TRUE, 'Pix'),
    (8, 7, 3, '2026-03-18', NULL, 'ATIVA', TRUE, 'Cartão de crédito'),
    (9, 8, 2, '2025-04-01', '2026-03-31', 'CANCELADA', FALSE, 'Boleto'),
    (10, 9, 1, '2025-07-10', '2025-10-10', 'CANCELADA', FALSE, 'Pix'),
    (11, 10, 1, '2026-05-22', NULL, 'ATIVA', TRUE, 'Pix');

INSERT INTO dispositivo (id_dispositivo, id_usuario, tipo_dispositivo, nome_dispositivo, data_registro, ultimo_acesso) VALUES
    (1, 1, 'Smart TV', 'TV da Sala', '2025-02-10 09:30:00', '2026-11-08 21:10:00'),
    (2, 1, 'Celular', 'Celular da Ana', '2025-02-11 07:50:00', '2026-11-09 07:45:00'),
    (3, 1, 'Notebook', 'Notebook do Trabalho', '2025-05-12 12:00:00', '2026-10-20 12:30:00'),
    (4, 2, 'Smart TV', 'TV do Quarto', '2025-03-01 20:00:00', '2026-11-07 22:00:00'),
    (5, 2, 'Celular', 'Celular do Bruno', '2025-03-02 08:15:00', '2026-11-09 08:00:00'),
    (6, 3, 'Celular', 'Celular da Carla', '2025-06-15 19:00:00', '2026-11-06 23:10:00'),
    (7, 4, 'Smart TV', 'TV da Sala', '2025-09-20 18:20:00', '2026-11-05 20:45:00'),
    (8, 4, 'Tablet', 'Tablet Antigo', '2025-09-22 10:00:00', NULL),
    (9, 5, 'Notebook', 'Notebook da Eduarda', '2026-01-12 11:00:00', '2026-11-04 10:20:00'),
    (10, 6, 'Celular', 'Celular do Felipe', '2026-02-03 20:30:00', '2026-11-08 18:00:00'),
    (11, 7, 'Smart TV', 'TV da Sala', '2026-03-18 21:00:00', '2026-11-07 21:30:00'),
    (12, 7, 'Celular', 'Celular da Gabriela', '2026-03-19 09:00:00', '2026-11-09 06:50:00'),
    (13, 8, 'Tablet', 'Tablet do Henrique', '2025-04-01 17:00:00', '2026-03-30 19:00:00'),
    (14, 10, 'Celular', 'Celular do João', '2026-05-22 20:15:00', '2026-11-08 22:40:00'),
    (15, 6, 'Smart TV', 'TV da Sala (nova)', '2026-09-10 15:00:00', NULL);

INSERT INTO filme (id_conteudo, duracao_minutos, diretor) VALUES
    (1, 112, 'Marcos Tavares'),
    (2, 104, 'Helena Vasconcelos'),
    (3, 128, 'Daniel Hoffman'),
    (4, 98, 'Ricardo Pinheiro'),
    (5, 95, 'Patrícia Gomes'),
    (6, 88, 'Luiza Amaral'),
    (7, 141, 'Daniel Hoffman'),
    (8, 117, 'Claire Dubois'),
    (9, 134, 'Rafael Monteiro'),
    (10, 92, 'Patrícia Gomes');

INSERT INTO serie (id_conteudo, total_temporadas, status_producao) VALUES
    (11, 2, 'EM ANDAMENTO'),
    (12, 2, 'EM ANDAMENTO'),
    (13, 2, 'ENCERRADA'),
    (14, 2, 'ENCERRADA'),
    (15, 1, 'EM ANDAMENTO');

-- ------------------------------------------------------------
-- 3) episodio, conteudo_genero, avaliacao
-- ------------------------------------------------------------

INSERT INTO episodio (id_episodio, id_conteudo, numero_temporada, numero_episodio, titulo_episodio, duracao_minutos, data_lancamento) VALUES
    (1, 11, 1, 1, 'Cruzando a Linha', 52, '2021-01-11'),
    (2, 11, 1, 2, 'O Primeiro Carregamento', 55, '2021-02-12'),
    (3, 11, 1, 3, 'Informante', 49, '2021-03-13'),
    (4, 11, 1, 4, 'Fogo Cruzado', 58, '2021-04-14'),
    (5, 11, 1, 5, 'A Casa Segura', 51, '2021-05-15'),
    (6, 11, 1, 6, 'Sem Retorno', 60, '2021-06-16'),
    (7, 11, 2, 1, 'Terra de Ninguém', 54, '2022-01-11'),
    (8, 11, 2, 2, 'O Novo Delegado', 50, '2022-02-12'),
    (9, 11, 2, 3, 'Rastros', 57, '2022-03-13'),
    (10, 11, 2, 4, 'Maré Alta', 53, '2022-04-14'),
    (11, 11, 2, 5, 'Traição', 56, '2022-05-15'),
    (12, 11, 2, 6, 'O Último Túnel', 61, '2022-06-16'),
    (13, 12, 1, 1, 'Sinal', 45, '2023-01-11'),
    (14, 12, 1, 2, 'Ruído Branco', 48, '2023-02-12'),
    (15, 12, 1, 3, 'Protocolo Zero', 52, '2023-03-13'),
    (16, 12, 1, 4, 'Eco', 47, '2023-04-14'),
    (17, 12, 2, 1, 'Contato', 50, '2024-01-11'),
    (18, 12, 2, 2, 'Linha do Tempo', 46, '2024-02-12'),
    (19, 12, 2, 3, 'Zona Morta', 53, '2024-03-13'),
    (20, 12, 2, 4, 'Aurora', 58, '2024-04-14'),
    (21, 13, 1, 1, 'Norte: Sabores da Floresta', 32, '2019-01-11'),
    (22, 13, 1, 2, 'Nordeste: Sol e Sal', 30, '2019-02-12'),
    (23, 13, 1, 3, 'Centro-Oeste: Pequi e Tradição', 35, '2019-03-13'),
    (24, 13, 1, 4, 'Sudeste: Mesa Mineira', 31, '2019-04-14'),
    (25, 13, 1, 5, 'Sul: Fogo de Chão', 34, '2019-05-15'),
    (26, 13, 2, 1, 'Feiras Livres', 33, '2020-01-11'),
    (27, 13, 2, 2, 'Doces de Tacho', 29, '2020-02-12'),
    (28, 13, 2, 3, 'Peixes de Rio', 36, '2020-03-13'),
    (29, 13, 2, 4, 'Cozinha de Rua', 32, '2020-04-14'),
    (30, 13, 2, 5, 'Festas e Receitas', 30, '2020-05-15'),
    (31, 14, 1, 1, 'Dois Sobrenomes', 44, '2020-01-11'),
    (32, 14, 1, 2, 'O Baile', 41, '2020-02-12'),
    (33, 14, 1, 3, 'Segredos de Família', 46, '2020-03-13'),
    (34, 14, 1, 4, 'Fuga', 43, '2020-04-14'),
    (35, 14, 2, 1, 'Reencontro', 45, '2021-01-11'),
    (36, 14, 2, 2, 'A Herança', 42, '2021-02-12'),
    (37, 14, 2, 3, 'Pedido Impossível', 47, '2021-03-13'),
    (38, 14, 2, 4, 'Recomeço', 50, '2021-04-14'),
    (39, 15, 1, 1, 'Três da Manhã', 42, '2024-01-11'),
    (40, 15, 1, 2, 'O Andar Vazio', 55, '2024-02-12'),
    (41, 15, 1, 3, 'Vozes no Elevador', 48, '2024-03-13'),
    (42, 15, 1, 4, 'O Morador do 7', 51, '2024-04-14'),
    (43, 15, 1, 5, 'Amanhecer', 59, '2024-05-15');

INSERT INTO conteudo_genero (id_conteudo, id_genero) VALUES
    (1, 3),
    (1, 4),
    (2, 4),
    (2, 3),
    (3, 1),
    (3, 6),
    (4, 5),
    (4, 6),
    (5, 2),
    (6, 9),
    (6, 8),
    (7, 1),
    (7, 11),
    (8, 4),
    (8, 3),
    (9, 7),
    (9, 6),
    (10, 2),
    (10, 8),
    (11, 3),
    (11, 11),
    (12, 7),
    (12, 6),
    (13, 10),
    (14, 4),
    (14, 3),
    (15, 5),
    (15, 6);

INSERT INTO avaliacao (id_avaliacao, id_usuario, id_conteudo, nota, comentario, data_avaliacao) VALUES
    (1, 1, 1, 9, 'Emocionante do começo ao fim.', '2026-02-11 20:10:00'),
    (2, 2, 1, 8, 'Ótima fotografia.', '2026-02-15 21:00:00'),
    (3, 3, 1, 7, NULL, '2026-03-02 22:30:00'),
    (4, 1, 3, 8, 'Muita ação e boa trilha.', '2026-03-10 23:00:00'),
    (5, 4, 3, 6, NULL, '2026-03-20 21:45:00'),
    (6, 5, 3, 9, 'Roteiro afiado.', '2026-04-01 22:15:00'),
    (7, 2, 2, 10, 'Meu favorito do ano.', '2026-04-12 20:20:00'),
    (8, 6, 2, 8, 'Sensível e bonito.', '2026-04-18 19:50:00'),
    (9, 7, 5, 5, 'Esperava mais humor.', '2026-05-03 21:10:00'),
    (10, 3, 5, 6, NULL, '2026-05-09 22:00:00'),
    (11, 1, 11, 10, 'Série perfeita.', '2026-06-01 21:30:00'),
    (12, 2, 11, 9, 'Viciante.', '2026-06-05 23:10:00'),
    (13, 4, 11, 8, 'Ótimo elenco.', '2026-06-14 20:40:00'),
    (14, 5, 12, 7, NULL, '2026-06-20 22:20:00'),
    (15, 6, 12, 8, 'Boas ideias, final apressado.', '2026-06-28 21:05:00'),
    (16, 7, 13, 9, 'Leve e informativa.', '2026-07-04 18:30:00'),
    (17, 8, 4, 4, 'Previsível.', '2026-02-20 20:00:00'),
    (18, 8, 7, 6, NULL, '2026-03-05 21:15:00'),
    (19, 4, 8, 8, 'Trilha linda.', '2026-07-19 22:50:00'),
    (20, 7, 15, 7, 'Tensa na medida.', '2026-08-02 23:30:00'),
    (21, 3, 14, 9, 'Chorei em todos os episódios.', '2026-08-15 21:55:00'),
    (22, 10, 6, 10, 'Meus filhos adoraram.', '2026-09-06 16:20:00');

-- ------------------------------------------------------------
-- 4) historico_visualizacao (filme: id_episodio NULL; série: id do episódio)
-- ------------------------------------------------------------

INSERT INTO historico_visualizacao (id_historico, id_usuario, id_dispositivo, id_conteudo, id_episodio, data_hora_inicio, tempo_assistido_segundos, concluido) VALUES
    (1, 3, 6, 1, NULL, '2026-03-01 21:00:00', 900, FALSE),
    (2, 1, 1, 1, NULL, '2026-02-10 21:15:00', 6720, TRUE),
    (3, 2, 4, 1, NULL, '2026-02-14 20:30:00', 6700, TRUE),
    (4, 5, 9, 1, NULL, '2026-03-05 14:00:00', 6710, TRUE),
    (5, 1, 2, 3, NULL, '2026-03-09 22:00:00', 7680, TRUE),
    (6, 4, 7, 3, NULL, '2026-03-18 20:30:00', 1500, FALSE),
    (7, 5, 9, 3, NULL, '2026-03-30 15:10:00', 1100, FALSE),
    (8, 6, 10, 3, NULL, '2026-04-02 19:00:00', 2000, FALSE),
    (9, 2, 5, 2, NULL, '2026-04-10 07:30:00', 6240, TRUE),
    (10, 6, 10, 2, NULL, '2026-04-17 19:00:00', 6250, TRUE),
    (11, 7, 11, 2, NULL, '2026-04-20 21:00:00', 6230, TRUE),
    (12, 7, 12, 5, NULL, '2026-05-02 08:00:00', 1800, FALSE),
    (13, 3, 6, 5, NULL, '2026-05-08 21:30:00', 900, FALSE),
    (14, 10, 14, 6, NULL, '2026-06-07 17:00:00', 5280, TRUE),
    (15, 8, 13, 4, NULL, '2026-02-18 20:00:00', 5880, TRUE),
    (16, 8, 13, 7, NULL, '2026-03-04 21:00:00', 3000, FALSE),
    (17, 4, 7, 8, NULL, '2026-07-18 21:00:00', 7000, TRUE),
    (18, 7, 11, 9, NULL, '2026-10-02 21:20:00', 1200, FALSE),
    (19, 1, 1, 9, NULL, '2026-10-05 22:00:00', 600, FALSE),
    (20, 10, 14, 10, NULL, '2026-06-15 18:00:00', 5520, TRUE),
    (21, 1, 1, 11, 1, '2026-05-20 21:00:00', 3120, TRUE),
    (22, 1, 1, 11, 2, '2026-05-21 21:00:00', 3300, TRUE),
    (23, 1, 1, 11, 3, '2026-05-22 21:00:00', 2940, TRUE),
    (24, 2, 4, 11, 1, '2026-06-03 22:00:00', 3120, TRUE),
    (25, 2, 4, 11, 2, '2026-06-04 22:00:00', 900, FALSE),
    (26, 4, 7, 11, 1, '2026-06-12 20:30:00', 3110, TRUE),
    (27, 5, 9, 12, 13, '2026-06-18 21:00:00', 2700, TRUE),
    (28, 5, 9, 12, 14, '2026-06-19 21:00:00', 2880, TRUE),
    (29, 6, 10, 12, 13, '2026-06-25 19:30:00', 2690, TRUE),
    (30, 6, 10, 12, 14, '2026-06-26 19:30:00', 1000, FALSE),
    (31, 7, 12, 13, 21, '2026-07-03 08:10:00', 1920, TRUE),
    (32, 7, 12, 13, 22, '2026-07-04 08:10:00', 1800, TRUE),
    (33, 3, 6, 14, 31, '2026-08-10 22:00:00', 2640, TRUE),
    (34, 3, 6, 14, 32, '2026-08-11 22:00:00', 2460, TRUE),
    (35, 3, 6, 14, 33, '2026-08-12 22:00:00', 2760, TRUE),
    (36, 7, 11, 14, 31, '2026-08-14 21:30:00', 2650, TRUE),
    (37, 7, 12, 15, 39, '2026-08-01 23:10:00', 900, FALSE),
    (38, 3, 6, 15, 39, '2026-08-20 23:00:00', 2520, TRUE);

-- ------------------------------------------------------------
-- Acerta os contadores (SERIAL): como os ids foram informados à mão,
-- o próximo INSERT sem id precisa continuar depois do maior id usado.
-- ------------------------------------------------------------
SELECT setval(pg_get_serial_sequence('usuario',                'id_usuario'),   (SELECT MAX(id_usuario)   FROM usuario));
SELECT setval(pg_get_serial_sequence('plano_assinatura',       'id_plano'),     (SELECT MAX(id_plano)     FROM plano_assinatura));
SELECT setval(pg_get_serial_sequence('assinatura',             'id_assinatura'),(SELECT MAX(id_assinatura)FROM assinatura));
SELECT setval(pg_get_serial_sequence('dispositivo',            'id_dispositivo'),(SELECT MAX(id_dispositivo) FROM dispositivo));
SELECT setval(pg_get_serial_sequence('conteudo',               'id_conteudo'),  (SELECT MAX(id_conteudo)  FROM conteudo));
SELECT setval(pg_get_serial_sequence('episodio',               'id_episodio'),  (SELECT MAX(id_episodio)  FROM episodio));
SELECT setval(pg_get_serial_sequence('genero',                 'id_genero'),    (SELECT MAX(id_genero)    FROM genero));
SELECT setval(pg_get_serial_sequence('avaliacao',              'id_avaliacao'), (SELECT MAX(id_avaliacao) FROM avaliacao));
SELECT setval(pg_get_serial_sequence('historico_visualizacao', 'id_historico'), (SELECT MAX(id_historico) FROM historico_visualizacao));

COMMIT;

-- Conferência rápida (esperado: 12 usuários, 4 planos, 11 assinaturas, 15 dispositivos,
-- 15 conteúdos (10 filmes + 5 séries), 43 episódios, 12 gêneros, 22 avaliações, 38 exibições)
SELECT (SELECT COUNT(*) FROM usuario)                AS usuarios,
       (SELECT COUNT(*) FROM plano_assinatura)       AS planos,
       (SELECT COUNT(*) FROM assinatura)             AS assinaturas,
       (SELECT COUNT(*) FROM dispositivo)            AS dispositivos,
       (SELECT COUNT(*) FROM filme)                  AS filmes,
       (SELECT COUNT(*) FROM serie)                  AS series,
       (SELECT COUNT(*) FROM episodio)               AS episodios,
       (SELECT COUNT(*) FROM genero)                 AS generos,
       (SELECT COUNT(*) FROM avaliacao)              AS avaliacoes,
       (SELECT COUNT(*) FROM historico_visualizacao) AS exibicoes;
