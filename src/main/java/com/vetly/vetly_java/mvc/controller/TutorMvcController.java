package com.vetly.vetly_java.mvc.controller;

import com.vetly.vetly_java.model.Tutor;
import com.vetly.vetly_java.mvc.form.TutorCreateForm;
import com.vetly.vetly_java.mvc.form.TutorEditForm;
import com.vetly.vetly_java.mvc.service.TutorAdminService;
import com.vetly.vetly_java.repository.AnimalRepository;
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
@RequestMapping("/mvc/tutores")
public class TutorMvcController {

    private final TutorAdminService tutorAdminService;
    private final AnimalRepository animalRepository;

    public TutorMvcController(TutorAdminService tutorAdminService, AnimalRepository animalRepository) {
        this.tutorAdminService = tutorAdminService;
        this.animalRepository = animalRepository;
    }

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("tutores", tutorAdminService.listar());
        return "tutores/lista";
    }

    @GetMapping("/novo")
    public String novoForm(Model model) {
        model.addAttribute("form", new TutorCreateForm());
        return "tutores/novo";
    }

    @PostMapping
    public String criar(@Valid @ModelAttribute("form") TutorCreateForm form, BindingResult bindingResult,
                        RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            return "tutores/novo";
        }
        try {
            tutorAdminService.criar(form);
        } catch (RuntimeException e) {
            bindingResult.reject("erro", mensagem(e));
            return "tutores/novo";
        }
        redirectAttributes.addFlashAttribute("sucesso", "Tutor cadastrado com sucesso.");
        return "redirect:/mvc/tutores";
    }

    @GetMapping("/{id}")
    public String visualizar(@PathVariable UUID id, Model model) {
        Tutor tutor = tutorAdminService.buscar(id);
        model.addAttribute("tutor", tutor);
        model.addAttribute("animais", animalRepository.findByTutor(tutor));
        return "tutores/detalhe";
    }

    @GetMapping("/{id}/editar")
    public String editarForm(@PathVariable UUID id, Model model) {
        Tutor tutor = tutorAdminService.buscar(id);
        TutorEditForm form = new TutorEditForm();
        form.setNome(tutor.getPessoa().getNome());
        form.setTelefone(tutor.getPessoa().getTelefone());
        form.setLgpdAceito(tutor.isLgpdAceito());
        form.setConsentimentoRede(tutor.isConsentimentoRede());
        model.addAttribute("form", form);
        model.addAttribute("tutor", tutor);
        return "tutores/editar";
    }

    @PostMapping("/{id}/editar")
    public String atualizar(@PathVariable UUID id, @Valid @ModelAttribute("form") TutorEditForm form,
                            BindingResult bindingResult, Model model, RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            model.addAttribute("tutor", tutorAdminService.buscar(id));
            return "tutores/editar";
        }
        try {
            tutorAdminService.atualizar(id, form);
        } catch (RuntimeException e) {
            bindingResult.reject("erro", mensagem(e));
            model.addAttribute("tutor", tutorAdminService.buscar(id));
            return "tutores/editar";
        }
        redirectAttributes.addFlashAttribute("sucesso", "Tutor atualizado com sucesso.");
        return "redirect:/mvc/tutores/" + id;
    }

    @PostMapping("/{id}/excluir")
    public String excluir(@PathVariable UUID id, RedirectAttributes redirectAttributes) {
        try {
            tutorAdminService.excluir(id);
            redirectAttributes.addFlashAttribute("sucesso", "Tutor excluído com sucesso.");
        } catch (DataIntegrityViolationException e) {
            redirectAttributes.addFlashAttribute("erro", "Não é possível excluir: tutor possui animais ou registros vinculados.");
        } catch (EntityNotFoundException e) {
            redirectAttributes.addFlashAttribute("erro", "Tutor não encontrado.");
        }
        return "redirect:/mvc/tutores";
    }

    private String mensagem(RuntimeException e) {
        return e.getMessage() != null ? e.getMessage() : "Erro ao processar a solicitação.";
    }
}
