package com.vetly.vetly_java.service;

import com.vetly.vetly_java.dto.EspecialidadeVetRequest;
import com.vetly.vetly_java.mapper.EspecialidadeVetMapper;
import com.vetly.vetly_java.model.EspecialidadeVet;
import com.vetly.vetly_java.repository.EspecialidadeVetRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class EspecialidadeVetService {
    private final EspecialidadeVetRepository especialidadeVetRepository;
    private final EspecialidadeVetMapper mapper;

    @Autowired
    public EspecialidadeVetService(EspecialidadeVetRepository especialidadeVetRepository,
                                   EspecialidadeVetMapper mapper) {
        this.especialidadeVetRepository = especialidadeVetRepository;
        this.mapper = mapper;
    }

    public EspecialidadeVet create(EspecialidadeVetRequest req) {
        EspecialidadeVet especialidadeVet = mapper.especialidadeVetRequestToEspecialidadeVet(req);
        return especialidadeVetRepository.save(especialidadeVet);
    }

    public EspecialidadeVet readById(String id) {
        Optional<EspecialidadeVet> especialidadeVet = especialidadeVetRepository.findById(id);
        return especialidadeVet.orElse(null);
    }

    public EspecialidadeVet update(EspecialidadeVet especialidadeVet) {
        return especialidadeVetRepository.save(especialidadeVet);
    }

    public void delete(String id) {
        especialidadeVetRepository.deleteById(id);
    }
}
