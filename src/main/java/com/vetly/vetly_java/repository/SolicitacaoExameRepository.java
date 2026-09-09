package com.vetly.vetly_java.repository;

import com.vetly.vetly_java.model.Consulta;
import com.vetly.vetly_java.model.SolicitacaoExame;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface SolicitacaoExameRepository extends JpaRepository<SolicitacaoExame, UUID> {
    Optional<SolicitacaoExame> findByConsulta(Consulta consulta);
}
