-- ============================================================
-- Cinevia - Plataforma de Streaming
-- Operações DML do dia a dia (valores ilustrativos)
-- Execute depois do 01_script_ddl.sql e depois de ter dados
-- carregados (os ids usados abaixo precisam existir).
-- ============================================================

-- ------------------------------------------------------------
-- Ordem de carga (com chaves estrangeiras ativas):
--   1) usuario, plano_assinatura, genero, conteudo
--   2) assinatura, dispositivo, filme, serie
--   3) episodio, conteudo_genero, avaliacao
--   4) historico_visualizacao
-- O tipo_conteudo de cada registro em conteudo deve coincidir com
-- a tabela filha (FILME -> filme, SERIE -> serie).
-- ------------------------------------------------------------

-- INSERT: novo usuário e primeira assinatura
INSERT INTO usuario (nome, email, senha_hash, cpf, data_nascimento)
VALUES ('Maria Souza', 'maria@exemplo.com', '<hash>', '000.000.000-00', '1995-04-12');

INSERT INTO assinatura (id_usuario, id_plano, data_inicio, status, forma_pagamento)
VALUES (1, 2, CURRENT_DATE, 'ATIVA', 'Cartão de crédito');

-- UPDATE: desligar a renovação automática
UPDATE assinatura
SET renovacao_automatica = FALSE
WHERE id_assinatura = 1;

-- UPDATE: registrar o acesso a um dispositivo
UPDATE dispositivo
SET ultimo_acesso = CURRENT_TIMESTAMP
WHERE id_dispositivo = 1;

-- UPDATE: salvar o progresso de quem está assistindo
UPDATE historico_visualizacao
SET tempo_assistido_segundos = 1800,
    concluido = FALSE
WHERE id_historico = 1;

-- DELETE: remover uma avaliação (o WHERE é obrigatório)
DELETE FROM avaliacao
WHERE id_avaliacao = 1;

-- ------------------------------------------------------------
-- Efeito das regras de integridade (testes que devem FALHAR)
-- ------------------------------------------------------------
-- Plano em uso: falha enquanto houver assinaturas nele (RESTRICT)
-- DELETE FROM plano_assinatura WHERE id_plano = 2;

-- Nota inválida: rejeitada pelo CHECK (0 a 10)
-- INSERT INTO avaliacao (id_usuario, id_conteudo, nota) VALUES (1, 1, 11);

-- Tipo inválido: rejeitado pelo CHECK (FILME ou SERIE)
-- INSERT INTO conteudo (titulo_original, ano_lancamento, classificacao_indicativa, tipo_conteudo)
-- VALUES ('Teste', 2026, 'L', 'DOCUMENTARIO');

-- Exclusão de usuário: remove em cascata assinaturas, dispositivos,
-- avaliações e histórico (atende pedidos de eliminação de dados da LGPD)
-- DELETE FROM usuario WHERE id_usuario = 1;

-- ------------------------------------------------------------
-- Cenário de concorrência: cancelamento x renovação automática
-- A transação trava a linha antes de decidir; a outra espera o COMMIT
-- e já enxerga o status atualizado.
-- ------------------------------------------------------------
BEGIN;

SELECT status, renovacao_automatica
FROM assinatura
WHERE id_assinatura = 1
FOR UPDATE;          -- a outra transação espera aqui

UPDATE assinatura
SET status = 'CANCELADA', data_fim = CURRENT_DATE
WHERE id_assinatura = 1 AND status = 'ATIVA';

COMMIT;
