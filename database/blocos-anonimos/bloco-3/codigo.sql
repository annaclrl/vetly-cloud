
-- ============================================================
-- BLOCO ANONIMO
-- Le tutores com seus nomes e exibe, para cada linha:
--   - nome do tutor atual
--   - nome do tutor na linha anterior  (LAG)
--   - nome do tutor na proxima linha   (LEAD)
-- Ordenado por ID_TUTOR
-- ============================================================
DECLARE
 
    CURSOR c_tutores IS
        SELECT
            t.ID_TUTOR                                          AS id_tutor,
            p.NM_PESSOA                                         AS nm_atual,
            LAG(p.NM_PESSOA)  OVER (ORDER BY t.ID_TUTOR)       AS nm_anterior,
            LEAD(p.NM_PESSOA) OVER (ORDER BY t.ID_TUTOR)       AS nm_proximo
        FROM TB_TUTOR  t
            JOIN TB_PESSOA p ON p.ID_PESSOA = t.TB_PESSOA_ID_PESSOA
        ORDER BY t.ID_TUTOR;
 
    v_anterior VARCHAR2(100);
    v_proximo  VARCHAR2(100);
 
BEGIN
    DBMS_OUTPUT.PUT_LINE('=============================================================================');
    DBMS_OUTPUT.PUT_LINE(' RELATORIO: TUTORES COM LINHA ANTERIOR E PROXIMA (NM_PESSOA)');
    DBMS_OUTPUT.PUT_LINE('=============================================================================');
    DBMS_OUTPUT.PUT_LINE(
        RPAD('ID',  6) ||
        RPAD('ANTERIOR',       25) ||
        RPAD('ATUAL',          25) ||
        'PROXIMO'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 78, '-'));
 
    FOR r IN c_tutores LOOP
 
        -- Substitui NULL por 'Vazio'
        v_anterior := NVL(r.nm_anterior, 'Vazio');
        v_proximo  := NVL(r.nm_proximo,  'Vazio');
 
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.id_tutor,   6) ||
            RPAD(v_anterior,  25) ||
            RPAD(r.nm_atual,  25) ||
            v_proximo
        );
    END LOOP;
 
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 78, '-'));
    DBMS_OUTPUT.PUT_LINE(' * "Vazio" indica ausencia de linha anterior ou proxima.');
    DBMS_OUTPUT.PUT_LINE('=============================================================================');
END;
/