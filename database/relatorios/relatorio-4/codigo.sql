
-- ============================================================
-- BLOCO ANONIMO 4
-- Lista veterinarios, suas especialidades e especies
-- e classifica o perfil de atuacao:
--   GENERALISTA  (1 especialidade)
--   ESPECIALISTA (2 ou 3 especialidades)
--   MULTIPLO     (4 ou mais especialidades)
-- ============================================================
DECLARE
    CURSOR c_veterinarios IS
        SELECT
            v.ID_VETERINARIO,
            p.NM_PESSOA          AS nm_veterinario,
            v.CRMV_VETERINARIO,
            u.EM_USUARIO         AS email,
            u.FL_ATV_USUARIO     AS ativo,
            COUNT(DISTINCT ve.TB_ESPCD_VET_ID_ESPCD_VET) AS qt_especialidades,
            COUNT(DISTINCT vs.TB_ESPECIE_ID_ESPECIE)      AS qt_especies,
            COUNT(DISTINCT c.ID_CONSULTA)                 AS qt_consultas
        FROM TB_VETERINARIO              v
            JOIN TB_PESSOA               p  ON p.ID_PESSOA    = v.TB_PESSOA_ID_PESSOA
            JOIN TB_USUARIO              u  ON u.ID_USUARIO   = v.TB_USUARIO_ID_USUARIO
            LEFT JOIN TB_VETERINARIO_ESPECIALIDADE ve ON ve.TB_VETERINARIO_ID_VETERINARIO = v.ID_VETERINARIO
            LEFT JOIN TB_VETERINARIO_ESPECIE       vs ON vs.TB_VETERINARIO_ID_VETERINARIO = v.ID_VETERINARIO
            LEFT JOIN TB_CONSULTA                  c  ON c.TB_VETERINARIO_ID_VETERINARIO  = v.ID_VETERINARIO
        GROUP BY
            v.ID_VETERINARIO,
            p.NM_PESSOA,
            v.CRMV_VETERINARIO,
            u.EM_USUARIO,
            u.FL_ATV_USUARIO
        ORDER BY p.NM_PESSOA;
 
    -- Cursor de especialidades por veterinario
    CURSOR c_especialidades(p_id_vet NUMBER) IS
        SELECT ev.NM_ESPECIALIDADE
        FROM TB_VETERINARIO_ESPECIALIDADE ve
            JOIN TB_ESPECIALIDADES_VET ev ON ev.ID_ESPECIALIDADE_VET = ve.TB_ESPCD_VET_ID_ESPCD_VET
        WHERE ve.TB_VETERINARIO_ID_VETERINARIO = p_id_vet;
 
    -- Cursor de especies por veterinario
    CURSOR c_especies(p_id_vet NUMBER) IS
        SELECT e.NM_ESPECIE
        FROM TB_VETERINARIO_ESPECIE vs
            JOIN TB_ESPECIE e ON e.ID_ESPECIE = vs.TB_ESPECIE_ID_ESPECIE
        WHERE vs.TB_VETERINARIO_ID_VETERINARIO = p_id_vet;
 
    v_perfil        VARCHAR2(15);
    v_ativo_ext     VARCHAR2(10);
    v_especialidades VARCHAR2(300);
    v_especies       VARCHAR2(300);
    v_qt_total      NUMBER := 0;
    v_qt_generalista  NUMBER := 0;
    v_qt_especialista NUMBER := 0;
    v_qt_multiplo     NUMBER := 0;
 
    r_vet c_veterinarios%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=======================================================================');
    DBMS_OUTPUT.PUT_LINE(' BLOCO 4 - RELATORIO DE VETERINARIOS COM PERFIL DE ATUACAO');
    DBMS_OUTPUT.PUT_LINE('=======================================================================');
 
    OPEN c_veterinarios;
    LOOP
        FETCH c_veterinarios INTO r_vet;
        EXIT WHEN c_veterinarios%NOTFOUND;
 
        v_qt_total := v_qt_total + 1;
 
        -- Tomada de decisao: perfil por numero de especialidades
        IF    r_vet.qt_especialidades <= 1 THEN
            v_perfil          := 'GENERALISTA';
            v_qt_generalista  := v_qt_generalista + 1;
        ELSIF r_vet.qt_especialidades <= 3 THEN
            v_perfil          := 'ESPECIALISTA';
            v_qt_especialista := v_qt_especialista + 1;
        ELSE
            v_perfil          := 'MULTIPLO';
            v_qt_multiplo     := v_qt_multiplo + 1;
        END IF;
 
        -- Tomada de decisao: flag ativo
        IF r_vet.ativo = '1' THEN
            v_ativo_ext := 'ATIVO';
        ELSE
            v_ativo_ext := 'INATIVO';
        END IF;
 
        -- Concatena especialidades via cursor aninhado
        v_especialidades := '';
        FOR r_esp IN c_especialidades(r_vet.ID_VETERINARIO) LOOP
            IF v_especialidades IS NULL OR v_especialidades = '' THEN
                v_especialidades := r_esp.NM_ESPECIALIDADE;
            ELSE
                v_especialidades := v_especialidades || ', ' || r_esp.NM_ESPECIALIDADE;
            END IF;
        END LOOP;
        IF v_especialidades = '' OR v_especialidades IS NULL THEN
            v_especialidades := '-';
        END IF;
 
        -- Concatena especies via cursor aninhado
        v_especies := '';
        FOR r_esp IN c_especies(r_vet.ID_VETERINARIO) LOOP
            IF v_especies IS NULL OR v_especies = '' THEN
                v_especies := r_esp.NM_ESPECIE;
            ELSE
                v_especies := v_especies || ', ' || r_esp.NM_ESPECIE;
            END IF;
        END LOOP;
        IF v_especies = '' OR v_especies IS NULL THEN
            v_especies := '-';
        END IF;
 
        -- Exibe cabecalho de cada veterinario
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE(' Veterinario : ' || r_vet.nm_veterinario || ' (' || v_ativo_ext || ')');
        DBMS_OUTPUT.PUT_LINE(' CRMV        : ' || r_vet.CRMV_VETERINARIO);
        DBMS_OUTPUT.PUT_LINE(' Email       : ' || r_vet.email);
        DBMS_OUTPUT.PUT_LINE(' Perfil      : ' || v_perfil);
        DBMS_OUTPUT.PUT_LINE(' Consultas   : ' || r_vet.qt_consultas);
        DBMS_OUTPUT.PUT_LINE(' Especialidades (' || r_vet.qt_especialidades || '): ' || v_especialidades);
        DBMS_OUTPUT.PUT_LINE(' Especies habilitadas (' || r_vet.qt_especies || '): ' || v_especies);
    END LOOP;
    CLOSE c_veterinarios;
 
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=======================================================================');
    DBMS_OUTPUT.PUT_LINE(' RESUMO DE PERFIS');
    DBMS_OUTPUT.PUT_LINE('=======================================================================');
    DBMS_OUTPUT.PUT_LINE(' Total de veterinarios : ' || v_qt_total);
    DBMS_OUTPUT.PUT_LINE(' Generalistas          : ' || v_qt_generalista  || '  (1 especialidade)');
    DBMS_OUTPUT.PUT_LINE(' Especialistas         : ' || v_qt_especialista || '  (2 a 3 especialidades)');
    DBMS_OUTPUT.PUT_LINE(' Multiplos             : ' || v_qt_multiplo     || '  (4 ou mais especialidades)');
    DBMS_OUTPUT.PUT_LINE('=======================================================================');
END;
/