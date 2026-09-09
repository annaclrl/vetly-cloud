package com.vetly.vetly_java.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;

import java.util.List;

public record SolicitacaoExameRequest(
        @Size(max = 300, message = "maximo de 300 caracteres")
        String observacao,

        @NotEmpty(message = "informe ao menos um exame")
        @Valid
        List<ItemRequest> itens
) {
    public record ItemRequest(
            @jakarta.validation.constraints.NotBlank(message = "nao pode ser vazio")
            @Size(max = 100, message = "maximo de 100 caracteres")
            String nomeExame
    ) {
    }
}
