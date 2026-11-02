-- ============================================================================
-- SPRINT 4 - TESTES DE EXECUCAO (caminho feliz + excecoes tratadas)
-- Pre-requisito: 07_carga_demo.sql. SET SERVEROUTPUT ON.
-- Cada bloco imprime PASSOU / FALHOU; os prints do PDF/video saem daqui.
-- ============================================================================
SET SERVEROUTPUT ON SIZE UNLIMITED

-- ---- PKG_VETLY_VALIDACAO ---------------------------------------------------
DECLARE
    PROCEDURE chk(p_nome VARCHAR2, p_ok BOOLEAN) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE(CASE WHEN p_ok THEN 'PASSOU  ' ELSE 'FALHOU  ' END || p_nome);
    END;
BEGIN
    chk('CPF valido -> S',            PKG_VETLY_VALIDACAO.fn_valida_cpf('52998224725') = 'S');
    chk('CPF digito errado -> N',     PKG_VETLY_VALIDACAO.fn_valida_cpf('52998224726') = 'N');
    chk('CPF repetido -> N',          PKG_VETLY_VALIDACAO.fn_valida_cpf('11111111111') = 'N');
    chk('CPF alfanumerico -> N',      PKG_VETLY_VALIDACAO.fn_valida_cpf('5299822472A') = 'N');
    BEGIN
        IF PKG_VETLY_VALIDACAO.fn_valida_cpf(NULL) = 'x' THEN NULL; END IF;
        chk('CPF nulo levanta ORA-20011', FALSE);
    EXCEPTION WHEN OTHERS THEN chk('CPF nulo levanta ORA-20011', SQLCODE = -20011);
    END;
    BEGIN
        IF PKG_VETLY_VALIDACAO.fn_valida_cpf('123') = 'x' THEN NULL; END IF;
        chk('CPF curto levanta ORA-20012', FALSE);
    EXCEPTION WHEN OTHERS THEN chk('CPF curto levanta ORA-20012', SQLCODE = -20012);
    END;
END;
/

-- ---- PKG_VETLY_JSON --------------------------------------------------------
DECLARE
    v_nd    CLOB;
    v_arr   CLOB;
    PROCEDURE chk(p_nome VARCHAR2, p_ok BOOLEAN) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE(CASE WHEN p_ok THEN 'PASSOU  ' ELSE 'FALHOU  ' END || p_nome);
    END;
BEGIN
    v_nd  := PKG_VETLY_JSON.fn_dataset_animais_json('NDJSON');
    v_arr := PKG_VETLY_JSON.fn_dataset_animais_json('ARRAY');
    chk('NDJSON nao vazio',                    DBMS_LOB.GETLENGTH(v_nd) > 0);
    chk('ARRAY comeca com [ e termina com ]',  SUBSTR(v_arr, 1, 1) = '[' AND SUBSTR(v_arr, -1, 1) = ']');
    chk('Aspas do nome do tutor escapadas',    DBMS_LOB.INSTR(v_nd, 'Carlos \"Dudu\" Lima') > 0);
    chk('Decimal com ponto (31.50)',           DBMS_LOB.INSTR(v_nd, '"pesoKg":31.50') > 0);
    chk('Consultas embutidas no animal',       DBMS_LOB.INSTR(v_nd, '"consultas":[{') > 0);
    chk('Filtro por tutor so traz Thor/Mia',
        DBMS_LOB.INSTR(PKG_VETLY_JSON.fn_dataset_animais_json('NDJSON', 'DEMO4-T1'), 'Bidu') = 0);
    BEGIN
        v_nd := PKG_VETLY_JSON.fn_dataset_animais_json('XML');
        chk('Formato invalido levanta ORA-20021', FALSE);
    EXCEPTION WHEN OTHERS THEN chk('Formato invalido levanta ORA-20021', SQLCODE = -20021);
    END;
    BEGIN
        v_nd := PKG_VETLY_JSON.fn_dataset_animais_json('NDJSON', 'NAO-EXISTE');
        chk('Tutor inexistente levanta ORA-20022', FALSE);
    EXCEPTION WHEN OTHERS THEN chk('Tutor inexistente levanta ORA-20022', SQLCODE = -20022);
    END;
END;
/

-- ---- PKG_VETLY_RELATORIO ---------------------------------------------------
DECLARE
    v_rc     SYS_REFCURSOR;
    v_nm     VARCHAR2(100);
    v_st     VARCHAR2(20);
    v_qt     NUMBER;
    v_vl     NUMBER;
    v_tp     VARCHAR2(10);
    v_total  NUMBER;
    v_soma   NUMBER;
BEGIN
    PKG_VETLY_RELATORIO.prc_consultas_vet_status(NULL, v_rc);
    DBMS_OUTPUT.PUT_LINE(RPAD('VETERINARIO', 22) || RPAD('STATUS', 16) || RPAD('QTD', 5) || RPAD('VALOR', 10) || 'TIPO');
    LOOP
        FETCH v_rc INTO v_nm, v_st, v_qt, v_vl, v_tp;
        EXIT WHEN v_rc%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(NVL(v_nm, '-'), 22) || RPAD(NVL(v_st, '-'), 16)
            || RPAD(v_qt, 5) || RPAD(TO_CHAR(v_vl, 'FM99990.00', 'NLS_NUMERIC_CHARACTERS=''.,'''), 10) || v_tp);
        IF v_tp = 'TOTAL' THEN v_total := v_vl; END IF;
    END LOOP;
    CLOSE v_rc;
    SELECT SUM(VL_CONSULTA) INTO v_soma FROM TB_CONSULTA
     WHERE TB_VETERINARIO_ID_VETERINARIO IS NOT NULL;
    DBMS_OUTPUT.PUT_LINE(CASE WHEN v_total = v_soma
                              THEN 'PASSOU  ' ELSE 'FALHOU  ' END || 'TOTAL GERAL confere com SUM(TB_CONSULTA)');

    PKG_VETLY_RELATORIO.prc_consultas_vet_status('REALIZADA', v_rc);
    CLOSE v_rc;
    DBMS_OUTPUT.PUT_LINE('PASSOU  Filtro por status REALIZADA abre cursor');

    BEGIN
        PKG_VETLY_RELATORIO.prc_consultas_vet_status('INEXISTENTE', v_rc);
        DBMS_OUTPUT.PUT_LINE('FALHOU  Status invalido levanta ORA-20005');
    EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(CASE WHEN SQLCODE = -20005 THEN 'PASSOU  ' ELSE 'FALHOU  ' END
            || 'Status invalido levanta ORA-20005');
    END;
END;
/

-- ---- TRG_AUD_CONSULTA ------------------------------------------------------
DECLARE
    v_antes PLS_INTEGER;
    v_depois PLS_INTEGER;
    PROCEDURE chk(p_nome VARCHAR2, p_ok BOOLEAN) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE(CASE WHEN p_ok THEN 'PASSOU  ' ELSE 'FALHOU  ' END || p_nome);
    END;
BEGIN
    SELECT COUNT(*) INTO v_antes FROM TB_AUDITORIA WHERE TP_OPERACAO = 'UPDATE';
    UPDATE TB_CONSULTA SET ST_CONSULTA = 'REALIZADA' WHERE ID_CONSULTA = 'DEMO4-C4';
    SELECT COUNT(*) INTO v_depois FROM TB_AUDITORIA WHERE TP_OPERACAO = 'UPDATE';
    chk('UPDATE em TB_CONSULTA gera linha de auditoria', v_depois = v_antes + 1);

    SELECT COUNT(*) INTO v_antes FROM TB_AUDITORIA WHERE TP_OPERACAO = 'DELETE';
    DELETE FROM TB_CONSULTA WHERE ID_CONSULTA = 'DEMO4-C6';
    SELECT COUNT(*) INTO v_depois FROM TB_AUDITORIA WHERE TP_OPERACAO = 'DELETE';
    chk('DELETE em TB_CONSULTA gera linha de auditoria', v_depois = v_antes + 1);
    ROLLBACK;
END;
/

-- ---- PKG_VETLY_CARGA: excecao tratada e logada -----------------------------
DECLARE
    v_logs_antes  PLS_INTEGER;
    v_logs_depois PLS_INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_logs_antes FROM TB_LOG_ERRO;
    BEGIN
        PKG_VETLY_CARGA.prc_ins_usuario('DEMO4-U-T1', 'dup@vetly.test', 'TUTOR', 'S', 'x'); -- PK duplicada
        DBMS_OUTPUT.PUT_LINE('FALHOU  Insert duplicado deveria levantar erro');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('PASSOU  Insert duplicado levanta DUP_VAL_ON_INDEX');
    END;
    SELECT COUNT(*) INTO v_logs_depois FROM TB_LOG_ERRO;
    DBMS_OUTPUT.PUT_LINE(CASE WHEN v_logs_depois = v_logs_antes + 1 THEN 'PASSOU  ' ELSE 'FALHOU  ' END
        || 'Erro registrado em TB_LOG_ERRO via PKG_VETLY_LOG (transacao autonoma)');
END;
/
