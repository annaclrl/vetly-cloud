package com.vetly.vetly_java.repository;

import com.vetly.vetly_java.model.EspecialidadeVet;
import com.vetly.vetly_java.model.NomeEspecialidade;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface EspecialidadeVetRepository extends JpaRepository<EspecialidadeVet, String> {

    List<EspecialidadeVet> findByNomeIn(List<NomeEspecialidade> nomes);

}