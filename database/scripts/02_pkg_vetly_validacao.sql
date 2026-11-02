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
