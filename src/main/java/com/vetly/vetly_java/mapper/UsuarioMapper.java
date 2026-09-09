package com.vetly.vetly_java.mapper;

import com.vetly.vetly_java.dto.UsuarioResponse;
import com.vetly.vetly_java.model.Usuario;
import org.springframework.stereotype.Component;

@Component
public class UsuarioMapper {
    public UsuarioResponse usuarioToResponse(Usuario usuario) {
        return new UsuarioResponse(usuario.getId(), usuario.getEmail(), usuario.getRole(), usuario.getFlagAtivo());
    }
}
