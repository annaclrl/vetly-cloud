package com.vetly.vetly_java.repository;

import com.vetly.vetly_java.model.Especie;
import com.vetly.vetly_java.model.NomeEspecie;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface EspecieRepository extends JpaRepository<Especie, String> {
    List<Especie> findByNomeIn(List<NomeEspecie> nomes);
}
