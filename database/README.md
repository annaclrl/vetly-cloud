# Banco de Dados — Sprint 4 (Mastering Relational and Non-Relational Database)

Entrega final de Banco de Dados do Challenge Vetly. Evolui a Sprint 3 (funções, procedures e
trigger soltos, em schema autocontido) para **objetos empacotados no schema real**, consumidos
pelo painel Java deste repositório, e acrescenta a exportação **Oracle → JSON → MongoDB**.

## O que mudou em relação à Sprint 3

| Sprint 3 | Sprint 4 |
|---|---|
| Objetos soltos, em scripts que recriam suas próprias tabelas | **Pacotes PL/SQL** no schema real (o mesmo que o Java usa) |
| Saída por `DBMS_OUTPUT` (só útil no SQL Developer) | `SYS_REFCURSOR` e `CLOB` — qualquer cliente (Java, .NET) consome |
| `TB_AUDITORIA` só no schema de demonstração | `TB_AUDITORIA` e a trigger entregues por **migration Flyway V10** |
| JSON apenas impresso | **Dataset JSON** exportado e **importado no MongoDB** |

## Pacotes e objetos

| Objeto | Conteúdo | Substitui (Sprint 3) |
|---|---|---|
| `PKG_VETLY_LOG` | `registrar` — grava em `TB_LOG_ERRO` em transação autônoma; nunca propaga erro | `SP_REGISTRA_LOG` |
| `PKG_VETLY_VALIDACAO` | `fn_valida_cpf` — dígito verificador módulo 11 | `FN_VALIDA_CPF` |
| `PKG_VETLY_JSON` | `fn_monta_json_animal`, `fn_dataset_animais_json(formato, tutor)` — animal com tutor e consultas embutidos | `FN_MONTA_JSON_ANIMAL`, `PRC_LISTA_ANIMAIS_TUTORES_JSON` |
| `PKG_VETLY_RELATORIO` | `prc_consultas_vet_status(status, OUT cursor)` — detalhe, subtotal por veterinário e total geral (`ROLLUP`) | `PRC_RELATORIO_CONSULTAS_VET_STATUS` |
| `PKG_VETLY_CARGA` | 16 procedures `prc_ins_*` | `SP_INS_*` (de `procedures/procedures_carga.sql`) |
| `TRG_AUD_CONSULTA` | Auditoria DML de `TB_CONSULTA` em `TB_AUDITORIA` (trigger não pode ficar em pacote; delega ao `PKG_VETLY_LOG`) | idem |

Tratamento de exceções: erros de contrato usam `RAISE_APPLICATION_ERROR` com código próprio
(`-20001`, `-20005`, `-20011`, `-20012`, `-20021`, `-20022`); todo bloco `EXCEPTION` registra em
`TB_LOG_ERRO` via `PKG_VETLY_LOG` e re-propaga. A trigger engole a própria falha de log para
nunca bloquear a operação de negócio.

## Integração com o Java (independente de ambiente)

O painel Java → `RelatorioConsultasService` chama `PKG_VETLY_RELATORIO` por
`SimpleJdbcCall`; a tela é `/mvc/relatorios/consultas`. Cada decisão abaixo existe para que o
resultado **não mude conforme onde o Java foi publicado**:

- **O schema viaja com a aplicação.** Os pacotes e a trigger chegam pela migration
  `src/main/resources/db/migration/V10__pacotes_plsql_auditoria.sql` (gerada de `scripts/01..05` por `gerar-migration.sh`). Qualquer ambiente —
  Web App, ACI, máquina local, schema novo ou existente — recebe os objetos quando o Flyway roda.
- **Sem dependência de servidor.** Nada usa `UTL_FILE`, `DIRECTORY`, `DBMS_OUTPUT` nem caminho de
  arquivo no host do Oracle. O JSON volta como `CLOB` e é gravado pelo cliente.
- **Sem dependência de configuração regional.** Números e datas usam máscaras fixas
  (`NLS_NUMERIC_CHARACTERS='.,'`, `YYYY-MM-DD"T"HH24:MI:SS`). Testado com `NLS_LANG` brasileiro
  (decimal = vírgula): o JSON continua com ponto decimal.
- **Conexão só por variável de ambiente** (`SPRING_DATASOURCE_URL/USERNAME/PASSWORD`).
- **Chamada sem leitura do dicionário de dados** (`withoutProcedureColumnMetaDataAccess`): funciona
  com o usuário dono do schema, com sinônimo ou só com `EXECUTE`.
- **MongoDB fora do caminho crítico.** O Java não depende de Mongo; o fluxo Oracle → JSON → Mongo
  é um conjunto de scripts independentes.

## Arquivos

| Pasta/arquivo | Conteúdo |
|---|---|
| `scripts/01..05` | `PKG_VETLY_LOG`, `_VALIDACAO`, `_JSON`, `_RELATORIO`, `TB_AUDITORIA` + trigger |
| `scripts/06_pkg_vetly_carga.sql` | `PKG_VETLY_CARGA` (**gerado** de `procedures/procedures_carga.sql`) |
| `scripts/07_carga_demo.sql` | Carga de 2 tutores, 2 veterinários, 3 animais e 6 consultas **via pacote** |
| `scripts/08_testes_execucao.sql` | 21 verificações `PASSOU/FALHOU` (caminho feliz e exceções) |
| `gerar-migration.sh` | Monta `src/main/resources/db/migration/V10__pacotes_plsql_auditoria.sql` a partir de `scripts/01..05` |
| `DDL.txt` | Schema Oracle consolidado (V1–V8) |
| `modelagem-db/` | Modelo lógico e relacional (Data Modeler + PNG) |
| `blocos-anonimos/`, `relatorios/` | Blocos PL/SQL e relatórios SQL de sprints anteriores (evidência de scripts) |
| `docs/arquitetura-banco.md` | Documento de arquitetura e decisões de modelagem |
| `mongo/01_exportar_dataset.sql` | `SPOOL` do dataset NDJSON (SQL*Plus/SQLcl) |
| `mongo/dataset/animais.ndjson` | Dataset exportado (dados da carga demo) |
| `mongo/02_importar_mongo.js` | Cria a coleção com validador de schema e índices e importa |
| `mongo/03_consultas_demo.js` | Consultas de demonstração com o equivalente relacional |
| `mongo/docker-compose.yml` | MongoDB local para a demonstração |

## Como executar

### 1. Banco relacional

Em schema Oracle com as migrations V1–V9 aplicadas (o Flyway do app aplica V1–V10 sozinho):

```sql
@scripts/01_pkg_vetly_log.sql
@scripts/02_pkg_vetly_validacao.sql
@scripts/03_pkg_vetly_json.sql
@scripts/04_pkg_vetly_relatorio.sql
@scripts/05_trigger_auditoria.sql
@scripts/06_pkg_vetly_carga.sql
@scripts/07_carga_demo.sql
@scripts/08_testes_execucao.sql      -- SET SERVEROUTPUT ON
```

Chamada do relatório de qualquer cliente:

```sql
VAR rc REFCURSOR
EXEC PKG_VETLY_RELATORIO.prc_consultas_vet_status(NULL, :rc)
PRINT rc
```

### 2. Exportar para JSON

```bash
cd mongo
export NLS_LANG=.AL32UTF8
sqlplus USUARIO/SENHA@//HOST:1521/SERVICO @01_exportar_dataset.sql   # gera dataset/animais.ndjson
```

### 3. Importar no MongoDB

```bash
cd mongo
docker compose up -d
mongosh "mongodb://localhost:27017/vetly" --file 02_importar_mongo.js
mongosh "mongodb://localhost:27017/vetly" --file 03_consultas_demo.js
```

Alternativa só com ferramentas de linha de comando: `mongoimport --db vetly --collection animais --file dataset/animais.ndjson`
(as datas ficam como string; o script `.js` as converte para `Date` e aplica validador e índices).

## Modelo no MongoDB

Uma coleção, `animais`, um documento por animal, com **tutor e consultas embutidos**:

```json
{ "_id": "…", "nome": "Thor", "especie": "CAO", "pesoKg": 31.5,
  "tutor": { "idTutor": "…", "nome": "…", "telefone": "…" },
  "consultas": [ { "idConsulta": "…", "dataHora": ISODate, "status": "REALIZADA",
                   "valor": 250, "veterinario": { "idVeterinario": "…", "nome": "…" } } ] }
```

Por que embutir: a ficha do animal sempre é lida com tutor e consultas (no Oracle são 4 `JOIN`s
sobre 6 tabelas), e a lista de consultas de um animal é pequena e limitada — não cresce sem fim.
O que **não** foi embutido de propósito: prontuário e exames (volume e ciclo de vida próprios).

## Como foi validado

Executado em Oracle Free 23ai (container) e MongoDB 7: compilação sem erros, 08_testes_execucao
com todos os casos `PASSOU`, o `TOTAL GERAL` do relatório Oracle (6 consultas / R$ 1.200,00) igual
ao total agregado no Mongo, e o app Java subindo contra um schema **vazio** com o Flyway
aplicando V1–V10 e a tela de relatório respondendo.

## Pendências fora deste diretório

- **Modelagem lógica/física:** reentregar `modelagem-db/` com as correções do professor da Sprint 3
  (o feedback não está no repositório).
- **Vídeo:** execução da procedure pela aplicação, inserção no relacional, exportação JSON e
  importação no Mongo — roteiro em [`../docs/ENTREGA-FINAL-SPRINT4.md`](../docs/ENTREGA-FINAL-SPRINT4.md).
- **Oracle da FIAP:** a V10 ainda não foi aplicada lá; ela roda sozinha no próximo deploy do Java.
