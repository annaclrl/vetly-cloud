package com.vetly.vetly_java.mvc.form;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

public class ConsultaForm {

    @NotNull(message = "Selecione o animal")
    private UUID animalId;

    @NotNull(message = "Selecione o veterinário")
    private UUID veterinarioId;

    @NotNull(message = "Informe a data e hora")
    private LocalDateTime dataHora;

    @NotNull(message = "Informe o valor")
    @DecimalMin(value = "0.01", message = "deve ser maior que zero")
    private BigDecimal valor;

    @Size(max = 500, message = "máximo de 500 caracteres")
    private String observacao;

    public UUID getAnimalId() {
        return animalId;
    }

    public void setAnimalId(UUID animalId) {
        this.animalId = animalId;
    }

    public UUID getVeterinarioId() {
        return veterinarioId;
    }

    public void setVeterinarioId(UUID veterinarioId) {
        this.veterinarioId = veterinarioId;
    }

    public LocalDateTime getDataHora() {
        return dataHora;
    }

    public void setDataHora(LocalDateTime dataHora) {
        this.dataHora = dataHora;
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
}
