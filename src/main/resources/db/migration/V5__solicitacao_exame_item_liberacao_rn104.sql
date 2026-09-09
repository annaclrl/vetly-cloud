-- docs/java-database-alignment.md §2.7 — RN-104: o resultado do exame so chega ao Responsavel
-- apos liberacao explicita do vet. Decidido em 2026-09-05: RESULTADO_ENVIADO significa
-- liberado ao Responsavel (nao "enviado ao vet"); registrar o laudo para em ANALISADO e a
-- liberacao explicita move o item para RESULTADO_ENVIADO junto com FL_LIBERADO_RESPONSAVEL='S'.

ALTER TABLE TB_SOLICITACAO_EXAME_ITEM ADD (
    FL_LIBERADO_RESPONSAVEL    CHAR(1) DEFAULT 'N' NOT NULL,
    DT_LIBERACAO_RESPONSAVEL   DATE
);

ALTER TABLE TB_SOLICITACAO_EXAME_ITEM ADD CONSTRAINT CK_FL_LIBERADO CHECK (FL_LIBERADO_RESPONSAVEL IN ('S','N'));
