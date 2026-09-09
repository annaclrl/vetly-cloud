package com.vetly.vetly_java.repository;

import com.vetly.vetly_java.model.EvolucaoClinica;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface EvolucaoClinicaRepository extends JpaRepository<EvolucaoClinica, UUID> {

    @Query("""
            SELECT e FROM EvolucaoClinica e
            WHERE e.consulta.animal.id = :animalId
            ORDER BY e.consulta.dataHora DESC
            """)
    List<EvolucaoClinica> findByAnimalId(@Param("animalId") UUID animalId);

    @Query("""
            SELECT e FROM EvolucaoClinica e
            WHERE e.consulta.animal.id = :animalId AND e.consulta.veterinario.id = :veterinarioId
            ORDER BY e.consulta.dataHora DESC
            """)
    List<EvolucaoClinica> findByAnimalIdAndVeterinarioId(@Param("animalId") UUID animalId,
                                                         @Param("veterinarioId") UUID veterinarioId);
}
