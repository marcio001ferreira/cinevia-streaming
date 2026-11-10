-- ============================================================
-- Cinevia - Plataforma de Streaming
-- Subconsultas, Views, DCL e TCL (10 subconsultas, 1 view, 1 papel
-- com GRANT/REVOKE e 7 passos de transação)
-- Método: rode a subconsulta SOZINHA primeiro (valor, lista ou tabela?)
--         e só então encaixe na consulta de fora (=, IN, EXISTS, FROM)
-- Linhas começadas por "-- " dentro dos blocos são testes que DÃO ERRO de
-- propósito: descomente e rode à parte para ver a mensagem.
-- ============================================================

-- ------------------------------------------------------------
-- Parte 1: Subconsultas
-- ------------------------------------------------------------

-- Q1. Planos com preço acima da média, sem escrever a média na mão.
SELECT nome_plano, preco_mensal
FROM plano_assinatura
WHERE preco_mensal > (SELECT AVG(preco_mensal) FROM plano_assinatura)
ORDER BY preco_mensal DESC;

-- Q2. Quanto cada plano representa da receita das assinaturas ATIVAS, em %, com 1 casa.
SELECT p.nome_plano,
       SUM(p.preco_mensal) AS receita,
       ROUND(100.0 * SUM(p.preco_mensal) /
             (SELECT SUM(p2.preco_mensal)
              FROM assinatura a2
              JOIN plano_assinatura p2 ON p2.id_plano = a2.id_plano
              WHERE a2.status = 'ATIVA'), 1) AS percentual
FROM assinatura a
JOIN plano_assinatura p ON p.id_plano = a.id_plano
WHERE a.status = 'ATIVA'
GROUP BY p.nome_plano
ORDER BY percentual DESC;

-- Q3. Conteúdos que já receberam alguma nota 9 ou 10.
SELECT titulo_original
FROM conteudo
WHERE id_conteudo IN (SELECT id_conteudo FROM avaliacao WHERE nota >= 9)
ORDER BY titulo_original;

-- Q4. Usuários que nunca assistiram nada.
SELECT u.id_usuario, u.nome
FROM usuario u
WHERE NOT EXISTS (SELECT 1
                  FROM historico_visualizacao h
                  WHERE h.id_usuario = u.id_usuario)
ORDER BY u.nome;

-- Q5. Episódios que nunca foram assistidos.
SELECT e.id_episodio, e.numero_temporada, e.numero_episodio, e.titulo_episodio
FROM episodio e
WHERE NOT EXISTS (SELECT 1
                  FROM historico_visualizacao h
                  WHERE h.id_episodio = e.id_episodio)
ORDER BY e.id_conteudo, e.numero_temporada, e.numero_episodio;

-- Q6. Usuários sem nenhuma assinatura ATIVA (candidatos a campanha de retorno).
SELECT u.nome, u.email
FROM usuario u
WHERE NOT EXISTS (SELECT 1
                  FROM assinatura a
                  WHERE a.id_usuario = u.id_usuario
                    AND a.status = 'ATIVA')
ORDER BY u.nome;

-- Q7. Avaliações com nota acima da média do PRÓPRIO conteúdo.
SELECT a.id_avaliacao, a.id_conteudo, a.nota
FROM avaliacao a
WHERE a.nota > (SELECT AVG(a2.nota)
                FROM avaliacao a2
                WHERE a2.id_conteudo = a.id_conteudo)
ORDER BY a.id_conteudo, a.nota DESC;

-- Q8. Qual foi o ÚLTIMO conteúdo que cada usuário começou a assistir? Nome, título e data, do mais recente ao mais antigo.
SELECT u.nome, c.titulo_original, h.data_hora_inicio
FROM historico_visualizacao h
JOIN usuario u  ON u.id_usuario  = h.id_usuario
JOIN conteudo c ON c.id_conteudo = h.id_conteudo
WHERE h.data_hora_inicio = (SELECT MAX(h2.data_hora_inicio)
                            FROM historico_visualizacao h2
                            WHERE h2.id_usuario = h.id_usuario)
ORDER BY h.data_hora_inicio DESC;

-- Q9. Conteúdos com nota média igual ou superior a 7.
SELECT c.titulo_original, ROUND(m.nota_media, 2) AS nota_media
FROM (SELECT id_conteudo, AVG(nota) AS nota_media
      FROM avaliacao
      GROUP BY id_conteudo) m
JOIN conteudo c ON c.id_conteudo = m.id_conteudo
WHERE m.nota_media >= 7
ORDER BY m.nota_media DESC;

-- Q10. Séries com mais episódios que a média de episódios por série.
SELECT c.titulo_original, COUNT(*) AS qtd_episodios
FROM episodio e
JOIN conteudo c ON c.id_conteudo = e.id_conteudo
GROUP BY c.titulo_original
HAVING COUNT(*) > (SELECT AVG(qtd)
                   FROM (SELECT COUNT(*) AS qtd
                         FROM episodio
                         GROUP BY id_conteudo) t)
ORDER BY qtd_episodios DESC;

-- ------------------------------------------------------------
-- Parte 2: View (agenda do atendimento) e DCL
-- ------------------------------------------------------------

-- Q11. Crie a view vw_assinaturas_suporte para o atendimento: assinatura, nome, e-mail, plano, status, datas, renovação e pagamento. NÃO pode expor senha_hash, cpf nem data_nascimento.
CREATE OR REPLACE VIEW vw_assinaturas_suporte AS
SELECT a.id_assinatura, u.nome, u.email, p.nome_plano,
       a.status, a.data_inicio, a.data_fim,
       a.renovacao_automatica, a.forma_pagamento
FROM assinatura a
JOIN usuario u          ON u.id_usuario = a.id_usuario
JOIN plano_assinatura p ON p.id_plano   = a.id_plano;

-- Conferência: deve ser igual a SELECT COUNT(*) FROM assinatura;
SELECT COUNT(*) FROM vw_assinaturas_suporte;

-- Q12. Usando SÓ a view: assinaturas ATIVAS com renovação automática desligada, por data de início.
SELECT nome, email, nome_plano, data_inicio
FROM vw_assinaturas_suporte
WHERE status = 'ATIVA'
  AND renovacao_automatica = FALSE
ORDER BY data_inicio;

-- Q13. Crie o papel suporte e dê a ele acesso SÓ à view. Depois teste como suporte.
-- Para refazer o teste do zero: DROP OWNED BY suporte; DROP ROLE suporte;
-- CREATE ROLE dá erro se o papel já existir; este bloco só cria quando ainda não existe,
-- então o script pode ser rodado várias vezes.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'suporte') THEN
        CREATE ROLE suporte NOLOGIN;
    END IF;
END
$$;

GRANT suporte TO CURRENT_USER;
GRANT USAGE  ON SCHEMA public           TO suporte;
GRANT SELECT ON vw_assinaturas_suporte  TO suporte;

-- Teste 1: pela view funciona (mesmo número da conferência da Q11).
BEGIN;
SET LOCAL ROLE suporte;
SELECT COUNT(*) FROM vw_assinaturas_suporte;
ROLLBACK;

-- Teste 2: direto na tabela, o erro é o resultado certo.
-- Esperado: ERROR: permission denied for table usuario
-- BEGIN;
-- SET LOCAL ROLE suporte;
-- SELECT senha_hash, cpf FROM usuario;
-- ROLLBACK;

-- Q14. O suporte perdeu o acesso: REVOKE o SELECT da view, repita o Teste 1 e devolva o acesso.
REVOKE SELECT ON vw_assinaturas_suporte FROM suporte;

-- Esperado: ERROR: permission denied for view vw_assinaturas_suporte
-- BEGIN;
-- SET LOCAL ROLE suporte;
-- SELECT COUNT(*) FROM vw_assinaturas_suporte;
-- ROLLBACK;

GRANT SELECT ON vw_assinaturas_suporte TO suporte;

-- ------------------------------------------------------------
-- Parte 3: TCL (um filme são duas linhas: conteudo + filme)
-- ------------------------------------------------------------

-- Limpeza preventiva: se uma execução anterior parou no meio, sobram linhas de teste
-- e a auditoria do Passo 2 mostraria mais de um órfão.
DELETE FROM conteudo
WHERE titulo_original IN ('Filme de Teste TCL', 'Filme Descartado TCL', 'Série de Teste TCL');

-- Passo 1. Dois Runs separados, como uma aplicação sem transação. Um filme são DUAS linhas: conteudo + filme. O Run 1 dá certo.
INSERT INTO conteudo (titulo_original, ano_lancamento, classificacao_indicativa, idioma_original, tipo_conteudo)
VALUES ('Filme de Teste TCL', 2026, '12', 'Português', 'FILME');

-- Run 2: duração NULL viola o NOT NULL. Erro esperado:
-- null value in column "duracao_minutos" violates not-null constraint
-- INSERT INTO filme (id_conteudo, duracao_minutos, diretor)
-- VALUES ((SELECT MAX(id_conteudo) FROM conteudo), NULL, 'Diretor Teste');

-- Passo 2. Auditoria: conteúdos sem nenhuma subclasse (nem filme nem série). Esperado: 1 linha, o órfão. Depois apague o órfão.
SELECT c.id_conteudo, c.titulo_original, c.tipo_conteudo
FROM conteudo c
WHERE NOT EXISTS (SELECT 1 FROM filme f WHERE f.id_conteudo = c.id_conteudo)
  AND NOT EXISTS (SELECT 1 FROM serie s WHERE s.id_conteudo = c.id_conteudo);

DELETE FROM conteudo WHERE titulo_original = 'Filme de Teste TCL';

-- Passo 3. O mesmo erro, agora dentro de uma transação, num Run só. A transação falha inteira e o COMMIT vira ROLLBACK. Rode a auditoria de novo: 0 linhas.
-- BEGIN;
-- INSERT INTO conteudo (titulo_original, ano_lancamento, classificacao_indicativa, idioma_original, tipo_conteudo)
-- VALUES ('Filme de Teste TCL', 2026, '12', 'Português', 'FILME');
-- INSERT INTO filme (id_conteudo, duracao_minutos, diretor)
-- VALUES ((SELECT MAX(id_conteudo) FROM conteudo), NULL, 'Diretor Teste');
-- COMMIT;

-- Passo 4. Corrija a duração para 120 e rode o bloco do Passo 3. Auditoria: 0 linhas. O filme novo existe nas duas tabelas.
BEGIN;
INSERT INTO conteudo (titulo_original, ano_lancamento, classificacao_indicativa, idioma_original, tipo_conteudo)
VALUES ('Filme de Teste TCL', 2026, '12', 'Português', 'FILME');
INSERT INTO filme (id_conteudo, duracao_minutos, diretor)
VALUES ((SELECT MAX(id_conteudo) FROM conteudo), 120, 'Diretor Teste');
COMMIT;

SELECT c.titulo_original, f.duracao_minutos
FROM conteudo c
JOIN filme f ON f.id_conteudo = c.id_conteudo
WHERE c.titulo_original = 'Filme de Teste TCL';

-- Passo 5. ROLLBACK explícito: desfaz tudo o que foi feito desde o BEGIN. Esperado: 0 linhas na conferência.
BEGIN;
INSERT INTO conteudo (titulo_original, ano_lancamento, classificacao_indicativa, idioma_original, tipo_conteudo)
VALUES ('Filme Descartado TCL', 2026, '12', 'Português', 'FILME');
ROLLBACK;

SELECT COUNT(*) FROM conteudo WHERE titulo_original = 'Filme Descartado TCL';

-- Passo 6. SAVEPOINT: desfaz só uma parte da transação. A série entra com 0 temporadas por engano, volta ao ponto salvo e entra certa.
BEGIN;
INSERT INTO conteudo (titulo_original, ano_lancamento, classificacao_indicativa, idioma_original, tipo_conteudo)
VALUES ('Série de Teste TCL', 2026, '14', 'Português', 'SERIE');
SAVEPOINT apos_conteudo;
INSERT INTO serie (id_conteudo, total_temporadas, status_producao)
VALUES ((SELECT MAX(id_conteudo) FROM conteudo), 0, 'EM ANDAMENTO');
ROLLBACK TO SAVEPOINT apos_conteudo;
INSERT INTO serie (id_conteudo, total_temporadas, status_producao)
VALUES ((SELECT MAX(id_conteudo) FROM conteudo), 1, 'EM ANDAMENTO');
COMMIT;

-- Passo 7. Devolva a base ao estado anterior. A conferência deve dar 0.
DELETE FROM conteudo
WHERE titulo_original IN ('Filme de Teste TCL', 'Série de Teste TCL');

SELECT COUNT(*) FROM conteudo
WHERE titulo_original IN ('Filme de Teste TCL', 'Série de Teste TCL');

-- ------------------------------------------------------------
-- Cuidados com subconsultas, views e transações (testes de "aposta")
-- ------------------------------------------------------------
-- A1. SELECT COUNT(*) FROM episodio WHERE id_episodio NOT IN
--       (SELECT id_episodio FROM historico_visualizacao);
--     id_episodio é NULL nas exibições de filmes: NOT IN com NULL na lista
--     nunca é verdadeiro e devolve 0 linhas. Use NOT EXISTS (Q5).
-- A2. SELECT titulo_original FROM conteudo WHERE id_conteudo =
--       (SELECT id_conteudo FROM avaliacao WHERE nota >= 9);
--     Com = a subconsulta precisa devolver UMA linha; com várias dá erro
--     "more than one row returned by a subquery". Use IN (Q3).
-- A3. Antes: N conteúdos. Depois do Passo 3 (BEGIN, um INSERT que dá certo,
--     um que dá erro, COMMIT), quantos? N: o COMMIT vira ROLLBACK.
-- A view esconde colunas, mas só protege se o papel NÃO tiver GRANT na tabela.
-- Cada Run é um pedido novo: SET LOCAL ROLE só vale dentro do BEGIN ... ROLLBACK.
