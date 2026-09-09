package com.vetly.vetly_java.mvc.controller;

import com.vetly.vetly_java.model.Animal;
import com.vetly.vetly_java.model.Sexo;
import com.vetly.vetly_java.mvc.form.AnimalForm;
import com.vetly.vetly_java.mvc.service.AnimalAdminService;
import com.vetly.vetly_java.repository.EspecieRepository;
import com.vetly.vetly_java.repository.TutorRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.Valid;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.UUID;

@Controller
@RequestMapping("/mvc/animais")
public class AnimalMvcController {

    private final AnimalAdminService animalAdminService;
    private final TutorRepository tutorRepository;
    private final EspecieRepository especieRepository;

    public AnimalMvcController(AnimalAdminService animalAdminService, TutorRepository tutorRepository,
                               EspecieRepository especieRepository) {
        this.animalAdminService = animalAdminService;
        this.tutorRepository = tutorRepository;
        this.especieRepository = especieRepository;
    }

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("animais", animalAdminService.listar());
        return "animais/lista";
    }

    @GetMapping("/novo")
    public String novoForm(Model model) {
        model.addAttribute("form", new AnimalForm());
        adicionarListasApoio(model);
        return "animais/novo";
    }

    @PostMapping
    public String criar(@Valid @ModelAttribute("form") AnimalForm form, BindingResult bindingResult,
                        Model model, RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            adicionarListasApoio(model);
            return "animais/novo";
        }
        Animal animal;
        try {
            animal = animalAdminService.criar(form);
        } catch (RuntimeException e) {
            bindingResult.reject("erro", mensagem(e));
            adicionarListasApoio(model);
            return "animais/novo";
        }
        redirectAttributes.addFlashAttribute("sucesso", "Animal cadastrado com sucesso.");
        return "redirect:/mvc/animais/" + animal.getId();
    }

    @GetMapping("/{id}")
    public String visualizar(@PathVariable UUID id, Model model) {
        model.addAttribute("animal", animalAdminService.buscar(id));
        return "animais/detalhe";
    }

    @GetMapping("/{id}/editar")
    public String editarForm(@PathVariable UUID id, Model model) {
        Animal animal = animalAdminService.buscar(id);
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
        return "animais/editar";
    }

    @PostMapping("/{id}/editar")
    public String atualizar(@PathVariable UUID id, @Valid @ModelAttribute("form") AnimalForm form,
                            BindingResult bindingResult, Model model, RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            model.addAttribute("animal", animalAdminService.buscar(id));
            adicionarListasApoio(model);
            return "animais/editar";
        }
        try {
            animalAdminService.atualizar(id, form);
        } catch (RuntimeException e) {
            bindingResult.reject("erro", mensagem(e));
            model.addAttribute("animal", animalAdminService.buscar(id));
            adicionarListasApoio(model);
            return "animais/editar";
        }
        redirectAttributes.addFlashAttribute("sucesso", "Animal atualizado com sucesso.");
        return "redirect:/mvc/animais/" + id;
    }

    @PostMapping("/{id}/excluir")
    public String excluir(@PathVariable UUID id, RedirectAttributes redirectAttributes) {
        try {
            animalAdminService.excluir(id);
            redirectAttributes.addFlashAttribute("sucesso", "Animal excluído com sucesso.");
        } catch (DataIntegrityViolationException e) {
            redirectAttributes.addFlashAttribute("erro", "Não é possível excluir: animal possui consultas ou prontuário vinculados.");
        } catch (EntityNotFoundException e) {
            redirectAttributes.addFlashAttribute("erro", "Animal não encontrado.");
        }
        return "redirect:/mvc/animais";
    }

    private void adicionarListasApoio(Model model) {
        model.addAttribute("tutores", tutorRepository.findAll());
        model.addAttribute("especies", especieRepository.findAll());
        model.addAttribute("sexos", Sexo.values());
    }

    private String mensagem(RuntimeException e) {
        return e.getMessage() != null ? e.getMessage() : "Erro ao processar a solicitação.";
    }
}
