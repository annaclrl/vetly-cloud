package com.vetly.vetly_java.repository;

import com.vetly.vetly_java.model.Animal;
import com.vetly.vetly_java.model.Consulta;
import com.vetly.vetly_java.model.StatusConsulta;
import com.vetly.vetly_java.model.Tutor;
import com.vetly.vetly_java.model.Veterinario;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ConsultaRepository extends JpaRepository<Consulta, UUID> {
    Page<Consulta> findByAnimal_Tutor(Tutor tutor, Pageable pageable);

    Page<Consulta> findByVeterinario(Veterinario veterinario, Pageable pageable);

    boolean existsByAnimalAndVeterinarioAndStatusNot(Animal animal, Veterinario veterinario, StatusConsulta status);
}
