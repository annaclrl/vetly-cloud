
-- ============================================================
-- BLOCO ANONIMO 2
-- Exibe dados de consultas, evolucoes clinicas e logs de erro
-- ============================================================
DECLARE
 
    -- 1. Historico de consultas por animal com evolucao clinica
    CURSOR c_historico_consultas IS
        SELECT
            a.NM_ANIMAL                         AS nm_animal,
            p_tutor.NM_PESSOA                   AS nm_tutor,
            p_vet.NM_PESSOA                     AS nm_veterinario,
            c.ST_CONSULTA                       AS status_consulta,
            COUNT(c.ID_CONSULTA)                AS qt_consultas,
            SUM(c.VL_CONSULTA)                  AS vl_gasto_total,
            MAX(c.DT_HR_CONSULTA)               AS dt_ultima_consulta
        FROM TB_ANIMAL a
            JOIN TB_TUTOR       t       ON t.ID_TUTOR                   = a.TB_TUTOR_ID_TUTOR
            JOIN TB_PESSOA      p_tutor ON p_tutor.ID_PESSOA            = t.TB_PESSOA_ID_PESSOA
            JOIN TB_CONSULTA    c       ON c.TB_ANIMAL_ID_ANIMAL        = a.ID_ANIMAL
            JOIN TB_VETERINARIO v       ON v.ID_VETERINARIO             = c.TB_VETERINARIO_ID_VETERINARIO
            JOIN TB_PESSOA      p_vet   ON p_vet.ID_PESSOA              = v.TB_PESSOA_ID_PESSOA
        GROUP BY
            a.NM_ANIMAL,
            p_tutor.NM_PESSOA,
            p_vet.NM_PESSOA,
            c.ST_CONSULTA
        ORDER BY
            a.NM_ANIMAL ASC,
            dt_ultima_consulta DESC;
 
    -- 2. Especies atendidas por veterinario
    CURSOR c_vet_especies IS
        SELECT
            p.NM_PESSOA             AS nm_veterinario,
            v.CRMV_VETERINARIO      AS crmv,
            e.NM_ESPECIE            AS especie,
            COUNT(DISTINCT a.ID_ANIMAL) AS qt_animais_atendidos
        FROM TB_VETERINARIO v
            JOIN TB_PESSOA              p  ON p.ID_PESSOA              = v.TB_PESSOA_ID_PESSOA
            JOIN TB_VETERINARIO_ESPECIE ve ON ve.TB_VETERINARIO_ID_VETERINARIO = v.ID_VETERINARIO
            JOIN TB_ESPECIE             e  ON e.ID_ESPECIE             = ve.TB_ESPECIE_ID_ESPECIE
            LEFT JOIN TB_CONSULTA       c  ON c.TB_VETERINARIO_ID_VETERINARIO = v.ID_VETERINARIO
            LEFT JOIN TB_ANIMAL         a  ON a.ID_ANIMAL              = c.TB_ANIMAL_ID_ANIMAL
                                          AND a.TB_ESPECIE_ID_ESPECIE  = e.ID_ESPECIE
        GROUP BY
            p.NM_PESSOA,
            v.CRMV_VETERINARIO,
            e.NM_ESPECIE
        ORDER BY
            p.NM_PESSOA ASC,
            qt_animais_atendidos DESC;
 
    -- 3. Resumo de erros na tabela de log por procedure
    CURSOR c_resumo_logs IS
        SELECT
            NM_PROCEDURE            AS nm_procedure,
            COUNT(ID_LOG)           AS qt_erros,
            MIN(DT_OCORRENCIA)      AS primeiro_erro,
            MAX(DT_OCORRENCIA)      AS ultimo_erro
        FROM TB_LOG_ERRO
        GROUP BY
            NM_PROCEDURE
        ORDER BY
            qt_erros DESC,
            NM_PROCEDURE ASC;
 
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================================');
    DBMS_OUTPUT.PUT_LINE(' BLOCO 2 - HISTORICO, ATENDIMENTOS E LOG DE ERROS');
    DBMS_OUTPUT.PUT_LINE('========================================================');
 
    -- --------------------------------------------------------
    -- CONSULTA 1: Historico de consultas por animal
    -- --------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- [1] HISTORICO DE CONSULTAS POR ANIMAL ---');
    DBMS_OUTPUT.PUT_LINE(
        RPAD('ANIMAL', 15) || RPAD('TUTOR', 22) || RPAD('VETERINARIO', 22) ||
        RPAD('STATUS', 12) || RPAD('QT', 6) || RPAD('VL TOTAL', 14) || 'ULTIMA CONSULTA'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 100, '-'));
 
    FOR r IN c_historico_consultas LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.nm_animal,          15) ||
            RPAD(r.nm_tutor,           22) ||
            RPAD(r.nm_veterinario,     22) ||
            RPAD(r.status_consulta,    12) ||
            RPAD(r.qt_consultas,        6) ||
            RPAD(TO_CHAR(r.vl_gasto_total, 'FM999990.00'), 14) ||
            TO_CHAR(r.dt_ultima_consulta, 'DD/MM/YYYY HH24:MI')
        );
    END LOOP;
 
    -- --------------------------------------------------------
    -- CONSULTA 2: Especies habilitadas por veterinario
    -- --------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- [2] ESPECIES HABILITADAS POR VETERINARIO ---');
    DBMS_OUTPUT.PUT_LINE(
        RPAD('VETERINARIO', 25) || RPAD('CRMV', 18) ||
        RPAD('ESPECIE', 15) || 'QT ANIMAIS ATENDIDOS'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 70, '-'));
 
    FOR r IN c_vet_especies LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.nm_veterinario,         25) ||
            RPAD(r.crmv,                   18) ||
            RPAD(r.especie,                15) ||
            r.qt_animais_atendidos
        );
    END LOOP;
 
    -- --------------------------------------------------------
    -- CONSULTA 3: Resumo dos logs de erro por procedure
    -- --------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- [3] RESUMO DE ERROS REGISTRADOS POR PROCEDURE ---');
    DBMS_OUTPUT.PUT_LINE(
        RPAD('PROCEDURE', 35) || RPAD('QT ERROS', 12) ||
        RPAD('PRIMEIRO ERRO', 22) || 'ULTIMO ERRO'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 85, '-'));
 
    FOR r IN c_resumo_logs LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.nm_procedure,                    35) ||
            RPAD(r.qt_erros,                        12) ||
            RPAD(TO_CHAR(r.primeiro_erro, 'DD/MM/YYYY HH24:MI'), 22) ||
            TO_CHAR(r.ultimo_erro, 'DD/MM/YYYY HH24:MI')
        );
    END LOOP;
 
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================================');
    DBMS_OUTPUT.PUT_LINE(' FIM DO BLOCO 2');
    DBMS_OUTPUT.PUT_LINE('========================================================');
END;
/