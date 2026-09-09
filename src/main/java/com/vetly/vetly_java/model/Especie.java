package com.vetly.vetly_java.model;

import jakarta.persistence.*;

@Entity
@Table(name = "TB_ESPECIE",
        uniqueConstraints = @UniqueConstraint(
                name = "TB_ESPECIE_NM_ESPECIE_UN",
                columnNames = {"NM_ESPECIE"}
        ))
public class Especie {

    @Id
    @Column(name = "ID_ESPECIE", length = 36)
    private String id;

    @Column(name = "NM_ESPECIE", nullable = false, unique = true, length = 50)
    @Enumerated(EnumType.STRING)
    private NomeEspecie nome;

    public Especie(String id, NomeEspecie nome) {
        this.id = id;
        this.nome = nome;
    }

    public Especie() {

    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public NomeEspecie getNome() {
        return nome;
    }

    public void setNome(NomeEspecie nome) {
        this.nome = nome;
    }
}