-- docs/java-database-alignment.md §2.1 — campos clinicos do Animal citados em vetly-tech.md
-- (foto, castrado, condicoes pre-existentes, alergias, medicacoes em uso), ausentes do DDL original.

ALTER TABLE TB_ANIMAL ADD (
    URL_FOTO_ANIMAL         VARCHAR2(500 CHAR),
    FL_CASTRADO             CHAR(1) DEFAULT 'N' NOT NULL,
    DS_CONDICOES_PREEXIST   VARCHAR2(1000 CHAR),
    DS_ALERGIAS             VARCHAR2(1000 CHAR),
    DS_MEDICACOES_EM_USO    VARCHAR2(1000 CHAR)
);

ALTER TABLE TB_ANIMAL ADD CONSTRAINT CK_FL_CASTRADO CHECK (FL_CASTRADO IN ('S','N'));
