package com.vetly.vetly_java.mvc.service;

import com.vetly.vetly_java.dto.ConsultaRequest;
import com.vetly.vetly_java.mapper.ConsultaMapper;
import com.vetly.vetly_java.model.Animal;
import com.vetly.vetly_java.model.Consulta;
import com.vetly.vetly_java.model.StatusConsulta;
import com.vetly.vetly_java.model.Veterinario;
import com.vetly.vetly_java.mvc.form.ConsultaForm;
import com.vetly.vetly_java.repository.AnimalRepository;
import com.vetly.vetly_java.repository.ConsultaRepository;
import com.vetly.vetly_java.repository.VeterinarioRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class ConsultaAdminService {

    private final ConsultaRepository consultaRepository;
    private final AnimalRepository animalRepository;
    private final VeterinarioRepository veterinarioRepository;
    private final ConsultaMapper mapper;

    public ConsultaAdminService(ConsultaRepository consultaRepository, AnimalRepository animalRepository,
                                VeterinarioRepository veterinarioRepository, ConsultaMapper mapper) {
        this.consultaRepository = consultaRepository;
        this.animalRepository = animalRepository;
        this.veterinarioRepository = veterinarioRepository;
        this.mapper = mapper;
    }

    public List<Consulta> listar() {
        return consultaRepository.findAll();
    }

    public Consulta buscar(UUID id) {
        return consultaRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Consulta não encontrada: " + id));
    }

    public Consulta criar(ConsultaForm form) {
        Animal animal = animalRepository.findById(form.getAnimalId())
                .orElseThrow(() -> new EntityNotFoundException("Animal não encontrado: " + form.getAnimalId()));
        Veterinario veterinario = veterinarioRepository.findById(form.getVeterinarioId())
                .orElseThrow(() -> new EntityNotFoundException("Veterinário não encontrado: " + form.getVeterinarioId()));

        ConsultaRequest request = new ConsultaRequest(
                form.getAnimalId(), form.getVeterinarioId(), form.getDataHora(), form.getValor(), form.getObservacao());
        Consulta consulta = mapper.consultaRequestToConsulta(request, animal, veterinario);
        return consultaRepository.save(consulta);
    }

    public Consulta reagendar(UUID id, LocalDateTime novaDataHora) {
        Consulta consulta = buscar(id);
        if (consulta.getStatus() != StatusConsulta.AGENDADA) {
            throw new IllegalArgumentException("Só é possível reagendar consultas com status AGENDADA");
        }
        consulta.setDataHora(novaDataHora);
        return consultaRepository.save(consulta);
    }

    public Consulta transicionar(UUID id, StatusConsulta destino) {
        Consulta consulta = buscar(id);
        if (consulta.getStatus() != StatusConsulta.AGENDADA) {
            throw new IllegalArgumentException(
                    "Transição inválida: consulta está em " + consulta.getStatus() + ", não é possível ir para " + destino);
        }
        consulta.setStatus(destino);
        return consultaRepository.save(consulta);
    }
}
