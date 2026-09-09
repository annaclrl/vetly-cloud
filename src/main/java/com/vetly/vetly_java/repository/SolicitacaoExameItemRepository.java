package com.vetly.vetly_java.repository;

import com.vetly.vetly_java.model.SolicitacaoExameItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface SolicitacaoExameItemRepository extends JpaRepository<SolicitacaoExameItem, UUID> {
}
