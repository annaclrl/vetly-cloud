-- docs/java-database-alignment.md §2.2 — RN-068: Responsavel pode ocultar registros do historico,
-- exceto alertas de seguranca (alergias e interacoes), que nunca sao ocultaveis.
-- A regra "alerta de seguranca ignora o flag de oculto" e aplicada em codigo, nao no banco.

ALTER TABLE TB_EVOLUCAO_CLINICA ADD (
    FL_OCULTO_RESPONSAVEL   CHAR(1) DEFAULT 'N' NOT NULL,
    FL_ALERTA_SEGURANCA     CHAR(1) DEFAULT 'N' NOT NULL
);

ALTER TABLE TB_EVOLUCAO_CLINICA ADD CONSTRAINT CK_FL_OCULTO CHECK (FL_OCULTO_RESPONSAVEL IN ('S','N'));
ALTER TABLE TB_EVOLUCAO_CLINICA ADD CONSTRAINT CK_FL_ALERTA CHECK (FL_ALERTA_SEGURANCA IN ('S','N'));
