package com.vetly.vetly_java.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

public record ConsultaRequest(
        @NotNull(message = "nao pode ser vazio")
        UUID animalId,

        @NotNull(message = "nao pode ser vazio")
        UUID veterinarioId,

        @NotNull(message = "nao pode ser vazio")
        @Future(message = "deve ser uma data futura")
        LocalDateTime dataHora,

        @NotNull(message = "nao pode ser vazio")
        @DecimalMin(value = "0.01", message = "deve ser maior que zero")
        BigDecimal valor,

        @Size(max = 500, message = "maximo de 500 caracteres")
        String observacao
) {
}
