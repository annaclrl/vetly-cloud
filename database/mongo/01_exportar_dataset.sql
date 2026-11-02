-- ============================================================================
-- SPRINT 4 - EXPORTA O DATASET RELACIONAL PARA JSON (NDJSON)
--
-- Executar com SQL*Plus ou SQLcl, de dentro da pasta database/mongo:
--
--   export NLS_LANG=.AL32UTF8        (acentos em UTF-8)
--   sqlplus USUARIO/SENHA@//HOST:1521/SERVICO @01_exportar_dataset.sql
--
-- O JSON e montado dentro do banco por PKG_VETLY_JSON.fn_dataset_animais_json e
-- gravado no computador de quem executa (SPOOL do cliente) -- nenhum diretorio do
-- servidor Oracle e necessario, entao funciona igual em qualquer instancia.
--
-- Um documento por linha (NDJSON). Para um unico array JSON, troque 'NDJSON'
-- por 'ARRAY' na consulta e use mongoimport --jsonArray.
-- ============================================================================
SET ECHO OFF FEEDBACK OFF HEADING OFF VERIFY OFF TERMOUT OFF
SET PAGESIZE 0 TRIMSPOOL ON TRIMOUT ON
SET LONG 100000000 LONGCHUNKSIZE 32767 LINESIZE 32767 WRAP ON

SPOOL dataset/animais.ndjson
SELECT PKG_VETLY_JSON.fn_dataset_animais_json('NDJSON') FROM DUAL;
SPOOL OFF

EXIT
