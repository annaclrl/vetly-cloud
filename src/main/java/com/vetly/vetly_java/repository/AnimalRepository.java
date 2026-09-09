package com.vetly.vetly_java.repository;

import com.vetly.vetly_java.model.Animal;
import com.vetly.vetly_java.model.Tutor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface AnimalRepository extends JpaRepository<Animal, UUID> {
    Page<Animal> findByTutor(Tutor tutor, Pageable pageable);

    List<Animal> findByTutor(Tutor tutor);
}
