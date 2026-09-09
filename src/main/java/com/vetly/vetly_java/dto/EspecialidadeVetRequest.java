package com.vetly.vetly_java.dto;

import com.vetly.vetly_java.model.NomeEspecialidade;
import com.vetly.vetly_java.validation.ValueOfEnum;
import jakarta.validation.constraints.*;

public record EspecialidadeVetRequest(
        @NotNull(message = "nao pode ser vazio")
        @ValueOfEnum(enumClass = NomeEspecialidade.class)
        String nome,
        @NotBlank(message = "nao pode ser vazio")
        @Size(max = 150, message = "A descricao deve ter no maximo 150 caracteres")
        String descricao
) {
}