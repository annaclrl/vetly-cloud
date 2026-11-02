# Documentação de Arquitetura — Projeto Vetly (Parceria Clyvo Vet)

## Visão Geral do Projeto

O projeto Vetly foi desenvolvido como uma solução acadêmica voltada para clínicas veterinárias, com foco principal em melhorar a experiência tanto dos médicos veterinários quanto dos tutores durante toda a jornada clínica.

A proposta da plataforma consiste em reduzir a fricção operacional existente antes, durante e após as consultas veterinárias, aumentando a eficiência do atendimento, a qualidade do acompanhamento clínico e a fidelização dos clientes.

A estratégia de negócio do projeto está baseada em três pilares principais:

* Redução da carga operacional do veterinário;
* Melhoria da experiência do tutor;
* Aumento da recorrência de consultas e, consequentemente, da receita da empresa.

O sistema foi concebido desde o início pensando em escalabilidade, segurança e evolução contínua da plataforma.

---

# Objetivos da Plataforma

## Objetivos para o Médico Veterinário

A solução busca facilitar o fluxo clínico do veterinário através de:

* Centralização das informações clínicas;
* Histórico completo do animal;
* Solicitação digital de exames;
* Organização do prontuário;
* Redução de retrabalho operacional;
* Analise automatica do prontuario do animal com uso de IA.

---

## Objetivos para o Tutor

A plataforma busca melhorar a experiência do tutor através de:

* Acompanhamento do histórico clínico do animal;
* Upload digital de resultados de exames;
* Facilidade de comunicação com a clínica;
* Interface acessível e intuitiva;
* Maior transparência durante o tratamento.

---

# Arquitetura Tecnológica

## Backend

O backend está sendo desenvolvido utilizando:

* Java
* Spring Boot
* Spring Security
* JPA/Hibernate
* Oracle Database

A escolha do ecossistema Spring foi realizada devido à robustez, maturidade e capacidade de escalabilidade da plataforma.

O Spring Boot fornece:

* Estrutura modular;
* Facilidade de manutenção;
* Facilidade de integração;
* Suporte nativo a autenticação e autorização;
* Padronização arquitetural.

---

## Frontend

O frontend está sendo desenvolvido em React Native.

A escolha do React Native foi motivada por:

* Desenvolvimento multiplataforma;
* Boa experiência mobile;
* Alta produtividade;
* Grande ecossistema;
* Facilidade de evolução futura.

A interface foi projetada com foco em:

* Clareza visual;
* Navegação simples;
* Acessibilidade;
* Baixa fricção operacional;
* Experiência intuitiva para tutores e veterinários.

---

# Arquitetura de Segurança

## Tabela de Usuários

Uma das principais decisões arquiteturais do projeto foi a criação da entidade `TB_USUARIO`.

Essa decisão foi tomada para desacoplar os dados de autenticação dos dados pessoais do sistema.

A tabela de usuários é responsável por:

* Controle de autenticação;
* Armazenamento de senha hash;
* Gerenciamento de roles;
* Controle de ativação de contas;
* Segurança de acesso.

---

## Controle de Roles

O sistema possui diferentes perfis de acesso:

* ADMIN
* VETERINARIO
* TUTOR

As permissões são validadas em duas camadas:

### Backend

Através do Spring Security.

### Banco de Dados

Através de constraints e regras estruturais.

Essa abordagem aumenta:

* Segurança;
* Integridade;
* Controle de acesso;
* Robustez do sistema.

---

# Modelagem de Banco de Dados

## Filosofia da Modelagem

O banco de dados foi modelado com foco em:

* Normalização;
* Escalabilidade;
* Integridade relacional;
* Redução de redundância;
* Evolução futura.

A modelagem foi estruturada focando na Terceira Forma Normal (3FN), buscando evitar:

* Dependências transitivas;
* Redundância de dados;
* Anomalias de atualização;
* Dados derivados armazenados desnecessariamente.

---

# Estrutura Clínica

## Animal e Prontuário

Cada animal possui um prontuário único.

O prontuário foi modelado como o agregador principal do histórico clínico do animal.

O relacionamento principal ocorre da seguinte forma:

```text
PRONTUARIO
   -> ANIMAL
       -> CONSULTAS
            -> EVOLUCOES
            -> SOLICITACOES_EXAME
                 -> ITENS_EXAME
                      -> ANEXOS
```

Essa abordagem evita redundância e permite que o prontuário centralize o histórico completo de forma indireta.

---

# Consultas e Evolução Clínica

## Evolução Clínica

A entidade de evolução clínica foi modelada inicialmente com relacionamento 1:1 com consulta.

Essa decisão foi tomada considerando o escopo do MVP.

Atualmente:

```text
CONSULTA 1:1 EVOLUCAO_CLINICA
```

No entanto, a arquitetura permite evolução futura simples para:

```text
CONSULTA 1:N EVOLUCAO_CLINICA
```

caso seja necessário registrar múltiplas evoluções clínicas por consulta.

---

# Sistema de Exames

## Motivação Arquitetural

Os exames não são realizados diretamente pela plataforma.

A solução foi modelada para representar:

* Solicitação de exames;
* Upload de resultados externos;
* Acompanhamento clínico;
* Histórico médico.

---

## Estrutura da Solicitação de Exames

O sistema foi dividido em:

### TB_SOLICITACAO_EXAME

Representa o cabeçalho da solicitação.

Cada consulta gera uma única solicitação de exames.

```text
CONSULTA 1:1 SOLICITACAO_EXAME
```

---

### TB_SOLICITACAO_EXAME_ITEM

Representa cada exame individual solicitado.

Exemplo:

* Hemograma;
* Ultrassom;
* Raio-X;
* Exames laboratoriais.

Relacionamento:

```text
SOLICITACAO_EXAME 1:N SOLICITACAO_EXAME_ITEM
```

Essa separação permite:

* Controle individual de status;
* Controle de datas;
* Controle de resultados;
* Upload individual de anexos;
* Escalabilidade futura.

---

# Upload de Resultados de Exames

## TB_ANEXO_EXAME

Os anexos de exames foram separados em uma entidade própria.

Essa decisão foi tomada para permitir:

* Múltiplos arquivos por exame;
* PDFs;
* Imagens;
* Laudos laboratoriais;
* Escalabilidade futura.

Relacionamento:

```text
SOLICITACAO_EXAME_ITEM 1:N ANEXO_EXAME
```

O tutor é responsável pelo upload dos resultados diretamente na plataforma.

Essa funcionalidade reduz fricção operacional e melhora a comunicação clínica.

---

# Robustez Arquitetural

## Desacoplamento de Responsabilidades

O sistema foi modelado utilizando separação clara de responsabilidades.

Exemplos:

* Usuário ≠ Pessoa;
* Consulta ≠ Evolução;
* Solicitação ≠ Item de exame;
* Item de exame ≠ Anexo.

Essa abordagem reduz acoplamento e facilita:

* manutenção;
* testes;
* evolução futura;
* escalabilidade.

---

# Escalabilidade do Projeto

A arquitetura foi projetada para permitir evolução gradual sem necessidade de refatorações estruturais severas.

---

# Roadmap de Evolução

## 1. IA para Geração de Evolução Clínica

Um dos principais objetivos futuros da plataforma é integrar IA ao fluxo clínico.

A ideia consiste em:

* analisar dados da consulta;
* sugerir evolução clínica;
* reduzir tempo de preenchimento;
* auxiliar o veterinário.

---

## Estrutura Prevista

Será necessária uma entidade específica para armazenar análises geradas por IA.

Exemplo conceitual:

```text
TB_ANALISE_IA
```

Possíveis campos:

* Prompt utilizado;
* Resposta gerada;
* Data da análise;
* Veterinário responsável;
* Consulta relacionada;
* Status de aprovação.

---

# 2. Sistema de Receitas Médicas

O roadmap inclui implementação de receitas veterinárias digitais.

Arquitetura prevista:

```text
CONSULTA 1:1 RECEITA
RECEITA 1:N RECEITA_ITEM
```

Essa estrutura permitirá:

* Prescrição digital;
* Histórico medicamentoso;
* Controle terapêutico;
* Evolução futura para integração comercial.

---

# 3. Integração com Farmácias Parceiras

O sistema deverá futuramente sugerir farmácias veterinárias parceiras próximas ao tutor.

Para isso, novas entidades poderão ser adicionadas:

* TB_ENDERECO;
* TB_FARMACIA_VETERINARIA;
* TB_PARCEIRO_COMERCIAL.

---

# Estrutura de Endereços

A arquitetura prevê futura normalização de endereços para:

* tutores;
* veterinários;
* clínicas;
* farmácias parceiras.

A modelagem futura poderá utilizar:

```text
TB_ENDERECO
```

centralizando:

* CEP;
* cidade;
* estado;
* latitude;
* longitude;
* logradouro.

Essa abordagem facilitará:

* geolocalização;
* integração com mapas;
* busca por parceiros próximos;
* expansão da plataforma.

---

# Decisões de Escalabilidade

Durante o desenvolvimento, diversas decisões foram tomadas pensando em médio e longo prazo.

## Principais decisões:

### Separação entre autenticação e dados pessoais;

### Estrutura modular de exames;

### Uso de tabelas associativas;

### Modelagem próxima da 3FN;

### Separação de anexos;

### Preparação para IA;

### Preparação para integrações futuras.

---

# Benefícios Esperados para a Clyvo Vet

A solução busca gerar impacto operacional e comercial.

## Benefícios operacionais

* Menor tempo gasto em tarefas administrativas;
* Melhor organização dos veterinarios;
* Histórico centralizado;
* Maior controle dos exames;
* Facilidade de acompanhamento.

---

## Benefícios para os tutores

* Melhor experiência digital;
* Transparência clínica;
* Facilidade de acesso ao histórico;
* Upload simples de exames;
* Maior proximidade com a clínica.

---

## Benefícios comerciais

A estratégia da plataforma busca:

* aumentar fidelização;
* aumentar recorrência;
* melhorar retenção;
* aumentar frequência de consultas;
* aumentar receita da empresa.

---

# Considerações Finais

O projeto foi desenvolvido buscando equilíbrio entre:

* simplicidade para o MVP;
* robustez arquitetural;
* escalabilidade futura.

A arquitetura atual já permite evolução consistente para funcionalidades avançadas sem necessidade de reconstrução estrutural do sistema.

O modelo foi pensado não apenas como um sistema acadêmico, mas como uma base sólida para uma futura plataforma veterinária escalável, segura e preparada para integrações inteligentes.
