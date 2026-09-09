package com.vetly.vetly_java.mvc.form;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class TutorEditForm {

    @NotBlank(message = "O nome é obrigatório")
    @Size(max = 100, message = "máximo de 100 caracteres")
    private String nome;

    @NotBlank(message = "O telefone é obrigatório")
    @Pattern(
            regexp = "^\\(?\\d{2}\\)?[\\s-]?9?\\d{4}[-\\s]?\\d{4}$",
            message = "Telefone inválido. Formato esperado: (11) 91234-5678"
    )
    private String telefone;

    private boolean lgpdAceito;

    private boolean consentimentoRede;

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

    public boolean isLgpdAceito() {
        return lgpdAceito;
    }

    public void setLgpdAceito(boolean lgpdAceito) {
        this.lgpdAceito = lgpdAceito;
    }

    public boolean isConsentimentoRede() {
        return consentimentoRede;
    }

    public void setConsentimentoRede(boolean consentimentoRede) {
        this.consentimentoRede = consentimentoRede;
    }
}
