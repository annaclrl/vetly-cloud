-- docs/java-database-alignment.md §2.3 — aceite LGPD simplificado (RN-060/061) e o gatilho de
-- consentimento de rede que a Colmeia (RN-064) le para conceder acesso automatico ao historico.

ALTER TABLE TB_TUTOR ADD (
    FL_LGPD_ACEITO          CHAR(1) DEFAULT 'N' NOT NULL,
    DT_LGPD_ACEITO          DATE,
    FL_CONSENTIMENTO_REDE   CHAR(1) DEFAULT 'N' NOT NULL,
    DT_CONSENTIMENTO_REDE   DATE
);

ALTER TABLE TB_TUTOR ADD CONSTRAINT CK_FL_LGPD CHECK (FL_LGPD_ACEITO IN ('S','N'));
ALTER TABLE TB_TUTOR ADD CONSTRAINT CK_FL_CONSENT_REDE CHECK (FL_CONSENTIMENTO_REDE IN ('S','N'));
