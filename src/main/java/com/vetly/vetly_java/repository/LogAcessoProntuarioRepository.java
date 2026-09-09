package com.vetly.vetly_java.repository;

import com.vetly.vetly_java.model.Animal;
import com.vetly.vetly_java.model.LogAcessoProntuario;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface LogAcessoProntuarioRepository extends JpaRepository<LogAcessoProntuario, UUID> {
    Page<LogAcessoProntuario> findByAnimal(Animal animal, Pageable pageable);
}
