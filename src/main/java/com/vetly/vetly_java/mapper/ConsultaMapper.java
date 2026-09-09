package com.vetly.vetly_java.mapper;

import com.vetly.vetly_java.dto.ConsultaRequest;
import com.vetly.vetly_java.model.Animal;
import com.vetly.vetly_java.model.Consulta;
import com.vetly.vetly_java.model.StatusConsulta;
import com.vetly.vetly_java.model.Veterinario;
import org.springframework.stereotype.Component;

@Component
public class ConsultaMapper {

    public Consulta consultaRequestToConsulta(ConsultaRequest request, Animal animal, Veterinario veterinario) {
        Consulta consulta = new Consulta();
        consulta.setDataHora(request.dataHora());
        consulta.setStatus(StatusConsulta.AGENDADA);
        consulta.setValor(request.valor());
        consulta.setObservacao(request.observacao());
        consulta.setAnimal(animal);
        consulta.setVeterinario(veterinario);
        return consulta;
    }
}
