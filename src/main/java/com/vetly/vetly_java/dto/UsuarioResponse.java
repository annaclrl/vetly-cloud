package com.vetly.vetly_java.dto;

import com.vetly.vetly_java.model.UserRole;

import java.util.UUID;

public record UsuarioResponse(
        UUID id,
        String email,
        UserRole role,
        String flagAtivo
) {
}
