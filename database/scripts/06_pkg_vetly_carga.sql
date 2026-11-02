-- ============================================================================
-- SPRINT 4 - PACOTE PKG_VETLY_CARGA
--
-- Empacota as 16 procedures de insercao (antes SP_INS_*, soltas) em um unico
-- modulo. Mesma logica e mesmas assinaturas (inclusive os campos das migrations
-- V2..V6), agora com nomes prc_ins_* e log via PKG_VETLY_LOG.
-- Este arquivo e a fonte; as SP_INS_* soltas da sprint anterior foram removidas.
-- ============================================================================
CREATE OR REPLACE PACKAGE PKG_VETLY_CARGA AS

    -- 1. TB_USUARIO
    PROCEDURE prc_ins_usuario (
    p_id_usuario        IN TB_USUARIO.ID_USUARIO%TYPE,
    p_em_usuario        IN TB_USUARIO.EM_USUARIO%TYPE,
    p_rl_usuario        IN TB_USUARIO.RL_USUARIO%TYPE,
    p_fl_atv_usuario    IN TB_USUARIO.FL_ATV_USUARIO%TYPE,
    p_sen_hash_usuario  IN TB_USUARIO.SEN_HASH_USUARIO%TYPE
    );

    -- 2. TB_PESSOA
    PROCEDURE prc_ins_pessoa (
    p_id_pessoa     IN TB_PESSOA.ID_PESSOA%TYPE,
    p_nm_pessoa     IN TB_PESSOA.NM_PESSOA%TYPE,
    p_cpf_pessoa    IN TB_PESSOA.CPF_PESSOA%TYPE,
    p_tel_pessoa    IN TB_PESSOA.TEL_PESSOA%TYPE
    );

    -- 3. TB_ESPECIE
    PROCEDURE prc_ins_especie (
    p_id_especie    IN TB_ESPECIE.ID_ESPECIE%TYPE,
    p_nm_especie    IN TB_ESPECIE.NM_ESPECIE%TYPE
    );

    -- 4. TB_ESPECIALIDADES_VET
    PROCEDURE prc_ins_especialidade_vet (
    p_id_especialidade_vet  IN TB_ESPECIALIDADES_VET.ID_ESPECIALIDADE_VET%TYPE,
    p_nm_especialidade      IN TB_ESPECIALIDADES_VET.NM_ESPECIALIDADE%TYPE,
    p_ds_especialidade      IN TB_ESPECIALIDADES_VET.DS_ESPECIALIDADE%TYPE
    );

    -- 5. TB_TUTOR
    PROCEDURE prc_ins_tutor (
    p_id_tutor              IN TB_TUTOR.ID_TUTOR%TYPE,
    p_tb_usuario_id_usuario IN TB_TUTOR.TB_USUARIO_ID_USUARIO%TYPE,
    p_tb_pessoa_id_pessoa   IN TB_TUTOR.TB_PESSOA_ID_PESSOA%TYPE,
    -- Flyway V6 (docs/java-database-alignment.md §2.3) — LGPD e consentimento de rede (RN-064)
    p_fl_lgpd_aceito        IN TB_TUTOR.FL_LGPD_ACEITO%TYPE DEFAULT 'N',
    p_dt_lgpd_aceito        IN TB_TUTOR.DT_LGPD_ACEITO%TYPE DEFAULT NULL,
    p_fl_consentimento_rede IN TB_TUTOR.FL_CONSENTIMENTO_REDE%TYPE DEFAULT 'N',
    p_dt_consentimento_rede IN TB_TUTOR.DT_CONSENTIMENTO_REDE%TYPE DEFAULT NULL
    );

    -- 6. TB_VETERINARIO
    PROCEDURE prc_ins_veterinario (
    p_id_veterinario        IN TB_VETERINARIO.ID_VETERINARIO%TYPE,
    p_crmv_veterinario      IN TB_VETERINARIO.CRMV_VETERINARIO%TYPE,
    p_tb_usuario_id_usuario IN TB_VETERINARIO.TB_USUARIO_ID_USUARIO%TYPE,
    p_tb_pessoa_id_pessoa   IN TB_VETERINARIO.TB_PESSOA_ID_PESSOA%TYPE
    );

    -- 7. TB_VETERINARIO_ESPECIALIDADE
    PROCEDURE prc_ins_vet_especialidade (
    p_id_especialidade_veterinario  IN TB_VETERINARIO_ESPECIALIDADE.ID_ESPECIALIDADE_VETERINARIO%TYPE,
    p_tb_veterinario_id_veterinario IN TB_VETERINARIO_ESPECIALIDADE.TB_VETERINARIO_ID_VETERINARIO%TYPE,
    p_tb_espcd_vet_id_espcd_vet     IN TB_VETERINARIO_ESPECIALIDADE.TB_ESPCD_VET_ID_ESPCD_VET%TYPE
    );

    -- 8. TB_VETERINARIO_ESPECIE
    PROCEDURE prc_ins_vet_especie (
    p_id_veterinario_especie        IN TB_VETERINARIO_ESPECIE.ID_VETERINARIO_ESPECIE%TYPE,
    p_tb_veterinario_id_veterinario IN TB_VETERINARIO_ESPECIE.TB_VETERINARIO_ID_VETERINARIO%TYPE,
    p_tb_especie_id_especie         IN TB_VETERINARIO_ESPECIE.TB_ESPECIE_ID_ESPECIE%TYPE
    );

    -- 9. TB_ANIMAL
    PROCEDURE prc_ins_animal (
    p_id_animal             IN TB_ANIMAL.ID_ANIMAL%TYPE,
    p_nm_animal             IN TB_ANIMAL.NM_ANIMAL%TYPE,
    p_rc_animal             IN TB_ANIMAL.RC_ANIMAL%TYPE,
    p_sx_animal             IN TB_ANIMAL.SX_ANIMAL%TYPE,
    p_dt_nasc_animal        IN TB_ANIMAL.DT_NASC_ANIMAL%TYPE,
    p_nr_peso_animal        IN TB_ANIMAL.NR_PESO_ANIMAL%TYPE,
    p_tb_tutor_id_tutor     IN TB_ANIMAL.TB_TUTOR_ID_TUTOR%TYPE,
    p_tb_especie_id_especie IN TB_ANIMAL.TB_ESPECIE_ID_ESPECIE%TYPE,
    -- Flyway V2 (docs/java-database-alignment.md §2.1) — campos clinicos adicionados ao Animal
    p_url_foto_animal       IN TB_ANIMAL.URL_FOTO_ANIMAL%TYPE DEFAULT NULL,
    p_fl_castrado           IN TB_ANIMAL.FL_CASTRADO%TYPE DEFAULT 'N',
    p_ds_condicoes_preexist IN TB_ANIMAL.DS_CONDICOES_PREEXIST%TYPE DEFAULT NULL,
    p_ds_alergias           IN TB_ANIMAL.DS_ALERGIAS%TYPE DEFAULT NULL,
    p_ds_medicacoes_em_uso  IN TB_ANIMAL.DS_MEDICACOES_EM_USO%TYPE DEFAULT NULL
    );

    -- 10. TB_PRONTUARIO
    PROCEDURE prc_ins_prontuario (
    p_id_prontuario             IN TB_PRONTUARIO.ID_PRONTUARIO%TYPE,
    p_dt_upd_pronturario        IN TB_PRONTUARIO.DT_UPD_PRONTURARIO%TYPE,
    -- Flyway V8 (docs/java-database-alignment.md §2.5, Opcao A) — versionamento do prontuario:
    -- DS_CONTEUDO_CLINICO passou a ser obrigatorio; uma linha original por animal
    -- (p_tb_prontuario_id_original = NULL) mais N linhas de correcao apontando para ela.
    p_ds_conteudo_clinico       IN TB_PRONTUARIO.DS_CONTEUDO_CLINICO%TYPE,
    p_tb_animal_id_animal       IN TB_PRONTUARIO.TB_ANIMAL_ID_ANIMAL%TYPE,
    p_tb_prontuario_id_original IN TB_PRONTUARIO.TB_PRONTUARIO_ID_ORIGINAL%TYPE DEFAULT NULL,
    p_dt_hr_correcao            IN TB_PRONTUARIO.DT_HR_CORRECAO%TYPE DEFAULT NULL,
    p_crmv_solicitante_correcao IN TB_PRONTUARIO.CRMV_SOLICITANTE_CORRECAO%TYPE DEFAULT NULL,
    p_ds_justificativa_correcao IN TB_PRONTUARIO.DS_JUSTIFICATIVA_CORRECAO%TYPE DEFAULT NULL
    );

    -- 11. TB_CONSULTA
    PROCEDURE prc_ins_consulta (
    p_id_consulta                   IN TB_CONSULTA.ID_CONSULTA%TYPE,
    p_dt_hr_consulta                IN TB_CONSULTA.DT_HR_CONSULTA%TYPE,
    p_st_consulta                   IN TB_CONSULTA.ST_CONSULTA%TYPE,
    p_vl_consulta                   IN TB_CONSULTA.VL_CONSULTA%TYPE,
    p_obs_consulta                  IN TB_CONSULTA.OBS_CONSULTA%TYPE,
    p_tb_veterinario_id_veterinario IN TB_CONSULTA.TB_VETERINARIO_ID_VETERINARIO%TYPE,
    p_tb_animal_id_animal           IN TB_CONSULTA.TB_ANIMAL_ID_ANIMAL%TYPE
    );

    -- 12. TB_EVOLUCAO_CLINICA
    PROCEDURE prc_ins_evolucao_clinica (
    p_id_evolucao_clinica     IN TB_EVOLUCAO_CLINICA.ID_EVOLUCAO_CLINICA%TYPE,
    p_ant_evolucao_clinica    IN TB_EVOLUCAO_CLINICA.ANT_EVOLUCAO_CLINICA%TYPE,
    p_tb_consulta_id_consulta IN TB_EVOLUCAO_CLINICA.TB_CONSULTA_ID_CONSULTA%TYPE,
    -- Flyway V3 (docs/java-database-alignment.md §2.2) — RN-068: ocultar do Responsavel,
    -- exceto alerta de seguranca (alergia/interacao), que nunca pode ser ocultado
    p_fl_oculto_responsavel  IN TB_EVOLUCAO_CLINICA.FL_OCULTO_RESPONSAVEL%TYPE DEFAULT 'N',
    p_fl_alerta_seguranca    IN TB_EVOLUCAO_CLINICA.FL_ALERTA_SEGURANCA%TYPE DEFAULT 'N'
    );

    -- 13. TB_SOLICITACAO_EXAME
    PROCEDURE prc_ins_solicitacao_exame (
    p_id_solicitacao_exame  IN TB_SOLICITACAO_EXAME.ID_SOLICITACAO_EXAME%TYPE,
    p_obs_solicitacao       IN TB_SOLICITACAO_EXAME.OBS_SOLICITACAO%TYPE,
    p_tb_consulta_id_consulta IN TB_SOLICITACAO_EXAME.TB_CONSULTA_ID_CONSULTA%TYPE
    );

    -- 14. TB_SOLICITACAO_EXAME_ITEM
    PROCEDURE prc_ins_solicitacao_exame_item (
    p_id_solicitacao_exame_item     IN TB_SOLICITACAO_EXAME_ITEM.ID_SOLICITACAO_EXAME_ITEM%TYPE,
    p_nm_exame                      IN TB_SOLICITACAO_EXAME_ITEM.NM_EXAME%TYPE,
    p_st_exame                      IN TB_SOLICITACAO_EXAME_ITEM.ST_EXAME%TYPE,
    p_dt_solc_exame                 IN TB_SOLICITACAO_EXAME_ITEM.DT_SOLC_EXAME%TYPE,
    p_dt_res_exame                  IN TB_SOLICITACAO_EXAME_ITEM.DT_RES_EXAME%TYPE,
    p_ds_res_exame                  IN TB_SOLICITACAO_EXAME_ITEM.DS_RES_EXAME%TYPE,
    p_dt_analise                    IN TB_SOLICITACAO_EXAME_ITEM.DT_ANALISE%TYPE,
    p_dt_envio_resultado            IN TB_SOLICITACAO_EXAME_ITEM.DT_ENVIO_RESULTADO%TYPE,
    p_tb_solct_exame_id_solct_exame IN TB_SOLICITACAO_EXAME_ITEM.TB_SOLCT_EXAME_ID_SOLCT_EXAME%TYPE,
    -- Flyway V5 (docs/java-database-alignment.md §2.7) — RN-104: resultado so chega ao
    -- Responsavel apos liberacao explicita do vet (RESULTADO_ENVIADO = liberado, nao "enviado ao vet")
    p_fl_liberado_responsavel       IN TB_SOLICITACAO_EXAME_ITEM.FL_LIBERADO_RESPONSAVEL%TYPE DEFAULT 'N',
    p_dt_liberacao_responsavel      IN TB_SOLICITACAO_EXAME_ITEM.DT_LIBERACAO_RESPONSAVEL%TYPE DEFAULT NULL
    );

    -- 15. TB_ANEXO_EXAME
    PROCEDURE prc_ins_anexo_exame (
    p_id_anexo_exame                IN TB_ANEXO_EXAME.ID_ANEXO_EXAME%TYPE,
    p_url_arquivo_anexo             IN TB_ANEXO_EXAME.URL_ARQUIVO_ANEXO%TYPE,
    p_mime_type_anexo               IN TB_ANEXO_EXAME.MIME_TYPE_ANEXO%TYPE,
    p_dt_upload_anexo               IN TB_ANEXO_EXAME.DT_UPLOAD_ANEXO%TYPE,
    p_tb_slc_ex_item_id_slc_ex_item IN TB_ANEXO_EXAME.TB_SLC_EX_ITEM_ID_SLC_EX_ITEM%TYPE
    );

    -- SP_INS_LOG_ACESSO_PRONTUARIO
    PROCEDURE prc_ins_log_acesso_prontuario (
    p_id_log_acesso                 IN TB_LOG_ACESSO_PRONTUARIO.ID_LOG_ACESSO%TYPE,
    p_dt_hr_acesso                  IN TB_LOG_ACESSO_PRONTUARIO.DT_HR_ACESSO%TYPE,
    p_ds_contexto_acesso            IN TB_LOG_ACESSO_PRONTUARIO.DS_CONTEXTO_ACESSO%TYPE,
    p_ds_base_acesso                IN TB_LOG_ACESSO_PRONTUARIO.DS_BASE_ACESSO%TYPE,
    p_tb_animal_id_animal           IN TB_LOG_ACESSO_PRONTUARIO.TB_ANIMAL_ID_ANIMAL%TYPE,
    p_tb_veterinario_id_veterinario IN TB_LOG_ACESSO_PRONTUARIO.TB_VETERINARIO_ID_VETERINARIO%TYPE
    );

END PKG_VETLY_CARGA;
/

CREATE OR REPLACE PACKAGE BODY PKG_VETLY_CARGA AS

    PROCEDURE prc_ins_usuario (
    p_id_usuario        IN TB_USUARIO.ID_USUARIO%TYPE,
    p_em_usuario        IN TB_USUARIO.EM_USUARIO%TYPE,
    p_rl_usuario        IN TB_USUARIO.RL_USUARIO%TYPE,
    p_fl_atv_usuario    IN TB_USUARIO.FL_ATV_USUARIO%TYPE,
    p_sen_hash_usuario  IN TB_USUARIO.SEN_HASH_USUARIO%TYPE
    ) IS
BEGIN
    INSERT INTO TB_USUARIO (
        ID_USUARIO, EM_USUARIO, RL_USUARIO, FL_ATV_USUARIO, SEN_HASH_USUARIO
    ) VALUES (
        p_id_usuario, p_em_usuario, p_rl_usuario, p_fl_atv_usuario, p_sen_hash_usuario
    );
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_USUARIO', SQLCODE, 'Registro duplicado: ' || SQLERRM);
        RAISE;
    WHEN VALUE_ERROR THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_USUARIO', SQLCODE, 'Erro de valor/tipo: ' || SQLERRM);
        RAISE;
    WHEN OTHERS THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_USUARIO', SQLCODE, SQLERRM);
        RAISE;
    END prc_ins_usuario;

    PROCEDURE prc_ins_pessoa (
    p_id_pessoa     IN TB_PESSOA.ID_PESSOA%TYPE,
    p_nm_pessoa     IN TB_PESSOA.NM_PESSOA%TYPE,
    p_cpf_pessoa    IN TB_PESSOA.CPF_PESSOA%TYPE,
    p_tel_pessoa    IN TB_PESSOA.TEL_PESSOA%TYPE
    ) IS
BEGIN
    INSERT INTO TB_PESSOA (
        ID_PESSOA, NM_PESSOA, CPF_PESSOA, TEL_PESSOA
    ) VALUES (
        p_id_pessoa, p_nm_pessoa, p_cpf_pessoa, p_tel_pessoa
    );
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_PESSOA', SQLCODE, 'Registro duplicado: ' || SQLERRM);
        RAISE;
    WHEN VALUE_ERROR THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_PESSOA', SQLCODE, 'Erro de valor/tipo: ' || SQLERRM);
        RAISE;
    WHEN OTHERS THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_PESSOA', SQLCODE, SQLERRM);
        RAISE;
    END prc_ins_pessoa;

    PROCEDURE prc_ins_especie (
    p_id_especie    IN TB_ESPECIE.ID_ESPECIE%TYPE,
    p_nm_especie    IN TB_ESPECIE.NM_ESPECIE%TYPE
    ) IS
BEGIN
    INSERT INTO TB_ESPECIE (
        ID_ESPECIE, NM_ESPECIE
    ) VALUES (
        p_id_especie, p_nm_especie
    );
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_ESPECIE', SQLCODE, 'Registro duplicado: ' || SQLERRM);
        RAISE;
    WHEN VALUE_ERROR THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_ESPECIE', SQLCODE, 'Erro de valor/tipo: ' || SQLERRM);
        RAISE;
    WHEN OTHERS THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_ESPECIE', SQLCODE, SQLERRM);
        RAISE;
    END prc_ins_especie;

    PROCEDURE prc_ins_especialidade_vet (
    p_id_especialidade_vet  IN TB_ESPECIALIDADES_VET.ID_ESPECIALIDADE_VET%TYPE,
    p_nm_especialidade      IN TB_ESPECIALIDADES_VET.NM_ESPECIALIDADE%TYPE,
    p_ds_especialidade      IN TB_ESPECIALIDADES_VET.DS_ESPECIALIDADE%TYPE
    ) IS
BEGIN
    INSERT INTO TB_ESPECIALIDADES_VET (
        ID_ESPECIALIDADE_VET, NM_ESPECIALIDADE, DS_ESPECIALIDADE
    ) VALUES (
        p_id_especialidade_vet, p_nm_especialidade, p_ds_especialidade
    );
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_ESPECIALIDADE_VET', SQLCODE, 'Registro duplicado: ' || SQLERRM);
        RAISE;
    WHEN VALUE_ERROR THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_ESPECIALIDADE_VET', SQLCODE, 'Erro de valor/tipo: ' || SQLERRM);
        RAISE;
    WHEN OTHERS THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_ESPECIALIDADE_VET', SQLCODE, SQLERRM);
        RAISE;
    END prc_ins_especialidade_vet;

    PROCEDURE prc_ins_tutor (
    p_id_tutor              IN TB_TUTOR.ID_TUTOR%TYPE,
    p_tb_usuario_id_usuario IN TB_TUTOR.TB_USUARIO_ID_USUARIO%TYPE,
    p_tb_pessoa_id_pessoa   IN TB_TUTOR.TB_PESSOA_ID_PESSOA%TYPE,
    -- Flyway V6 (docs/java-database-alignment.md §2.3) — LGPD e consentimento de rede (RN-064)
    p_fl_lgpd_aceito        IN TB_TUTOR.FL_LGPD_ACEITO%TYPE DEFAULT 'N',
    p_dt_lgpd_aceito        IN TB_TUTOR.DT_LGPD_ACEITO%TYPE DEFAULT NULL,
    p_fl_consentimento_rede IN TB_TUTOR.FL_CONSENTIMENTO_REDE%TYPE DEFAULT 'N',
    p_dt_consentimento_rede IN TB_TUTOR.DT_CONSENTIMENTO_REDE%TYPE DEFAULT NULL
    ) IS
BEGIN
    INSERT INTO TB_TUTOR (
        ID_TUTOR, TB_USUARIO_ID_USUARIO, TB_PESSOA_ID_PESSOA,
        FL_LGPD_ACEITO, DT_LGPD_ACEITO, FL_CONSENTIMENTO_REDE, DT_CONSENTIMENTO_REDE
    ) VALUES (
        p_id_tutor, p_tb_usuario_id_usuario, p_tb_pessoa_id_pessoa,
        p_fl_lgpd_aceito, p_dt_lgpd_aceito, p_fl_consentimento_rede, p_dt_consentimento_rede
    );
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_TUTOR', SQLCODE, 'Registro duplicado: ' || SQLERRM);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_TUTOR', SQLCODE, 'FK nao encontrada: ' || SQLERRM);
        RAISE;
    WHEN OTHERS THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_TUTOR', SQLCODE, SQLERRM);
        RAISE;
    END prc_ins_tutor;

    PROCEDURE prc_ins_veterinario (
    p_id_veterinario        IN TB_VETERINARIO.ID_VETERINARIO%TYPE,
    p_crmv_veterinario      IN TB_VETERINARIO.CRMV_VETERINARIO%TYPE,
    p_tb_usuario_id_usuario IN TB_VETERINARIO.TB_USUARIO_ID_USUARIO%TYPE,
    p_tb_pessoa_id_pessoa   IN TB_VETERINARIO.TB_PESSOA_ID_PESSOA%TYPE
    ) IS
BEGIN
    INSERT INTO TB_VETERINARIO (
        ID_VETERINARIO, CRMV_VETERINARIO, TB_USUARIO_ID_USUARIO, TB_PESSOA_ID_PESSOA
    ) VALUES (
        p_id_veterinario, p_crmv_veterinario, p_tb_usuario_id_usuario, p_tb_pessoa_id_pessoa
    );
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_VETERINARIO', SQLCODE, 'Registro duplicado: ' || SQLERRM);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_VETERINARIO', SQLCODE, 'FK nao encontrada: ' || SQLERRM);
        RAISE;
    WHEN OTHERS THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_VETERINARIO', SQLCODE, SQLERRM);
        RAISE;
    END prc_ins_veterinario;

    PROCEDURE prc_ins_vet_especialidade (
    p_id_especialidade_veterinario  IN TB_VETERINARIO_ESPECIALIDADE.ID_ESPECIALIDADE_VETERINARIO%TYPE,
    p_tb_veterinario_id_veterinario IN TB_VETERINARIO_ESPECIALIDADE.TB_VETERINARIO_ID_VETERINARIO%TYPE,
    p_tb_espcd_vet_id_espcd_vet     IN TB_VETERINARIO_ESPECIALIDADE.TB_ESPCD_VET_ID_ESPCD_VET%TYPE
    ) IS
BEGIN
    INSERT INTO TB_VETERINARIO_ESPECIALIDADE (
        ID_ESPECIALIDADE_VETERINARIO, TB_VETERINARIO_ID_VETERINARIO, TB_ESPCD_VET_ID_ESPCD_VET
    ) VALUES (
        p_id_especialidade_veterinario, p_tb_veterinario_id_veterinario, p_tb_espcd_vet_id_espcd_vet
    );
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_VET_ESPECIALIDADE', SQLCODE, 'Registro duplicado: ' || SQLERRM);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_VET_ESPECIALIDADE', SQLCODE, 'FK nao encontrada: ' || SQLERRM);
        RAISE;
    WHEN OTHERS THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_VET_ESPECIALIDADE', SQLCODE, SQLERRM);
        RAISE;
    END prc_ins_vet_especialidade;

    PROCEDURE prc_ins_vet_especie (
    p_id_veterinario_especie        IN TB_VETERINARIO_ESPECIE.ID_VETERINARIO_ESPECIE%TYPE,
    p_tb_veterinario_id_veterinario IN TB_VETERINARIO_ESPECIE.TB_VETERINARIO_ID_VETERINARIO%TYPE,
    p_tb_especie_id_especie         IN TB_VETERINARIO_ESPECIE.TB_ESPECIE_ID_ESPECIE%TYPE
    ) IS
BEGIN
    INSERT INTO TB_VETERINARIO_ESPECIE (
        ID_VETERINARIO_ESPECIE, TB_VETERINARIO_ID_VETERINARIO, TB_ESPECIE_ID_ESPECIE
    ) VALUES (
        p_id_veterinario_especie, p_tb_veterinario_id_veterinario, p_tb_especie_id_especie
    );
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_VET_ESPECIE', SQLCODE, 'Registro duplicado: ' || SQLERRM);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_VET_ESPECIE', SQLCODE, 'FK nao encontrada: ' || SQLERRM);
        RAISE;
    WHEN OTHERS THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_VET_ESPECIE', SQLCODE, SQLERRM);
        RAISE;
    END prc_ins_vet_especie;

    PROCEDURE prc_ins_animal (
    p_id_animal             IN TB_ANIMAL.ID_ANIMAL%TYPE,
    p_nm_animal             IN TB_ANIMAL.NM_ANIMAL%TYPE,
    p_rc_animal             IN TB_ANIMAL.RC_ANIMAL%TYPE,
    p_sx_animal             IN TB_ANIMAL.SX_ANIMAL%TYPE,
    p_dt_nasc_animal        IN TB_ANIMAL.DT_NASC_ANIMAL%TYPE,
    p_nr_peso_animal        IN TB_ANIMAL.NR_PESO_ANIMAL%TYPE,
    p_tb_tutor_id_tutor     IN TB_ANIMAL.TB_TUTOR_ID_TUTOR%TYPE,
    p_tb_especie_id_especie IN TB_ANIMAL.TB_ESPECIE_ID_ESPECIE%TYPE,
    -- Flyway V2 (docs/java-database-alignment.md §2.1) — campos clinicos adicionados ao Animal
    p_url_foto_animal       IN TB_ANIMAL.URL_FOTO_ANIMAL%TYPE DEFAULT NULL,
    p_fl_castrado           IN TB_ANIMAL.FL_CASTRADO%TYPE DEFAULT 'N',
    p_ds_condicoes_preexist IN TB_ANIMAL.DS_CONDICOES_PREEXIST%TYPE DEFAULT NULL,
    p_ds_alergias           IN TB_ANIMAL.DS_ALERGIAS%TYPE DEFAULT NULL,
    p_ds_medicacoes_em_uso  IN TB_ANIMAL.DS_MEDICACOES_EM_USO%TYPE DEFAULT NULL
    ) IS
BEGIN
    INSERT INTO TB_ANIMAL (
        ID_ANIMAL, NM_ANIMAL, RC_ANIMAL, SX_ANIMAL, DT_NASC_ANIMAL,
        NR_PESO_ANIMAL, TB_TUTOR_ID_TUTOR, TB_ESPECIE_ID_ESPECIE,
        URL_FOTO_ANIMAL, FL_CASTRADO, DS_CONDICOES_PREEXIST, DS_ALERGIAS, DS_MEDICACOES_EM_USO
    ) VALUES (
        p_id_animal, p_nm_animal, p_rc_animal, p_sx_animal, p_dt_nasc_animal,
        p_nr_peso_animal, p_tb_tutor_id_tutor, p_tb_especie_id_especie,
        p_url_foto_animal, p_fl_castrado, p_ds_condicoes_preexist, p_ds_alergias, p_ds_medicacoes_em_uso
    );
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_ANIMAL', SQLCODE, 'Registro duplicado: ' || SQLERRM);
        RAISE;
    WHEN VALUE_ERROR THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_ANIMAL', SQLCODE, 'Erro de valor/tipo: ' || SQLERRM);
        RAISE;
    WHEN OTHERS THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_ANIMAL', SQLCODE, SQLERRM);
        RAISE;
    END prc_ins_animal;

    PROCEDURE prc_ins_prontuario (
    p_id_prontuario             IN TB_PRONTUARIO.ID_PRONTUARIO%TYPE,
    p_dt_upd_pronturario        IN TB_PRONTUARIO.DT_UPD_PRONTURARIO%TYPE,
    -- Flyway V8 (docs/java-database-alignment.md §2.5, Opcao A) — versionamento do prontuario:
    -- DS_CONTEUDO_CLINICO passou a ser obrigatorio; uma linha original por animal
    -- (p_tb_prontuario_id_original = NULL) mais N linhas de correcao apontando para ela.
    p_ds_conteudo_clinico       IN TB_PRONTUARIO.DS_CONTEUDO_CLINICO%TYPE,
    p_tb_animal_id_animal       IN TB_PRONTUARIO.TB_ANIMAL_ID_ANIMAL%TYPE,
    p_tb_prontuario_id_original IN TB_PRONTUARIO.TB_PRONTUARIO_ID_ORIGINAL%TYPE DEFAULT NULL,
    p_dt_hr_correcao            IN TB_PRONTUARIO.DT_HR_CORRECAO%TYPE DEFAULT NULL,
    p_crmv_solicitante_correcao IN TB_PRONTUARIO.CRMV_SOLICITANTE_CORRECAO%TYPE DEFAULT NULL,
    p_ds_justificativa_correcao IN TB_PRONTUARIO.DS_JUSTIFICATIVA_CORRECAO%TYPE DEFAULT NULL
    ) IS
BEGIN
    INSERT INTO TB_PRONTUARIO (
        ID_PRONTUARIO, DT_UPD_PRONTURARIO, DS_CONTEUDO_CLINICO, TB_ANIMAL_ID_ANIMAL,
        TB_PRONTUARIO_ID_ORIGINAL, DT_HR_CORRECAO, CRMV_SOLICITANTE_CORRECAO, DS_JUSTIFICATIVA_CORRECAO
    ) VALUES (
        p_id_prontuario, p_dt_upd_pronturario, p_ds_conteudo_clinico, p_tb_animal_id_animal,
        p_tb_prontuario_id_original, p_dt_hr_correcao, p_crmv_solicitante_correcao, p_ds_justificativa_correcao
    );
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_PRONTUARIO', SQLCODE, 'Registro duplicado: ' || SQLERRM);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_PRONTUARIO', SQLCODE, 'FK nao encontrada: ' || SQLERRM);
        RAISE;
    WHEN OTHERS THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_PRONTUARIO', SQLCODE, SQLERRM);
        RAISE;
    END prc_ins_prontuario;

    PROCEDURE prc_ins_consulta (
    p_id_consulta                   IN TB_CONSULTA.ID_CONSULTA%TYPE,
    p_dt_hr_consulta                IN TB_CONSULTA.DT_HR_CONSULTA%TYPE,
    p_st_consulta                   IN TB_CONSULTA.ST_CONSULTA%TYPE,
    p_vl_consulta                   IN TB_CONSULTA.VL_CONSULTA%TYPE,
    p_obs_consulta                  IN TB_CONSULTA.OBS_CONSULTA%TYPE,
    p_tb_veterinario_id_veterinario IN TB_CONSULTA.TB_VETERINARIO_ID_VETERINARIO%TYPE,
    p_tb_animal_id_animal           IN TB_CONSULTA.TB_ANIMAL_ID_ANIMAL%TYPE
    ) IS
BEGIN
    INSERT INTO TB_CONSULTA (
        ID_CONSULTA, DT_HR_CONSULTA, ST_CONSULTA, VL_CONSULTA, OBS_CONSULTA,
        TB_VETERINARIO_ID_VETERINARIO, TB_ANIMAL_ID_ANIMAL
    ) VALUES (
        p_id_consulta, p_dt_hr_consulta, p_st_consulta, p_vl_consulta, p_obs_consulta,
        p_tb_veterinario_id_veterinario, p_tb_animal_id_animal
    );
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_CONSULTA', SQLCODE, 'Registro duplicado: ' || SQLERRM);
        RAISE;
    WHEN VALUE_ERROR THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_CONSULTA', SQLCODE, 'Erro de valor/tipo: ' || SQLERRM);
        RAISE;
    WHEN OTHERS THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_CONSULTA', SQLCODE, SQLERRM);
        RAISE;
    END prc_ins_consulta;

    PROCEDURE prc_ins_evolucao_clinica (
    p_id_evolucao_clinica     IN TB_EVOLUCAO_CLINICA.ID_EVOLUCAO_CLINICA%TYPE,
    p_ant_evolucao_clinica    IN TB_EVOLUCAO_CLINICA.ANT_EVOLUCAO_CLINICA%TYPE,
    p_tb_consulta_id_consulta IN TB_EVOLUCAO_CLINICA.TB_CONSULTA_ID_CONSULTA%TYPE,
    -- Flyway V3 (docs/java-database-alignment.md §2.2) — RN-068: ocultar do Responsavel,
    -- exceto alerta de seguranca (alergia/interacao), que nunca pode ser ocultado
    p_fl_oculto_responsavel  IN TB_EVOLUCAO_CLINICA.FL_OCULTO_RESPONSAVEL%TYPE DEFAULT 'N',
    p_fl_alerta_seguranca    IN TB_EVOLUCAO_CLINICA.FL_ALERTA_SEGURANCA%TYPE DEFAULT 'N'
    ) IS
BEGIN
    INSERT INTO TB_EVOLUCAO_CLINICA (
        ID_EVOLUCAO_CLINICA, ANT_EVOLUCAO_CLINICA, TB_CONSULTA_ID_CONSULTA,
        FL_OCULTO_RESPONSAVEL, FL_ALERTA_SEGURANCA
    ) VALUES (
        p_id_evolucao_clinica, p_ant_evolucao_clinica, p_tb_consulta_id_consulta,
        p_fl_oculto_responsavel, p_fl_alerta_seguranca
    );
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_EVOLUCAO_CLINICA', SQLCODE, 'Registro duplicado: ' || SQLERRM);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_EVOLUCAO_CLINICA', SQLCODE, 'FK nao encontrada: ' || SQLERRM);
        RAISE;
    WHEN OTHERS THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_EVOLUCAO_CLINICA', SQLCODE, SQLERRM);
        RAISE;
    END prc_ins_evolucao_clinica;

    PROCEDURE prc_ins_solicitacao_exame (
    p_id_solicitacao_exame  IN TB_SOLICITACAO_EXAME.ID_SOLICITACAO_EXAME%TYPE,
    p_obs_solicitacao       IN TB_SOLICITACAO_EXAME.OBS_SOLICITACAO%TYPE,
    p_tb_consulta_id_consulta IN TB_SOLICITACAO_EXAME.TB_CONSULTA_ID_CONSULTA%TYPE
    ) IS
BEGIN
    INSERT INTO TB_SOLICITACAO_EXAME (
        ID_SOLICITACAO_EXAME, OBS_SOLICITACAO, TB_CONSULTA_ID_CONSULTA
    ) VALUES (
        p_id_solicitacao_exame, p_obs_solicitacao, p_tb_consulta_id_consulta
    );
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_SOLICITACAO_EXAME', SQLCODE, 'Registro duplicado: ' || SQLERRM);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_SOLICITACAO_EXAME', SQLCODE, 'FK nao encontrada: ' || SQLERRM);
        RAISE;
    WHEN OTHERS THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_SOLICITACAO_EXAME', SQLCODE, SQLERRM);
        RAISE;
    END prc_ins_solicitacao_exame;

    PROCEDURE prc_ins_solicitacao_exame_item (
    p_id_solicitacao_exame_item     IN TB_SOLICITACAO_EXAME_ITEM.ID_SOLICITACAO_EXAME_ITEM%TYPE,
    p_nm_exame                      IN TB_SOLICITACAO_EXAME_ITEM.NM_EXAME%TYPE,
    p_st_exame                      IN TB_SOLICITACAO_EXAME_ITEM.ST_EXAME%TYPE,
    p_dt_solc_exame                 IN TB_SOLICITACAO_EXAME_ITEM.DT_SOLC_EXAME%TYPE,
    p_dt_res_exame                  IN TB_SOLICITACAO_EXAME_ITEM.DT_RES_EXAME%TYPE,
    p_ds_res_exame                  IN TB_SOLICITACAO_EXAME_ITEM.DS_RES_EXAME%TYPE,
    p_dt_analise                    IN TB_SOLICITACAO_EXAME_ITEM.DT_ANALISE%TYPE,
    p_dt_envio_resultado            IN TB_SOLICITACAO_EXAME_ITEM.DT_ENVIO_RESULTADO%TYPE,
    p_tb_solct_exame_id_solct_exame IN TB_SOLICITACAO_EXAME_ITEM.TB_SOLCT_EXAME_ID_SOLCT_EXAME%TYPE,
    -- Flyway V5 (docs/java-database-alignment.md §2.7) — RN-104: resultado so chega ao
    -- Responsavel apos liberacao explicita do vet (RESULTADO_ENVIADO = liberado, nao "enviado ao vet")
    p_fl_liberado_responsavel       IN TB_SOLICITACAO_EXAME_ITEM.FL_LIBERADO_RESPONSAVEL%TYPE DEFAULT 'N',
    p_dt_liberacao_responsavel      IN TB_SOLICITACAO_EXAME_ITEM.DT_LIBERACAO_RESPONSAVEL%TYPE DEFAULT NULL
    ) IS
BEGIN
    INSERT INTO TB_SOLICITACAO_EXAME_ITEM (
        ID_SOLICITACAO_EXAME_ITEM, NM_EXAME, ST_EXAME, DT_SOLC_EXAME,
        DT_RES_EXAME, DS_RES_EXAME, DT_ANALISE, DT_ENVIO_RESULTADO,
        TB_SOLCT_EXAME_ID_SOLCT_EXAME, FL_LIBERADO_RESPONSAVEL, DT_LIBERACAO_RESPONSAVEL
    ) VALUES (
        p_id_solicitacao_exame_item, p_nm_exame, p_st_exame, p_dt_solc_exame,
        p_dt_res_exame, p_ds_res_exame, p_dt_analise, p_dt_envio_resultado,
        p_tb_solct_exame_id_solct_exame, p_fl_liberado_responsavel, p_dt_liberacao_responsavel
    );
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_SOLICITACAO_EXAME_ITEM', SQLCODE, 'Registro duplicado: ' || SQLERRM);
        RAISE;
    WHEN VALUE_ERROR THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_SOLICITACAO_EXAME_ITEM', SQLCODE, 'Erro de valor/tipo: ' || SQLERRM);
        RAISE;
    WHEN OTHERS THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_SOLICITACAO_EXAME_ITEM', SQLCODE, SQLERRM);
        RAISE;
    END prc_ins_solicitacao_exame_item;

    PROCEDURE prc_ins_anexo_exame (
    p_id_anexo_exame                IN TB_ANEXO_EXAME.ID_ANEXO_EXAME%TYPE,
    p_url_arquivo_anexo             IN TB_ANEXO_EXAME.URL_ARQUIVO_ANEXO%TYPE,
    p_mime_type_anexo               IN TB_ANEXO_EXAME.MIME_TYPE_ANEXO%TYPE,
    p_dt_upload_anexo               IN TB_ANEXO_EXAME.DT_UPLOAD_ANEXO%TYPE,
    p_tb_slc_ex_item_id_slc_ex_item IN TB_ANEXO_EXAME.TB_SLC_EX_ITEM_ID_SLC_EX_ITEM%TYPE
    ) IS
BEGIN
    INSERT INTO TB_ANEXO_EXAME (
        ID_ANEXO_EXAME, URL_ARQUIVO_ANEXO, MIME_TYPE_ANEXO, DT_UPLOAD_ANEXO,
        TB_SLC_EX_ITEM_ID_SLC_EX_ITEM
    ) VALUES (
        p_id_anexo_exame, p_url_arquivo_anexo, p_mime_type_anexo, p_dt_upload_anexo,
        p_tb_slc_ex_item_id_slc_ex_item
    );
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_ANEXO_EXAME', SQLCODE, 'Registro duplicado: ' || SQLERRM);
        RAISE;
    WHEN VALUE_ERROR THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_ANEXO_EXAME', SQLCODE, 'Erro de valor/tipo: ' || SQLERRM);
        RAISE;
    WHEN OTHERS THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_ANEXO_EXAME', SQLCODE, SQLERRM);
        RAISE;
    END prc_ins_anexo_exame;

    PROCEDURE prc_ins_log_acesso_prontuario (
    p_id_log_acesso                 IN TB_LOG_ACESSO_PRONTUARIO.ID_LOG_ACESSO%TYPE,
    p_dt_hr_acesso                  IN TB_LOG_ACESSO_PRONTUARIO.DT_HR_ACESSO%TYPE,
    p_ds_contexto_acesso            IN TB_LOG_ACESSO_PRONTUARIO.DS_CONTEXTO_ACESSO%TYPE,
    p_ds_base_acesso                IN TB_LOG_ACESSO_PRONTUARIO.DS_BASE_ACESSO%TYPE,
    p_tb_animal_id_animal           IN TB_LOG_ACESSO_PRONTUARIO.TB_ANIMAL_ID_ANIMAL%TYPE,
    p_tb_veterinario_id_veterinario IN TB_LOG_ACESSO_PRONTUARIO.TB_VETERINARIO_ID_VETERINARIO%TYPE
    ) IS
BEGIN
    INSERT INTO TB_LOG_ACESSO_PRONTUARIO (
        ID_LOG_ACESSO, DT_HR_ACESSO, DS_CONTEXTO_ACESSO, DS_BASE_ACESSO,
        TB_ANIMAL_ID_ANIMAL, TB_VETERINARIO_ID_VETERINARIO
    ) VALUES (
        p_id_log_acesso, p_dt_hr_acesso, p_ds_contexto_acesso, p_ds_base_acesso,
        p_tb_animal_id_animal, p_tb_veterinario_id_veterinario
    );
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_LOG_ACESSO_PRONTUARIO', SQLCODE, 'Registro duplicado: ' || SQLERRM);
        RAISE;
    WHEN NO_DATA_FOUND THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_LOG_ACESSO_PRONTUARIO', SQLCODE, 'FK nao encontrada: ' || SQLERRM);
        RAISE;
    WHEN OTHERS THEN
        PKG_VETLY_LOG.registrar('PKG_VETLY_CARGA.SP_INS_LOG_ACESSO_PRONTUARIO', SQLCODE, SQLERRM);
        RAISE;
    END prc_ins_log_acesso_prontuario;

END PKG_VETLY_CARGA;
/
