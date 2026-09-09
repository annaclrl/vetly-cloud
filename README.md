# Vetly — Painel Administrativo (Java MVC)

Painel administrativo server-side em **Java 21 + Spring Boot + Thymeleaf** da
plataforma Vetly, um marketplace que conecta tutores a veterinários independentes.
Este serviço é um back-office operado por **ADMIN** (staff), cobrindo a fatia de
domínio **Usuário · Tutor · Veterinário · Animal · Consulta · Prontuário · Exame ·
Espécie · Especialidade**, com login por formulário e telas HTML renderizadas no
servidor — sem API REST.

> **Contexto de projeto.** O Vetly tem dois backends. O `vetly-.net` implementa o
> produto completo (incluindo o app de tutores/veterinários); este repositório é uma
> implementação **paralela e independente** de um subconjunto do domínio — identidade,
> banco e dados próprios, **sem integração** com o `.NET`. As regras de negócio
> seguidas aqui são as **atuais** (RN-001 a RN-107 de `vetly-qa/vetly-tech.md`), não
> as do produto legado.

> **Mudança de arquitetura (2026-09).** Este repositório chegou a expor uma API REST
> completa (JWT, self-service para TUTOR/VETERINARIO) **junto** de um painel MVC
> administrativo bolted-on por cima — duas arquiteturas, dois modelos de segurança,
> Swagger e HATEOAS coexistindo com formulários Thymeleaf. Isso foi resolvido: o
> repositório agora é **só MVC**, um back-office operado por ADMIN. A API REST
> self-service (login de tutor/veterinário, auto-registro, "Colmeia") foi removida —
> ver [Funcionalidade removida](#funcionalidade-removida-colmeia) abaixo.

---

## Índice

- [Escopo do domínio](#escopo-do-domínio)
- [Funcionalidade removida: Colmeia](#funcionalidade-removida-colmeia)
- [Stack tecnológica](#stack-tecnológica)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Regras de negócio implementadas](#regras-de-negócio-implementadas)
- [Modelo de domínio](#modelo-de-domínio)
- [Telas do painel (rotas)](#telas-do-painel-rotas)
- [Segurança e autenticação](#segurança-e-autenticação)
- [Banco de dados e migrations](#banco-de-dados-e-migrations)
- [Como executar](#como-executar)
- [Configuração](#configuração)
- [Roadmap](#roadmap)

---

## Escopo do domínio

| Dentro deste repositório | Somente no `vetly-.net` |
|---|---|
| Cadastro de Tutor, Veterinário e Usuário pelo ADMIN | Auto-registro/login de tutor e veterinário, Empresa/Administrador |
| Animal — CRUD com campos clínicos | Pagamento, split financeiro, fidelidade |
| Consulta — agendamento e máquina de estados | Matching e geolocalização |
| Prontuário — versionamento original × correção | IA na consulta (áudio, sugestões) |
| Exame — solicitação, resultado, anexo, liberação | Internação |
| Espécie / Especialidade — cadastros de apoio | Notificações push, avaliação, avatar |

Decisões de fronteira e a justificativa de cada exclusão estão em
`project-context/docs/java-scope.md`.

---

## Funcionalidade removida: Colmeia

Antes da consolidação em MVC, a API REST expunha a **Colmeia** (RN-064 a RN-068):
concessão automática de acesso ao histórico clínico para o veterinário com vínculo
ativo, escopo por consentimento de rede do tutor, e log de todo acesso — tudo
inerentemente **self-service** (o veterinário ou o tutor autenticado consultando o
próprio histórico). Um painel operado por ADMIN não tem "o veterinário logado" nem
"o tutor logado" como ator, então a feature não tem equivalente MVC possível sem
reintroduzir login de tutor/veterinário — o que contradiria a decisão de ficar só
admin.

`AcessoProntuarioService`, o `ColmeiaController` REST e os DTOs de histórico/log de
acesso foram removidos. As entidades `EvolucaoClinica` e `LogAcessoProntuario`
continuam mapeadas (JPA) e no schema, mas não têm mais controller/service/tela —
ficam disponíveis para quem quiser reintroduzir a feature (por exemplo em
`vetly-.net`, ou nesta base se ela ganhar de volta um login self-service). RN-064,
RN-066, RN-067 e RN-068 estão hoje **sem implementação neste serviço**.

---

## Stack tecnológica

| Camada | Tecnologia |
|--------|-----------|
| Linguagem | Java 21 |
| Framework | Spring Boot 4.0.6 |
| Persistência | Spring Data JPA (Hibernate) |
| Migrations | Flyway (`flyway-core` + `flyway-database-oracle`) |
| Banco de dados | Oracle Database (ojdbc11) |
| Segurança | Spring Security — login por formulário, sessão |
| Web | Spring Web MVC + Thymeleaf |
| Validação | Bean Validation (Jakarta) |
| Build | Gradle |
| Testes | JUnit 5 via Spring Boot Test |

---

## Estrutura do projeto

```
mvc-vetly-java/
├── build.gradle
├── settings.gradle
├── DDL.txt                                  # Schema Oracle completo (espelha vetly-database)
└── src/main/
    ├── java/com/vetly/vetly_java/
    │   ├── VetlyJavaApplication.java
    │   ├── mvc/
    │   │   ├── controller/                   # Único ponto de entrada HTTP — telas do painel
    │   │   ├── form/                         # Records de formulário (bind de @ModelAttribute)
    │   │   └── service/                      # Casos de uso do ADMIN (lista/cria/edita/exclui)
    │   ├── dto/                              # Records reaproveitados pelos services de domínio
    │   ├── mapper/                           # Entidade ↔ DTO
    │   ├── model/                            # Entidades JPA e enums
    │   ├── repository/                       # Spring Data JPA
    │   ├── security/MvcSecurityConfig.java    # Única SecurityFilterChain — login por formulário
    │   ├── service/                          # AuthService (login/registro) + cadastros de apoio
    │   └── validation/                       # @ValueOfEnum
    └── resources/
        ├── application.properties
        ├── templates/                        # Thymeleaf, uma pasta por entidade
        └── db/migration/                     # V1..V8 (Flyway)
```

Duas camadas de serviço coexistem de propósito, não por descuido:

| Camada | Papel | Por quê |
|---|---|---|
| `mvc/service/*AdminService` | Regras do ator ADMIN: lista/cria/edita/exclui **qualquer** registro, sem escopo de dono | É o que o painel back-office precisa — um humano de staff gerindo a base toda |
| `service/AuthService`, `EspecieService`, `EspecialidadeVetService` | Autenticação (`UserDetailsService` do login) e cadastros de apoio simples | Reaproveitados como estão pelos controllers MVC — não há necessidade de um "AdminService" para uma tabela de 2 campos |

Os services de domínio que existiam só para a API REST self-service (`AnimalService`,
`ConsultaService`, `TutorService`, `VeterinarioService`, `UsuarioService`,
`AcessoProntuarioService`, `ProntuarioService`, `SolicitacaoExameService`) foram
removidos — cada um assumia "o tutor/veterinário autenticado" como ator
(`SecurityContextHolder` → `currentTutor()`), o que não existe mais neste app.

---

## Regras de negócio implementadas

Numeração conforme `vetly-qa/vetly-tech.md` — **única fonte de verdade**. A tabela abaixo
lista o que está de fato implementado neste serviço e onde verificar.

| RN | Regra | Como está implementada | Onde |
|----|-------|------------------------|------|
| **RN-003** | Consulta atribuída ao profissional escolhido | O formulário informa `veterinarioId` no agendamento; não há clínica designando (Empresa está fora de escopo) | `ConsultaMvcController` → `ConsultaAdminService.criar` |
| **RN-008** | Consulta encerra por ação do vet | Só transição a partir de `AGENDADA`; sem IA acoplada, isso apenas fecha o registro | `ConsultaAdminService.transicionar` |
| **RN-012** | Responsável cancela ou remarca | Ambas as ações disponíveis na tela de detalhe da consulta | `ConsultaAdminService.reagendar` / `.transicionar` |
| **RN-038** | Estados da consulta | `AGENDADA → REALIZADA \| CANCELADA \| NAO_COMPARECEU`; toda transição parte de `AGENDADA`, o resto rejeita com erro | `ConsultaAdminService.transicionar` |
| **RN-060** | Consentimento LGPD registrado | Aceite com carimbo de data no momento em que passa a `true` | `TutorMvcController` → `TutorAdminService.atualizar` |
| **RN-062** | Revogação, com registro | `consentimentoRede=false` limpa a data, sem apagar registro clínico já produzido | `TutorAdminService.atualizar` |
| **RN-063** | Prontuário pertence ao animal | Rota é `/mvc/animais/{animalId}/prontuario`; nenhum vet "possui" o prontuário | `ProntuarioMvcController` |
| **RN-081** | Peso obrigatório | `peso` é `@NotNull` e maior que zero no formulário de animal | `AnimalForm` |
| **RN-088** | Correção vinculada ao original | A correção cria **nova linha** apontando para a original, com data, hora e justificativa; o original nunca é sobrescrito | `ProntuarioAdminService.corrigir` |
| **RN-089** | Correção fora de 24h exige justificativa | Passada a janela, `justificativa` em branco é rejeitada | `ProntuarioAdminService.corrigir` |
| **RN-103** | Exame solicitado na plataforma | Cria uma solicitação com N itens, vinculada à consulta e, por ela, ao animal | `SolicitacaoExameAdminService.criar` |
| **RN-104** | Resultado só chega ao Responsável após liberação | Registrar o laudo (`ANALISADO`) não libera nada; só a ação "liberar" torna o resultado visível | `SolicitacaoExameAdminService.liberarParaResponsavel` |

RN-064, RN-066, RN-067, RN-068 (Colmeia) não têm implementação neste serviço — ver
[Funcionalidade removida](#funcionalidade-removida-colmeia).

### Adaptações e exclusões conscientes

| RN | Situação neste serviço |
|----|------------------------|
| RN-013 (pagamento transferido na remarcação) | **Não se aplica** — não há Pagamento no Java; remarcar só troca a data |
| RN-035 (`EM_CHECKOUT`) | **Removido do ciclo** — o estado existe por causa do lock de pagamento |
| RN-041 a RN-045 (cancelamento com reembolso) | **Fora de escopo** — pressupõem Pagamento |
| RN-046 (obrigações do pet) | **Fora do v1** — é consumida por Fidelidade/Avatar/Notificações, que são `.NET` |
| RN-061 (consentimento granular por finalidade) | **Versão mínima** — dois flags (LGPD e rede) em vez das cinco finalidades |
| RN-064/065/066/067/068 (Colmeia) | **Removidas com a API REST self-service** — ver seção dedicada acima |
| RN-078 a RN-085 (IA na consulta) | **Somente `.NET`** |
| RN-100 a RN-102 (internação) | **Somente `.NET`** |
| RN-107 (validação de CRMV) | **Não implementada** — só é relevante com matching/diretório público de vets |

### Decisão de implementação registrada

`StatusExame.RESULTADO_ENVIADO` significa **liberado ao Responsável**, não "enviado ao
veterinário". A ambiguidade estava aberta em `docs/java-database-alignment.md` §2.7 e foi
resolvida assim porque é a leitura que corresponde a RN-104: o marco que importa é a
divulgação ao tutor.

---

## Modelo de domínio

### Entidades

#### `Usuario`
Conta de acesso; implementa `UserDetails`. Só `ADMIN` autentica no painel — `TUTOR` e
`VETERINARIO` existem como dados de cadastro geridos pelo ADMIN, sem login próprio.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id` | String (UUID) | Identificador |
| `email` | String | E-mail único de login |
| `role` | UserRole | `ADMIN`, `TUTOR` ou `VETERINARIO` |
| `flagAtivo` | String (`S`/`N`) | Conta ativa |
| `senhaHash` | String | BCrypt |

#### `Pessoa`
Dados pessoais compartilhados por Veterinário e Tutor — `nome`, `cpf`, `telefone`
(CPF+telefone únicos em conjunto).

#### `Tutor`
Dono do animal. Além do vínculo com `Usuario` e `Pessoa`, carrega o consentimento:

| Campo | Tipo | RN |
|-------|------|----|
| `lgpdAceito` / `dataLgpdAceito` | `S`/`N` + LocalDate | RN-060 |
| `consentimentoRede` / `dataConsentimentoRede` | `S`/`N` + LocalDate | RN-062 |

#### `Veterinario`
`crmv` único, `usuario`, `pessoa`, mais as listas `especialidades` e `especies`.

#### `Animal`
Pertence a um `Tutor` e a uma `Especie`.

| Campo | Tipo | Observação |
|-------|------|-----------|
| `id` | UUID | |
| `nome`, `raca` | String (80) | |
| `sexo` | Sexo | `M` / `F` |
| `dataNascimento` | LocalDate | Não pode ser futura |
| `peso` | BigDecimal | **Obrigatório** (RN-081) |
| `urlFoto` | String (500) | |
| `castrado` | `S`/`N` | |
| `condicoesPreexistentes`, `alergias`, `medicacoesEmUso` | String (1000) | |

#### `Consulta`
`dataHora`, `status` (`StatusConsulta`), `valor`, `observacao`, `veterinario`, `animal`.

#### `Prontuario`
Uma linha por versão do prontuário do animal.

| Campo | Descrição |
|-------|-----------|
| `conteudoClinico` | Texto clínico da versão |
| `dataUltimaAtualizacao` | Data da versão |
| `original` | Auto-FK: `null` na original, aponta para ela em cada correção (RN-088) |
| `dataHoraCorrecao`, `crmvSolicitanteCorrecao` | Carimbo da correção (RN-088) |
| `justificativaCorrecao` | Preenchida só fora da janela de 24h (RN-089) |

#### `EvolucaoClinica` / `LogAcessoProntuario`
Mapeadas (JPA) e no schema, mas sem controller/service/tela — ver
[Funcionalidade removida](#funcionalidade-removida-colmeia).

#### `SolicitacaoExame` / `SolicitacaoExameItem` / `AnexoExame`
Uma solicitação por consulta, N itens por solicitação, N anexos por item.
O item guarda `status`, `descricaoResultado`, `liberadoResponsavel` e
`dataLiberacaoResponsavel` (RN-104).

#### `LogErro`
Registro de erros de execução para auditoria.

### Enums

| Enum | Valores |
|------|---------|
| `UserRole` | `ADMIN`, `TUTOR`, `VETERINARIO` |
| `Sexo` | `M`, `F` |
| `StatusConsulta` | `AGENDADA`, `REALIZADA`, `CANCELADA`, `NAO_COMPARECEU` |
| `StatusExame` | `SOLICITADO`, `AGUARDANDO_RESULTADO`, `ANALISADO`, `RESULTADO_ENVIADO`, `CANCELADO` |
| `BaseAcesso` | `CONSENTIMENTO_REDE`, `ATENDIMENTO_DIRETO` |
| `NomeEspecie` | `AVE`, `REPTIL`, `MAMIFERO`, `ANFIBIO`, `PEIXE`, `EQUIDEO`, `CAO`, `GATO` |
| `NomeEspecialidade` | 21 especialidades (`ACUPUNTURA` … `RADIOLOGIA`) |

### Máquina de estados

```
Consulta (RN-038)                    Item de exame (RN-103/104)

        AGENDADA                          SOLICITADO
       /    |    \                            |  registrar resultado
      /     |     \                           v
CANCELADA REALIZADA NAO_COMPARECEU        ANALISADO
                                              |  liberar
                                              v
                                      RESULTADO_ENVIADO   # = liberado ao tutor
```

Qualquer transição que não parta do estado de origem é rejeitada.

---

## Telas do painel (rotas)

Tudo sob `/mvc/**`, protegido por login (só `ADMIN`):

| Prefixo | Controller | Telas |
|---|---|---|
| `/mvc/login` | `AuthViewController` | Login |
| `/mvc/` | `DashboardController` | Painel inicial |
| `/mvc/usuarios` | `UsuarioMvcController` | Listar, ativar/desativar |
| `/mvc/tutores` | `TutorMvcController` | Listar, cadastrar (cria `Usuario`+`Pessoa`+`Tutor`), detalhar (com animais), editar (consentimento), excluir |
| `/mvc/veterinarios` | `VeterinarioMvcController` | Listar, cadastrar (com especialidades/espécies), detalhar, editar, excluir |
| `/mvc/animais` | `AnimalMvcController` | Listar, cadastrar, detalhar, editar, excluir |
| `/mvc/animais/{id}/prontuario` | `ProntuarioMvcController` | Ver histórico de versões, criar, corrigir |
| `/mvc/consultas` | `ConsultaMvcController` | Listar, agendar, detalhar, reagendar, mudar status |
| `/mvc/exames` | `SolicitacaoExameMvcController` | Listar, criar solicitação, registrar resultado, liberar, cancelar |
| `/mvc/especies` | `EspecieMvcController` | Listar, cadastrar, editar, excluir |
| `/mvc/especialidades` | `EspecialidadeVetMvcController` | Listar, cadastrar, editar, excluir |

---

## Segurança e autenticação

Login por formulário e sessão com Spring Security — uma única `SecurityFilterChain`
(`MvcSecurityConfig`):

- `/mvc/login` é público; **toda** outra rota exige `ROLE_ADMIN`
- Senhas em **BCrypt**
- `AuthService` é o `UserDetailsService` do login (`loadUserByUsername`) e também quem
  registra `Tutor`/`Veterinario` a partir do formulário do ADMIN
  (`registerTutor`/`registerVeterinario`) — sem essas contas terem acesso ao painel

Não há mais camada JWT/stateless: como o único ator é o ADMIN operando o back-office,
sessão de servidor é suficiente e mais simples que manter dois modelos de autenticação
em paralelo.

---

## Banco de dados e migrations

O schema é versionado com **Flyway** em `src/main/resources/db/migration/`.

| Migration | O que faz | RN |
|-----------|-----------|----|
| `V1__baseline_schema` | Baseline espelhando o `DDL.txt` anterior ao Flyway | — |
| `V2__animal_campos_clinicos` | `URL_FOTO_ANIMAL`, `FL_CASTRADO`, `DS_CONDICOES_PREEXIST`, `DS_ALERGIAS`, `DS_MEDICACOES_EM_USO` | RN-081 |
| `V3__evolucao_clinica_flags_rn068` | `FL_OCULTO_RESPONSAVEL`, `FL_ALERTA_SEGURANCA` | RN-068 |
| `V4__consulta_status_nao_compareceu` | Inclui `NAO_COMPARECEU` no CHECK de status | RN-038 |
| `V5__solicitacao_exame_item_liberacao_rn104` | `FL_LIBERADO_RESPONSAVEL`, `DT_LIBERACAO_RESPONSAVEL` | RN-104 |
| `V6__tutor_consentimento_lgpd_rede` | `FL_LGPD_ACEITO`, `DT_LGPD_ACEITO`, `FL_CONSENTIMENTO_REDE`, `DT_CONSENTIMENTO_REDE` | RN-060/062 |
| `V7__log_acesso_prontuario_rn067` | Tabela `TB_LOG_ACESSO_PRONTUARIO` | RN-067 (tabela mantida, sem uso hoje) |
| `V8__prontuario_versionamento_rn088_089` | `DS_CONTEUDO_CLINICO`, auto-FK `TB_PRONTUARIO_ID_ORIGINAL`, `DT_HR_CORRECAO`, `CRMV_SOLICITANTE_CORRECAO`, `DS_JUSTIFICATIVA_CORRECAO` | RN-088/089 |

Regras de manutenção:

- `spring.jpa.hibernate.ddl-auto=validate` — o Hibernate **nunca** gera DDL; Flyway é a
  única fonte de verdade do schema.
- `baseline-on-migrate=true` porque o schema da FIAP já existia criado à mão: a migration
  `V1` não é reexecutada nesse ambiente, mas roda normalmente em um schema vazio.
- Ao criar uma migration nova, replique o mesmo DDL no fim de `vetly-database/DDL.txt`.
- **Nunca edite uma migration já aplicada.** O checksum do Flyway cobre o arquivo inteiro,
  comentários inclusive, então qualquer alteração derruba o start com *checksum mismatch*.

---

## Como executar

### Pré-requisitos

- Java 21+
- Instância Oracle acessível (o wrapper `./gradlew` dispensa instalar o Gradle)

```bash
git clone https://github.com/challenge-vetly/vetly-java.git
cd mvc-vetly-java

./gradlew build        # compila e roda os testes
./gradlew bootRun      # sobe em http://localhost:8080/mvc/login
./gradlew test         # só os testes
```

Na subida, o Flyway aplica as migrations pendentes e o Hibernate valida o mapeamento
contra o schema — divergência entre entidade e tabela derruba a aplicação no start,
de propósito.

### Primeiro acesso

Não existe auto-registro nem tela de "criar admin" — só `ADMIN` loga no painel, e o
cadastro de Tutor/Veterinário é feito pelo próprio ADMIN já logado. Para resolver o
"ovo e a galinha", `AdminBootstrap` cria um `ADMIN` no startup **se nenhum existir
ainda**, usando `vetly.admin.bootstrap.email`/`vetly.admin.bootstrap.senha` de
`application.properties`. Rode uma vez, logue em `/mvc/login`, e depois pode remover
essas duas linhas — o bootstrap não faz nada assim que já existe um ADMIN.

---

## Configuração

`src/main/resources/application.properties`:

```properties
spring.application.name=vetly-java

# Oracle
spring.datasource.url=jdbc:oracle:thin:@//localhost:1521/orcl
spring.datasource.username=seu_usuario
spring.datasource.password=sua_senha
spring.datasource.driver-class-name=oracle.jdbc.OracleDriver

# Flyway é dono do schema; Hibernate apenas valida
spring.flyway.enabled=true
spring.flyway.baseline-on-migrate=true
spring.flyway.baseline-version=1
spring.jpa.hibernate.ddl-auto=validate

# 404 em rota inexistente em vez de página de erro estática
spring.mvc.throw-exception-if-no-handler-found=true
spring.web.resources.add-mappings=false

# Primeiro ADMIN — só roda enquanto nenhum ADMIN existir, ver "Primeiro acesso"
vetly.admin.bootstrap.email=admin@vetly.com.br
vetly.admin.bootstrap.senha=Admin@123
```

> ⚠️ O arquivo versionado hoje contém credenciais reais do ambiente da FIAP. Antes de
> qualquer uso fora da disciplina, mova-as para variáveis de ambiente
> (`SPRING_DATASOURCE_PASSWORD`) e não comite segredo.

---

## Roadmap

### Pendências conhecidas

- [ ] `TB_CONSULTA` — avaliar tornar `TB_VETERINARIO_ID_VETERINARIO` e `TB_ANIMAL_ID_ANIMAL`
      `NOT NULL` (checar dado existente antes)
- [ ] Credenciais fora do `application.properties`
- [ ] Testes automatizados dos serviços do painel (hoje só existe o smoke test de contexto)

### Backlog de escopo (decidir antes de implementar)

- [ ] Reintroduzir a Colmeia exigiria um login self-service (tutor/veterinário) separado
      do login `ADMIN` do painel — decisão de produto antes de reimplementar RN-064/066/067/068
- [ ] `Empresa`/`Administrador` entram no domínio do Java, ou ele fica só para vet autônomo?
- [ ] Validação de CRMV (RN-107) — só relevante se o Java expuser diretório/matching de vets
- [ ] Documentos além do prontuário (atestado, receita, NF) — depende de RN-087 (assinatura)
      e de uma decisão sobre split financeiro
- [ ] LGPD granular por finalidade (RN-061) em vez do aceite simplificado atual
- [ ] `Disponibilidade` — grade horária do veterinário e resolução de conflitos de agenda
