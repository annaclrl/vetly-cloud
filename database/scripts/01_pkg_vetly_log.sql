-- ============================================================================
-- SPRINT 4 - MASTERING RELATIONAL AND NON-RELATIONAL DATABASE
-- PACOTE PKG_VETLY_LOG
--
-- Substitui a procedure solta SP_REGISTRA_LOG. Grava em TB_LOG_ERRO cada excecao
-- tratada pelos demais pacotes, em transacao autonoma: o log sobrevive mesmo que
-- a operacao chamadora seja desfeita.
--
-- Nunca propaga erro: um log que falha nao pode derrubar a operacao de negocio
-- (nem a trigger de auditoria) que o chamou.
-- ============================================================================
CREATE OR REPLACE PACKAGE PKG_VETLY_LOG AS
    PROCEDURE registrar (
        p_origem   IN VARCHAR2,
        p_cd_erro  IN NUMBER,
        p_mensagem IN VARCHAR2
    );
END PKG_VETLY_LOG;
/

CREATE OR REPLACE PACKAGE BODY PKG_VETLY_LOG AS

    PROCEDURE registrar (
        p_origem   IN VARCHAR2,
        p_cd_erro  IN NUMBER,
        p_mensagem IN VARCHAR2
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO TB_LOG_ERRO (
            ID_LOG, NM_PROCEDURE, NM_USUARIO, DT_OCORRENCIA, CD_ERRO, DS_MENSAGEM
        ) VALUES (
            TO_CHAR(SQ_LOG_ERRO.NEXTVAL),
            SUBSTR(NVL(p_origem, 'DESCONHECIDA'), 1, 100),
            USER,
            SYSDATE,
            TO_CHAR(NVL(p_cd_erro, 0)),
            SUBSTR(NVL(p_mensagem, '(sem mensagem)'), 1, 4000)
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; -- falha ao logar e deliberadamente silenciosa
    END registrar;

END PKG_VETLY_LOG;
/
