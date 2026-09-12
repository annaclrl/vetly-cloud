-- Script de correção incremental (sem DROP) para alinhar o schema físico
-- às entidades JPA. Rode contra o banco Oracle existente (local e depois Azure),
-- de preferência com backup antes. Reflete as colunas/tabelas que os migrations
-- Flyway V2, V3, V4, V5, V6, V7 e V8 (removidos do repositório) criavam e que
-- não foram replicadas no script_bd.sql manual.

-- TB_TUTOR (V6 - LGPD / consentimento de rede)
ALTER TABLE TB_TUTOR ADD (
    FL_LGPD_ACEITO        CHAR(1) DEFAULT 'N' NOT NULL,
    DT_LGPD_ACEITO        DATE,
    FL_CONSENTIMENTO_REDE CHAR(1) DEFAULT 'N' NOT NULL,
    DT_CONSENTIMENTO_REDE DATE
);

-- TB_ANIMAL (V2 - campos clínicos)
ALTER TABLE TB_ANIMAL ADD (
    URL_FOTO_ANIMAL       VARCHAR2(500 CHAR),
    FL_CASTRADO           CHAR(1) DEFAULT 'N' NOT NULL,
    DS_CONDICOES_PREEXIST VARCHAR2(1000 CHAR),
    DS_ALERGIAS           VARCHAR2(1000 CHAR),
    DS_MEDICACOES_EM_USO  VARCHAR2(1000 CHAR)
);

-- TB_CONSULTA (V4 - status "não compareceu")
ALTER TABLE TB_CONSULTA DROP CONSTRAINT CK_STATUS_CONSULTA;

ALTER TABLE TB_CONSULTA
    ADD CONSTRAINT CK_STATUS_CONSULTA
        CHECK (
            ST_CONSULTA IN (
                            'AGENDADA',
                            'CANCELADA',
                            'REALIZADA',
                            'NAO_COMPARECEU'
                )
            );

-- TB_EVOLUCAO_CLINICA (V3 - flags RN068)
ALTER TABLE TB_EVOLUCAO_CLINICA ADD (
    FL_OCULTO_RESPONSAVEL CHAR(1) DEFAULT 'N' NOT NULL,
    FL_ALERTA_SEGURANCA   CHAR(1) DEFAULT 'N' NOT NULL
);

-- TB_SOLICITACAO_EXAME_ITEM (V5 - liberação RN104)
ALTER TABLE TB_SOLICITACAO_EXAME_ITEM ADD (
    FL_LIBERADO_RESPONSAVEL  CHAR(1) DEFAULT 'N' NOT NULL,
    DT_LIBERACAO_RESPONSAVEL DATE
);

-- TB_PRONTUARIO (V8 - versionamento RN088/089)
-- ATENÇÃO: DS_CONTEUDO_CLINICO é NOT NULL na entidade. Se já existirem
-- prontuários cadastrados, ajuste o valor padrão abaixo antes de rodar
-- (ou preencha manualmente e só depois marque a coluna como NOT NULL).
ALTER TABLE TB_PRONTUARIO ADD (
    DS_CONTEUDO_CLINICO       CLOB DEFAULT 'Sem conteúdo registrado' NOT NULL,
    TB_PRONTUARIO_ID_ORIGINAL VARCHAR2(36),
    DT_HR_CORRECAO            DATE,
    CRMV_SOLICITANTE_CORRECAO VARCHAR2(20),
    DS_JUSTIFICATIVA_CORRECAO VARCHAR2(1000 CHAR)
);

ALTER TABLE TB_PRONTUARIO
    ADD CONSTRAINT TB_PRONTUARIO_TB_ORIGINAL_FK
        FOREIGN KEY (TB_PRONTUARIO_ID_ORIGINAL)
            REFERENCES TB_PRONTUARIO (ID_PRONTUARIO);

-- TB_LOG_ACESSO_PRONTUARIO (V7 - tabela inteira ausente)
CREATE TABLE TB_LOG_ACESSO_PRONTUARIO (
                                          ID_LOG_ACESSO                 VARCHAR2(36) NOT NULL,
                                          DT_HR_ACESSO                  DATE NOT NULL,
                                          DS_CONTEXTO_ACESSO            VARCHAR2(200 CHAR),
                                          DS_BASE_ACESSO                VARCHAR2(30) NOT NULL,
                                          TB_ANIMAL_ID_ANIMAL           VARCHAR2(36) NOT NULL,
                                          TB_VETERINARIO_ID_VETERINARIO VARCHAR2(36) NOT NULL
);

ALTER TABLE TB_LOG_ACESSO_PRONTUARIO
    ADD CONSTRAINT CK_BASE_ACESSO_PRONTUARIO
        CHECK (
            DS_BASE_ACESSO IN (
                               'CONSENTIMENTO_REDE',
                               'ATENDIMENTO_DIRETO'
                )
            );

ALTER TABLE TB_LOG_ACESSO_PRONTUARIO
    ADD CONSTRAINT TB_LOG_ACESSO_PRONTUARIO_PK
        PRIMARY KEY (ID_LOG_ACESSO);

ALTER TABLE TB_LOG_ACESSO_PRONTUARIO
    ADD CONSTRAINT TB_LOG_ACESSO_TB_ANIMAL_FK
        FOREIGN KEY (TB_ANIMAL_ID_ANIMAL)
            REFERENCES TB_ANIMAL (ID_ANIMAL);

ALTER TABLE TB_LOG_ACESSO_PRONTUARIO
    ADD CONSTRAINT TB_LOG_ACESSO_TB_VET_FK
        FOREIGN KEY (TB_VETERINARIO_ID_VETERINARIO)
            REFERENCES TB_VETERINARIO (ID_VETERINARIO);

COMMENT ON TABLE TB_LOG_ACESSO_PRONTUARIO IS
'Tabela responsável pelo registro de acessos ao prontuário de um animal';

COMMENT ON COLUMN TB_LOG_ACESSO_PRONTUARIO.ID_LOG_ACESSO IS
'Identificador único do registro de acesso';

COMMENT ON COLUMN TB_LOG_ACESSO_PRONTUARIO.DT_HR_ACESSO IS
'Data e horário do acesso ao prontuário';

COMMENT ON COLUMN TB_LOG_ACESSO_PRONTUARIO.DS_CONTEXTO_ACESSO IS
'Contexto ou motivo do acesso ao prontuário';

COMMENT ON COLUMN TB_LOG_ACESSO_PRONTUARIO.DS_BASE_ACESSO IS
'Base legal do acesso: CONSENTIMENTO_REDE ou ATENDIMENTO_DIRETO';

COMMENT ON COLUMN TB_LOG_ACESSO_PRONTUARIO.TB_ANIMAL_ID_ANIMAL IS
'Identificador do animal cujo prontuário foi acessado';

COMMENT ON COLUMN TB_LOG_ACESSO_PRONTUARIO.TB_VETERINARIO_ID_VETERINARIO IS
'Identificador do veterinário que realizou o acesso';
