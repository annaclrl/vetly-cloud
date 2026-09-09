package com.vetly.vetly_java.model;

import jakarta.persistence.*;

import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "TB_PRONTUARIO")
public class Prontuario {

    @Id
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "ID_PRONTUARIO")
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "DT_UPD_PRONTURARIO", nullable = false)
    private LocalDate dataUltimaAtualizacao;

    @ManyToOne
    @JoinColumn(name = "TB_ANIMAL_ID_ANIMAL", nullable = false)
    private Animal animal;

    @Lob
    @Column(name = "DS_CONTEUDO_CLINICO", nullable = false)
    private String conteudoClinico;

    @ManyToOne
    @JoinColumn(name = "TB_PRONTUARIO_ID_ORIGINAL")
    private Prontuario original;

    @Column(name = "DT_HR_CORRECAO")
    private LocalDateTime dataHoraCorrecao;

    @Column(name = "CRMV_SOLICITANTE_CORRECAO", length = 20)
    private String crmvSolicitanteCorrecao;

    @Column(name = "DS_JUSTIFICATIVA_CORRECAO", length = 1000)
    private String justificativaCorrecao;

    public Prontuario() {
    }

    public Prontuario(UUID id, LocalDate dataUltimaAtualizacao, Animal animal, String conteudoClinico) {
        this.id = id;
        this.dataUltimaAtualizacao = dataUltimaAtualizacao;
        this.animal = animal;
        this.conteudoClinico = conteudoClinico;
    }

    public boolean isOriginal() {
        return original == null;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public LocalDate getDataUltimaAtualizacao() {
        return dataUltimaAtualizacao;
    }

    public void setDataUltimaAtualizacao(LocalDate dataUltimaAtualizacao) {
        this.dataUltimaAtualizacao = dataUltimaAtualizacao;
    }

    public Animal getAnimal() {
        return animal;
    }

    public void setAnimal(Animal animal) {
        this.animal = animal;
    }

    public String getConteudoClinico() {
        return conteudoClinico;
    }

    public void setConteudoClinico(String conteudoClinico) {
        this.conteudoClinico = conteudoClinico;
    }

    public Prontuario getOriginal() {
        return original;
    }

    public void setOriginal(Prontuario original) {
        this.original = original;
    }

    public LocalDateTime getDataHoraCorrecao() {
        return dataHoraCorrecao;
    }

    public void setDataHoraCorrecao(LocalDateTime dataHoraCorrecao) {
        this.dataHoraCorrecao = dataHoraCorrecao;
    }

    public String getCrmvSolicitanteCorrecao() {
        return crmvSolicitanteCorrecao;
    }

    public void setCrmvSolicitanteCorrecao(String crmvSolicitanteCorrecao) {
        this.crmvSolicitanteCorrecao = crmvSolicitanteCorrecao;
    }

    public String getJustificativaCorrecao() {
        return justificativaCorrecao;
    }

    public void setJustificativaCorrecao(String justificativaCorrecao) {
        this.justificativaCorrecao = justificativaCorrecao;
    }
}
