package com.vetly.vetly_java.controller;

import com.vetly.vetly_java.form.TutorCreateForm;
import com.vetly.vetly_java.form.VeterinarioCreateForm;
import com.vetly.vetly_java.model.NomeEspecialidade;
import com.vetly.vetly_java.model.NomeEspecie;
import com.vetly.vetly_java.service.TutorAdminService;
import com.vetly.vetly_java.service.VeterinarioAdminService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * Auto-registro público de Tutor e Veterinário — as duas únicas roles que se
 * cadastram sozinhas. ADMIN nunca se cria por aqui (ver AdminBootstrap).
 */
@Controller
@RequestMapping("/mvc/cadastro")
public class CadastroController {

    private final TutorAdminService tutorAdminService;
    private final VeterinarioAdminService veterinarioAdminService;

    public CadastroController(TutorAdminService tutorAdminService, VeterinarioAdminService veterinarioAdminService) {
        this.tutorAdminService = tutorAdminService;
        this.veterinarioAdminService = veterinarioAdminService;
    }

    @GetMapping
    public String formulario(Model model, HttpServletRequest request) {
        // Garante a sessao antes de renderizar (token CSRF dos formularios; ver AuthViewController)
        request.getSession(true);
        return form(model);
    }

    private String form(Model model) {
        if (!model.containsAttribute("tutorForm")) {
            model.addAttribute("tutorForm", new TutorCreateForm());
        }
        if (!model.containsAttribute("veterinarioForm")) {
            model.addAttribute("veterinarioForm", new VeterinarioCreateForm());
        }
        model.addAttribute("especialidadesDisponiveis", NomeEspecialidade.values());
        model.addAttribute("especiesDisponiveis", NomeEspecie.values());
        return "cadastro";
    }

    @PostMapping("/tutor")
    public String cadastrarTutor(@Valid @ModelAttribute("tutorForm") TutorCreateForm form, BindingResult bindingResult,
                                  Model model, RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            return form(model);
        }
        try {
            tutorAdminService.criar(form);
        } catch (RuntimeException e) {
            bindingResult.reject("erro", mensagem(e));
            return form(model);
        }
        redirectAttributes.addFlashAttribute("sucesso", "Cadastro realizado com sucesso. Faça login para continuar.");
        return "redirect:/mvc/login?cadastrado";
    }

    @PostMapping("/veterinario")
    public String cadastrarVeterinario(@Valid @ModelAttribute("veterinarioForm") VeterinarioCreateForm form,
                                        BindingResult bindingResult, Model model, RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            return form(model);
        }
        try {
            veterinarioAdminService.criar(form);
        } catch (RuntimeException e) {
            bindingResult.reject("erro", mensagem(e));
            return form(model);
        }
        redirectAttributes.addFlashAttribute("sucesso", "Cadastro realizado com sucesso. Faça login para continuar.");
        return "redirect:/mvc/login?cadastrado";
    }

    private String mensagem(RuntimeException e) {
        if (e instanceof DataIntegrityViolationException) {
            return "Já existe uma pessoa cadastrada com este CPF e telefone.";
        }
        return e.getMessage() != null ? e.getMessage() : "Erro ao processar a solicitação.";
    }
}
