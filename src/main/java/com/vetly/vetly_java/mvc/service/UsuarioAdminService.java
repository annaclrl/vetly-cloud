package com.vetly.vetly_java.mvc.service;

import com.vetly.vetly_java.model.Usuario;
import com.vetly.vetly_java.repository.UsuarioRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class UsuarioAdminService {

    private final UsuarioRepository usuarioRepository;

    public UsuarioAdminService(UsuarioRepository usuarioRepository) {
        this.usuarioRepository = usuarioRepository;
    }

    public List<Usuario> listar() {
        return usuarioRepository.findAll();
    }

    public Usuario buscar(UUID id) {
        return usuarioRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Usuário não encontrado: " + id));
    }

    public Usuario alternarAtivo(UUID id) {
        Usuario usuario = buscar(id);
        usuario.setFlagAtivo("S".equals(usuario.getFlagAtivo()) ? "N" : "S");
        return usuarioRepository.save(usuario);
    }
}
