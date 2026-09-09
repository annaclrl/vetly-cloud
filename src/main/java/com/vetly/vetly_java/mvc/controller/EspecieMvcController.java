package com.vetly.vetly_java.mvc.controller;

import com.vetly.vetly_java.dto.EspecieRequest;
import com.vetly.vetly_java.model.Especie;
import com.vetly.vetly_java.model.NomeEspecie;
import com.vetly.vetly_java.service.EspecieService;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/mvc/especies")
public class EspecieMvcController {

    private final EspecieService especieService;

    public EspecieMvcController(EspecieService especieService) {
        this.especieService = especieService;
    }

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("especies", especieService.read());
        return "especies/lista";
    }

    @GetMapping("/novo")
    public String novoForm(Model model) {
        model.addAttribute("nomesDisponiveis", NomeEspecie.values());
        return "especies/novo";
    }

    @PostMapping
    public String criar(@RequestParam NomeEspecie nome, RedirectAttributes redirectAttributes) {
        try {
            especieService.create(new EspecieRequest(nome.name()));
            redirectAttributes.addFlashAttribute("sucesso", "Espécie cadastrada com sucesso.");
        } catch (DataIntegrityViolationException e) {
            redirectAttributes.addFlashAttribute("erro", "Espécie já cadastrada.");
        }
        return "redirect:/mvc/especies";
    }

    @GetMapping("/{id}/editar")
    public String editarForm(@PathVariable String id, Model model) {
        model.addAttribute("especie", especieService.read(id));
        model.addAttribute("nomesDisponiveis", NomeEspecie.values());
        return "especies/editar";
    }

    @PostMapping("/{id}/editar")
    public String atualizar(@PathVariable String id, @RequestParam NomeEspecie nome, RedirectAttributes redirectAttributes) {
        Especie especie = especieService.read(id);
        especie.setNome(nome);
        especieService.update(especie);
        redirectAttributes.addFlashAttribute("sucesso", "Espécie atualizada com sucesso.");
        return "redirect:/mvc/especies";
    }

    @PostMapping("/{id}/excluir")
    public String excluir(@PathVariable String id, RedirectAttributes redirectAttributes) {
        try {
            especieService.delete(id);
            redirectAttributes.addFlashAttribute("sucesso", "Espécie excluída com sucesso.");
        } catch (DataIntegrityViolationException e) {
            redirectAttributes.addFlashAttribute("erro", "Não é possível excluir: espécie em uso por animais ou veterinários.");
        }
        return "redirect:/mvc/especies";
    }
}
