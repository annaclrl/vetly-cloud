package com.vetly.vetly_java.model;

import jakarta.persistence.*;

@Entity
@Table(
        name = "TB_VETERINARIO_ESPECIE",
        uniqueConstraints = @UniqueConstraint(
                name = "TB_VETERINARIO_ESPECIE_UN",
                columnNames = {"TB_VETERINARIO_ID_VETERINARIO", "TB_ESPECIE_ID_ESPECIE"}
        )
)
public class VeterinarioEspecie {

    @Id
    @Column(name = "ID_VETERINARIO_ESPECIE")
    private String id;

    @ManyToOne
    @JoinColumn(name = "TB_VETERINARIO_ID_VETERINARIO", nullable = false)
    private Veterinario veterinario;

    @ManyToOne
    @JoinColumn(name = "TB_ESPECIE_ID_ESPECIE", nullable = false)
    private Especie especie;

    public VeterinarioEspecie(String id, Veterinario veterinario, Especie especie) {
        this.id = id;
        this.veterinario = veterinario;
        this.especie = especie;
    }

    public VeterinarioEspecie() {

    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Veterinario getVeterinario() {
        return veterinario;
    }

    public void setVeterinario(Veterinario veterinario) {
        this.veterinario = veterinario;
    }

    public Especie getEspecie() {
        return especie;
    }

    public void setEspecie(Especie especie) {
        this.especie = especie;
    }
}
