-- ============================================================
-- BLOCO ANONIMO - RELATORIO 1
-- Lista todos os dados de TB_CONSULTA
-- Sumariza dados numericos (VL_CONSULTA)
-- Agrupa sumarizacao por ST_CONSULTA
-- ============================================================
DECLARE
    -- Cursor principal: todos os dados da consulta
    CURSOR c_consultas IS
        SELECT
            c.ID_CONSULTA,
            c.DT_HR_CONSULTA,
            c.ST_CONSULTA,
            c.VL_CONSULTA,
            c.OBS_CONSULTA,
            p_vet.NM_PESSOA   AS nm_veterinario,
            a.NM_ANIMAL       AS nm_animal
        FROM TB_CONSULTA    c
            JOIN TB_VETERINARIO v     ON v.ID_VETERINARIO  = c.TB_VETERINARIO_ID_VETERINARIO
            JOIN TB_PESSOA      p_vet ON p_vet.ID_PESSOA   = v.TB_PESSOA_ID_PESSOA
            JOIN TB_ANIMAL      a     ON a.ID_ANIMAL       = c.TB_ANIMAL_ID_ANIMAL
        ORDER BY c.DT_HR_CONSULTA;
 
    -- Cursor de sumarizacao por status
    CURSOR c_sumar_status IS
        SELECT
            ST_CONSULTA,
            COUNT(*)          AS qt_consultas,
            SUM(VL_CONSULTA)  AS vl_total,
            AVG(VL_CONSULTA)  AS vl_medio,
            MIN(VL_CONSULTA)  AS vl_minimo,
            MAX(VL_CONSULTA)  AS vl_maximo
        FROM TB_CONSULTA
        GROUP BY ST_CONSULTA
        ORDER BY ST_CONSULTA;
 
    -- Variaveis de totalizacao geral
    v_qt_total      NUMBER := 0;
    v_vl_total      NUMBER := 0;
    v_vl_medio      NUMBER := 0;
    v_vl_min        NUMBER := 999999;
    v_vl_max        NUMBER := 0;
    v_qt_agendada   NUMBER := 0;
    v_qt_realizada  NUMBER := 0;
    v_qt_cancelada  NUMBER := 0;
 
    r_cons          c_consultas%ROWTYPE;
    r_status        c_sumar_status%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=======================================================================');
    DBMS_OUTPUT.PUT_LINE(' BLOCO 1 - RELATORIO COMPLETO DE CONSULTAS');
    DBMS_OUTPUT.PUT_LINE('=======================================================================');
    DBMS_OUTPUT.PUT_LINE(
        RPAD('ID', 5) || RPAD('DATA/HORA', 20) || RPAD('STATUS', 12) ||
        RPAD('VALOR', 10) || RPAD('VETERINARIO', 22) || RPAD('ANIMAL', 15) || 'OBSERVACAO'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 100, '-'));
 
    OPEN c_consultas;
    LOOP
        FETCH c_consultas INTO r_cons;
        EXIT WHEN c_consultas%NOTFOUND;
 
        -- Tomada de decisao: acumula contador por status
        IF r_cons.ST_CONSULTA = 'AGENDADA' THEN
            v_qt_agendada := v_qt_agendada + 1;
        ELSIF r_cons.ST_CONSULTA = 'REALIZADA' THEN
            v_qt_realizada := v_qt_realizada + 1;
        ELSIF r_cons.ST_CONSULTA = 'CANCELADA' THEN
            v_qt_cancelada := v_qt_cancelada + 1;
        END IF;
 
        -- Acumula totais gerais
        v_qt_total := v_qt_total + 1;
        v_vl_total := v_vl_total + r_cons.VL_CONSULTA;
 
        IF r_cons.VL_CONSULTA < v_vl_min THEN
            v_vl_min := r_cons.VL_CONSULTA;
        END IF;
        IF r_cons.VL_CONSULTA > v_vl_max THEN
            v_vl_max := r_cons.VL_CONSULTA;
        END IF;
 
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r_cons.ID_CONSULTA,                           5)  ||
            RPAD(TO_CHAR(r_cons.DT_HR_CONSULTA,'DD/MM/YYYY HH24:MI'), 20) ||
            RPAD(r_cons.ST_CONSULTA,                          12)  ||
            RPAD(TO_CHAR(r_cons.VL_CONSULTA,'FM9990.00'),     10)  ||
            RPAD(r_cons.nm_veterinario,                       22)  ||
            RPAD(r_cons.nm_animal,                            15)  ||
            NVL(r_cons.OBS_CONSULTA, '-')
        );
    END LOOP;
    CLOSE c_consultas;
 
    -- Calcula media geral
    IF v_qt_total > 0 THEN
        v_vl_medio := ROUND(v_vl_total / v_qt_total, 2);
    END IF;
 
    -- Sumarizacao geral
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 100, '-'));
    DBMS_OUTPUT.PUT_LINE(' SUMARIZACAO GERAL DOS DADOS NUMERICOS (VL_CONSULTA)');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 100, '-'));
    DBMS_OUTPUT.PUT_LINE(' Total de consultas : ' || v_qt_total);
    DBMS_OUTPUT.PUT_LINE(' Valor total (R$)   : ' || TO_CHAR(v_vl_total, 'FM9999990.00'));
    DBMS_OUTPUT.PUT_LINE(' Valor medio (R$)   : ' || TO_CHAR(v_vl_medio, 'FM9999990.00'));
    DBMS_OUTPUT.PUT_LINE(' Valor minimo (R$)  : ' || TO_CHAR(v_vl_min,   'FM9999990.00'));
    DBMS_OUTPUT.PUT_LINE(' Valor maximo (R$)  : ' || TO_CHAR(v_vl_max,   'FM9999990.00'));
 
    -- Sumarizacao agrupada por status
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE(' SUMARIZACAO AGRUPADA POR STATUS');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 70, '-'));
    DBMS_OUTPUT.PUT_LINE(
        RPAD('STATUS', 14) || RPAD('QT', 8) || RPAD('VL TOTAL', 14) ||
        RPAD('VL MEDIO', 14) || RPAD('VL MIN', 12) || 'VL MAX'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 70, '-'));
 
    OPEN c_sumar_status;
    LOOP
        FETCH c_sumar_status INTO r_status;
        EXIT WHEN c_sumar_status%NOTFOUND;
 
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r_status.ST_CONSULTA,                          14) ||
            RPAD(r_status.qt_consultas,                          8) ||
            RPAD(TO_CHAR(r_status.vl_total, 'FM9990.00'),       14) ||
            RPAD(TO_CHAR(r_status.vl_medio, 'FM9990.00'),       14) ||
            RPAD(TO_CHAR(r_status.vl_minimo,'FM9990.00'),       12) ||
            TO_CHAR(r_status.vl_maximo, 'FM9990.00')
        );
    END LOOP;
    CLOSE c_sumar_status;
 
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE(' Agendadas : ' || v_qt_agendada  ||
                         '  | Realizadas: ' || v_qt_realizada ||
                         '  | Canceladas: ' || v_qt_cancelada);
    DBMS_OUTPUT.PUT_LINE('=======================================================================');
END;
/
 