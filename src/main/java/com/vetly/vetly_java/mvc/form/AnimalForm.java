package com.vetly.vetly_java.mvc.form;

import com.vetly.vetly_java.model.Sexo;
import com.vetly.vetly_java.validation.ValueOfEnum;
import jakarta.validation.constraints.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public class AnimalForm {

    @NotNull(message = "Selecione o tutor")
    private UUID tutorId;

    @NotBlank(message = "nao pode ser vazio")
    @Size(max = 80, message = "maximo de 80 caracteres")
    private String nome;

    @NotBlank(message = "nao pode ser vazio")
    @Size(max = 80, message = "maximo de 80 caracteres")
    private String raca;

    @NotNull(message = "nao pode ser vazio")
    @ValueOfEnum(enumClass = Sexo.class)
    private String sexo;

    @PastOrPresent(message = "nao pode ser uma data futura")
    private LocalDate dataNascimento;

    @NotNull(message = "nao pode ser vazio")
    @DecimalMin(value = "0.01", message = "deve ser maior que zero")
    @Digits(integer = 3, fraction = 2, message = "formato invalido")
    private BigDecimal peso;

    @NotBlank(message = "nao pode ser vazio")
    private String especieId;

    @Size(max = 500, message = "maximo de 500 caracteres")
    private String urlFoto;

    @NotNull(message = "nao pode ser vazio")
    private Boolean castrado;

    @Size(max = 1000, message = "maximo de 1000 caracteres")
    private String condicoesPreexistentes;

    @Size(max = 1000, message = "maximo de 1000 caracteres")
    private String alergias;

    @Size(max = 1000, message = "maximo de 1000 caracteres")
    private String medicacoesEmUso;

    public UUID getTutorId() {
        return tutorId;
    }

    public void setTutorId(UUID tutorId) {
        this.tutorId = tutorId;
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

    public String getSexo() {
        return sexo;
    }

    public void setSexo(String sexo) {
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

    public String getEspecieId() {
        return especieId;
    }

    public void setEspecieId(String especieId) {
        this.especieId = especieId;
    }

    public String getUrlFoto() {
        return urlFoto;
    }

    public void setUrlFoto(String urlFoto) {
        this.urlFoto = urlFoto;
    }

    public Boolean getCastrado() {
        return castrado;
    }

    public void setCastrado(Boolean castrado) {
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
