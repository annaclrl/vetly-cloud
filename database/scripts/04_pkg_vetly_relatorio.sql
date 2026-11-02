-- ============================================================================
-- SPRINT 4 - PACOTE PKG_VETLY_RELATORIO
--
-- Relatorio de consultas por veterinario x status, com subtotal por veterinario
-- e total geral. DEVOLVE um SYS_REFCURSOR (consumivel por JDBC/Java, .NET e
-- qualquer cliente); nao usa DBMS_OUTPUT.
--
-- Colunas do cursor:
--   NM_VETERINARIO | ST_CONSULTA | QT_CONSULTAS | VL_TOTAL | TP_LINHA
--   TP_LINHA: DETALHE (vet+status), SUBTOTAL (vet, status nulo), TOTAL (ambos nulos)
--
-- ORA-20005: p_status fora dos valores validos de TB_CONSULTA.ST_CONSULTA
-- ============================================================================
CREATE OR REPLACE PACKAGE PKG_VETLY_RELATORIO AS
    PROCEDURE prc_consultas_vet_status (
        p_status    IN  VARCHAR2 DEFAULT NULL,
        p_resultado OUT SYS_REFCURSOR
    );
END PKG_VETLY_RELATORIO;
/

CREATE OR REPLACE PACKAGE BODY PKG_VETLY_RELATORIO AS

    PROCEDURE prc_consultas_vet_status (
        p_status    IN  VARCHAR2 DEFAULT NULL,
        p_resultado OUT SYS_REFCURSOR
    ) IS
        v_status VARCHAR2(20) := UPPER(TRIM(p_status));
    BEGIN
        IF v_status IS NOT NULL
           AND v_status NOT IN ('AGENDADA', 'CANCELADA', 'REALIZADA', 'NAO_COMPARECEU') THEN
            RAISE_APPLICATION_ERROR(-20005,
                'prc_consultas_vet_status: status invalido: ' || p_status);
        END IF;

        OPEN p_resultado FOR
            SELECT x.nm_veterinario,
                   x.st_consulta,
                   x.qt_consultas,
                   x.vl_total,
                   x.tp_linha
              FROM (
                    SELECT CASE WHEN GROUPING(v.ID_VETERINARIO) = 1 THEN 'TOTAL GERAL'
                                ELSE MAX(p.NM_PESSOA) END                AS nm_veterinario,
                           CASE WHEN GROUPING(c.ST_CONSULTA) = 1 THEN NULL
                                ELSE c.ST_CONSULTA END                   AS st_consulta,
                           COUNT(*)                                      AS qt_consultas,
                           SUM(c.VL_CONSULTA)                            AS vl_total,
                           CASE WHEN GROUPING(v.ID_VETERINARIO) = 1 THEN 'TOTAL'
                                WHEN GROUPING(c.ST_CONSULTA)    = 1 THEN 'SUBTOTAL'
                                ELSE 'DETALHE' END                       AS tp_linha,
                           GROUPING(v.ID_VETERINARIO)                    AS g_vet,
                           GROUPING(c.ST_CONSULTA)                       AS g_st,
                           v.ID_VETERINARIO                              AS id_vet
                      FROM TB_CONSULTA c
                      JOIN TB_VETERINARIO v ON v.ID_VETERINARIO = c.TB_VETERINARIO_ID_VETERINARIO
                      JOIN TB_PESSOA      p ON p.ID_PESSOA      = v.TB_PESSOA_ID_PESSOA
                     WHERE v_status IS NULL OR c.ST_CONSULTA = v_status
                     GROUP BY ROLLUP (v.ID_VETERINARIO, c.ST_CONSULTA)
                   ) x
             ORDER BY x.g_vet, x.nm_veterinario, x.id_vet, x.g_st, x.st_consulta;
    EXCEPTION
        WHEN OTHERS THEN
            PKG_VETLY_LOG.registrar('PKG_VETLY_RELATORIO.prc_consultas_vet_status', SQLCODE, SQLERRM);
            RAISE;
    END prc_consultas_vet_status;

END PKG_VETLY_RELATORIO;
/
