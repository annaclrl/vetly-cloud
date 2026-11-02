-- ============================================================================
-- SPRINT 4 - CARGA DEMONSTRATIVA via PKG_VETLY_CARGA
--
-- Insere 2 tutores, 2 veterinarios, 3 animais e 6 consultas usando os
-- procedimentos empacotados (e nao INSERTs soltos). Pre-requisito: schema migrado
-- ate V10 (TB_ESPECIE ja semeada pela V9).
-- Idempotente: prefixo DEMO4- nos ids; roda de novo limpando o que ja existe.
-- SET SERVEROUTPUT ON antes de executar para ver as mensagens.
-- ============================================================================
DECLARE
    v_cao   TB_ESPECIE.ID_ESPECIE%TYPE;
    v_gato  TB_ESPECIE.ID_ESPECIE%TYPE;
BEGIN
    -- limpeza da execucao anterior (ordem inversa das FKs)
    DELETE FROM TB_CONSULTA   WHERE ID_CONSULTA LIKE 'DEMO4-%';
    DELETE FROM TB_ANIMAL     WHERE ID_ANIMAL   LIKE 'DEMO4-%';
    DELETE FROM TB_TUTOR      WHERE ID_TUTOR    LIKE 'DEMO4-%';
    DELETE FROM TB_VETERINARIO WHERE ID_VETERINARIO LIKE 'DEMO4-%';
    DELETE FROM TB_PESSOA     WHERE ID_PESSOA   LIKE 'DEMO4-%';
    DELETE FROM TB_USUARIO    WHERE ID_USUARIO  LIKE 'DEMO4-%';
    COMMIT;

    SELECT ID_ESPECIE INTO v_cao  FROM TB_ESPECIE WHERE NM_ESPECIE = 'CAO';
    SELECT ID_ESPECIE INTO v_gato FROM TB_ESPECIE WHERE NM_ESPECIE = 'GATO';

    -- Usuarios (hash ficticio: contas de demonstracao, sem login possivel)
    PKG_VETLY_CARGA.prc_ins_usuario('DEMO4-U-T1', 'marina.demo4@vetly.test',  'TUTOR',       'S', 'x');
    PKG_VETLY_CARGA.prc_ins_usuario('DEMO4-U-T2', 'carlos.demo4@vetly.test',  'TUTOR',       'S', 'x');
    PKG_VETLY_CARGA.prc_ins_usuario('DEMO4-U-V1', 'dra.helena.demo4@vetly.test', 'VETERINARIO', 'S', 'x');
    PKG_VETLY_CARGA.prc_ins_usuario('DEMO4-U-V2', 'dr.paulo.demo4@vetly.test',   'VETERINARIO', 'S', 'x');

    -- Pessoas (CPFs validos pelo modulo 11)
    PKG_VETLY_CARGA.prc_ins_pessoa('DEMO4-P-T1', 'Marina Souza',  '52998224725', '11988887777');
    PKG_VETLY_CARGA.prc_ins_pessoa('DEMO4-P-T2', 'Carlos "Dudu" Lima', '11144477735', '11977776666');
    PKG_VETLY_CARGA.prc_ins_pessoa('DEMO4-P-V1', 'Helena Prado',  '39053344705', '11966665555');
    PKG_VETLY_CARGA.prc_ins_pessoa('DEMO4-P-V2', 'Paulo Nogueira','16899535009', '11955554444');

    PKG_VETLY_CARGA.prc_ins_tutor('DEMO4-T1', 'DEMO4-U-T1', 'DEMO4-P-T1');
    PKG_VETLY_CARGA.prc_ins_tutor('DEMO4-T2', 'DEMO4-U-T2', 'DEMO4-P-T2');
    PKG_VETLY_CARGA.prc_ins_veterinario('DEMO4-V1', 'CRMV-SP 11111', 'DEMO4-U-V1', 'DEMO4-P-V1');
    PKG_VETLY_CARGA.prc_ins_veterinario('DEMO4-V2', 'CRMV-SP 22222', 'DEMO4-U-V2', 'DEMO4-P-V2');

    PKG_VETLY_CARGA.prc_ins_animal('DEMO4-A1', 'Thor',  'Labrador', 'M', DATE '2020-03-10', 31.5, 'DEMO4-T1', v_cao);
    PKG_VETLY_CARGA.prc_ins_animal('DEMO4-A2', 'Mia',   'Siames',   'F', DATE '2021-07-22',  4.2, 'DEMO4-T1', v_gato);
    PKG_VETLY_CARGA.prc_ins_animal('DEMO4-A3', 'Bidu',  'SRD',      'M', DATE '2018-11-02', 12.0, 'DEMO4-T2', v_cao);

    PKG_VETLY_CARGA.prc_ins_consulta('DEMO4-C1', DATE '2026-10-01', 'REALIZADA', 250.00, 'Check-up anual',        'DEMO4-V1', 'DEMO4-A1');
    PKG_VETLY_CARGA.prc_ins_consulta('DEMO4-C2', DATE '2026-10-08', 'REALIZADA', 180.00, 'Vacina polivalente',    'DEMO4-V1', 'DEMO4-A2');
    PKG_VETLY_CARGA.prc_ins_consulta('DEMO4-C3', DATE '2026-10-15', 'CANCELADA', 120.00, NULL,                    'DEMO4-V1', 'DEMO4-A1');
    PKG_VETLY_CARGA.prc_ins_consulta('DEMO4-C4', DATE '2026-10-20', 'AGENDADA',  300.00, 'Retorno cardiologico',  'DEMO4-V2', 'DEMO4-A3');
    PKG_VETLY_CARGA.prc_ins_consulta('DEMO4-C5', DATE '2026-10-22', 'REALIZADA', 200.00, 'Exame de rotina',       'DEMO4-V2', 'DEMO4-A3');
    PKG_VETLY_CARGA.prc_ins_consulta('DEMO4-C6', DATE '2026-10-25', 'NAO_COMPARECEU', 150.00, NULL,               'DEMO4-V2', 'DEMO4-A2');

    DBMS_OUTPUT.PUT_LINE('Carga demo concluida: 2 tutores, 2 veterinarios, 3 animais, 6 consultas.');
END;
/
