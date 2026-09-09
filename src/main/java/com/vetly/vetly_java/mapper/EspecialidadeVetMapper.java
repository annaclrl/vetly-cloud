package com.vetly.vetly_java.mapper;

import com.vetly.vetly_java.dto.EspecialidadeVetRequest;
import com.vetly.vetly_java.model.EspecialidadeVet;
import com.vetly.vetly_java.model.NomeEspecialidade;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
public class EspecialidadeVetMapper {
    public EspecialidadeVet especialidadeVetRequestToEspecialidadeVet(EspecialidadeVetRequest req) {
        EspecialidadeVet entity = new EspecialidadeVet();
        entity.setId(UUID.randomUUID().toString());
        entity.setNome(NomeEspecialidade.valueOf(req.nome()));
        entity.setDescricao(req.descricao());
        return entity;
    }
}
