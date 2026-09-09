package com.vetly.vetly_java.repository;

import com.vetly.vetly_java.model.Animal;
import com.vetly.vetly_java.model.Prontuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProntuarioRepository extends JpaRepository<Prontuario, UUID> {
    Optional<Prontuario> findByAnimalAndOriginalIsNull(Animal animal);

    List<Prontuario> findByOriginalOrderByDataHoraCorrecaoAsc(Prontuario original);
}
