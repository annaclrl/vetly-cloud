package com.vetly.vetly_java.model;

import jakarta.persistence.*;

import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "tb_animal")
public class Animal {
    @Id
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "ID_ANIMAL")
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "NM_ANIMAL", nullable = false, length = 80)
    private String nome;

    @Column(name = "RC_ANIMAL", nullable = false, length = 80)
    private String raca;

    @Column(name = "SX_ANIMAL", nullable = false, length = 1)
    @Enumerated(EnumType.STRING)
    private Sexo sexo;

    @Column(name = "DT_NASC_ANIMAL")
    private LocalDate dataNascimento;

    @Column(name = "NR_PESO_ANIMAL", nullable = false, precision = 5, scale = 2)
    private BigDecimal peso;

    @ManyToOne
    @JoinColumn(name = "TB_TUTOR_ID_TUTOR", nullable = false)
    private Tutor tutor;

    @ManyToOne
    @JoinColumn(name = "TB_ESPECIE_ID_ESPECIE", nullable = false)
    private Especie especie;

    @Column(name = "URL_FOTO_ANIMAL", length = 500)
    private String urlFoto;

    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "FL_CASTRADO", nullable = false, length = 1)
    private String castrado;

    @Column(name = "DS_CONDICOES_PREEXIST", length = 1000)
    private String condicoesPreexistentes;

    @Column(name = "DS_ALERGIAS", length = 1000)
    private String alergias;

    @Column(name = "DS_MEDICACOES_EM_USO", length = 1000)
    private String medicacoesEmUso;


    public Animal() {
    }

    public Animal(UUID id, String nome, String raca, Sexo sexo, LocalDate dataNascimento, BigDecimal peso, Tutor tutor, Especie especie,
                  String urlFoto, String castrado, String condicoesPreexistentes, String alergias, String medicacoesEmUso) {
        this.id = id;
        this.nome = nome;
        this.raca = raca;
        this.sexo = sexo;
        this.dataNascimento = dataNascimento;
        this.peso = peso;
        this.tutor = tutor;
        this.especie = especie;
        this.urlFoto = urlFoto;
        this.castrado = castrado;
        this.condicoesPreexistentes = condicoesPreexistentes;
        this.alergias = alergias;
        this.medicacoesEmUso = medicacoesEmUso;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getRaca() {
        return raca;
    }

    public void setRaca(String raca) {
        this.raca = raca;
    }

    public Sexo getSexo() {
        return sexo;
    }

    public void setSexo(Sexo sexo) {
        this.sexo = sexo;
    }

    public LocalDate getDataNascimento() {
        return dataNascimento;
    }

    public void setDataNascimento(LocalDate dataNascimento) {
        this.dataNascimento = dataNascimento;
    }

    public BigDecimal getPeso() {
        return peso;
    }

    public void setPeso(BigDecimal peso) {
        this.peso = peso;
    }

    public Tutor getTutor() {
        return tutor;
    }

    public void setTutor(Tutor tutor) {
        this.tutor = tutor;
    }

    public Especie getEspecie() {
        return especie;
    }

    public void setEspecie(Especie especie) {
        this.especie = especie;
    }

    public String getUrlFoto() {
        return urlFoto;
    }

    public void setUrlFoto(String urlFoto) {
        this.urlFoto = urlFoto;
    }

    public String getCastrado() {
        return castrado;
    }

    public void setCastrado(String castrado) {
        this.castrado = castrado;
    }

    public String getCondicoesPreexistentes() {
        return condicoesPreexistentes;
    }

    public void setCondicoesPreexistentes(String condicoesPreexistentes) {
        this.condicoesPreexistentes = condicoesPreexistentes;
    }

    public String getAlergias() {
        return alergias;
    }

    public void setAlergias(String alergias) {
        this.alergias = alergias;
    }

    public String getMedicacoesEmUso() {
        return medicacoesEmUso;
    }

    public void setMedicacoesEmUso(String medicacoesEmUso) {
        this.medicacoesEmUso = medicacoesEmUso;
    }
}
