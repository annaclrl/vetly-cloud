
 
-- ============================================================
-- BLOCO ANONIMO 3
-- Lista exames solicitados e classifica o prazo desde
-- a solicitacao como: NO PRAZO, ATENCAO ou ATRASADO
-- ============================================================
DECLARE
    CURSOR c_exames IS
        SELECT
            sei.ID_SOLICITACAO_EXAME_ITEM   AS id_item,
            sei.NM_EXAME,
            sei.ST_EXAME,
            sei.DT_SOLC_EXAME,
            sei.DT_RES_EXAME,
            sei.DS_RES_EXAME,
            a.NM_ANIMAL,
            p_vet.NM_PESSOA                 AS nm_veterinario
        FROM TB_SOLICITACAO_EXAME_ITEM sei
            JOIN TB_SOLICITACAO_EXAME  se  ON se.ID_SOLICITACAO_EXAME         = sei.TB_SOLCT_EXAME_ID_SOLCT_EXAME
            JOIN TB_CONSULTA           c   ON c.ID_CONSULTA                   = se.TB_CONSULTA_ID_CONSULTA
            JOIN TB_ANIMAL             a   ON a.ID_ANIMAL                     = c.TB_ANIMAL_ID_ANIMAL
            JOIN TB_VETERINARIO        v   ON v.ID_VETERINARIO                = c.TB_VETERINARIO_ID_VETERINARIO
            JOIN TB_PESSOA             p_vet ON p_vet.ID_PESSOA               = v.TB_PESSOA_ID_PESSOA
        ORDER BY sei.DT_SOLC_EXAME;
 
    v_dias_decorridos NUMBER;
    v_prazo_status    VARCHAR2(15);
    v_qt_no_prazo     NUMBER := 0;
    v_qt_atencao      NUMBER := 0;
    v_qt_atrasado     NUMBER := 0;
    v_qt_concluido    NUMBER := 0;
 
    r_exame c_exames%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=======================================================================');
    DBMS_OUTPUT.PUT_LINE(' BLOCO 3 - RELATORIO DE EXAMES SOLICITADOS COM CLASSIFICACAO DE PRAZO');
    DBMS_OUTPUT.PUT_LINE('=======================================================================');
    DBMS_OUTPUT.PUT_LINE(
        RPAD('ID', 5) || RPAD('EXAME', 25) || RPAD('STATUS', 22) ||
        RPAD('SOLICITADO EM', 16) || RPAD('DIAS', 6) ||
        RPAD('PRAZO', 12) || RPAD('ANIMAL', 12) || 'VETERINARIO'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 108, '-'));
 
    OPEN c_exames;
    LOOP
        FETCH c_exames INTO r_exame;
        EXIT WHEN c_exames%NOTFOUND;
 
        v_dias_decorridos := TRUNC(SYSDATE - r_exame.DT_SOLC_EXAME);
 
        -- Tomada de decisao: classifica prazo apenas para exames ainda abertos
        IF r_exame.ST_EXAME IN ('ANALISADO', 'RESULTADO_ENVIADO') THEN
            v_prazo_status  := 'CONCLUIDO';
            v_qt_concluido  := v_qt_concluido + 1;
        ELSIF r_exame.ST_EXAME = 'CANCELADO' THEN
            v_prazo_status  := 'CANCELADO';
        ELSIF v_dias_decorridos <= 3 THEN
            v_prazo_status  := 'NO PRAZO';
            v_qt_no_prazo   := v_qt_no_prazo + 1;
        ELSIF v_dias_decorridos <= 7 THEN
            v_prazo_status  := 'ATENCAO';
            v_qt_atencao    := v_qt_atencao + 1;
        ELSE
            v_prazo_status  := 'ATRASADO';
            v_qt_atrasado   := v_qt_atrasado + 1;
        END IF;
 
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r_exame.id_item,                               5) ||
            RPAD(r_exame.NM_EXAME,                             25) ||
            RPAD(r_exame.ST_EXAME,                             22) ||
            RPAD(TO_CHAR(r_exame.DT_SOLC_EXAME,'DD/MM/YYYY'), 16) ||
            RPAD(v_dias_decorridos,                             6) ||
            RPAD(v_prazo_status,                               12) ||
            RPAD(r_exame.NM_ANIMAL,                            12) ||
            r_exame.nm_veterinario
        );
    END LOOP;
    CLOSE c_exames;
 
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 108, '-'));
    DBMS_OUTPUT.PUT_LINE(' No prazo  : ' || v_qt_no_prazo  ||
                         '  | Atencao: '  || v_qt_atencao  ||
                         '  | Atrasado: ' || v_qt_atrasado ||
                         '  | Concluido: '|| v_qt_concluido);
    DBMS_OUTPUT.PUT_LINE('=======================================================================');
END;
/
 