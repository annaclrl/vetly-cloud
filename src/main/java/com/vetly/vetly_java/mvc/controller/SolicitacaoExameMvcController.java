package com.vetly.vetly_java.mvc.controller;

import com.vetly.vetly_java.model.SolicitacaoExame;
import com.vetly.vetly_java.model.SolicitacaoExameItem;
import com.vetly.vetly_java.mvc.service.SolicitacaoExameAdminService;
import com.vetly.vetly_java.repository.ConsultaRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Arrays;
import java.util.UUID;

@Controller
@RequestMapping("/mvc/exames")
public class SolicitacaoExameMvcController {

    private final SolicitacaoExameAdminService solicitacaoExameAdminService;
    private final ConsultaRepository consultaRepository;

    public SolicitacaoExameMvcController(SolicitacaoExameAdminService solicitacaoExameAdminService,
                                         ConsultaRepository consultaRepository) {
        this.solicitacaoExameAdminService = solicitacaoExameAdminService;
        this.consultaRepository = consultaRepository;
    }

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("solicitacoes", solicitacaoExameAdminService.listar());
        return "exames/lista";
    }

    @GetMapping("/novo")
    public String novoForm(@RequestParam(required = false) UUID consultaId, Model model) {
        model.addAttribute("consultaId", consultaId);
        model.addAttribute("consultas", consultaRepository.findAll());
        return "exames/novo";
    }

    @PostMapping
    public String criar(@RequestParam UUID consultaId, @RequestParam(required = false) String observacao,
                        @RequestParam String exames, RedirectAttributes redirectAttributes) {
        try {
            SolicitacaoExame solicitacao = solicitacaoExameAdminService.criar(
                    consultaId, observacao, Arrays.asList(exames.split("\\r?\\n")));
            redirectAttributes.addFlashAttribute("sucesso", "Solicitação de exame registrada com sucesso.");
            return "redirect:/mvc/exames/" + solicitacao.getId();
        } catch (RuntimeException e) {
            redirectAttributes.addFlashAttribute("erro", mensagem(e));
            return "redirect:/mvc/exames/novo?consultaId=" + consultaId;
        }
    }

    @GetMapping("/{id}")
    public String visualizar(@PathVariable UUID id, Model model) {
        model.addAttribute("solicitacao", solicitacaoExameAdminService.buscar(id));
        return "exames/detalhe";
    }

    @PostMapping("/itens/{itemId}/resultado")
    public String registrarResultado(@PathVariable UUID itemId, @RequestParam String descricaoResultado,
                                     RedirectAttributes redirectAttributes) {
        return processarItem(itemId, redirectAttributes,
                () -> solicitacaoExameAdminService.registrarResultado(itemId, descricaoResultado),
                "Resultado registrado com sucesso.");
    }

    @PostMapping("/itens/{itemId}/liberar")
    public String liberar(@PathVariable UUID itemId, RedirectAttributes redirectAttributes) {
        return processarItem(itemId, redirectAttributes,
                () -> solicitacaoExameAdminService.liberarParaResponsavel(itemId),
                "Resultado liberado para o responsável.");
    }

    @PostMapping("/itens/{itemId}/cancelar")
    public String cancelar(@PathVariable UUID itemId, RedirectAttributes redirectAttributes) {
        return processarItem(itemId, redirectAttributes,
                () -> solicitacaoExameAdminService.cancelar(itemId),
                "Exame cancelado.");
    }

    private String processarItem(UUID itemId, RedirectAttributes redirectAttributes,
                                 java.util.function.Supplier<SolicitacaoExameItem> acao, String mensagemSucesso) {
        UUID solicitacaoId = solicitacaoExameAdminService.buscarItem(itemId).getSolicitacaoExame().getId();
        try {
            acao.get();
            redirectAttributes.addFlashAttribute("sucesso", mensagemSucesso);
        } catch (RuntimeException e) {
            redirectAttributes.addFlashAttribute("erro", mensagem(e));
        }
        return "redirect:/mvc/exames/" + solicitacaoId;
    }

    private String mensagem(RuntimeException e) {
        return e.getMessage() != null ? e.getMessage() : "Erro ao processar a solicitação.";
    }
}
