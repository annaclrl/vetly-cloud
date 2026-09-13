package com.vetly.vetly_java.controller;

import com.vetly.vetly_java.model.Consulta;
import com.vetly.vetly_java.model.SolicitacaoExame;
import com.vetly.vetly_java.model.SolicitacaoExameItem;
import com.vetly.vetly_java.model.Usuario;
import com.vetly.vetly_java.model.Veterinario;
import com.vetly.vetly_java.repository.ConsultaRepository;
import com.vetly.vetly_java.repository.SolicitacaoExameRepository;
import com.vetly.vetly_java.repository.VeterinarioRepository;
import com.vetly.vetly_java.service.SolicitacaoExameAdminService;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Arrays;
import java.util.UUID;

/**
 * Solicitação e liberação de exames pelo próprio Veterinário — RN-103/104:
 * o veterinário da consulta cria a solicitação, registra o resultado e só
 * então libera cada item ao Tutor explicitamente.
 */
@Controller
@RequestMapping("/mvc/area-veterinario/exames")
public class AreaVeterinarioExameController {

    private final SolicitacaoExameAdminService solicitacaoExameAdminService;
    private final SolicitacaoExameRepository solicitacaoExameRepository;
    private final ConsultaRepository consultaRepository;
    private final VeterinarioRepository veterinarioRepository;

    public AreaVeterinarioExameController(SolicitacaoExameAdminService solicitacaoExameAdminService,
                                          SolicitacaoExameRepository solicitacaoExameRepository,
                                          ConsultaRepository consultaRepository, VeterinarioRepository veterinarioRepository) {
        this.solicitacaoExameAdminService = solicitacaoExameAdminService;
        this.solicitacaoExameRepository = solicitacaoExameRepository;
        this.consultaRepository = consultaRepository;
        this.veterinarioRepository = veterinarioRepository;
    }

    @GetMapping
    public String listar(@AuthenticationPrincipal Usuario usuario, Model model) {
        model.addAttribute("solicitacoes", solicitacaoExameRepository.findByConsulta_Veterinario(veterinarioAtual(usuario)));
        return "area-veterinario/exames-lista";
    }

    @GetMapping("/novo")
    public String novoForm(@AuthenticationPrincipal Usuario usuario, @RequestParam(required = false) UUID consultaId, Model model) {
        model.addAttribute("consultaId", consultaId);
        model.addAttribute("consultas", consultaRepository.findByVeterinario(veterinarioAtual(usuario), PageRequest.of(0, 100)).getContent());
        return "area-veterinario/exame-novo";
    }

    @PostMapping
    public String criar(@AuthenticationPrincipal Usuario usuario, @RequestParam UUID consultaId,
                        @RequestParam(required = false) String observacao, @RequestParam String exames,
                        RedirectAttributes redirectAttributes) {
        buscarConsultaDoVeterinario(usuario, consultaId);
        try {
            SolicitacaoExame solicitacao = solicitacaoExameAdminService.criar(
                    consultaId, observacao, Arrays.asList(exames.split("\\r?\\n")));
            redirectAttributes.addFlashAttribute("sucesso", "Solicitação de exame registrada com sucesso.");
            return "redirect:/mvc/area-veterinario/exames/" + solicitacao.getId();
        } catch (RuntimeException e) {
            redirectAttributes.addFlashAttribute("erro", mensagem(e));
            return "redirect:/mvc/area-veterinario/exames/novo?consultaId=" + consultaId;
        }
    }

    @GetMapping("/{id}")
    public String visualizar(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID id, Model model) {
        model.addAttribute("solicitacao", buscarDoVeterinario(usuario, id));
        return "area-veterinario/exame-detalhe";
    }

    @PostMapping("/itens/{itemId}/resultado")
    public String registrarResultado(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID itemId,
                                     @RequestParam String descricaoResultado, RedirectAttributes redirectAttributes) {
        return processarItem(usuario, itemId, redirectAttributes,
                () -> solicitacaoExameAdminService.registrarResultado(itemId, descricaoResultado),
                "Resultado registrado com sucesso.");
    }

    @PostMapping("/itens/{itemId}/liberar")
    public String liberar(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID itemId,
                          RedirectAttributes redirectAttributes) {
        return processarItem(usuario, itemId, redirectAttributes,
                () -> solicitacaoExameAdminService.liberarParaResponsavel(itemId),
                "Resultado liberado para o tutor.");
    }

    @PostMapping("/itens/{itemId}/cancelar")
    public String cancelar(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID itemId,
                           RedirectAttributes redirectAttributes) {
        return processarItem(usuario, itemId, redirectAttributes,
                () -> solicitacaoExameAdminService.cancelar(itemId),
                "Exame cancelado.");
    }

    private String processarItem(Usuario usuario, UUID itemId, RedirectAttributes redirectAttributes,
                                 java.util.function.Supplier<SolicitacaoExameItem> acao, String mensagemSucesso) {
        SolicitacaoExameItem item = solicitacaoExameAdminService.buscarItem(itemId);
        UUID solicitacaoId = item.getSolicitacaoExame().getId();
        if (!item.getSolicitacaoExame().getConsulta().getVeterinario().getId().equals(veterinarioAtual(usuario).getId())) {
            throw new EntityNotFoundException("Item de exame não encontrado: " + itemId);
        }
        try {
            acao.get();
            redirectAttributes.addFlashAttribute("sucesso", mensagemSucesso);
        } catch (RuntimeException e) {
            redirectAttributes.addFlashAttribute("erro", mensagem(e));
        }
        return "redirect:/mvc/area-veterinario/exames/" + solicitacaoId;
    }

    private void buscarConsultaDoVeterinario(Usuario usuario, UUID consultaId) {
        Consulta consulta = consultaRepository.findById(consultaId)
                .orElseThrow(() -> new EntityNotFoundException("Consulta não encontrada: " + consultaId));
        if (!consulta.getVeterinario().getId().equals(veterinarioAtual(usuario).getId())) {
            throw new EntityNotFoundException("Consulta não encontrada: " + consultaId);
        }
    }

    private SolicitacaoExame buscarDoVeterinario(Usuario usuario, UUID id) {
        SolicitacaoExame solicitacao = solicitacaoExameAdminService.buscar(id);
        if (!solicitacao.getConsulta().getVeterinario().getId().equals(veterinarioAtual(usuario).getId())) {
            throw new EntityNotFoundException("Solicitação de exame não encontrada: " + id);
        }
        return solicitacao;
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
