package com.vetly.vetly_java.mvc.service;

import com.vetly.vetly_java.dto.AnimalRequest;
import com.vetly.vetly_java.mapper.AnimalMapper;
import com.vetly.vetly_java.model.Animal;
import com.vetly.vetly_java.model.Especie;
import com.vetly.vetly_java.model.Tutor;
import com.vetly.vetly_java.mvc.form.AnimalForm;
import com.vetly.vetly_java.repository.AnimalRepository;
import com.vetly.vetly_java.repository.EspecieRepository;
import com.vetly.vetly_java.repository.TutorRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class AnimalAdminService {

    private final AnimalRepository animalRepository;
    private final TutorRepository tutorRepository;
    private final EspecieRepository especieRepository;
    private final AnimalMapper mapper;

    public AnimalAdminService(AnimalRepository animalRepository, TutorRepository tutorRepository,
                              EspecieRepository especieRepository, AnimalMapper mapper) {
        this.animalRepository = animalRepository;
        this.tutorRepository = tutorRepository;
        this.especieRepository = especieRepository;
        this.mapper = mapper;
    }

    public List<Animal> listar() {
        return animalRepository.findAll();
    }

    public Animal buscar(UUID id) {
        return animalRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Animal não encontrado: " + id));
    }

    public Animal criar(AnimalForm form) {
        Tutor tutor = findTutor(form.getTutorId());
        Especie especie = findEspecie(form.getEspecieId());
        Animal animal = mapper.animalRequestToAnimal(toRequest(form), tutor, especie);
        return animalRepository.save(animal);
    }

    public Animal atualizar(UUID id, AnimalForm form) {
        Animal animal = buscar(id);
        Especie especie = findEspecie(form.getEspecieId());
        mapper.updateAnimalFromRequest(animal, toRequest(form), especie);
        animal.setTutor(findTutor(form.getTutorId()));
        return animalRepository.save(animal);
    }

    public void excluir(UUID id) {
        animalRepository.deleteById(id);
    }

    private AnimalRequest toRequest(AnimalForm form) {
        return new AnimalRequest(
                form.getNome(), form.getRaca(), form.getSexo(), form.getDataNascimento(), form.getPeso(),
                form.getEspecieId(), form.getUrlFoto(), form.getCastrado(), form.getCondicoesPreexistentes(),
                form.getAlergias(), form.getMedicacoesEmUso());
    }

    private Tutor findTutor(UUID tutorId) {
        return tutorRepository.findById(tutorId)
                .orElseThrow(() -> new EntityNotFoundException("Tutor não encontrado: " + tutorId));
    }

    private Especie findEspecie(String especieId) {
        return especieRepository.findById(especieId)
                .orElseThrow(() -> new EntityNotFoundException("Espécie não encontrada: " + especieId));
    }
}
