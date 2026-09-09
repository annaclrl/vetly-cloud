package com.vetly.vetly_java.model;

import jakarta.persistence.*;

@Entity
@Table(name = "TB_ESPECIALIDADES_VET",
        uniqueConstraints = @UniqueConstraint(
                name = "TB_ESPCD_VET_NM_ESPCD_UN",
                columnNames = {"NM_ESPECIALIDADE"}
        ))
public class EspecialidadeVet {

    @Id
    @Column(name = "ID_ESPECIALIDADE_VET", length = 36)
    private String id;

    @Column(name = "NM_ESPECIALIDADE", nullable = false, unique = true, length = 50)
    @Enumerated(EnumType.STRING)
    private NomeEspecialidade nome;

    @Column(name = "DS_ESPECIALIDADE", nullable = false, length = 150)
    private String descricao;

    public EspecialidadeVet(String id, NomeEspecialidade nome, String descricao) {
        this.id = id;
        this.nome = nome;
        this.descricao = descricao;
    }

    public EspecialidadeVet() {

    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public NomeEspecialidade getNome() {
        return nome;
    }

    public void setNome(NomeEspecialidade nome) {
        this.nome = nome;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }
}

