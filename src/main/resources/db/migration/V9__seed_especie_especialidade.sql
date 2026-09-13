-- TB_ESPECIE e TB_ESPECIALIDADES_VET sao tabelas "hibridas": os valores
-- validos sao fixados pelos enums Java (NomeEspecie/NomeEspecialidade), mas
-- nunca havia uma migration que semeasse as linhas correspondentes -- o
-- cadastro de animal (selecao de especie) e o cadastro de veterinario
-- (selecao de especialidade/especie) ficavam vazios ate um ADMIN criar cada
-- uma manualmente em /mvc/especies e /mvc/especialidades.
INSERT INTO TB_ESPECIE (ID_ESPECIE, NM_ESPECIE)
SELECT RAWTOHEX(SYS_GUID()), nome
FROM (
    SELECT 'AVE' AS nome FROM DUAL UNION ALL
    SELECT 'REPTIL' FROM DUAL UNION ALL
    SELECT 'MAMIFERO' FROM DUAL UNION ALL
    SELECT 'ANFIBIO' FROM DUAL UNION ALL
    SELECT 'PEIXE' FROM DUAL UNION ALL
    SELECT 'EQUIDEO' FROM DUAL UNION ALL
    SELECT 'CAO' FROM DUAL UNION ALL
    SELECT 'GATO' FROM DUAL
) especies
WHERE NOT EXISTS (SELECT 1 FROM TB_ESPECIE e WHERE e.NM_ESPECIE = especies.nome);

INSERT INTO TB_ESPECIALIDADES_VET (ID_ESPECIALIDADE_VET, NM_ESPECIALIDADE, DS_ESPECIALIDADE)
SELECT RAWTOHEX(SYS_GUID()), nome, descricao
FROM (
    SELECT 'ACUPUNTURA' AS nome, 'Acupuntura veterinaria' AS descricao FROM DUAL UNION ALL
    SELECT 'ANESTESIOLOGIA', 'Anestesiologia veterinaria' FROM DUAL UNION ALL
    SELECT 'CARDIOLOGIA', 'Cardiologia veterinaria' FROM DUAL UNION ALL
    SELECT 'CIRURGIA', 'Cirurgia veterinaria' FROM DUAL UNION ALL
    SELECT 'DERMATOLOGIA', 'Dermatologia veterinaria' FROM DUAL UNION ALL
    SELECT 'ENDOCRINOLOGIA', 'Endocrinologia veterinaria' FROM DUAL UNION ALL
    SELECT 'FISIOTERAPIA', 'Fisioterapia veterinaria' FROM DUAL UNION ALL
    SELECT 'GERIATRIA', 'Geriatria veterinaria' FROM DUAL UNION ALL
    SELECT 'HOMEOPATIA', 'Homeopatia veterinaria' FROM DUAL UNION ALL
    SELECT 'MEDICINA_ANIMAIS_SELVAGENS', 'Medicina de animais selvagens' FROM DUAL UNION ALL
    SELECT 'MEDICINA_DO_COLETIVO', 'Medicina do coletivo' FROM DUAL UNION ALL
    SELECT 'MEDICINA_INTENSIVA', 'Medicina intensiva veterinaria' FROM DUAL UNION ALL
    SELECT 'NEFROLOGIA_E_UROLOGIA', 'Nefrologia e urologia veterinaria' FROM DUAL UNION ALL
    SELECT 'NEUROLOGIA', 'Neurologia veterinaria' FROM DUAL UNION ALL
    SELECT 'NUTROLOGIA', 'Nutrologia veterinaria' FROM DUAL UNION ALL
    SELECT 'ODONTOLOGIA', 'Odontologia veterinaria' FROM DUAL UNION ALL
    SELECT 'OFTALMOLOGIA', 'Oftalmologia veterinaria' FROM DUAL UNION ALL
    SELECT 'PATOLOGIA', 'Patologia veterinaria' FROM DUAL UNION ALL
    SELECT 'PEQUENOS_ANIMAIS', 'Clinica medica de pequenos animais' FROM DUAL UNION ALL
    SELECT 'PNEUMOLOGIA', 'Pneumologia veterinaria' FROM DUAL UNION ALL
    SELECT 'RADIOLOGIA', 'Radiologia veterinaria' FROM DUAL
) especialidades
WHERE NOT EXISTS (
    SELECT 1 FROM TB_ESPECIALIDADES_VET ev WHERE ev.NM_ESPECIALIDADE = especialidades.nome
);
