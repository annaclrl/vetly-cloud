package com.vetly.vetly_java.dto;

import com.vetly.vetly_java.model.NomeEspecie;
import com.vetly.vetly_java.validation.ValueOfEnum;
import jakarta.validation.constraints.NotNull;

public record EspecieRequest(
        @NotNull(message = "nao pode ser vazio")
        @ValueOfEnum(enumClass = NomeEspecie.class)
        String nome
) {
}
