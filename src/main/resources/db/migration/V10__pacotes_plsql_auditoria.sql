-- V10: pacotes PL/SQL, trilha de auditoria e trigger (Sprint 4 - Banco de Dados)
--
-- Cria PKG_VETLY_LOG, PKG_VETLY_VALIDACAO, PKG_VETLY_JSON e PKG_VETLY_RELATORIO,
-- a tabela TB_AUDITORIA e a trigger TRG_AUD_CONSULTA. O painel Java consome
-- PKG_VETLY_RELATORIO; os demais servem a validacao, a exportacao para MongoDB
-- e a auditoria. Tudo e entregue por esta migration: qualquer ambiente que rode
-- o Flyway recebe os objetos, sem passo manual.
--
-- Fonte: database/scripts/01..05 (gerado por gerar-migration.sh).
-- NAO EDITE depois de aplicada: o checksum do Flyway cobre o arquivo inteiro.

-- ---------------------------------------------------------------- 01_pkg_vetly_log
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

-- ---------------------------------------------------------------- 02_pkg_vetly_validacao
-- ============================================================================
-- SPRINT 4 - PACOTE PKG_VETLY_VALIDACAO
--
-- fn_valida_cpf: algoritmo oficial de digito verificador (modulo 11).
-- Retorna 'S' (valido) ou 'N' (invalido). Entrada nula ou com tamanho diferente
-- de 11 e erro de contrato e levanta ORA-20011 / ORA-20012.
-- ============================================================================
CREATE OR REPLACE PACKAGE PKG_VETLY_VALIDACAO AS
    FUNCTION fn_valida_cpf (p_cpf IN VARCHAR2) RETURN CHAR;
END PKG_VETLY_VALIDACAO;
/

CREATE OR REPLACE PACKAGE BODY PKG_VETLY_VALIDACAO AS

    FUNCTION fn_valida_cpf (p_cpf IN VARCHAR2) RETURN CHAR IS
        v_cpf      VARCHAR2(11);
        v_soma     PLS_INTEGER;
        v_resto    PLS_INTEGER;
        v_digito1  PLS_INTEGER;
        v_digito2  PLS_INTEGER;
        v_repetido BOOLEAN := TRUE;
    BEGIN
        IF p_cpf IS NULL THEN
            RAISE_APPLICATION_ERROR(-20011, 'fn_valida_cpf: CPF nao informado');
        END IF;

        v_cpf := TRIM(p_cpf);

        IF LENGTH(v_cpf) <> 11 THEN
            RAISE_APPLICATION_ERROR(-20012,
                'fn_valida_cpf: CPF deve possuir 11 digitos, recebido ' || LENGTH(v_cpf));
        END IF;

        IF NOT REGEXP_LIKE(v_cpf, '^[0-9]{11}$') THEN
            RETURN 'N';
        END IF;

        -- 111.111.111-11 e similares passam no modulo 11, mas sao invalidos
        FOR i IN 2 .. 11 LOOP
            IF SUBSTR(v_cpf, i, 1) <> SUBSTR(v_cpf, 1, 1) THEN
                v_repetido := FALSE;
                EXIT;
            END IF;
        END LOOP;
        IF v_repetido THEN
            RETURN 'N';
        END IF;

        v_soma := 0;
        FOR i IN 1 .. 9 LOOP
            v_soma := v_soma + TO_NUMBER(SUBSTR(v_cpf, i, 1)) * (11 - i);
        END LOOP;
        v_resto   := MOD(v_soma, 11);
        v_digito1 := CASE WHEN v_resto < 2 THEN 0 ELSE 11 - v_resto END;

        v_soma := 0;
        FOR i IN 1 .. 9 LOOP
            v_soma := v_soma + TO_NUMBER(SUBSTR(v_cpf, i, 1)) * (12 - i);
        END LOOP;
        v_soma    := v_soma + v_digito1 * 2;
        v_resto   := MOD(v_soma, 11);
        v_digito2 := CASE WHEN v_resto < 2 THEN 0 ELSE 11 - v_resto END;

        IF TO_NUMBER(SUBSTR(v_cpf, 10, 1)) = v_digito1
           AND TO_NUMBER(SUBSTR(v_cpf, 11, 1)) = v_digito2 THEN
            RETURN 'S';
        END IF;
        RETURN 'N';
    EXCEPTION
        WHEN OTHERS THEN
            PKG_VETLY_LOG.registrar('PKG_VETLY_VALIDACAO.fn_valida_cpf', SQLCODE, SQLERRM);
            RAISE;
    END fn_valida_cpf;

END PKG_VETLY_VALIDACAO;
/

-- ---------------------------------------------------------------- 03_pkg_vetly_json
-- ============================================================================
-- SPRINT 4 - PACOTE PKG_VETLY_JSON
--
-- Gera o dataset relacional -> JSON que alimenta o MongoDB.
--
-- Cada documento e um ANIMAL com o tutor embutido e a lista de suas consultas
-- (cada uma com o veterinario embutido): o formato de documento que o Mongo
-- consulta sem JOIN. O JSON e montado por concatenacao, sem depender de
-- funcoes JSON de uma versao especifica do Oracle.
--
-- Independente de ambiente: a funcao DEVOLVE o texto (CLOB). Nao grava arquivo
-- no servidor (UTL_FILE/DIRECTORY), nao usa DBMS_OUTPUT e formata numeros e
-- datas com mascaras fixas, sem herdar NLS da sessao.
-- ============================================================================
CREATE OR REPLACE PACKAGE PKG_VETLY_JSON AS

    -- Um documento (VARCHAR2) para o animal informado, sem consultas.
    FUNCTION fn_monta_json_animal (
        p_id_animal   IN VARCHAR2,
        p_nm_animal   IN VARCHAR2,
        p_nm_especie  IN VARCHAR2,
        p_rc_animal   IN VARCHAR2,
        p_sx_animal   IN VARCHAR2,
        p_peso_animal IN NUMBER,
        p_nm_tutor    IN VARCHAR2,
        p_tel_tutor   IN VARCHAR2
    ) RETURN VARCHAR2;

    -- Dataset completo.
    --   p_formato = 'NDJSON' (padrao): um documento por linha (mongoimport nativo)
    --   p_formato = 'ARRAY'          : um unico array JSON (mongoimport --jsonArray)
    --   p_id_tutor                   : opcional, restringe a um tutor
    -- ORA-20021 formato invalido | ORA-20022 tutor inexistente
    FUNCTION fn_dataset_animais_json (
        p_formato  IN VARCHAR2 DEFAULT 'NDJSON',
        p_id_tutor IN VARCHAR2 DEFAULT NULL
    ) RETURN CLOB;

END PKG_VETLY_JSON;
/

CREATE OR REPLACE PACKAGE BODY PKG_VETLY_JSON AS

    -- Mascara numerica fixa: ponto decimal independente de NLS_NUMERIC_CHARACTERS
    c_nls_num CONSTANT VARCHAR2(40) := 'NLS_NUMERIC_CHARACTERS=''.,''';

    -- Escapa o necessario para uma string JSON valida
    FUNCTION fn_escapa (p_valor IN VARCHAR2) RETURN VARCHAR2 IS
        v_saida VARCHAR2(32767);
    BEGIN
        IF p_valor IS NULL THEN
            RETURN '';
        END IF;
        v_saida := REPLACE(p_valor, '\', '\\');
        v_saida := REPLACE(v_saida, '"', '\"');
        v_saida := REPLACE(v_saida, CHR(10), '\n');
        v_saida := REPLACE(v_saida, CHR(13), '\r');
        v_saida := REPLACE(v_saida, CHR(9),  '\t');
        RETURN v_saida;
    END fn_escapa;

    FUNCTION fn_str (p_valor IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        IF p_valor IS NULL THEN
            RETURN 'null';
        END IF;
        RETURN '"' || fn_escapa(p_valor) || '"';
    END fn_str;

    FUNCTION fn_num (p_valor IN NUMBER) RETURN VARCHAR2 IS
    BEGIN
        IF p_valor IS NULL THEN
            RETURN 'null';
        END IF;
        RETURN TO_CHAR(p_valor, 'FM99999999990.00', c_nls_num);
    END fn_num;

    FUNCTION fn_data (p_valor IN DATE) RETURN VARCHAR2 IS
    BEGIN
        IF p_valor IS NULL THEN
            RETURN 'null';
        END IF;
        RETURN '"' || TO_CHAR(p_valor, 'YYYY-MM-DD"T"HH24:MI:SS') || '"';
    END fn_data;

    PROCEDURE p_anexa (p_clob IN OUT NOCOPY CLOB, p_texto IN VARCHAR2) IS
    BEGIN
        IF p_texto IS NOT NULL AND LENGTH(p_texto) > 0 THEN
            DBMS_LOB.WRITEAPPEND(p_clob, LENGTH(p_texto), p_texto);
        END IF;
    END p_anexa;

    FUNCTION fn_monta_json_animal (
        p_id_animal   IN VARCHAR2,
        p_nm_animal   IN VARCHAR2,
        p_nm_especie  IN VARCHAR2,
        p_rc_animal   IN VARCHAR2,
        p_sx_animal   IN VARCHAR2,
        p_peso_animal IN NUMBER,
        p_nm_tutor    IN VARCHAR2,
        p_tel_tutor   IN VARCHAR2
    ) RETURN VARCHAR2 IS
    BEGIN
        IF p_id_animal IS NULL OR p_nm_animal IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001,
                'fn_monta_json_animal: ID_ANIMAL e NM_ANIMAL sao obrigatorios');
        END IF;

        RETURN '{'
            || '"_id":'     || fn_str(p_id_animal)  || ','
            || '"nome":'    || fn_str(p_nm_animal)  || ','
            || '"especie":' || fn_str(p_nm_especie) || ','
            || '"raca":'    || fn_str(p_rc_animal)  || ','
            || '"sexo":'    || fn_str(p_sx_animal)  || ','
            || '"pesoKg":'  || fn_num(p_peso_animal) || ','
            || '"tutor":{'
            ||     '"nome":'     || fn_str(p_nm_tutor)  || ','
            ||     '"telefone":' || fn_str(p_tel_tutor)
            || '}'
            || '}';
    EXCEPTION
        WHEN OTHERS THEN
            PKG_VETLY_LOG.registrar('PKG_VETLY_JSON.fn_monta_json_animal', SQLCODE, SQLERRM);
            RAISE;
    END fn_monta_json_animal;

    FUNCTION fn_dataset_animais_json (
        p_formato  IN VARCHAR2 DEFAULT 'NDJSON',
        p_id_tutor IN VARCHAR2 DEFAULT NULL
    ) RETURN CLOB IS
        v_formato  VARCHAR2(10) := UPPER(TRIM(NVL(p_formato, 'NDJSON')));
        v_resultado CLOB;
        v_qt_tutor  PLS_INTEGER;
        v_qt_animal PLS_INTEGER := 0;
        v_qt_cons   PLS_INTEGER;
        v_sep       VARCHAR2(4);

        CURSOR c_animais IS
            SELECT a.ID_ANIMAL, a.NM_ANIMAL, a.RC_ANIMAL, a.SX_ANIMAL,
                   a.DT_NASC_ANIMAL, a.NR_PESO_ANIMAL,
                   e.NM_ESPECIE,
                   t.ID_TUTOR, p.NM_PESSOA AS NM_TUTOR, p.TEL_PESSOA AS TEL_TUTOR
              FROM TB_ANIMAL a
              JOIN TB_ESPECIE e ON e.ID_ESPECIE = a.TB_ESPECIE_ID_ESPECIE
              JOIN TB_TUTOR   t ON t.ID_TUTOR   = a.TB_TUTOR_ID_TUTOR
              JOIN TB_PESSOA  p ON p.ID_PESSOA  = t.TB_PESSOA_ID_PESSOA
             WHERE p_id_tutor IS NULL OR t.ID_TUTOR = p_id_tutor
             ORDER BY a.NM_ANIMAL, a.ID_ANIMAL;

        CURSOR c_consultas (p_animal IN VARCHAR2) IS
            SELECT c.ID_CONSULTA, c.DT_HR_CONSULTA, c.ST_CONSULTA, c.VL_CONSULTA,
                   c.OBS_CONSULTA, v.ID_VETERINARIO, pv.NM_PESSOA AS NM_VETERINARIO
              FROM TB_CONSULTA c
              LEFT JOIN TB_VETERINARIO v ON v.ID_VETERINARIO = c.TB_VETERINARIO_ID_VETERINARIO
              LEFT JOIN TB_PESSOA     pv ON pv.ID_PESSOA     = v.TB_PESSOA_ID_PESSOA
             WHERE c.TB_ANIMAL_ID_ANIMAL = p_animal
             ORDER BY c.DT_HR_CONSULTA, c.ID_CONSULTA;
    BEGIN
        IF v_formato NOT IN ('NDJSON', 'ARRAY') THEN
            RAISE_APPLICATION_ERROR(-20021,
                'fn_dataset_animais_json: formato invalido (use NDJSON ou ARRAY): ' || p_formato);
        END IF;

        IF p_id_tutor IS NOT NULL THEN
            SELECT COUNT(*) INTO v_qt_tutor FROM TB_TUTOR WHERE ID_TUTOR = p_id_tutor;
            IF v_qt_tutor = 0 THEN
                RAISE_APPLICATION_ERROR(-20022,
                    'fn_dataset_animais_json: tutor ' || p_id_tutor || ' nao encontrado');
            END IF;
        END IF;

        DBMS_LOB.CREATETEMPORARY(v_resultado, TRUE);
        IF v_formato = 'ARRAY' THEN
            p_anexa(v_resultado, '[' || CHR(10));
        END IF;

        FOR r IN c_animais LOOP
            v_qt_animal := v_qt_animal + 1;

            IF v_formato = 'ARRAY' THEN
                v_sep := CASE WHEN v_qt_animal = 1 THEN '' ELSE ',' || CHR(10) END;
            ELSE
                v_sep := CASE WHEN v_qt_animal = 1 THEN '' ELSE CHR(10) END;
            END IF;
            p_anexa(v_resultado, v_sep);

            p_anexa(v_resultado, '{'
                || '"_id":'         || fn_str(r.ID_ANIMAL)        || ','
                || '"nome":'        || fn_str(r.NM_ANIMAL)        || ','
                || '"especie":'     || fn_str(r.NM_ESPECIE)       || ','
                || '"raca":'        || fn_str(r.RC_ANIMAL)        || ','
                || '"sexo":'        || fn_str(r.SX_ANIMAL)        || ','
                || '"dataNascimento":' || fn_data(r.DT_NASC_ANIMAL) || ','
                || '"pesoKg":'      || fn_num(r.NR_PESO_ANIMAL)   || ','
                || '"tutor":{'
                ||     '"idTutor":'  || fn_str(r.ID_TUTOR)        || ','
                ||     '"nome":'     || fn_str(r.NM_TUTOR)        || ','
                ||     '"telefone":' || fn_str(r.TEL_TUTOR)
                || '},'
                || '"consultas":[');

            v_qt_cons := 0;
            FOR c IN c_consultas(r.ID_ANIMAL) LOOP
                v_qt_cons := v_qt_cons + 1;
                p_anexa(v_resultado,
                       CASE WHEN v_qt_cons = 1 THEN '' ELSE ',' END
                    || '{'
                    ||   '"idConsulta":'  || fn_str(c.ID_CONSULTA)        || ','
                    ||   '"dataHora":'    || fn_data(c.DT_HR_CONSULTA)    || ','
                    ||   '"status":'      || fn_str(c.ST_CONSULTA)        || ','
                    ||   '"valor":'       || fn_num(c.VL_CONSULTA)        || ','
                    ||   '"observacao":'  || fn_str(c.OBS_CONSULTA)       || ','
                    ||   '"veterinario":' ||
                         CASE WHEN c.ID_VETERINARIO IS NULL THEN 'null'
                              ELSE '{"idVeterinario":' || fn_str(c.ID_VETERINARIO)
                                   || ',"nome":' || fn_str(c.NM_VETERINARIO) || '}'
                         END
                    || '}');
            END LOOP;

            p_anexa(v_resultado, ']}');
        END LOOP;

        IF v_formato = 'ARRAY' THEN
            p_anexa(v_resultado, CHR(10) || ']');
        ELSIF v_qt_animal > 0 THEN
            p_anexa(v_resultado, CHR(10));
        END IF;

        RETURN v_resultado;
    EXCEPTION
        WHEN OTHERS THEN
            PKG_VETLY_LOG.registrar('PKG_VETLY_JSON.fn_dataset_animais_json', SQLCODE, SQLERRM);
            RAISE;
    END fn_dataset_animais_json;

END PKG_VETLY_JSON;
/

-- ---------------------------------------------------------------- 04_pkg_vetly_relatorio
-- ============================================================================
-- SPRINT 4 - PACOTE PKG_VETLY_RELATORIO
--
-- Relatorio de consultas por veterinario x status, com subtotal por veterinario
-- e total geral. DEVOLVE um SYS_REFCURSOR (consumivel por JDBC/Java, .NET e
-- qualquer cliente); nao usa DBMS_OUTPUT.
--
-- Colunas do cursor:
--   NM_VETERINARIO | ST_CONSULTA | QT_CONSULTAS | VL_TOTAL | TP_LINHA
--   TP_LINHA: DETALHE (vet+status), SUBTOTAL (vet, status nulo), TOTAL (ambos nulos)
--
-- ORA-20005: p_status fora dos valores validos de TB_CONSULTA.ST_CONSULTA
-- ============================================================================
CREATE OR REPLACE PACKAGE PKG_VETLY_RELATORIO AS
    PROCEDURE prc_consultas_vet_status (
        p_status    IN  VARCHAR2 DEFAULT NULL,
        p_resultado OUT SYS_REFCURSOR
    );
END PKG_VETLY_RELATORIO;
/

CREATE OR REPLACE PACKAGE BODY PKG_VETLY_RELATORIO AS

    PROCEDURE prc_consultas_vet_status (
        p_status    IN  VARCHAR2 DEFAULT NULL,
        p_resultado OUT SYS_REFCURSOR
    ) IS
        v_status VARCHAR2(20) := UPPER(TRIM(p_status));
    BEGIN
        IF v_status IS NOT NULL
           AND v_status NOT IN ('AGENDADA', 'CANCELADA', 'REALIZADA', 'NAO_COMPARECEU') THEN
            RAISE_APPLICATION_ERROR(-20005,
                'prc_consultas_vet_status: status invalido: ' || p_status);
        END IF;

        OPEN p_resultado FOR
            SELECT x.nm_veterinario,
                   x.st_consulta,
                   x.qt_consultas,
                   x.vl_total,
                   x.tp_linha
              FROM (
                    SELECT CASE WHEN GROUPING(v.ID_VETERINARIO) = 1 THEN 'TOTAL GERAL'
                                ELSE MAX(p.NM_PESSOA) END                AS nm_veterinario,
                           CASE WHEN GROUPING(c.ST_CONSULTA) = 1 THEN NULL
                                ELSE c.ST_CONSULTA END                   AS st_consulta,
                           COUNT(*)                                      AS qt_consultas,
                           SUM(c.VL_CONSULTA)                            AS vl_total,
                           CASE WHEN GROUPING(v.ID_VETERINARIO) = 1 THEN 'TOTAL'
                                WHEN GROUPING(c.ST_CONSULTA)    = 1 THEN 'SUBTOTAL'
                                ELSE 'DETALHE' END                       AS tp_linha,
                           GROUPING(v.ID_VETERINARIO)                    AS g_vet,
                           GROUPING(c.ST_CONSULTA)                       AS g_st,
                           v.ID_VETERINARIO                              AS id_vet
                      FROM TB_CONSULTA c
                      JOIN TB_VETERINARIO v ON v.ID_VETERINARIO = c.TB_VETERINARIO_ID_VETERINARIO
                      JOIN TB_PESSOA      p ON p.ID_PESSOA      = v.TB_PESSOA_ID_PESSOA
                     WHERE v_status IS NULL OR c.ST_CONSULTA = v_status
                     GROUP BY ROLLUP (v.ID_VETERINARIO, c.ST_CONSULTA)
                   ) x
             ORDER BY x.g_vet, x.nm_veterinario, x.id_vet, x.g_st, x.st_consulta;
    EXCEPTION
        WHEN OTHERS THEN
            PKG_VETLY_LOG.registrar('PKG_VETLY_RELATORIO.prc_consultas_vet_status', SQLCODE, SQLERRM);
            RAISE;
    END prc_consultas_vet_status;

END PKG_VETLY_RELATORIO;
/

-- ---------------------------------------------------------------- 05_trigger_auditoria
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
