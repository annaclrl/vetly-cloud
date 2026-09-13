package com.vetly.vetly_java.repository;

import com.vetly.vetly_java.model.Pessoa;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PessoaRepository extends JpaRepository<Pessoa, String> {
    boolean existsByCpfAndTelefone(String cpf, String telefone);
}
