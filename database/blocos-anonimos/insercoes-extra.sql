-- ============================================================
-- INSERCOES ADICIONAIS: TB_USUARIO, TB_PESSOA e TB_TUTOR
-- (id 1 ja fizemos no arquivo de teste, inserindo ids 3 a 6 para novos tutores)
-- ============================================================

-- Usuarios para os novos tutores
BEGIN
    SP_INS_USUARIO(3, 'carlos.ferreira@email.com', 'TUTOR', '1', 'hash_carlos');
    SP_INS_USUARIO(4, 'mariana.lima@email.com',    'TUTOR', '1', 'hash_mariana');
    SP_INS_USUARIO(5, 'pedro.costa@email.com',     'TUTOR', '1', 'hash_pedro');
    SP_INS_USUARIO(6, 'fernanda.rocha@email.com',  'TUTOR', '1', 'hash_fernanda');
    DBMS_OUTPUT.PUT_LINE('Usuarios inseridos: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao inserir usuarios: ' || SQLERRM);
END;
/

-- Pessoas para os novos tutores
BEGIN
    SP_INS_PESSOA(3, 'Carlos Ferreira',  '11122233344', '11977770003');
    SP_INS_PESSOA(4, 'Mariana Lima',     '22233344455', '11966660004');
    SP_INS_PESSOA(5, 'Pedro Costa',      '33344455566', '11955550005');
    SP_INS_PESSOA(6, 'Fernanda Rocha',   '44455566677', '11944440006');
    DBMS_OUTPUT.PUT_LINE('Pessoas inseridas: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao inserir pessoas: ' || SQLERRM);
END;
/

-- Tutores (ids 2 a 5 novos; tutor id 1 ja existe vinculado a usuario 1 e pessoa 1)
BEGIN
    SP_INS_TUTOR(2, 3, 3);
    SP_INS_TUTOR(3, 4, 4);
    SP_INS_TUTOR(4, 5, 5);
    SP_INS_TUTOR(5, 6, 6);
    DBMS_OUTPUT.PUT_LINE('Tutores inseridos: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao inserir tutores: ' || SQLERRM);
END;
/