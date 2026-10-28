-- ============================================================
-- Cinevia - Plataforma de Streaming
-- Consultas DQL II (22 consultas: JOIN, GROUP BY, HAVING, ORDER BY
-- e funções de agregação COUNT, SUM, AVG, MIN e MAX)
-- Método: FROM/JOIN -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY / LIMIT
-- ============================================================

-- ------------------------------------------------------------
-- Aquecimento: as cinco funções de agregação
-- ------------------------------------------------------------

-- Q1. As cinco funções de agregação sobre os planos: quantidade, soma, média, menor e maior preço.
SELECT COUNT(*)          AS qtd_planos,
       SUM(preco_mensal) AS soma_precos,
       AVG(preco_mensal) AS preco_medio,
       MIN(preco_mensal) AS menor_preco,
       MAX(preco_mensal) AS maior_preco
FROM plano_assinatura;

-- ------------------------------------------------------------
-- Parte 1: JOIN
-- ------------------------------------------------------------

-- Q2. Quem assina o quê? Nome do usuário, plano e preço das assinaturas ATIVAS, em ordem alfabética.
SELECT u.nome, p.nome_plano, p.preco_mensal, a.data_inicio
FROM assinatura a
JOIN usuario u          ON u.id_usuario = a.id_usuario
JOIN plano_assinatura p ON p.id_plano   = a.id_plano
WHERE a.status = 'ATIVA'
ORDER BY u.nome;

-- Q3. Em quais gêneros cada conteúdo se encaixa? Título e gênero.
SELECT c.titulo_original, g.nome_genero
FROM conteudo c
JOIN conteudo_genero cg ON cg.id_conteudo = c.id_conteudo
JOIN genero g           ON g.id_genero    = cg.id_genero
ORDER BY c.titulo_original, g.nome_genero;

-- Q4. Episódios com o nome da série a que pertencem, da 1ª temporada em diante.
SELECT c.titulo_original AS serie, e.numero_temporada, e.numero_episodio, e.titulo_episodio
FROM episodio e
JOIN serie s    ON s.id_conteudo = e.id_conteudo
JOIN conteudo c ON c.id_conteudo = s.id_conteudo
ORDER BY c.titulo_original, e.numero_temporada, e.numero_episodio;

-- Q5. Filmes com diretor e duração, usando a especialização conteudo/filme.
SELECT c.titulo_original, f.diretor, f.duracao_minutos
FROM conteudo c
JOIN filme f ON f.id_conteudo = c.id_conteudo
WHERE c.ano_lancamento >= 2020
ORDER BY f.duracao_minutos DESC;

-- Q6. Usuários que nunca avaliaram nenhum conteúdo.
SELECT u.id_usuario, u.nome, u.email
FROM usuario u
LEFT JOIN avaliacao a ON a.id_usuario = u.id_usuario
WHERE a.id_avaliacao IS NULL
ORDER BY u.nome;

-- Q7. Histórico de visualização legível: quem assistiu, em qual aparelho e qual conteúdo (apenas exibições não concluídas).
SELECT u.nome, d.tipo_dispositivo, c.titulo_original,
       h.tempo_assistido_segundos, h.data_hora_inicio
FROM historico_visualizacao h
JOIN usuario u      ON u.id_usuario     = h.id_usuario
JOIN dispositivo d  ON d.id_dispositivo = h.id_dispositivo
JOIN conteudo c     ON c.id_conteudo    = h.id_conteudo
WHERE h.concluido = FALSE
ORDER BY h.data_hora_inicio DESC;

-- ------------------------------------------------------------
-- Parte 2: Funções de agregação com GROUP BY
-- ------------------------------------------------------------

-- Q8. Quantas assinaturas há em cada plano? (COUNT)
SELECT p.nome_plano, COUNT(*) AS total_assinaturas
FROM assinatura a
JOIN plano_assinatura p ON p.id_plano = a.id_plano
GROUP BY p.nome_plano
ORDER BY total_assinaturas DESC;

-- Q9. Qual a receita mensal das assinaturas ATIVAS, por plano? (SUM)
SELECT p.nome_plano, SUM(p.preco_mensal) AS receita_mensal
FROM assinatura a
JOIN plano_assinatura p ON p.id_plano = a.id_plano
WHERE a.status = 'ATIVA'
GROUP BY p.nome_plano
ORDER BY receita_mensal DESC;

-- Q10. Qual a nota média de cada conteúdo? (AVG)
SELECT c.titulo_original, ROUND(AVG(av.nota), 2) AS nota_media
FROM avaliacao av
JOIN conteudo c ON c.id_conteudo = av.id_conteudo
GROUP BY c.titulo_original
ORDER BY nota_media DESC;

-- Q11. Qual a menor e a maior duração de episódio de cada série? (MIN/MAX)
SELECT c.titulo_original AS serie,
       MIN(e.duracao_minutos) AS menor_episodio,
       MAX(e.duracao_minutos) AS maior_episodio
FROM episodio e
JOIN conteudo c ON c.id_conteudo = e.id_conteudo
GROUP BY c.titulo_original
ORDER BY c.titulo_original;

-- Q12. Quantos conteúdos existem em cada gênero?
SELECT g.nome_genero, COUNT(cg.id_conteudo) AS qtd_conteudos
FROM genero g
LEFT JOIN conteudo_genero cg ON cg.id_genero = g.id_genero
GROUP BY g.nome_genero
ORDER BY qtd_conteudos DESC, g.nome_genero;

-- Q13. Quantas avaliações cada usuário fez, incluindo quem fez zero? (COUNT(coluna) ignora NULL)
SELECT u.nome, COUNT(av.id_avaliacao) AS qtd_avaliacoes
FROM usuario u
LEFT JOIN avaliacao av ON av.id_usuario = u.id_usuario
GROUP BY u.id_usuario, u.nome
ORDER BY qtd_avaliacoes DESC, u.nome;

-- Q14. Total de horas assistidas por usuário. (SUM)
SELECT u.nome,
       ROUND(SUM(h.tempo_assistido_segundos) / 3600.0, 2) AS horas_assistidas
FROM historico_visualizacao h
JOIN usuario u ON u.id_usuario = h.id_usuario
GROUP BY u.id_usuario, u.nome
ORDER BY horas_assistidas DESC
LIMIT 10;

-- Q15. Resumo dos filmes por classificação indicativa: quantidade, duração média, menor e maior.
SELECT c.classificacao_indicativa,
       COUNT(*)                       AS qtd_filmes,
       ROUND(AVG(f.duracao_minutos))  AS duracao_media,
       MIN(f.duracao_minutos)         AS mais_curto,
       MAX(f.duracao_minutos)         AS mais_longo
FROM filme f
JOIN conteudo c ON c.id_conteudo = f.id_conteudo
GROUP BY c.classificacao_indicativa
ORDER BY c.classificacao_indicativa;

-- Q16. Quantidade de episódios e duração total (em minutos) de cada série.
SELECT c.titulo_original AS serie,
       COUNT(e.id_episodio)    AS qtd_episodios,
       SUM(e.duracao_minutos)  AS minutos_totais
FROM serie s
JOIN conteudo c ON c.id_conteudo = s.id_conteudo
JOIN episodio e ON e.id_conteudo = s.id_conteudo
GROUP BY c.titulo_original
ORDER BY minutos_totais DESC;

-- ------------------------------------------------------------
-- Parte 3: HAVING (filtro de grupos)
-- ------------------------------------------------------------

-- Q17. Quais conteúdos têm pelo menos 2 avaliações e nota média igual ou superior a 7?
SELECT c.titulo_original,
       COUNT(*)                    AS qtd_avaliacoes,
       ROUND(AVG(av.nota), 2)      AS nota_media
FROM avaliacao av
JOIN conteudo c ON c.id_conteudo = av.id_conteudo
GROUP BY c.titulo_original
HAVING COUNT(*) >= 2
   AND AVG(av.nota) >= 7
ORDER BY nota_media DESC;

-- Q18. Quais usuários têm mais de um dispositivo registrado?
SELECT u.nome, COUNT(d.id_dispositivo) AS qtd_dispositivos
FROM usuario u
JOIN dispositivo d ON d.id_usuario = u.id_usuario
GROUP BY u.id_usuario, u.nome
HAVING COUNT(d.id_dispositivo) > 1
ORDER BY qtd_dispositivos DESC, u.nome;

-- Q19. Quais planos têm receita mensal ativa acima de R$ 100?
SELECT p.nome_plano, SUM(p.preco_mensal) AS receita_mensal
FROM assinatura a
JOIN plano_assinatura p ON p.id_plano = a.id_plano
WHERE a.status = 'ATIVA'
GROUP BY p.nome_plano
HAVING SUM(p.preco_mensal) > 100
ORDER BY receita_mensal DESC;

-- Q20. Quais conteúdos foram assistidos mais de 3 vezes? Os 5 mais vistos.
SELECT c.titulo_original, COUNT(*) AS qtd_exibicoes
FROM historico_visualizacao h
JOIN conteudo c ON c.id_conteudo = h.id_conteudo
GROUP BY c.titulo_original
HAVING COUNT(*) > 3
ORDER BY qtd_exibicoes DESC
LIMIT 5;

-- Q21. Quais conteúdos têm taxa de conclusão abaixo de 50% nas exibições registradas?
SELECT c.titulo_original,
       COUNT(*) AS exibicoes,
       SUM(CASE WHEN h.concluido THEN 1 ELSE 0 END) AS concluidas,
       ROUND(100.0 * SUM(CASE WHEN h.concluido THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_conclusao
FROM historico_visualizacao h
JOIN conteudo c ON c.id_conteudo = h.id_conteudo
GROUP BY c.titulo_original
HAVING 100.0 * SUM(CASE WHEN h.concluido THEN 1 ELSE 0 END) / COUNT(*) < 50
ORDER BY pct_conclusao;

-- Q22. Quais séries têm mais de 10 episódios cadastrados e duração média acima de 40 minutos?
SELECT c.titulo_original AS serie,
       COUNT(e.id_episodio)             AS qtd_episodios,
       ROUND(AVG(e.duracao_minutos), 1) AS duracao_media
FROM episodio e
JOIN conteudo c ON c.id_conteudo = e.id_conteudo
GROUP BY c.titulo_original
HAVING COUNT(e.id_episodio) > 10
   AND AVG(e.duracao_minutos) > 40
ORDER BY duracao_media DESC;

-- ------------------------------------------------------------
-- Cuidados com JOIN, NULL e agregações (testes de "aposta")
-- ------------------------------------------------------------
-- WHERE filtra linhas antes de agrupar e não aceita agregação; HAVING filtra
-- grupos depois de agrupar.
-- JOIN interno descarta linhas sem par: plano sem assinatura não aparece.
-- Com LEFT JOIN e COUNT(coluna), ele aparece com zero.
-- COUNT(*) conta linhas; COUNT(coluna), SUM, AVG, MIN e MAX ignoram NULL.
-- AVG(nota) com WHERE nota > 5 calcula a média só das notas de 6 a 10.
-- Agrupe pela chave (id_usuario, nome) para não somar homônimos.
