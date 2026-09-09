package com.vetly.vetly_java.mvc.service;

import com.vetly.vetly_java.model.Animal;
import com.vetly.vetly_java.model.Prontuario;
import com.vetly.vetly_java.repository.AnimalRepository;
import com.vetly.vetly_java.repository.ProntuarioRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Tela MVC é operada por ADMIN, sem veterinário autenticado — não usa
 * ProntuarioService (que exige vínculo clínico do vet via Colmeia), mas
 * preserva a regra RN-089 de justificativa obrigatória fora da janela de 24h.
 */
@Service
public class ProntuarioAdminService {

    private final ProntuarioRepository prontuarioRepository;
    private final AnimalRepository animalRepository;

    public ProntuarioAdminService(ProntuarioRepository prontuarioRepository, AnimalRepository animalRepository) {
        this.prontuarioRepository = prontuarioRepository;
        this.animalRepository = animalRepository;
    }

    public Optional<Prontuario> buscarOriginal(UUID animalId) {
        return prontuarioRepository.findByAnimalAndOriginalIsNull(findAnimal(animalId));
    }

    public List<Prontuario> historico(UUID animalId) {
        Optional<Prontuario> original = buscarOriginal(animalId);
        if (original.isEmpty()) {
            return List.of();
        }
        List<Prontuario> historico = new ArrayList<>();
        historico.add(original.get());
        historico.addAll(prontuarioRepository.findByOriginalOrderByDataHoraCorrecaoAsc(original.get()));
        return historico;
    }

    public Prontuario criar(UUID animalId, String conteudoClinico) {
        Animal animal = findAnimal(animalId);
        if (prontuarioRepository.findByAnimalAndOriginalIsNull(animal).isPresent()) {
            throw new IllegalArgumentException("Este animal já possui um prontuário — use a correção para atualizá-lo");
        }
        Prontuario prontuario = new Prontuario(UUID.randomUUID(), LocalDate.now(), animal, conteudoClinico);
        return prontuarioRepository.save(prontuario);
    }

    public Prontuario corrigir(UUID animalId, String conteudoClinico, String justificativa) {
        Animal animal = findAnimal(animalId);
        Prontuario original = prontuarioRepository.findByAnimalAndOriginalIsNull(animal)
                .orElseThrow(() -> new EntityNotFoundException("Animal ainda não possui prontuário: " + animalId));

        boolean dentroDaJanelaDe24h = !LocalDate.now().isAfter(original.getDataUltimaAtualizacao());
        if (!dentroDaJanelaDe24h && (justificativa == null || justificativa.isBlank())) {
            throw new IllegalArgumentException(
                    "Correção fora da janela de 24h da criação do prontuário original exige justificativa (RN-089)");
        }

        Prontuario correcao = new Prontuario(UUID.randomUUID(), LocalDate.now(), animal, conteudoClinico);
        correcao.setOriginal(original);
        correcao.setDataHoraCorrecao(LocalDateTime.now());
        correcao.setJustificativaCorrecao(dentroDaJanelaDe24h ? null : justificativa);
        return prontuarioRepository.save(correcao);
    }

    private Animal findAnimal(UUID animalId) {
        return animalRepository.findById(animalId)
                .orElseThrow(() -> new EntityNotFoundException("Animal não encontrado: " + animalId));
    }
}
