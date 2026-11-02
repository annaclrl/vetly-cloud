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
