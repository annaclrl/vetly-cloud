package com.vetly.vetly_java.repository;

import com.vetly.vetly_java.model.UserRole;
import com.vetly.vetly_java.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;


public interface UsuarioRepository extends JpaRepository<Usuario, UUID> {
    Usuario findByEmail(String email);
    boolean existsByRole(UserRole role);
}
