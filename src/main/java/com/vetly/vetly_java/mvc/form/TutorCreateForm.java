package com.vetly.vetly_java.mvc.form;

import jakarta.validation.constraints.*;
import org.hibernate.validator.constraints.br.CPF;

public class TutorCreateForm {

    @NotBlank(message = "O email é obrigatório")
    @Email(message = "Email inválido")
    private String email;

    @NotBlank(message = "A senha é obrigatória")
    @Pattern(
            regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$",
            message = "A senha deve ter no mínimo 8 caracteres, com maiúscula, minúscula, número e caractere especial"
    )
    private String senha;

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
}
