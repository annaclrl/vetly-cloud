DROP TABLE TB_ANEXO_EXAME CASCADE CONSTRAINTS;

DROP TABLE TB_ANIMAL CASCADE CONSTRAINTS;

DROP TABLE TB_CONSULTA CASCADE CONSTRAINTS;

DROP TABLE TB_ESPECIALIDADES_VET CASCADE CONSTRAINTS;

DROP TABLE TB_ESPECIE CASCADE CONSTRAINTS;

DROP TABLE TB_EVOLUCAO_CLINICA CASCADE CONSTRAINTS;

DROP TABLE TB_PESSOA CASCADE CONSTRAINTS;

DROP TABLE TB_PRONTUARIO CASCADE CONSTRAINTS;

DROP TABLE TB_SOLICITACAO_EXAME CASCADE CONSTRAINTS;

DROP TABLE TB_SOLICITACAO_EXAME_ITEM CASCADE CONSTRAINTS;

DROP TABLE TB_TUTOR CASCADE CONSTRAINTS;

DROP TABLE TB_USUARIO CASCADE CONSTRAINTS;

DROP TABLE TB_VETERINARIO CASCADE CONSTRAINTS;

DROP TABLE TB_VETERINARIO_ESPECIALIDADE CASCADE CONSTRAINTS;

DROP TABLE TB_VETERINARIO_ESPECIE CASCADE CONSTRAINTS;

DROP TABLE TB_LOG_ERRO CASCADE CONSTRAINTS;

DROP SEQUENCE SQ_LOG_ERRO;

CREATE TABLE TB_LOG_ERRO (
                             ID_LOG        VARCHAR2(36) NOT NULL,
                             NM_PROCEDURE  VARCHAR2(100) NOT NULL,
                             NM_USUARIO    VARCHAR2(100) NOT NULL,
                             DT_OCORRENCIA DATE NOT NULL,
                             CD_ERRO       VARCHAR2(36) NOT NULL,
                             DS_MENSAGEM   VARCHAR2(4000) NOT NULL,

                             CONSTRAINT TB_LOG_ERRO_PK PRIMARY KEY (ID_LOG)


);

CREATE SEQUENCE SQ_LOG_ERRO
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

COMMENT ON TABLE TB_LOG_ERRO IS
'Tabela responsável pelo armazenamento dos registros de erros ocorridos no sistema';

COMMENT ON COLUMN TB_LOG_ERRO.ID_LOG IS
'Identificador único do registro de erro';

COMMENT ON COLUMN TB_LOG_ERRO.NM_PROCEDURE IS
'Nome do procedimento ou processo onde ocorreu o erro';

COMMENT ON COLUMN TB_LOG_ERRO.NM_USUARIO IS
'Identificação do usuário relacionado à ocorrência';

COMMENT ON COLUMN TB_LOG_ERRO.DT_OCORRENCIA IS
'Data e horário da ocorrência do erro';

COMMENT ON COLUMN TB_LOG_ERRO.CD_ERRO IS
'Código identificador do erro';

COMMENT ON COLUMN TB_LOG_ERRO.DS_MENSAGEM IS
'Descrição detalhada da mensagem de erro';

CREATE TABLE TB_ESPECIE (
                            ID_ESPECIE VARCHAR2(36) NOT NULL,
                            NM_ESPECIE VARCHAR2(50 CHAR) NOT NULL
);

ALTER TABLE TB_ESPECIE
    ADD CONSTRAINT CK_ESPECIE
        CHECK (
            NM_ESPECIE IN (
                           'ANFIBIO',
                           'AVE',
                           'CAO',
                           'EQUIDEO',
                           'GATO',
                           'MAMIFERO',
                           'PEIXE',
                           'REPTIL'
                )
            );

ALTER TABLE TB_ESPECIE
    ADD CONSTRAINT TB_ESPECIE_PK
        PRIMARY KEY (ID_ESPECIE);

ALTER TABLE TB_ESPECIE
    ADD CONSTRAINT TB_ESPECIE_NM_ESPECIE_UN
        UNIQUE (NM_ESPECIE);

COMMENT ON TABLE TB_ESPECIE IS
'Tabela responsável pelo armazenamento das espécies de animais atendidas pelo sistema';

COMMENT ON COLUMN TB_ESPECIE.ID_ESPECIE IS
'Identificador único da espécie';

COMMENT ON COLUMN TB_ESPECIE.NM_ESPECIE IS
'Nome da espécie do animal';

CREATE TABLE TB_PESSOA (
                           ID_PESSOA  VARCHAR2(36) NOT NULL,
                           NM_PESSOA  VARCHAR2(100 CHAR) NOT NULL,
                           CPF_PESSOA VARCHAR2(11 CHAR) NOT NULL,
                           TEL_PESSOA VARCHAR2(15 CHAR) NOT NULL
);

ALTER TABLE TB_PESSOA
    ADD CONSTRAINT TB_PESSOA_PK
        PRIMARY KEY (ID_PESSOA);

ALTER TABLE TB_PESSOA
    ADD CONSTRAINT TB_PESSOA_CPF_TEL_UN
        UNIQUE (CPF_PESSOA, TEL_PESSOA);

COMMENT ON TABLE TB_PESSOA IS
'Tabela responsável pelo armazenamento dos dados pessoais relacionados aos tutores e veterinários';

COMMENT ON COLUMN TB_PESSOA.ID_PESSOA IS
'Identificador único da pessoa';

COMMENT ON COLUMN TB_PESSOA.NM_PESSOA IS
'Nome completo da pessoa';

COMMENT ON COLUMN TB_PESSOA.CPF_PESSOA IS
'Número do CPF da pessoa';

COMMENT ON COLUMN TB_PESSOA.TEL_PESSOA IS
'Número de telefone para contato';

CREATE TABLE TB_USUARIO (
                            ID_USUARIO       VARCHAR2(36) NOT NULL,
                            EM_USUARIO       VARCHAR2(255 CHAR) NOT NULL,
                            RL_USUARIO       VARCHAR2(20 CHAR) NOT NULL,
                            FL_ATV_USUARIO   CHAR(1) NOT NULL,
                            SEN_HASH_USUARIO VARCHAR2(255) NOT NULL
);

ALTER TABLE TB_USUARIO
    ADD CONSTRAINT CK_ROLE_USUARIO
        CHECK (
            RL_USUARIO IN (
                           'ADMIN',
                           'TUTOR',
                           'VETERINARIO'
                )
            );

ALTER TABLE TB_USUARIO
    ADD CONSTRAINT TB_USUARIO_PK
        PRIMARY KEY (ID_USUARIO);

ALTER TABLE TB_USUARIO
    ADD CONSTRAINT TB_USUARIO_EM_USUARIO_UN
        UNIQUE (EM_USUARIO);

COMMENT ON TABLE TB_USUARIO IS
'Tabela responsável pelo armazenamento das credenciais e permissões de acesso ao sistema';

COMMENT ON COLUMN TB_USUARIO.ID_USUARIO IS
'Identificador único do usuário';

COMMENT ON COLUMN TB_USUARIO.EM_USUARIO IS
'Endereço de e-mail utilizado como identificação do usuário';

COMMENT ON COLUMN TB_USUARIO.RL_USUARIO IS
'Perfil de acesso do usuário no sistema';

COMMENT ON COLUMN TB_USUARIO.FL_ATV_USUARIO IS
'Indicador que informa se o usuário está ativo';

COMMENT ON COLUMN TB_USUARIO.SEN_HASH_USUARIO IS
'Hash da senha do usuário, sem armazenamento da senha em texto puro';

CREATE TABLE TB_TUTOR (
                          ID_TUTOR              VARCHAR2(36) NOT NULL,
                          TB_USUARIO_ID_USUARIO VARCHAR2(36) NOT NULL,
                          TB_PESSOA_ID_PESSOA   VARCHAR2(36) NOT NULL
);

CREATE UNIQUE INDEX TB_TUTOR_PESSOA_IDX
    ON TB_TUTOR (TB_PESSOA_ID_PESSOA ASC);

CREATE UNIQUE INDEX TB_TUTOR_USUARIO_IDX
    ON TB_TUTOR (TB_USUARIO_ID_USUARIO ASC);

ALTER TABLE TB_TUTOR
    ADD CONSTRAINT TB_TUTOR_PK
        PRIMARY KEY (ID_TUTOR);

COMMENT ON TABLE TB_TUTOR IS
'Tabela responsável pela identificação dos tutores responsáveis pelos animais';

COMMENT ON COLUMN TB_TUTOR.ID_TUTOR IS
'Identificador único do tutor';

COMMENT ON COLUMN TB_TUTOR.TB_USUARIO_ID_USUARIO IS
'Identificador do usuário associado ao tutor';

COMMENT ON COLUMN TB_TUTOR.TB_PESSOA_ID_PESSOA IS
'Identificador dos dados pessoais associados ao tutor';

CREATE TABLE TB_ESPECIALIDADES_VET (
                                       ID_ESPECIALIDADE_VET VARCHAR2(36) NOT NULL,
                                       NM_ESPECIALIDADE     VARCHAR2(50 CHAR) NOT NULL,
                                       DS_ESPECIALIDADE     VARCHAR2(150 CHAR) NOT NULL
);

ALTER TABLE TB_ESPECIALIDADES_VET
    ADD CONSTRAINT CK_ESPECIALIDADE_VET
        CHECK (
            NM_ESPECIALIDADE IN (
                                 'ACUPUNTURA',
                                 'ANESTESIOLOGIA',
                                 'CARDIOLOGIA',
                                 'CIRURGIA',
                                 'DERMATOLOGIA',
                                 'ENDOCRINOLOGIA',
                                 'FISIOTERAPIA',
                                 'GERIATRIA',
                                 'HOMEOPATIA',
                                 'MEDICINA_ANIMAIS_SELVAGENS',
                                 'MEDICINA_DO_COLETIVO',
                                 'MEDICINA_INTENSIVA',
                                 'NEFROLOGIA_E_UROLOGIA',
                                 'NEUROLOGIA',
                                 'NUTROLOGIA',
                                 'ODONTOLOGIA',
                                 'OFTALMOLOGIA',
                                 'PATOLOGIA',
                                 'PEQUENOS_ANIMAIS',
                                 'PNEUMOLOGIA',
                                 'RADIOLOGIA'
                )
            );

ALTER TABLE TB_ESPECIALIDADES_VET
    ADD CONSTRAINT TB_ESPECIALIDADES_VET_PK
        PRIMARY KEY (ID_ESPECIALIDADE_VET);

ALTER TABLE TB_ESPECIALIDADES_VET
    ADD CONSTRAINT TB_ESPCD_VET_NM_ESPCD_UN
        UNIQUE (NM_ESPECIALIDADE);

COMMENT ON TABLE TB_ESPECIALIDADES_VET IS
'Tabela responsável pelo armazenamento das especialidades veterinárias disponíveis no sistema';

COMMENT ON COLUMN TB_ESPECIALIDADES_VET.ID_ESPECIALIDADE_VET IS
'Identificador único da especialidade veterinária';

COMMENT ON COLUMN TB_ESPECIALIDADES_VET.NM_ESPECIALIDADE IS
'Nome da especialidade veterinária';

COMMENT ON COLUMN TB_ESPECIALIDADES_VET.DS_ESPECIALIDADE IS
'Descrição da especialidade veterinária';

CREATE TABLE TB_VETERINARIO (
                                ID_VETERINARIO        VARCHAR2(36) NOT NULL,
                                CRMV_VETERINARIO      VARCHAR2(20) NOT NULL,
                                TB_USUARIO_ID_USUARIO VARCHAR2(36) NOT NULL,
                                TB_PESSOA_ID_PESSOA   VARCHAR2(36) NOT NULL
);

CREATE UNIQUE INDEX TB_VETERINARIO_PESSOA_IDX
    ON TB_VETERINARIO (TB_PESSOA_ID_PESSOA ASC);

CREATE UNIQUE INDEX TB_VETERINARIO_USUARIO_IDX
    ON TB_VETERINARIO (TB_USUARIO_ID_USUARIO ASC);

ALTER TABLE TB_VETERINARIO
    ADD CONSTRAINT TB_VETERINARIO_PK
        PRIMARY KEY (ID_VETERINARIO);

ALTER TABLE TB_VETERINARIO
    ADD CONSTRAINT TB_VETERINARIO_CRMV_UN
        UNIQUE (CRMV_VETERINARIO);

COMMENT ON TABLE TB_VETERINARIO IS
'Tabela responsável pelo armazenamento das informações profissionais dos veterinários';

COMMENT ON COLUMN TB_VETERINARIO.ID_VETERINARIO IS
'Identificador único do veterinário';

COMMENT ON COLUMN TB_VETERINARIO.CRMV_VETERINARIO IS
'Número de registro profissional do veterinário no CRMV';

COMMENT ON COLUMN TB_VETERINARIO.TB_USUARIO_ID_USUARIO IS
'Identificador do usuário associado ao veterinário';

COMMENT ON COLUMN TB_VETERINARIO.TB_PESSOA_ID_PESSOA IS
'Identificador dos dados pessoais associados ao veterinário';

CREATE TABLE TB_ANIMAL (
                           ID_ANIMAL             VARCHAR2(36) NOT NULL,
                           NM_ANIMAL             VARCHAR2(80) NOT NULL,
                           RC_ANIMAL             VARCHAR2(80) NOT NULL,
                           SX_ANIMAL             CHAR(1 CHAR) NOT NULL,
DT_NASC_ANIMAL        DATE,
NR_PESO_ANIMAL        NUMBER(5,2) NOT NULL,
TB_TUTOR_ID_TUTOR     VARCHAR2(36) NOT NULL,
TB_ESPECIE_ID_ESPECIE VARCHAR2(36) NOT NULL
);

ALTER TABLE TB_ANIMAL
    ADD CONSTRAINT CK_SX_ANIMAL
        CHECK (SX_ANIMAL IN ('F', 'M'));

ALTER TABLE TB_ANIMAL
    ADD CONSTRAINT TB_ANIMAL_PK
        PRIMARY KEY (ID_ANIMAL);

COMMENT ON TABLE TB_ANIMAL IS
'Tabela responsável pelo armazenamento das informações dos animais cadastrados no sistema Vetly';

COMMENT ON COLUMN TB_ANIMAL.ID_ANIMAL IS
'Identificador único do animal';

COMMENT ON COLUMN TB_ANIMAL.NM_ANIMAL IS
'Nome do animal';

COMMENT ON COLUMN TB_ANIMAL.RC_ANIMAL IS
'Raça do animal';

COMMENT ON COLUMN TB_ANIMAL.SX_ANIMAL IS
'Sexo do animal: F para feminino ou M para masculino';

COMMENT ON COLUMN TB_ANIMAL.DT_NASC_ANIMAL IS
'Data de nascimento do animal';

COMMENT ON COLUMN TB_ANIMAL.NR_PESO_ANIMAL IS
'Peso atual do animal em quilogramas';

COMMENT ON COLUMN TB_ANIMAL.TB_TUTOR_ID_TUTOR IS
'Identificador do tutor responsável pelo animal';

COMMENT ON COLUMN TB_ANIMAL.TB_ESPECIE_ID_ESPECIE IS
'Identificador da espécie do animal';

CREATE TABLE TB_CONSULTA (
                             ID_CONSULTA                   VARCHAR2(36) NOT NULL,
                             DT_HR_CONSULTA                DATE NOT NULL,
                             ST_CONSULTA                   VARCHAR2(20) NOT NULL,
                             VL_CONSULTA                   NUMBER(10,2) NOT NULL,
                             OBS_CONSULTA                  VARCHAR2(500),
                             TB_VETERINARIO_ID_VETERINARIO VARCHAR2(36),
                             TB_ANIMAL_ID_ANIMAL           VARCHAR2(36)
);

ALTER TABLE TB_CONSULTA
    ADD CONSTRAINT CK_STATUS_CONSULTA
        CHECK (
            ST_CONSULTA IN (
                            'AGENDADA',
                            'CANCELADA',
                            'REALIZADA'
                )
            );

ALTER TABLE TB_CONSULTA
    ADD CONSTRAINT TB_CONSULTA_PK
        PRIMARY KEY (ID_CONSULTA);

COMMENT ON TABLE TB_CONSULTA IS
'Tabela responsável pelo armazenamento das consultas veterinárias realizadas ou agendadas';

COMMENT ON COLUMN TB_CONSULTA.ID_CONSULTA IS
'Identificador único da consulta';

COMMENT ON COLUMN TB_CONSULTA.DT_HR_CONSULTA IS
'Data e horário da consulta veterinária';

COMMENT ON COLUMN TB_CONSULTA.ST_CONSULTA IS
'Status da consulta: AGENDADA, CANCELADA ou REALIZADA';

COMMENT ON COLUMN TB_CONSULTA.VL_CONSULTA IS
'Valor financeiro da consulta';

COMMENT ON COLUMN TB_CONSULTA.OBS_CONSULTA IS
'Observações registradas sobre a consulta';

COMMENT ON COLUMN TB_CONSULTA.TB_VETERINARIO_ID_VETERINARIO IS
'Identificador do veterinário responsável pela consulta';

COMMENT ON COLUMN TB_CONSULTA.TB_ANIMAL_ID_ANIMAL IS
'Identificador do animal atendido na consulta';

CREATE TABLE TB_PRONTUARIO (
                               ID_PRONTUARIO       VARCHAR2(36) NOT NULL,
                               DT_UPD_PRONTURARIO  DATE NOT NULL,
                               TB_ANIMAL_ID_ANIMAL VARCHAR2(36) NOT NULL
);

CREATE UNIQUE INDEX TB_PRONTUARIO__IDX
    ON TB_PRONTUARIO (TB_ANIMAL_ID_ANIMAL ASC);

ALTER TABLE TB_PRONTUARIO
    ADD CONSTRAINT TB_PRONTUARIO_PK
        PRIMARY KEY (ID_PRONTUARIO);

COMMENT ON TABLE TB_PRONTUARIO IS
'Tabela responsável pelo armazenamento do prontuário clínico de cada animal';

COMMENT ON COLUMN TB_PRONTUARIO.ID_PRONTUARIO IS
'Identificador único do prontuário';

COMMENT ON COLUMN TB_PRONTUARIO.DT_UPD_PRONTURARIO IS
'Data da última atualização do prontuário';

COMMENT ON COLUMN TB_PRONTUARIO.TB_ANIMAL_ID_ANIMAL IS
'Identificador do animal proprietário do prontuário';


CREATE TABLE TB_EVOLUCAO_CLINICA (
                                     ID_EVOLUCAO_CLINICA     VARCHAR2(36) NOT NULL,
                                     ANT_EVOLUCAO_CLINICA    VARCHAR2(2000 CHAR) NOT NULL,
                                     TB_CONSULTA_ID_CONSULTA VARCHAR2(36) NOT NULL
);

CREATE UNIQUE INDEX TB_EVOLUCAO_CLINICA__IDX
    ON TB_EVOLUCAO_CLINICA (TB_CONSULTA_ID_CONSULTA ASC);

ALTER TABLE TB_EVOLUCAO_CLINICA
    ADD CONSTRAINT TB_EVOLUCAO_CLINICA_PK
        PRIMARY KEY (ID_EVOLUCAO_CLINICA);

COMMENT ON TABLE TB_EVOLUCAO_CLINICA IS
'Tabela responsável pelo registro da evolução clínica do animal após uma consulta';

COMMENT ON COLUMN TB_EVOLUCAO_CLINICA.ID_EVOLUCAO_CLINICA IS
'Identificador único da evolução clínica';

COMMENT ON COLUMN TB_EVOLUCAO_CLINICA.ANT_EVOLUCAO_CLINICA IS
'Anotações referentes à evolução clínica do animal';

COMMENT ON COLUMN TB_EVOLUCAO_CLINICA.TB_CONSULTA_ID_CONSULTA IS
'Identificador da consulta relacionada à evolução clínica';


CREATE TABLE TB_SOLICITACAO_EXAME (
                                      ID_SOLICITACAO_EXAME    VARCHAR2(36) NOT NULL,
                                      OBS_SOLICITACAO         VARCHAR2(300 CHAR),
                                      TB_CONSULTA_ID_CONSULTA VARCHAR2(36)
);

CREATE UNIQUE INDEX TB_SOLICITACAO_EXAME__IDX
    ON TB_SOLICITACAO_EXAME (TB_CONSULTA_ID_CONSULTA ASC);

ALTER TABLE TB_SOLICITACAO_EXAME
    ADD CONSTRAINT TB_SOLICITACAO_EXAME_PK
        PRIMARY KEY (ID_SOLICITACAO_EXAME);

COMMENT ON TABLE TB_SOLICITACAO_EXAME IS
'Tabela responsável pelo registro das solicitações de exames realizadas durante uma consulta';

COMMENT ON COLUMN TB_SOLICITACAO_EXAME.ID_SOLICITACAO_EXAME IS
'Identificador único da solicitação de exame';

COMMENT ON COLUMN TB_SOLICITACAO_EXAME.OBS_SOLICITACAO IS
'Observações relacionadas à solicitação do exame';

COMMENT ON COLUMN TB_SOLICITACAO_EXAME.TB_CONSULTA_ID_CONSULTA IS
'Identificador da consulta responsável pela solicitação do exame';

CREATE TABLE TB_SOLICITACAO_EXAME_ITEM (
                                           ID_SOLICITACAO_EXAME_ITEM     VARCHAR2(36) NOT NULL,
                                           NM_EXAME                      VARCHAR2(100) NOT NULL,
                                           ST_EXAME                      VARCHAR2(20) NOT NULL,
                                           DT_SOLC_EXAME                 DATE NOT NULL,
                                           DT_RES_EXAME                  DATE,
                                           DS_RES_EXAME                  VARCHAR2(500),
                                           DT_ANALISE                    DATE,
                                           DT_ENVIO_RESULTADO            DATE,
                                           TB_SOLCT_EXAME_ID_SOLCT_EXAME VARCHAR2(36) NOT NULL
);

ALTER TABLE TB_SOLICITACAO_EXAME_ITEM
    ADD CONSTRAINT CK_STATUS_EXAME
        CHECK (
            ST_EXAME IN (
                         'AGUARDANDO_RESULTADO',
                         'ANALISADO',
                         'CANCELADO',
                         'RESULTADO_ENVIADO',
                         'SOLICITADO'
                )
            );

ALTER TABLE TB_SOLICITACAO_EXAME_ITEM
    ADD CONSTRAINT TB_SOLICITACAO_EXAME_ITEM_PK
        PRIMARY KEY (ID_SOLICITACAO_EXAME_ITEM);

COMMENT ON TABLE TB_SOLICITACAO_EXAME_ITEM IS
'Tabela responsável pelo armazenamento dos exames individuais solicitados';

COMMENT ON COLUMN TB_SOLICITACAO_EXAME_ITEM.ID_SOLICITACAO_EXAME_ITEM IS
'Identificador único do item de exame';

COMMENT ON COLUMN TB_SOLICITACAO_EXAME_ITEM.NM_EXAME IS
'Nome do exame solicitado';

COMMENT ON COLUMN TB_SOLICITACAO_EXAME_ITEM.ST_EXAME IS
'Status atual do exame';

COMMENT ON COLUMN TB_SOLICITACAO_EXAME_ITEM.DT_SOLC_EXAME IS
'Data da solicitação do exame';

COMMENT ON COLUMN TB_SOLICITACAO_EXAME_ITEM.DT_RES_EXAME IS
'Data de disponibilização do resultado do exame';

COMMENT ON COLUMN TB_SOLICITACAO_EXAME_ITEM.DS_RES_EXAME IS
'Descrição do resultado do exame';

COMMENT ON COLUMN TB_SOLICITACAO_EXAME_ITEM.DT_ANALISE IS
'Data em que o exame foi analisado';

COMMENT ON COLUMN TB_SOLICITACAO_EXAME_ITEM.DT_ENVIO_RESULTADO IS
'Data de envio do resultado';

COMMENT ON COLUMN TB_SOLICITACAO_EXAME_ITEM.TB_SOLCT_EXAME_ID_SOLCT_EXAME IS
'Identificador da solicitação à qual o exame pertence';

CREATE TABLE TB_ANEXO_EXAME (
                                ID_ANEXO_EXAME                VARCHAR2(36 CHAR) NOT NULL,
                                URL_ARQUIVO_ANEXO             VARCHAR2(500 CHAR) NOT NULL,
                                MIME_TYPE_ANEXO               VARCHAR2(30 CHAR) NOT NULL,
                                DT_UPLOAD_ANEXO               DATE NOT NULL,
                                TB_SLC_EX_ITEM_ID_SLC_EX_ITEM VARCHAR2(36)
);

ALTER TABLE TB_ANEXO_EXAME
    ADD CONSTRAINT TB_ANEXO_EXAME_PK
        PRIMARY KEY (ID_ANEXO_EXAME);

COMMENT ON TABLE TB_ANEXO_EXAME IS
'Tabela responsável pelo armazenamento das referências aos arquivos anexados aos exames';

COMMENT ON COLUMN TB_ANEXO_EXAME.ID_ANEXO_EXAME IS
'Identificador único do anexo';

COMMENT ON COLUMN TB_ANEXO_EXAME.URL_ARQUIVO_ANEXO IS
'URL ou localização do arquivo anexado';

COMMENT ON COLUMN TB_ANEXO_EXAME.MIME_TYPE_ANEXO IS
'Tipo MIME do arquivo anexado';

COMMENT ON COLUMN TB_ANEXO_EXAME.DT_UPLOAD_ANEXO IS
'Data de envio do arquivo';

COMMENT ON COLUMN TB_ANEXO_EXAME.TB_SLC_EX_ITEM_ID_SLC_EX_ITEM IS
'Identificador do item de exame relacionado ao anexo';

CREATE TABLE TB_VETERINARIO_ESPECIALIDADE (
                                              ID_ESPECIALIDADE_VETERINARIO  VARCHAR2(36) NOT NULL,
                                              TB_VETERINARIO_ID_VETERINARIO VARCHAR2(36) NOT NULL,
                                              TB_ESPCD_VET_ID_ESPCD_VET     VARCHAR2(36) NOT NULL
);

ALTER TABLE TB_VETERINARIO_ESPECIALIDADE
    ADD CONSTRAINT TB_VETERINARIO_ESPCD_PK
        PRIMARY KEY (ID_ESPECIALIDADE_VETERINARIO);

ALTER TABLE TB_VETERINARIO_ESPECIALIDADE
    ADD CONSTRAINT TB_VETERINARIO_ESPCD_UN
        UNIQUE (
                TB_VETERINARIO_ID_VETERINARIO,
                TB_ESPCD_VET_ID_ESPCD_VET
            );

COMMENT ON TABLE TB_VETERINARIO_ESPECIALIDADE IS
'Tabela responsável pelo relacionamento entre veterinários e suas especialidades profissionais';

COMMENT ON COLUMN TB_VETERINARIO_ESPECIALIDADE.ID_ESPECIALIDADE_VETERINARIO IS
'Identificador único do relacionamento entre veterinário e especialidade';

COMMENT ON COLUMN TB_VETERINARIO_ESPECIALIDADE.TB_VETERINARIO_ID_VETERINARIO IS
'Identificador do veterinário relacionado';

COMMENT ON COLUMN TB_VETERINARIO_ESPECIALIDADE.TB_ESPCD_VET_ID_ESPCD_VET IS
'Identificador da especialidade veterinária relacionada';


CREATE TABLE TB_VETERINARIO_ESPECIE (
                                        ID_VETERINARIO_ESPECIE        VARCHAR2(36) NOT NULL,
                                        TB_VETERINARIO_ID_VETERINARIO VARCHAR2(36) NOT NULL,
                                        TB_ESPECIE_ID_ESPECIE         VARCHAR2(36) NOT NULL
);

ALTER TABLE TB_VETERINARIO_ESPECIE
    ADD CONSTRAINT TB_VETERINARIO_ESPECIE_PK
        PRIMARY KEY (ID_VETERINARIO_ESPECIE);

ALTER TABLE TB_VETERINARIO_ESPECIE
    ADD CONSTRAINT TB_VETERINARIO_ESPECIE_UN
        UNIQUE (
                TB_VETERINARIO_ID_VETERINARIO,
                TB_ESPECIE_ID_ESPECIE
            );

COMMENT ON TABLE TB_VETERINARIO_ESPECIE IS
'Tabela responsável pelo relacionamento entre veterinários e as espécies que estão habilitados a atender';

COMMENT ON COLUMN TB_VETERINARIO_ESPECIE.ID_VETERINARIO_ESPECIE IS
'Identificador único do relacionamento entre veterinário e espécie';

COMMENT ON COLUMN TB_VETERINARIO_ESPECIE.TB_VETERINARIO_ID_VETERINARIO IS
'Identificador do veterinário relacionado';

COMMENT ON COLUMN TB_VETERINARIO_ESPECIE.TB_ESPECIE_ID_ESPECIE IS
'Identificador da espécie relacionada';


-- CHAVES ESTRANGEIRAS

ALTER TABLE TB_ANIMAL
    ADD CONSTRAINT TB_ANIMAL_TB_ESPECIE_FK
        FOREIGN KEY (TB_ESPECIE_ID_ESPECIE)
            REFERENCES TB_ESPECIE (ID_ESPECIE);

ALTER TABLE TB_ANIMAL
    ADD CONSTRAINT TB_ANIMAL_TB_TUTOR_FK
        FOREIGN KEY (TB_TUTOR_ID_TUTOR)
            REFERENCES TB_TUTOR (ID_TUTOR);

ALTER TABLE TB_TUTOR
    ADD CONSTRAINT TB_TUTOR_TB_PESSOA_FK
        FOREIGN KEY (TB_PESSOA_ID_PESSOA)
            REFERENCES TB_PESSOA (ID_PESSOA);

ALTER TABLE TB_TUTOR
    ADD CONSTRAINT TB_TUTOR_TB_USUARIO_FK
        FOREIGN KEY (TB_USUARIO_ID_USUARIO)
            REFERENCES TB_USUARIO (ID_USUARIO);

ALTER TABLE TB_VETERINARIO
    ADD CONSTRAINT TB_VETERINARIO_TB_PESSOA_FK
        FOREIGN KEY (TB_PESSOA_ID_PESSOA)
            REFERENCES TB_PESSOA (ID_PESSOA);

ALTER TABLE TB_VETERINARIO
    ADD CONSTRAINT TB_VETERINARIO_TB_USUARIO_FK
        FOREIGN KEY (TB_USUARIO_ID_USUARIO)
            REFERENCES TB_USUARIO (ID_USUARIO);

ALTER TABLE TB_CONSULTA
    ADD CONSTRAINT TB_CONSULTA_TB_ANIMAL_FK
        FOREIGN KEY (TB_ANIMAL_ID_ANIMAL)
            REFERENCES TB_ANIMAL (ID_ANIMAL);

ALTER TABLE TB_CONSULTA
    ADD CONSTRAINT TB_CONSULTA_TB_VETERINARIO_FK
        FOREIGN KEY (TB_VETERINARIO_ID_VETERINARIO)
            REFERENCES TB_VETERINARIO (ID_VETERINARIO);

ALTER TABLE TB_PRONTUARIO
    ADD CONSTRAINT TB_PRONTUARIO_TB_ANIMAL_FK
        FOREIGN KEY (TB_ANIMAL_ID_ANIMAL)
            REFERENCES TB_ANIMAL (ID_ANIMAL);

ALTER TABLE TB_EVOLUCAO_CLINICA
    ADD CONSTRAINT TB_EVO_CLNC_TB_CONSULTA_FK
        FOREIGN KEY (TB_CONSULTA_ID_CONSULTA)
            REFERENCES TB_CONSULTA (ID_CONSULTA);

ALTER TABLE TB_SOLICITACAO_EXAME
    ADD CONSTRAINT TB_SLCT_EXM_TB_CONSULTA_FK
        FOREIGN KEY (TB_CONSULTA_ID_CONSULTA)
            REFERENCES TB_CONSULTA (ID_CONSULTA);

ALTER TABLE TB_SOLICITACAO_EXAME_ITEM
    ADD CONSTRAINT TB_SLC_EX_ITEM_TB_SLC_EX_FK
        FOREIGN KEY (TB_SOLCT_EXAME_ID_SOLCT_EXAME)
            REFERENCES TB_SOLICITACAO_EXAME (ID_SOLICITACAO_EXAME);

ALTER TABLE TB_ANEXO_EXAME
    ADD CONSTRAINT TB_ANX_EXM_TB_SOLCT_ITEM_FK
        FOREIGN KEY (TB_SLC_EX_ITEM_ID_SLC_EX_ITEM)
            REFERENCES TB_SOLICITACAO_EXAME_ITEM (ID_SOLICITACAO_EXAME_ITEM);

ALTER TABLE TB_VETERINARIO_ESPECIALIDADE
    ADD CONSTRAINT TB_VET_ESPCD_TB_ESPCD_VET_FK
        FOREIGN KEY (TB_ESPCD_VET_ID_ESPCD_VET)
            REFERENCES TB_ESPECIALIDADES_VET (ID_ESPECIALIDADE_VET);

ALTER TABLE TB_VETERINARIO_ESPECIALIDADE
    ADD CONSTRAINT TB_VET_ESPCD_TB_VET_FK
        FOREIGN KEY (TB_VETERINARIO_ID_VETERINARIO)
            REFERENCES TB_VETERINARIO (ID_VETERINARIO);

ALTER TABLE TB_VETERINARIO_ESPECIE
    ADD CONSTRAINT TB_VET_ESPECIE_TB_ESPECIE_FK
        FOREIGN KEY (TB_ESPECIE_ID_ESPECIE)
            REFERENCES TB_ESPECIE (ID_ESPECIE);

ALTER TABLE TB_VETERINARIO_ESPECIE
    ADD CONSTRAINT TB_VET_ESPECIE_TB_VET_FK
        FOREIGN KEY (TB_VETERINARIO_ID_VETERINARIO)
            REFERENCES TB_VETERINARIO (ID_VETERINARIO);
