package com.vetly.vetly_java.controller;

import com.vetly.vetly_java.model.Consulta;
import com.vetly.vetly_java.model.StatusConsulta;
import com.vetly.vetly_java.model.Usuario;
import com.vetly.vetly_java.model.Veterinario;
import com.vetly.vetly_java.repository.ConsultaRepository;
import com.vetly.vetly_java.repository.EvolucaoClinicaRepository;
import com.vetly.vetly_java.repository.SolicitacaoExameRepository;
import com.vetly.vetly_java.repository.VeterinarioRepository;
import com.vetly.vetly_java.service.ConsultaAdminService;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.UUID;

/**
 * Consultas atribuídas ao próprio Veterinário — RN-008: só ele inicia
 * (REALIZADA) ou encerra sem comparecimento (NAO_COMPARECEU) a própria
 * consulta; cancelar/remarcar continuam exclusivos do Tutor.
 */
@Controller
@RequestMapping("/mvc/area-veterinario/consultas")
public class AreaVeterinarioConsultaController {

    private final ConsultaAdminService consultaAdminService;
    private final ConsultaRepository consultaRepository;
    private final VeterinarioRepository veterinarioRepository;
    private final SolicitacaoExameRepository solicitacaoExameRepository;
    private final EvolucaoClinicaRepository evolucaoClinicaRepository;

    public AreaVeterinarioConsultaController(ConsultaAdminService consultaAdminService, ConsultaRepository consultaRepository,
                                              VeterinarioRepository veterinarioRepository,
                                              SolicitacaoExameRepository solicitacaoExameRepository,
                                              EvolucaoClinicaRepository evolucaoClinicaRepository) {
        this.consultaAdminService = consultaAdminService;
        this.consultaRepository = consultaRepository;
        this.veterinarioRepository = veterinarioRepository;
        this.solicitacaoExameRepository = solicitacaoExameRepository;
        this.evolucaoClinicaRepository = evolucaoClinicaRepository;
    }

    @GetMapping
    public String listar(@AuthenticationPrincipal Usuario usuario, Model model) {
        Veterinario veterinario = veterinarioAtual(usuario);
        model.addAttribute("consultas", consultaRepository.findByVeterinario(veterinario, PageRequest.of(0, 50)).getContent());
        return "area-veterinario/consultas-lista";
    }

    @GetMapping("/{id}")
    public String visualizar(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID id, Model model) {
        Consulta consulta = buscarDoVeterinario(usuario, id);
        model.addAttribute("consulta", consulta);
        model.addAttribute("solicitacaoExame", solicitacaoExameRepository.findByConsulta(consulta).orElse(null));
        model.addAttribute("evolucao", evolucaoClinicaRepository.findByConsulta(consulta).orElse(null));
        return "area-veterinario/consulta-detalhe";
    }

    @PostMapping("/{id}/realizar")
    public String realizar(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID id,
                           RedirectAttributes redirectAttributes) {
        return transicionar(usuario, id, StatusConsulta.REALIZADA, redirectAttributes);
    }

    @PostMapping("/{id}/nao-compareceu")
    public String naoCompareceu(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID id,
                                RedirectAttributes redirectAttributes) {
        return transicionar(usuario, id, StatusConsulta.NAO_COMPARECEU, redirectAttributes);
    }

    private String transicionar(Usuario usuario, UUID id, StatusConsulta destino, RedirectAttributes redirectAttributes) {
        buscarDoVeterinario(usuario, id);
        try {
            consultaAdminService.transicionar(id, destino);
            redirectAttributes.addFlashAttribute("sucesso", "Status da consulta atualizado.");
        } catch (RuntimeException e) {
            redirectAttributes.addFlashAttribute("erro", mensagem(e));
        }
        return "redirect:/mvc/area-veterinario/consultas/" + id;
    }

    private Consulta buscarDoVeterinario(Usuario usuario, UUID id) {
        Consulta consulta = consultaAdminService.buscar(id);
        if (!consulta.getVeterinario().getId().equals(veterinarioAtual(usuario).getId())) {
            throw new EntityNotFoundException("Consulta não encontrada: " + id);
        }
        return consulta;
    }

    private Veterinario veterinarioAtual(Usuario usuario) {
        Veterinario veterinario = veterinarioRepository.findByUsuario(usuario);
        if (veterinario == null) {
            throw new EntityNotFoundException("Nenhum cadastro de veterinário associado a este usuário");
        }
        return veterinario;
    }

    private String mensagem(RuntimeException e) {
        return e.getMessage() != null ? e.getMessage() : "Erro ao processar a solicitação.";
    }
}
