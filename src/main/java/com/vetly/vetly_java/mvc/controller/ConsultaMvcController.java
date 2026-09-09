package com.vetly.vetly_java.mvc.controller;

import com.vetly.vetly_java.model.Consulta;
import com.vetly.vetly_java.model.StatusConsulta;
import com.vetly.vetly_java.mvc.form.ConsultaForm;
import com.vetly.vetly_java.mvc.service.ConsultaAdminService;
import com.vetly.vetly_java.repository.AnimalRepository;
import com.vetly.vetly_java.repository.SolicitacaoExameRepository;
import com.vetly.vetly_java.repository.VeterinarioRepository;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.util.UUID;

@Controller
@RequestMapping("/mvc/consultas")
public class ConsultaMvcController {

    private final ConsultaAdminService consultaAdminService;
    private final AnimalRepository animalRepository;
    private final VeterinarioRepository veterinarioRepository;
    private final SolicitacaoExameRepository solicitacaoExameRepository;

    public ConsultaMvcController(ConsultaAdminService consultaAdminService, AnimalRepository animalRepository,
                                 VeterinarioRepository veterinarioRepository,
                                 SolicitacaoExameRepository solicitacaoExameRepository) {
        this.consultaAdminService = consultaAdminService;
        this.animalRepository = animalRepository;
        this.veterinarioRepository = veterinarioRepository;
        this.solicitacaoExameRepository = solicitacaoExameRepository;
    }

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("consultas", consultaAdminService.listar());
        return "consultas/lista";
    }

    @GetMapping("/novo")
    public String novoForm(Model model) {
        model.addAttribute("form", new ConsultaForm());
        adicionarListasApoio(model);
        return "consultas/novo";
    }

    @PostMapping
    public String criar(@Valid @ModelAttribute("form") ConsultaForm form, BindingResult bindingResult,
                        Model model, RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            adicionarListasApoio(model);
            return "consultas/novo";
        }
        Consulta consulta;
        try {
            consulta = consultaAdminService.criar(form);
        } catch (RuntimeException e) {
            bindingResult.reject("erro", mensagem(e));
            adicionarListasApoio(model);
            return "consultas/novo";
        }
        redirectAttributes.addFlashAttribute("sucesso", "Consulta agendada com sucesso.");
        return "redirect:/mvc/consultas/" + consulta.getId();
    }

    @GetMapping("/{id}")
    public String visualizar(@PathVariable UUID id, Model model) {
        Consulta consulta = consultaAdminService.buscar(id);
        model.addAttribute("consulta", consulta);
        model.addAttribute("solicitacaoExame", solicitacaoExameRepository.findByConsulta(consulta).orElse(null));
        return "consultas/detalhe";
    }

    @PostMapping("/{id}/reagendar")
    public String reagendar(@PathVariable UUID id, @RequestParam
                            @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE_TIME)
                            LocalDateTime dataHora,
                            RedirectAttributes redirectAttributes) {
        try {
            consultaAdminService.reagendar(id, dataHora);
            redirectAttributes.addFlashAttribute("sucesso", "Consulta reagendada com sucesso.");
        } catch (RuntimeException e) {
            redirectAttributes.addFlashAttribute("erro", mensagem(e));
        }
        return "redirect:/mvc/consultas/" + id;
    }

    @PostMapping("/{id}/cancelar")
    public String cancelar(@PathVariable UUID id, RedirectAttributes redirectAttributes) {
        return transicionar(id, StatusConsulta.CANCELADA, redirectAttributes);
    }

    @PostMapping("/{id}/realizar")
    public String realizar(@PathVariable UUID id, RedirectAttributes redirectAttributes) {
        return transicionar(id, StatusConsulta.REALIZADA, redirectAttributes);
    }

    @PostMapping("/{id}/nao-compareceu")
    public String naoCompareceu(@PathVariable UUID id, RedirectAttributes redirectAttributes) {
        return transicionar(id, StatusConsulta.NAO_COMPARECEU, redirectAttributes);
    }

    private String transicionar(UUID id, StatusConsulta destino, RedirectAttributes redirectAttributes) {
        try {
            consultaAdminService.transicionar(id, destino);
            redirectAttributes.addFlashAttribute("sucesso", "Status da consulta atualizado.");
        } catch (RuntimeException e) {
            redirectAttributes.addFlashAttribute("erro", mensagem(e));
        }
        return "redirect:/mvc/consultas/" + id;
    }

    private void adicionarListasApoio(Model model) {
        model.addAttribute("animais", animalRepository.findAll());
        model.addAttribute("veterinarios", veterinarioRepository.findAll());
    }

    private String mensagem(RuntimeException e) {
        return e.getMessage() != null ? e.getMessage() : "Erro ao processar a solicitação.";
    }
}
