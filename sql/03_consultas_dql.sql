-- ============================================================
-- Cinevia - Plataforma de Streaming
-- Consultas DQL (14 consultas, cada uma sobre uma única tabela)
-- Método: FROM -> WHERE -> SELECT -> ORDER BY / LIMIT
-- ============================================================

-- Q1. Filmes do catálogo, do mais recente ao mais antigo.
SELECT titulo_original, ano_lancamento
FROM conteudo
WHERE tipo_conteudo = 'FILME'
ORDER BY ano_lancamento DESC;

-- Q2. Conteúdos impróprios para menores de 16 anos, em ordem alfabética.
SELECT titulo_original, classificacao_indicativa
FROM conteudo
WHERE classificacao_indicativa IN ('16', '18')
ORDER BY titulo_original;

-- Q3. Planos que permitem download, do mais barato ao mais caro.
SELECT nome_plano, preco_mensal
FROM plano_assinatura
WHERE permite_download = TRUE
ORDER BY preco_mensal ASC;

-- Q4. Assinaturas ATIVAS com renovação automática desligada (risco de cancelamento).
SELECT id_assinatura, id_usuario, data_inicio, forma_pagamento
FROM assinatura
WHERE status = 'ATIVA'
  AND renovacao_automatica = FALSE;

-- Q5. Assinaturas em aberto, sem data de fim.
SELECT *
FROM assinatura
WHERE data_fim IS NULL;

-- Q6. Usuários cadastrados em 2026 (data_cadastro é TIMESTAMP).
SELECT nome, email, data_cadastro
FROM usuario
WHERE data_cadastro >= '2026-01-01'
  AND data_cadastro <  '2027-01-01'
ORDER BY data_cadastro;

-- Q7. Dispositivos que nunca tiveram acesso registrado.
SELECT id_dispositivo, id_usuario, tipo_dispositivo, nome_dispositivo
FROM dispositivo
WHERE ultimo_acesso IS NULL;

-- Q8. Conteúdos com "amor" no título, sem diferenciar maiúsculas.
SELECT id_conteudo, titulo_original
FROM conteudo
WHERE titulo_original ILIKE '%amor%';

-- Q9. Avaliações com nota 8 ou mais e que tenham comentário.
SELECT id_avaliacao, id_conteudo, nota, comentario
FROM avaliacao
WHERE nota >= 8
  AND comentario IS NOT NULL
ORDER BY nota DESC;

-- Q10. Os 5 filmes mais longos.
SELECT id_conteudo, duracao_minutos
FROM filme
ORDER BY duracao_minutos DESC
LIMIT 5;

-- Q11. Séries em andamento, da que tem mais temporadas à que tem menos.
SELECT id_conteudo, total_temporadas
FROM serie
WHERE status_producao = 'EM ANDAMENTO'
ORDER BY total_temporadas DESC;

-- Q12. Episódios da 1ª temporada com duração entre 40 e 60 minutos.
SELECT id_conteudo, numero_episodio, titulo_episodio, duracao_minutos
FROM episodio
WHERE numero_temporada = 1
  AND duracao_minutos BETWEEN 40 AND 60
ORDER BY id_conteudo, numero_episodio;

-- Q13. Exibições começadas e não terminadas.
SELECT id_historico, id_usuario, id_conteudo, tempo_assistido_segundos
FROM historico_visualizacao
WHERE concluido = FALSE
  AND tempo_assistido_segundos > 0
ORDER BY tempo_assistido_segundos DESC;

-- Q14. Os 3 usuários mais novos.
SELECT nome, data_nascimento
FROM usuario
ORDER BY data_nascimento DESC
LIMIT 3;

-- ------------------------------------------------------------
-- Cuidados com NULL e maiúsculas (testes de "aposta")
-- ------------------------------------------------------------
-- data_fim <> '2026-12-31' descarta assinaturas em aberto (NULL <> valor é
-- desconhecido, não verdadeiro). Para incluí-las, trate IS NULL à parte.
-- idioma_original <> 'Português' também não devolve os registros sem idioma.
-- nome = 'ana' diferencia maiúsculas; 'ana' não encontra 'Ana'. Use ILIKE.
