
-- ============================================================
-- BLOCO ANONIMO 1
-- Exibe dados de animais, tutores, consultas e exames
-- ============================================================
DECLARE
    -- Cursores para cada consulta
    
    -- 1. Tutores e quantidade de animais cadastrados
    CURSOR c_tutor_animais IS
        SELECT
            p.NM_PESSOA                     AS nm_tutor,
            p.CPF_PESSOA                    AS cpf_tutor,
            e.NM_ESPECIE                    AS especie,
            COUNT(a.ID_ANIMAL)              AS qt_animais,
            ROUND(AVG(a.NR_PESO_ANIMAL), 2) AS peso_medio_kg
        FROM TB_TUTOR t
            JOIN TB_PESSOA   p ON p.ID_PESSOA  = t.TB_PESSOA_ID_PESSOA
            JOIN TB_ANIMAL   a ON a.TB_TUTOR_ID_TUTOR = t.ID_TUTOR
            JOIN TB_ESPECIE  e ON e.ID_ESPECIE = a.TB_ESPECIE_ID_ESPECIE
        GROUP BY
            p.NM_PESSOA,
            p.CPF_PESSOA,
            e.NM_ESPECIE
        ORDER BY
            qt_animais DESC,
            p.NM_PESSOA ASC;
 
    -- 2. Veterinarios, suas especialidades e quantidade de consultas realizadas
    CURSOR c_vet_consultas IS
        SELECT
            p.NM_PESSOA                AS nm_veterinario,
            v.CRMV_VETERINARIO         AS crmv,
            ev.NM_ESPECIALIDADE        AS especialidade,
            COUNT(c.ID_CONSULTA)       AS qt_consultas,
            SUM(c.VL_CONSULTA)         AS vl_total_consultas
        FROM TB_VETERINARIO v
            JOIN TB_PESSOA                   p  ON p.ID_PESSOA            = v.TB_PESSOA_ID_PESSOA
            JOIN TB_VETERINARIO_ESPECIALIDADE ve ON ve.TB_VETERINARIO_ID_VETERINARIO = v.ID_VETERINARIO
            JOIN TB_ESPECIALIDADES_VET       ev ON ev.ID_ESPECIALIDADE_VET = ve.TB_ESPCD_VET_ID_ESPCD_VET
            LEFT JOIN TB_CONSULTA            c  ON c.TB_VETERINARIO_ID_VETERINARIO = v.ID_VETERINARIO
        GROUP BY
            p.NM_PESSOA,
            v.CRMV_VETERINARIO,
            ev.NM_ESPECIALIDADE
        ORDER BY
            qt_consultas DESC,
            vl_total_consultas DESC;
 
    -- 3. Animais com quantidade de exames solicitados por status
    CURSOR c_animais_exames IS
        SELECT
            a.NM_ANIMAL              AS nm_animal,
            a.RC_ANIMAL              AS raca,
            sei.ST_EXAME             AS status_exame,
            COUNT(sei.ID_SOLICITACAO_EXAME_ITEM) AS qt_exames
        FROM TB_ANIMAL a
            JOIN TB_CONSULTA              c   ON c.TB_ANIMAL_ID_ANIMAL        = a.ID_ANIMAL
            JOIN TB_SOLICITACAO_EXAME     se  ON se.TB_CONSULTA_ID_CONSULTA   = c.ID_CONSULTA
            JOIN TB_SOLICITACAO_EXAME_ITEM sei ON sei.TB_SOLCT_EXAME_ID_SOLCT_EXAME = se.ID_SOLICITACAO_EXAME
        GROUP BY
            a.NM_ANIMAL,
            a.RC_ANIMAL,
            sei.ST_EXAME
        ORDER BY
            a.NM_ANIMAL ASC,
            qt_exames DESC;
 
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================================');
    DBMS_OUTPUT.PUT_LINE(' BLOCO 1 - RELATORIO GERAL DO SISTEMA');
    DBMS_OUTPUT.PUT_LINE('========================================================');
 
    -- --------------------------------------------------------
    -- CONSULTA 1: Tutores x Animais x Especie
    -- --------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- [1] TUTORES: QUANTIDADE E PESO MEDIO DE ANIMAIS POR ESPECIE ---');
    DBMS_OUTPUT.PUT_LINE(
        RPAD('TUTOR', 30) || RPAD('CPF', 15) ||
        RPAD('ESPECIE', 15) || RPAD('QT ANIMAIS', 12) || 'PESO MEDIO (KG)'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 85, '-'));
 
    FOR r IN c_tutor_animais LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.nm_tutor,    30) ||
            RPAD(r.cpf_tutor,   15) ||
            RPAD(r.especie,     15) ||
            RPAD(r.qt_animais,  12) ||
            r.peso_medio_kg
        );
    END LOOP;
 
    -- --------------------------------------------------------
    -- CONSULTA 2: Veterinarios x Especialidades x Consultas
    -- --------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- [2] VETERINARIOS: ESPECIALIDADES E CONSULTAS REALIZADAS ---');
    DBMS_OUTPUT.PUT_LINE(
        RPAD('VETERINARIO', 25) || RPAD('CRMV', 18) ||
        RPAD('ESPECIALIDADE', 28) || RPAD('QT CONSULTAS', 14) || 'VL TOTAL (R$)'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 95, '-'));
 
    FOR r IN c_vet_consultas LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.nm_veterinario,  25) ||
            RPAD(r.crmv,            18) ||
            RPAD(r.especialidade,   28) ||
            RPAD(r.qt_consultas,    14) ||
            TO_CHAR(r.vl_total_consultas, 'FM999990.00')
        );
    END LOOP;
 
    -- --------------------------------------------------------
    -- CONSULTA 3: Animais x Exames por Status
    -- --------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- [3] ANIMAIS: EXAMES AGRUPADOS POR STATUS ---');
    DBMS_OUTPUT.PUT_LINE(
        RPAD('ANIMAL', 20) || RPAD('RACA', 20) ||
        RPAD('STATUS EXAME', 25) || 'QT EXAMES'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 75, '-'));
 
    FOR r IN c_animais_exames LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.nm_animal,    20) ||
            RPAD(r.raca,         20) ||
            RPAD(r.status_exame, 25) ||
            r.qt_exames
        );
    END LOOP;
 
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================================');
    DBMS_OUTPUT.PUT_LINE(' FIM DO BLOCO 1');
    DBMS_OUTPUT.PUT_LINE('========================================================');
END;
/