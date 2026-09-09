package com.vetly.vetly_java.mvc.form;

import jakarta.validation.constraints.*;
import org.hibernate.validator.constraints.br.CPF;

import java.util.List;

public class VeterinarioCreateForm {

    @NotBlank(message = "O email é obrigatório")
    @Email(message = "Email inválido")
    private String email;

    @NotBlank(message = "A senha é obrigatória")
    @Pattern(
            regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$",
            message = "A senha deve ter no mínimo 8 caracteres, com maiúscula, minúscula, número e caractere especial"
    )
    private String senha;

    @NotBlank(message = "O CRMV é obrigatório")
    private String crmv;

    @NotBlank(message = "O nome é obrigatório")
    @Size(max = 100, message = "máximo de 100 caracteres")
    private String nome;

    @NotBlank(message = "O CPF é obrigatório")
    @Pattern(regexp = "\\d{11}", message = "O CPF deve conter exatamente 11 dígitos, sem pontuação")
    @CPF(message = "CPF inválido")
    private String cpf;

    @NotBlank(message = "O telefone é obrigatório")
    @Pattern(
            regexp = "^\\(?\\d{2}\\)?[\\s-]?9?\\d{4}[-\\s]?\\d{4}$",
            message = "Telefone inválido. Formato esperado: (11) 91234-5678"
    )
    private String telefone;

    @NotEmpty(message = "Selecione ao menos uma especialidade")
    private List<String> especialidades;

    @NotEmpty(message = "Selecione ao menos uma espécie")
    private List<String> especies;

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getSenha() {
        return senha;
    }

    public void setSenha(String senha) {
        this.senha = senha;
    }

    public String getCrmv() {
        return crmv;
    }

    public void setCrmv(String crmv) {
        this.crmv = crmv;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getCpf() {
        return cpf;
    }

    public void setCpf(String cpf) {
        this.cpf = cpf;
    }

    public String getTelefone() {
        return telefone;
    }

    public void setTelefone(String telefone) {
        this.telefone = telefone;
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
