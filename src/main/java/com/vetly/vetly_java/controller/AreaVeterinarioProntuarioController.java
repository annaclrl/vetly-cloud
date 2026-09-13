package com.vetly.vetly_java.controller;

import com.vetly.vetly_java.model.Animal;
import com.vetly.vetly_java.model.BaseAcesso;
import com.vetly.vetly_java.model.LogAcessoProntuario;
import com.vetly.vetly_java.model.StatusConsulta;
import com.vetly.vetly_java.model.Usuario;
import com.vetly.vetly_java.model.Veterinario;
import com.vetly.vetly_java.repository.AnimalRepository;
import com.vetly.vetly_java.repository.ConsultaRepository;
import com.vetly.vetly_java.repository.EvolucaoClinicaRepository;
import com.vetly.vetly_java.repository.LogAcessoProntuarioRepository;
import com.vetly.vetly_java.repository.VeterinarioRepository;
import com.vetly.vetly_java.service.ProntuarioAdminService;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Prontuário e Colmeia sob a ótica do Veterinário — RN-064/065: acesso só é
 * concedido a quem tem ao menos uma consulta não-cancelada com o animal;
 * com consentimento de rede do Tutor vê o histórico completo, sem
 * consentimento só as próprias evoluções. Todo acesso gera
 * LogAcessoProntuario (RN-067). Criação é única por animal; correção segue
 * RN-088/089 (24h livre, depois exige justificativa, original nunca sobrescrito).
 */
@Controller
@RequestMapping("/mvc/area-veterinario/animais/{animalId}/prontuario")
public class AreaVeterinarioProntuarioController {

    private final ProntuarioAdminService prontuarioAdminService;
    private final AnimalRepository animalRepository;
    private final VeterinarioRepository veterinarioRepository;
    private final ConsultaRepository consultaRepository;
    private final EvolucaoClinicaRepository evolucaoClinicaRepository;
    private final LogAcessoProntuarioRepository logAcessoProntuarioRepository;

    public AreaVeterinarioProntuarioController(ProntuarioAdminService prontuarioAdminService, AnimalRepository animalRepository,
                                                VeterinarioRepository veterinarioRepository, ConsultaRepository consultaRepository,
                                                EvolucaoClinicaRepository evolucaoClinicaRepository,
                                                LogAcessoProntuarioRepository logAcessoProntuarioRepository) {
        this.prontuarioAdminService = prontuarioAdminService;
        this.animalRepository = animalRepository;
        this.veterinarioRepository = veterinarioRepository;
        this.consultaRepository = consultaRepository;
        this.evolucaoClinicaRepository = evolucaoClinicaRepository;
        this.logAcessoProntuarioRepository = logAcessoProntuarioRepository;
    }

    @GetMapping
    public String visualizar(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID animalId, Model model) {
        Animal animal = buscarComAcessoColmeia(usuario, animalId);
        Veterinario veterinario = veterinarioAtual(usuario);
        boolean consentimentoRede = animal.getTutor().isConsentimentoRede();

        model.addAttribute("animal", animal);
        model.addAttribute("historico", prontuarioAdminService.historico(animalId));
        model.addAttribute("evolucoes", consentimentoRede
                ? evolucaoClinicaRepository.findByAnimalId(animalId)
                : evolucaoClinicaRepository.findByAnimalIdAndVeterinarioId(animalId, veterinario.getId()));

        LogAcessoProntuario log = new LogAcessoProntuario(UUID.randomUUID(), LocalDateTime.now(),
                "Consulta da colmeia do animal", consentimentoRede ? BaseAcesso.CONSENTIMENTO_REDE : BaseAcesso.ATENDIMENTO_DIRETO,
                animal, veterinario);
        logAcessoProntuarioRepository.save(log);

        return "area-veterinario/prontuario-detalhe";
    }

    @PostMapping("/criar")
    public String criar(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID animalId,
                        @RequestParam String conteudoClinico, RedirectAttributes redirectAttributes) {
        buscarComAcessoColmeia(usuario, animalId);
        try {
            prontuarioAdminService.criar(animalId, conteudoClinico);
            redirectAttributes.addFlashAttribute("sucesso", "Prontuário criado com sucesso.");
        } catch (RuntimeException e) {
            redirectAttributes.addFlashAttribute("erro", mensagem(e));
        }
        return "redirect:/mvc/area-veterinario/animais/" + animalId + "/prontuario";
    }

    @PostMapping("/correcoes")
    public String corrigir(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID animalId,
                           @RequestParam String conteudoClinico, @RequestParam(required = false) String justificativa,
                           RedirectAttributes redirectAttributes) {
        buscarComAcessoColmeia(usuario, animalId);
        try {
            prontuarioAdminService.corrigir(animalId, conteudoClinico, justificativa, veterinarioAtual(usuario).getCrmv());
            redirectAttributes.addFlashAttribute("sucesso", "Correção registrada com sucesso.");
        } catch (RuntimeException e) {
            redirectAttributes.addFlashAttribute("erro", mensagem(e));
        }
        return "redirect:/mvc/area-veterinario/animais/" + animalId + "/prontuario";
    }

    private Animal buscarComAcessoColmeia(Usuario usuario, UUID animalId) {
        Animal animal = animalRepository.findById(animalId)
                .orElseThrow(() -> new EntityNotFoundException("Animal não encontrado: " + animalId));
        Veterinario veterinario = veterinarioAtual(usuario);
        boolean temVinculoClinico = consultaRepository.existsByAnimalAndVeterinarioAndStatusNot(
                animal, veterinario, StatusConsulta.CANCELADA);
        if (!temVinculoClinico) {
            throw new EntityNotFoundException(
                    "Acesso ao histórico deste animal exige ao menos uma consulta não cancelada com ele (Colmeia)");
        }
        return animal;
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
