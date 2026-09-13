package com.vetly.vetly_java.controller;

import com.vetly.vetly_java.model.Animal;
import com.vetly.vetly_java.model.EvolucaoClinica;
import com.vetly.vetly_java.model.Tutor;
import com.vetly.vetly_java.model.Usuario;
import com.vetly.vetly_java.repository.AnimalRepository;
import com.vetly.vetly_java.repository.EvolucaoClinicaRepository;
import com.vetly.vetly_java.repository.LogAcessoProntuarioRepository;
import com.vetly.vetly_java.repository.TutorRepository;
import com.vetly.vetly_java.service.ProntuarioAdminService;
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
 * Leitura do prontuário e da colmeia (log de acesso) pelo próprio Tutor —
 * RN-063 (prontuário pertence ao animal), RN-067 (log de acesso visível ao
 * Responsável) e RN-068 (Tutor oculta itens do histórico, exceto alertas de
 * segurança, que nunca podem ser ocultados). Tutor não cria nem corrige
 * prontuário — isso é exclusivo do Veterinário.
 */
@Controller
@RequestMapping("/mvc/area-tutor/animais/{animalId}/prontuario")
public class AreaTutorProntuarioController {

    private final ProntuarioAdminService prontuarioAdminService;
    private final AnimalRepository animalRepository;
    private final TutorRepository tutorRepository;
    private final EvolucaoClinicaRepository evolucaoClinicaRepository;
    private final LogAcessoProntuarioRepository logAcessoProntuarioRepository;

    public AreaTutorProntuarioController(ProntuarioAdminService prontuarioAdminService, AnimalRepository animalRepository,
                                          TutorRepository tutorRepository, EvolucaoClinicaRepository evolucaoClinicaRepository,
                                          LogAcessoProntuarioRepository logAcessoProntuarioRepository) {
        this.prontuarioAdminService = prontuarioAdminService;
        this.animalRepository = animalRepository;
        this.tutorRepository = tutorRepository;
        this.evolucaoClinicaRepository = evolucaoClinicaRepository;
        this.logAcessoProntuarioRepository = logAcessoProntuarioRepository;
    }

    @GetMapping
    public String visualizar(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID animalId, Model model) {
        Animal animal = buscarDoTutor(usuario, animalId);
        model.addAttribute("animal", animal);
        model.addAttribute("historico", prontuarioAdminService.historico(animalId));
        model.addAttribute("evolucoes", evolucaoClinicaRepository.findByAnimalId(animalId));
        model.addAttribute("logsAcesso",
                logAcessoProntuarioRepository.findByAnimal(animal, PageRequest.of(0, 50)).getContent());
        return "area-tutor/prontuario-detalhe";
    }

    @PostMapping("/evolucoes/{evolucaoId}/ocultar")
    public String ocultar(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID animalId,
                          @PathVariable UUID evolucaoId, RedirectAttributes redirectAttributes) {
        return alterarVisibilidade(usuario, animalId, evolucaoId, "S", redirectAttributes);
    }

    @PostMapping("/evolucoes/{evolucaoId}/reexibir")
    public String reexibir(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID animalId,
                           @PathVariable UUID evolucaoId, RedirectAttributes redirectAttributes) {
        return alterarVisibilidade(usuario, animalId, evolucaoId, "N", redirectAttributes);
    }

    private String alterarVisibilidade(Usuario usuario, UUID animalId, UUID evolucaoId, String oculto,
                                       RedirectAttributes redirectAttributes) {
        buscarDoTutor(usuario, animalId);
        EvolucaoClinica evolucao = evolucaoClinicaRepository.findById(evolucaoId)
                .orElseThrow(() -> new EntityNotFoundException("Evolução clínica não encontrada: " + evolucaoId));
        if (!evolucao.getConsulta().getAnimal().getId().equals(animalId)) {
            throw new EntityNotFoundException("Evolução clínica não encontrada: " + evolucaoId);
        }
        if (evolucao.isAlertaSeguranca()) {
            redirectAttributes.addFlashAttribute("erro", "Alertas de segurança não podem ser ocultados (RN-068).");
        } else {
            evolucao.setOcultoResponsavel(oculto);
            evolucaoClinicaRepository.save(evolucao);
            redirectAttributes.addFlashAttribute("sucesso", "S".equals(oculto)
                    ? "Registro ocultado do seu histórico." : "Registro reexibido no seu histórico.");
        }
        return "redirect:/mvc/area-tutor/animais/" + animalId + "/prontuario";
    }

    private Animal buscarDoTutor(Usuario usuario, UUID animalId) {
        Animal animal = animalRepository.findById(animalId)
                .orElseThrow(() -> new EntityNotFoundException("Animal não encontrado: " + animalId));
        Tutor tutor = tutorRepository.findByUsuario(usuario);
        if (tutor == null || !animal.getTutor().getId().equals(tutor.getId())) {
            throw new EntityNotFoundException("Animal não encontrado: " + animalId);
        }
        return animal;
    }
}
