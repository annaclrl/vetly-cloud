package com.vetly.vetly_java.model;

import jakarta.persistence.*;

import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "TB_LOG_ACESSO_PRONTUARIO")
public class LogAcessoProntuario {

    @Id
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "ID_LOG_ACESSO")
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "DT_HR_ACESSO", nullable = false)
    private LocalDateTime dataHoraAcesso;

    @Column(name = "DS_CONTEXTO_ACESSO", length = 200)
    private String contextoAcesso;

    @Column(name = "DS_BASE_ACESSO", nullable = false, length = 30)
    @Enumerated(EnumType.STRING)
    private BaseAcesso baseAcesso;

    @ManyToOne
    @JoinColumn(name = "TB_ANIMAL_ID_ANIMAL", nullable = false)
    private Animal animal;

    @ManyToOne
    @JoinColumn(name = "TB_VETERINARIO_ID_VETERINARIO", nullable = false)
    private Veterinario veterinario;

    public LogAcessoProntuario() {
    }

    public LogAcessoProntuario(UUID id, LocalDateTime dataHoraAcesso, String contextoAcesso, BaseAcesso baseAcesso,
                               Animal animal, Veterinario veterinario) {
        this.id = id;
        this.dataHoraAcesso = dataHoraAcesso;
        this.contextoAcesso = contextoAcesso;
        this.baseAcesso = baseAcesso;
        this.animal = animal;
        this.veterinario = veterinario;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public LocalDateTime getDataHoraAcesso() {
        return dataHoraAcesso;
    }

    public void setDataHoraAcesso(LocalDateTime dataHoraAcesso) {
        this.dataHoraAcesso = dataHoraAcesso;
    }

    public String getContextoAcesso() {
        return contextoAcesso;
    }

    public void setContextoAcesso(String contextoAcesso) {
        this.contextoAcesso = contextoAcesso;
    }

    public BaseAcesso getBaseAcesso() {
        return baseAcesso;
    }

    public void setBaseAcesso(BaseAcesso baseAcesso) {
        this.baseAcesso = baseAcesso;
    }

    public Animal getAnimal() {
        return animal;
    }

    public void setAnimal(Animal animal) {
        this.animal = animal;
    }

    public Veterinario getVeterinario() {
        return veterinario;
    }

    public void setVeterinario(Veterinario veterinario) {
        this.veterinario = veterinario;
    }
}
