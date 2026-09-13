package com.vetly.vetly_java.controller;

import com.vetly.vetly_java.form.AnimalForm;
import com.vetly.vetly_java.model.Animal;
import com.vetly.vetly_java.model.Sexo;
import com.vetly.vetly_java.model.Tutor;
import com.vetly.vetly_java.model.Usuario;
import com.vetly.vetly_java.repository.AnimalRepository;
import com.vetly.vetly_java.repository.EspecieRepository;
import com.vetly.vetly_java.repository.TutorRepository;
import com.vetly.vetly_java.service.AnimalAdminService;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.Valid;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.UUID;

/**
 * CRUD de animais do próprio Tutor autenticado — mesmo domínio do painel
 * ADMIN, mas restrito aos animais do tutor logado (o tutorId nunca é
 * confiável a partir do formulário, é sempre reforçado aqui a partir da
 * sessão).
 */
@Controller
@RequestMapping("/mvc/area-tutor/animais")
public class AreaTutorAnimalController {

    private final AnimalAdminService animalAdminService;
    private final AnimalRepository animalRepository;
    private final TutorRepository tutorRepository;
    private final EspecieRepository especieRepository;

    public AreaTutorAnimalController(AnimalAdminService animalAdminService, AnimalRepository animalRepository,
                                      TutorRepository tutorRepository, EspecieRepository especieRepository) {
        this.animalAdminService = animalAdminService;
        this.animalRepository = animalRepository;
        this.tutorRepository = tutorRepository;
        this.especieRepository = especieRepository;
    }

    @GetMapping
    public String listar(@AuthenticationPrincipal Usuario usuario, Model model) {
        model.addAttribute("animais", animalRepository.findByTutor(tutorAtual(usuario)));
        return "area-tutor/animais-lista";
    }

    @GetMapping("/novo")
    public String novoForm(@AuthenticationPrincipal Usuario usuario, Model model) {
        AnimalForm form = new AnimalForm();
        form.setTutorId(tutorAtual(usuario).getId());
        model.addAttribute("form", form);
        adicionarListasApoio(model);
        return "area-tutor/animal-novo";
    }

    @PostMapping
    public String criar(@AuthenticationPrincipal Usuario usuario, @Valid @ModelAttribute("form") AnimalForm form,
                        BindingResult bindingResult, Model model, RedirectAttributes redirectAttributes) {
        Tutor tutor = tutorAtual(usuario);
        form.setTutorId(tutor.getId());
        if (bindingResult.hasErrors()) {
            adicionarListasApoio(model);
            return "area-tutor/animal-novo";
        }
        Animal animal;
        try {
            animal = animalAdminService.criar(form);
        } catch (RuntimeException e) {
            bindingResult.reject("erro", mensagem(e));
            adicionarListasApoio(model);
            return "area-tutor/animal-novo";
        }
        redirectAttributes.addFlashAttribute("sucesso", "Animal cadastrado com sucesso.");
        return "redirect:/mvc/area-tutor/animais/" + animal.getId();
    }

    @GetMapping("/{id}")
    public String visualizar(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID id, Model model) {
        Animal animal = buscarDoTutor(usuario, id);
        model.addAttribute("animal", animal);
        return "area-tutor/animal-detalhe";
    }

    @GetMapping("/{id}/editar")
    public String editarForm(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID id, Model model) {
        Animal animal = buscarDoTutor(usuario, id);
        AnimalForm form = new AnimalForm();
        form.setTutorId(animal.getTutor().getId());
        form.setNome(animal.getNome());
        form.setRaca(animal.getRaca());
        form.setSexo(animal.getSexo().name());
        form.setDataNascimento(animal.getDataNascimento());
        form.setPeso(animal.getPeso());
        form.setEspecieId(animal.getEspecie().getId());
        form.setUrlFoto(animal.getUrlFoto());
        form.setCastrado("S".equals(animal.getCastrado()));
        form.setCondicoesPreexistentes(animal.getCondicoesPreexistentes());
        form.setAlergias(animal.getAlergias());
        form.setMedicacoesEmUso(animal.getMedicacoesEmUso());
        model.addAttribute("form", form);
        model.addAttribute("animal", animal);
        adicionarListasApoio(model);
        return "area-tutor/animal-editar";
    }

    @PostMapping("/{id}/editar")
    public String atualizar(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID id,
                            @Valid @ModelAttribute("form") AnimalForm form, BindingResult bindingResult,
                            Model model, RedirectAttributes redirectAttributes) {
        Animal animal = buscarDoTutor(usuario, id);
        form.setTutorId(animal.getTutor().getId());
        if (bindingResult.hasErrors()) {
            model.addAttribute("animal", animal);
            adicionarListasApoio(model);
            return "area-tutor/animal-editar";
        }
        try {
            animalAdminService.atualizar(id, form);
        } catch (RuntimeException e) {
            bindingResult.reject("erro", mensagem(e));
            model.addAttribute("animal", animal);
            adicionarListasApoio(model);
            return "area-tutor/animal-editar";
        }
        redirectAttributes.addFlashAttribute("sucesso", "Animal atualizado com sucesso.");
        return "redirect:/mvc/area-tutor/animais/" + id;
    }

    @PostMapping("/{id}/excluir")
    public String excluir(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID id,
                          RedirectAttributes redirectAttributes) {
        buscarDoTutor(usuario, id);
        try {
            animalAdminService.excluir(id);
            redirectAttributes.addFlashAttribute("sucesso", "Animal excluído com sucesso.");
        } catch (DataIntegrityViolationException e) {
            redirectAttributes.addFlashAttribute("erro", "Não é possível excluir: animal possui consultas ou prontuário vinculados.");
        }
        return "redirect:/mvc/area-tutor/animais";
    }

    private Animal buscarDoTutor(Usuario usuario, UUID id) {
        Animal animal = animalAdminService.buscar(id);
        if (!animal.getTutor().getId().equals(tutorAtual(usuario).getId())) {
            throw new EntityNotFoundException("Animal não encontrado: " + id);
        }
        return animal;
    }

    private Tutor tutorAtual(Usuario usuario) {
        Tutor tutor = tutorRepository.findByUsuario(usuario);
        if (tutor == null) {
            throw new EntityNotFoundException("Nenhum cadastro de tutor associado a este usuário");
        }
        return tutor;
    }

    private void adicionarListasApoio(Model model) {
        model.addAttribute("especies", especieRepository.findAll());
        model.addAttribute("sexos", Sexo.values());
    }

    private String mensagem(RuntimeException e) {
        if (e instanceof DataIntegrityViolationException) {
            return "Já existe um cadastro conflitante para este animal.";
        }
        return e.getMessage() != null ? e.getMessage() : "Erro ao processar a solicitação.";
    }
}
