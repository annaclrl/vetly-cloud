package com.vetly.vetly_java.model;

import jakarta.persistence.*;

import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "TB_CONSULTA")
public class Consulta {
    @Id
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "ID_CONSULTA")
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "DT_HR_CONSULTA", nullable = false)
    private LocalDateTime dataHora;

    @Column(name = "ST_CONSULTA", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private StatusConsulta status;

    @Column(name = "VL_CONSULTA", nullable = false, precision = 10, scale = 2)
    private BigDecimal valor;

    @Column(name = "OBS_CONSULTA", length = 500)
    private String observacao;

    @ManyToOne
    @JoinColumn(name = "TB_VETERINARIO_ID_VETERINARIO")
    private Veterinario veterinario;

    @ManyToOne
    @JoinColumn(name = "TB_ANIMAL_ID_ANIMAL")
    private Animal animal;

    public Consulta() {
    }

    public Consulta(UUID id, LocalDateTime dataHora, StatusConsulta status, BigDecimal valor, String observacao, Veterinario veterinario, Animal animal) {
        this.id = id;
        this.dataHora = dataHora;
        this.status = status;
        this.valor = valor;
        this.observacao = observacao;
        this.veterinario = veterinario;
        this.animal = animal;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public LocalDateTime getDataHora() {
        return dataHora;
    }

    public void setDataHora(LocalDateTime dataHora) {
        this.dataHora = dataHora;
    }

    public StatusConsulta getStatus() {
        return status;
    }

    public void setStatus(StatusConsulta status) {
        this.status = status;
    }

    public BigDecimal getValor() {
        return valor;
    }

    public void setValor(BigDecimal valor) {
        this.valor = valor;
    }

    public String getObservacao() {
        return observacao;
    }

    public void setObservacao(String observacao) {
        this.observacao = observacao;
    }

    public Veterinario getVeterinario() {
        return veterinario;
    }

    public void setVeterinario(Veterinario veterinario) {
        this.veterinario = veterinario;
    }

    public Animal getAnimal() {
        return animal;
    }

    public void setAnimal(Animal animal) {
        this.animal = animal;
    }
}