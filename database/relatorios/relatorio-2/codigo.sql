
-- ============================================================
-- BLOCO ANONIMO - RELATORIO 2
-- Lista animais com seu tutor e classifica o peso como
-- ABAIXO DO PESO, PESO IDEAL ou ACIMA DO PESO
-- conforme faixa por especie
-- ============================================================
DECLARE
    CURSOR c_animais IS
        SELECT
            a.ID_ANIMAL,
            a.NM_ANIMAL,
            a.RC_ANIMAL,
            a.SX_ANIMAL,
            a.NR_PESO_ANIMAL,
            a.DT_NASC_ANIMAL,
            e.NM_ESPECIE,
            p.NM_PESSOA   AS nm_tutor,
            p.TEL_PESSOA  AS tel_tutor
        FROM TB_ANIMAL  a
            JOIN TB_ESPECIE e ON e.ID_ESPECIE         = a.TB_ESPECIE_ID_ESPECIE
            JOIN TB_TUTOR   t ON t.ID_TUTOR           = a.TB_TUTOR_ID_TUTOR
            JOIN TB_PESSOA  p ON p.ID_PESSOA          = t.TB_PESSOA_ID_PESSOA
        ORDER BY a.NM_ANIMAL;
 
    v_classificacao VARCHAR2(20);
    v_sexo_ext      VARCHAR2(10);
    v_idade_anos    NUMBER;
    v_qt_total      NUMBER := 0;
    v_qt_abaixo     NUMBER := 0;
    v_qt_ideal      NUMBER := 0;
    v_qt_acima      NUMBER := 0;
 
    r_animal c_animais%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=======================================================================');
    DBMS_OUTPUT.PUT_LINE(' BLOCO 2 - RELATORIO DE ANIMAIS COM CLASSIFICACAO DE PESO');
    DBMS_OUTPUT.PUT_LINE('=======================================================================');
    DBMS_OUTPUT.PUT_LINE(
        RPAD('ANIMAL', 15) || RPAD('ESPECIE', 12) || RPAD('RACA', 15) ||
        RPAD('SEXO', 8) || RPAD('IDADE', 8) || RPAD('PESO KG', 10) ||
        RPAD('CLASSIFICACAO', 18) || 'TUTOR'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 100, '-'));
 
    OPEN c_animais;
    LOOP
        FETCH c_animais INTO r_animal;
        EXIT WHEN c_animais%NOTFOUND;
 
        v_qt_total := v_qt_total + 1;
 
        -- Tomada de decisao: sexo extenso
        IF r_animal.SX_ANIMAL = 'M' THEN
            v_sexo_ext := 'Macho';
        ELSE
            v_sexo_ext := 'Femea';
        END IF;
 
        -- Tomada de decisao: idade em anos
        IF r_animal.DT_NASC_ANIMAL IS NOT NULL THEN
            v_idade_anos := TRUNC(MONTHS_BETWEEN(SYSDATE, r_animal.DT_NASC_ANIMAL) / 12);
        ELSE
            v_idade_anos := NULL;
        END IF;
 
        -- Tomada de decisao: classificacao de peso por especie
        IF r_animal.NM_ESPECIE = 'CAO' THEN
            IF    r_animal.NR_PESO_ANIMAL < 5  THEN v_classificacao := 'ABAIXO DO PESO';
            ELSIF r_animal.NR_PESO_ANIMAL <= 40 THEN v_classificacao := 'PESO IDEAL';
            ELSE  v_classificacao := 'ACIMA DO PESO';
            END IF;
        ELSIF r_animal.NM_ESPECIE = 'GATO' THEN
            IF    r_animal.NR_PESO_ANIMAL < 3  THEN v_classificacao := 'ABAIXO DO PESO';
            ELSIF r_animal.NR_PESO_ANIMAL <= 6  THEN v_classificacao := 'PESO IDEAL';
            ELSE  v_classificacao := 'ACIMA DO PESO';
            END IF;
        ELSIF r_animal.NM_ESPECIE = 'AVE' THEN
            IF    r_animal.NR_PESO_ANIMAL < 0.5 THEN v_classificacao := 'ABAIXO DO PESO';
            ELSIF r_animal.NR_PESO_ANIMAL <= 2   THEN v_classificacao := 'PESO IDEAL';
            ELSE  v_classificacao := 'ACIMA DO PESO';
            END IF;
        ELSE
            v_classificacao := 'NAO AVALIADO';
        END IF;
 
        -- Acumula contadores de classificacao
        IF    v_classificacao = 'ABAIXO DO PESO' THEN v_qt_abaixo := v_qt_abaixo + 1;
        ELSIF v_classificacao = 'PESO IDEAL'     THEN v_qt_ideal  := v_qt_ideal  + 1;
        ELSIF v_classificacao = 'ACIMA DO PESO'  THEN v_qt_acima  := v_qt_acima  + 1;
        END IF;
 
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r_animal.NM_ANIMAL,                         15) ||
            RPAD(r_animal.NM_ESPECIE,                        12) ||
            RPAD(r_animal.RC_ANIMAL,                         15) ||
            RPAD(v_sexo_ext,                                  8) ||
            RPAD(NVL(TO_CHAR(v_idade_anos) || ' ano(s)', '-'), 8) ||
            RPAD(r_animal.NR_PESO_ANIMAL,                    10) ||
            RPAD(v_classificacao,                            18) ||
            r_animal.nm_tutor || ' | ' || r_animal.tel_tutor
        );
    END LOOP;
    CLOSE c_animais;
 
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 100, '-'));
    DBMS_OUTPUT.PUT_LINE(' Total de animais   : ' || v_qt_total);
    DBMS_OUTPUT.PUT_LINE(' Abaixo do peso     : ' || v_qt_abaixo);
    DBMS_OUTPUT.PUT_LINE(' Peso ideal         : ' || v_qt_ideal);
    DBMS_OUTPUT.PUT_LINE(' Acima do peso      : ' || v_qt_acima);
    DBMS_OUTPUT.PUT_LINE('=======================================================================');
END;
/