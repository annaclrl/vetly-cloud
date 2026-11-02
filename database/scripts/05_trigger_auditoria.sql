-- ============================================================================
-- SPRINT 4 - TB_AUDITORIA + TRIGGER TRG_AUD_CONSULTA
--
-- Trigger nao pode morar em pacote; ela delega o log ao PKG_VETLY_LOG.
-- Dispara AFTER INSERT/UPDATE/DELETE em TB_CONSULTA, ou seja, audita tambem as
-- gravacoes feitas pela aplicacao Java (JPA), em qualquer ambiente onde o
-- schema esteja migrado.
-- ============================================================================

-- Idempotente: o schema pode ja ter TB_AUDITORIA/SQ_AUDITORIA (scripts da Sprint 3)
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE TB_AUDITORIA (
            ID_AUDITORIA        NUMBER          NOT NULL,
            NM_TABELA           VARCHAR2(30)    NOT NULL,
            NM_USUARIO          VARCHAR2(100)   NOT NULL,
            TP_OPERACAO         VARCHAR2(10)    NOT NULL,
            DT_HR_OPERACAO      DATE            NOT NULL,
            DS_VALORES_ANTIGOS  VARCHAR2(4000),
            DS_VALORES_NOVOS    VARCHAR2(4000),
            CONSTRAINT TB_AUDITORIA_PK PRIMARY KEY (ID_AUDITORIA),
            CONSTRAINT CK_TP_OPERACAO_AUDITORIA CHECK (TP_OPERACAO IN (''INSERT'', ''UPDATE'', ''DELETE''))
        )';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -955 THEN RAISE; END IF; -- ORA-00955: nome ja utilizado
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE SQ_AUDITORIA START WITH 1 INCREMENT BY 1 NOCACHE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -955 THEN RAISE; END IF;
END;
/

COMMENT ON TABLE TB_AUDITORIA IS 'Trilha de auditoria DML de TB_CONSULTA, preenchida por TRG_AUD_CONSULTA';

CREATE OR REPLACE TRIGGER TRG_AUD_CONSULTA
AFTER INSERT OR UPDATE OR DELETE ON TB_CONSULTA
FOR EACH ROW
DECLARE
    v_tp_operacao VARCHAR2(10);
    v_valores_old VARCHAR2(4000);
    v_valores_new VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_tp_operacao := 'INSERT';
    ELSIF UPDATING THEN
        v_tp_operacao := 'UPDATE';
    ELSE
        v_tp_operacao := 'DELETE';
    END IF;

    -- Mascaras fixas (data e numero) para o resultado nao depender de NLS da sessao
    IF NOT INSERTING THEN
        v_valores_old := SUBSTR(
            'ID_CONSULTA='     || :OLD.ID_CONSULTA ||
            '|DT_HR_CONSULTA=' || TO_CHAR(:OLD.DT_HR_CONSULTA, 'YYYY-MM-DD HH24:MI:SS') ||
            '|ST_CONSULTA='    || :OLD.ST_CONSULTA ||
            '|VL_CONSULTA='    || TO_CHAR(:OLD.VL_CONSULTA, 'FM99999990.00', 'NLS_NUMERIC_CHARACTERS=''.,''') ||
            '|OBS_CONSULTA='   || :OLD.OBS_CONSULTA ||
            '|VETERINARIO='    || :OLD.TB_VETERINARIO_ID_VETERINARIO ||
            '|ANIMAL='         || :OLD.TB_ANIMAL_ID_ANIMAL, 1, 4000);
    END IF;

    IF NOT DELETING THEN
        v_valores_new := SUBSTR(
            'ID_CONSULTA='     || :NEW.ID_CONSULTA ||
            '|DT_HR_CONSULTA=' || TO_CHAR(:NEW.DT_HR_CONSULTA, 'YYYY-MM-DD HH24:MI:SS') ||
            '|ST_CONSULTA='    || :NEW.ST_CONSULTA ||
            '|VL_CONSULTA='    || TO_CHAR(:NEW.VL_CONSULTA, 'FM99999990.00', 'NLS_NUMERIC_CHARACTERS=''.,''') ||
            '|OBS_CONSULTA='   || :NEW.OBS_CONSULTA ||
            '|VETERINARIO='    || :NEW.TB_VETERINARIO_ID_VETERINARIO ||
            '|ANIMAL='         || :NEW.TB_ANIMAL_ID_ANIMAL, 1, 4000);
    END IF;

    INSERT INTO TB_AUDITORIA (
        ID_AUDITORIA, NM_TABELA, NM_USUARIO, TP_OPERACAO, DT_HR_OPERACAO,
        DS_VALORES_ANTIGOS, DS_VALORES_NOVOS
    ) VALUES (
        SQ_AUDITORIA.NEXTVAL, 'TB_CONSULTA', USER, v_tp_operacao, SYSDATE,
        v_valores_old, v_valores_new
    );
EXCEPTION
    -- A auditoria jamais pode impedir a operacao de negocio que a disparou
    WHEN OTHERS THEN
        PKG_VETLY_LOG.registrar('TRG_AUD_CONSULTA', SQLCODE, SQLERRM);
END TRG_AUD_CONSULTA;
/
