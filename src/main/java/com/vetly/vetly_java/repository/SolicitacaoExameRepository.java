package com.vetly.vetly_java.repository;

import com.vetly.vetly_java.model.Consulta;
import com.vetly.vetly_java.model.SolicitacaoExame;
import com.vetly.vetly_java.model.Tutor;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface SolicitacaoExameRepository extends JpaRepository<SolicitacaoExame, UUID> {
    Optional<SolicitacaoExame> findByConsulta(Consulta consulta);

    List<SolicitacaoExame> findByConsulta_Animal_Tutor(Tutor tutor);
}
