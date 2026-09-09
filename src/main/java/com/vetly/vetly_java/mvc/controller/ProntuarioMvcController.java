package com.vetly.vetly_java.mvc.controller;

import com.vetly.vetly_java.mvc.service.AnimalAdminService;
import com.vetly.vetly_java.mvc.service.ProntuarioAdminService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.UUID;

@Controller
@RequestMapping("/mvc/animais/{animalId}/prontuario")
public class ProntuarioMvcController {

    private final ProntuarioAdminService prontuarioAdminService;
    private final AnimalAdminService animalAdminService;

    public ProntuarioMvcController(ProntuarioAdminService prontuarioAdminService, AnimalAdminService animalAdminService) {
        this.prontuarioAdminService = prontuarioAdminService;
        this.animalAdminService = animalAdminService;
    }

    @GetMapping
    public String visualizar(@PathVariable UUID animalId, Model model) {
        model.addAttribute("animal", animalAdminService.buscar(animalId));
        model.addAttribute("historico", prontuarioAdminService.historico(animalId));
        return "prontuarios/detalhe";
    }

    @PostMapping("/criar")
    public String criar(@PathVariable UUID animalId, @RequestParam String conteudoClinico,
                        RedirectAttributes redirectAttributes) {
        try {
            prontuarioAdminService.criar(animalId, conteudoClinico);
            redirectAttributes.addFlashAttribute("sucesso", "Prontuário criado com sucesso.");
        } catch (RuntimeException e) {
            redirectAttributes.addFlashAttribute("erro", mensagem(e));
        }
        return "redirect:/mvc/animais/" + animalId + "/prontuario";
    }

    @PostMapping("/correcoes")
    public String corrigir(@PathVariable UUID animalId, @RequestParam String conteudoClinico,
                           @RequestParam(required = false) String justificativa,
                           RedirectAttributes redirectAttributes) {
        try {
            prontuarioAdminService.corrigir(animalId, conteudoClinico, justificativa);
            redirectAttributes.addFlashAttribute("sucesso", "Correção registrada com sucesso.");
        } catch (RuntimeException e) {
            redirectAttributes.addFlashAttribute("erro", mensagem(e));
        }
        return "redirect:/mvc/animais/" + animalId + "/prontuario";
    }

    private String mensagem(RuntimeException e) {
        return e.getMessage() != null ? e.getMessage() : "Erro ao processar a solicitação.";
    }
}
