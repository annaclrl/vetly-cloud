package com.vetly.vetly_java.repository;

import com.vetly.vetly_java.model.Tutor;
import com.vetly.vetly_java.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface TutorRepository extends JpaRepository<Tutor, UUID> {
    Tutor findByUsuario(Usuario usuario);
}
