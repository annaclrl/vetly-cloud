package com.vetly.vetly_java.mvc.controller;

import com.vetly.vetly_java.model.NomeEspecialidade;
import com.vetly.vetly_java.model.NomeEspecie;
import com.vetly.vetly_java.model.Veterinario;
import com.vetly.vetly_java.mvc.form.VeterinarioCreateForm;
import com.vetly.vetly_java.mvc.form.VeterinarioEditForm;
import com.vetly.vetly_java.mvc.service.VeterinarioAdminService;
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
@RequestMapping("/mvc/veterinarios")
public class VeterinarioMvcController {

    private final VeterinarioAdminService veterinarioAdminService;

    public VeterinarioMvcController(VeterinarioAdminService veterinarioAdminService) {
        this.veterinarioAdminService = veterinarioAdminService;
    }

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("veterinarios", veterinarioAdminService.listar());
        return "veterinarios/lista";
    }

    @GetMapping("/novo")
    public String novoForm(Model model) {
        model.addAttribute("form", new VeterinarioCreateForm());
        model.addAttribute("especialidadesDisponiveis", NomeEspecialidade.values());
        model.addAttribute("especiesDisponiveis", NomeEspecie.values());
        return "veterinarios/novo";
    }

    @PostMapping
    public String criar(@Valid @ModelAttribute("form") VeterinarioCreateForm form, BindingResult bindingResult,
                        Model model, RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            model.addAttribute("especialidadesDisponiveis", NomeEspecialidade.values());
            model.addAttribute("especiesDisponiveis", NomeEspecie.values());
            return "veterinarios/novo";
        }
        try {
            veterinarioAdminService.criar(form);
        } catch (RuntimeException e) {
            bindingResult.reject("erro", mensagem(e));
            model.addAttribute("especialidadesDisponiveis", NomeEspecialidade.values());
            model.addAttribute("especiesDisponiveis", NomeEspecie.values());
            return "veterinarios/novo";
        }
        redirectAttributes.addFlashAttribute("sucesso", "Veterinário cadastrado com sucesso.");
        return "redirect:/mvc/veterinarios";
    }

    @GetMapping("/{id}")
    public String visualizar(@PathVariable UUID id, Model model) {
        model.addAttribute("veterinario", veterinarioAdminService.buscar(id));
        return "veterinarios/detalhe";
    }

    @GetMapping("/{id}/editar")
    public String editarForm(@PathVariable UUID id, Model model) {
        Veterinario veterinario = veterinarioAdminService.buscar(id);
        VeterinarioEditForm form = new VeterinarioEditForm();
        form.setNome(veterinario.getPessoa().getNome());
        form.setTelefone(veterinario.getPessoa().getTelefone());
        form.setCrmv(veterinario.getCrmv());
        form.setEspecialidades(veterinario.getEspecialidades().stream()
                .map(e -> e.getEspecialidade().getNome().name()).toList());
        form.setEspecies(veterinario.getEspecies().stream()
                .map(e -> e.getEspecie().getNome().name()).toList());
        model.addAttribute("form", form);
        model.addAttribute("veterinario", veterinario);
        model.addAttribute("especialidadesDisponiveis", NomeEspecialidade.values());
        model.addAttribute("especiesDisponiveis", NomeEspecie.values());
        return "veterinarios/editar";
    }

    @PostMapping("/{id}/editar")
    public String atualizar(@PathVariable UUID id, @Valid @ModelAttribute("form") VeterinarioEditForm form,
                            BindingResult bindingResult, Model model, RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            model.addAttribute("veterinario", veterinarioAdminService.buscar(id));
            model.addAttribute("especialidadesDisponiveis", NomeEspecialidade.values());
            model.addAttribute("especiesDisponiveis", NomeEspecie.values());
            return "veterinarios/editar";
        }
        try {
            veterinarioAdminService.atualizar(id, form);
        } catch (RuntimeException e) {
            bindingResult.reject("erro", mensagem(e));
            model.addAttribute("veterinario", veterinarioAdminService.buscar(id));
            model.addAttribute("especialidadesDisponiveis", NomeEspecialidade.values());
            model.addAttribute("especiesDisponiveis", NomeEspecie.values());
            return "veterinarios/editar";
        }
        redirectAttributes.addFlashAttribute("sucesso", "Veterinário atualizado com sucesso.");
        return "redirect:/mvc/veterinarios/" + id;
    }

    @PostMapping("/{id}/excluir")
    public String excluir(@PathVariable UUID id, RedirectAttributes redirectAttributes) {
        try {
            veterinarioAdminService.excluir(id);
            redirectAttributes.addFlashAttribute("sucesso", "Veterinário excluído com sucesso.");
        } catch (DataIntegrityViolationException e) {
            redirectAttributes.addFlashAttribute("erro", "Não é possível excluir: veterinário possui consultas vinculadas.");
        } catch (EntityNotFoundException e) {
            redirectAttributes.addFlashAttribute("erro", "Veterinário não encontrado.");
        }
        return "redirect:/mvc/veterinarios";
    }

    private String mensagem(RuntimeException e) {
        return e.getMessage() != null ? e.getMessage() : "Erro ao processar a solicitação.";
    }
}
