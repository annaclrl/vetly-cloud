package com.vetly.vetly_java.dto;

import com.vetly.vetly_java.model.Sexo;
import com.vetly.vetly_java.validation.ValueOfEnum;
import jakarta.validation.constraints.*;

import java.math.BigDecimal;
import java.time.LocalDate;

public record AnimalRequest(
        @NotBlank(message = "nao pode ser vazio")
        @Size(max = 80, message = "maximo de 80 caracteres")
        String nome,

        @NotBlank(message = "nao pode ser vazio")
        @Size(max = 80, message = "maximo de 80 caracteres")
        String raca,

        @NotNull(message = "nao pode ser vazio")
        @ValueOfEnum(enumClass = Sexo.class)
        String sexo,

        @PastOrPresent(message = "nao pode ser uma data futura")
        LocalDate dataNascimento,

        @NotNull(message = "nao pode ser vazio")
        @DecimalMin(value = "0.01", message = "deve ser maior que zero")
        @Digits(integer = 3, fraction = 2, message = "formato invalido")
        BigDecimal peso,

        @NotBlank(message = "nao pode ser vazio")
        String especieId,

        @Size(max = 500, message = "maximo de 500 caracteres")
        String urlFoto,

        @NotNull(message = "nao pode ser vazio")
        Boolean castrado,

        @Size(max = 1000, message = "maximo de 1000 caracteres")
        String condicoesPreexistentes,

        @Size(max = 1000, message = "maximo de 1000 caracteres")
        String alergias,

        @Size(max = 1000, message = "maximo de 1000 caracteres")
        String medicacoesEmUso
) {
}
