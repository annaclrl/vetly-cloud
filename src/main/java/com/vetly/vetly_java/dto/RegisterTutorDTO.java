package com.vetly.vetly_java.dto;

import jakarta.validation.constraints.*;
import org.hibernate.validator.constraints.br.CPF;
import org.springframework.format.annotation.NumberFormat;

public record RegisterTutorDTO(
        @NotNull(message = "O email é obrigatório")
        @Email(message = "Email inválido")
        String email,
        @NotBlank(message = "A senha é obrigatória")
        @Pattern(
                regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$",
                message = """
            A senha deve conter:
            - mínimo 8 caracteres
            - uma letra maiúscula
            - uma letra minúscula
            - um número
            - um caractere especial
            """
        )
        String senha,
        @NotNull(message = "nao pode ser nulo")
        @Size(max = 100, message = "maximo de 100 caracteres")
        String nome,
        @NotBlank(message = "nao pode ser nulo")
        @CPF
        @NumberFormat
        String cpf,
        @NotBlank(message = "nao pode ser nulo")
        @Pattern(
                regexp = "^\\(?\\d{2}\\)?[\\s-]?9?\\d{4}[-\\s]?\\d{4}$",
                message = "Telefone inválido. Formato esperado: (11) 91234-5678"
        )
        String telefone
) {
}
