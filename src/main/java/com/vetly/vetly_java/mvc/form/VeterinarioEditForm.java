package com.vetly.vetly_java.mvc.form;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.util.List;

public class VeterinarioEditForm {

    @NotBlank(message = "O nome é obrigatório")
    @Size(max = 100, message = "máximo de 100 caracteres")
    private String nome;

    @NotBlank(message = "O telefone é obrigatório")
    @Pattern(
            regexp = "^\\(?\\d{2}\\)?[\\s-]?9?\\d{4}[-\\s]?\\d{4}$",
            message = "Telefone inválido. Formato esperado: (11) 91234-5678"
    )
    private String telefone;

    @NotBlank(message = "O CRMV é obrigatório")
    private String crmv;

    @NotEmpty(message = "Selecione ao menos uma especialidade")
    private List<String> especialidades;

    @NotEmpty(message = "Selecione ao menos uma espécie")
    private List<String> especies;

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getTelefone() {
        return telefone;
    }

    public void setTelefone(String telefone) {
        this.telefone = telefone;
    }

    public String getCrmv() {
        return crmv;
    }

    public void setCrmv(String crmv) {
        this.crmv = crmv;
    }

    public List<String> getEspecialidades() {
        return especialidades;
    }

    public void setEspecialidades(List<String> especialidades) {
        this.especialidades = especialidades;
    }

    public List<String> getEspecies() {
        return especies;
    }

    public void setEspecies(List<String> especies) {
        this.especies = especies;
    }
}
