package com.vetly.vetly_java.controller;

import com.vetly.vetly_java.form.ConsultaForm;
import com.vetly.vetly_java.model.Consulta;
import com.vetly.vetly_java.model.StatusConsulta;
import com.vetly.vetly_java.model.Tutor;
import com.vetly.vetly_java.model.Usuario;
import com.vetly.vetly_java.repository.AnimalRepository;
import com.vetly.vetly_java.repository.ConsultaRepository;
import com.vetly.vetly_java.repository.SolicitacaoExameRepository;
import com.vetly.vetly_java.repository.TutorRepository;
import com.vetly.vetly_java.repository.VeterinarioRepository;
import com.vetly.vetly_java.service.ConsultaAdminService;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.Valid;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Agendamento/cancelamento/remarcação de consultas pelo próprio Tutor
 * (RN-001..013 adaptadas — sem cobrança/lock de checkout, fora de escopo do
 * Java). Tutor só enxerga e opera consultas dos seus próprios animais; as
 * transições "realizar"/"não compareceu" são exclusivas do Veterinário.
 */
@Controller
@RequestMapping("/mvc/area-tutor/consultas")
public class AreaTutorConsultaController {

    private final ConsultaAdminService consultaAdminService;
    private final ConsultaRepository consultaRepository;
    private final AnimalRepository animalRepository;
    private final VeterinarioRepository veterinarioRepository;
    private final SolicitacaoExameRepository solicitacaoExameRepository;
    private final TutorRepository tutorRepository;

    public AreaTutorConsultaController(ConsultaAdminService consultaAdminService, ConsultaRepository consultaRepository,
                                        AnimalRepository animalRepository, VeterinarioRepository veterinarioRepository,
                                        SolicitacaoExameRepository solicitacaoExameRepository,
                                        TutorRepository tutorRepository) {
        this.consultaAdminService = consultaAdminService;
        this.consultaRepository = consultaRepository;
        this.animalRepository = animalRepository;
        this.veterinarioRepository = veterinarioRepository;
        this.solicitacaoExameRepository = solicitacaoExameRepository;
        this.tutorRepository = tutorRepository;
    }

    @GetMapping
    public String listar(@AuthenticationPrincipal Usuario usuario, Model model) {
        Tutor tutor = tutorAtual(usuario);
        model.addAttribute("consultas", consultaRepository.findByAnimal_Tutor(tutor, PageRequest.of(0, 50)).getContent());
        return "area-tutor/consultas-lista";
    }

    @GetMapping("/novo")
    public String novoForm(@AuthenticationPrincipal Usuario usuario, Model model) {
        adicionarListasApoio(usuario, model);
        model.addAttribute("form", new ConsultaForm());
        return "area-tutor/consulta-novo";
    }

    @PostMapping
    public String criar(@AuthenticationPrincipal Usuario usuario, @Valid @ModelAttribute("form") ConsultaForm form,
                        BindingResult bindingResult, Model model, RedirectAttributes redirectAttributes) {
        Tutor tutor = tutorAtual(usuario);
        if (!bindingResult.hasErrors() && !pertenceAoTutor(form.getAnimalId(), tutor)) {
            bindingResult.reject("erro", "Selecione um dos seus próprios animais.");
        }
        if (bindingResult.hasErrors()) {
            adicionarListasApoio(usuario, model);
            return "area-tutor/consulta-novo";
        }
        Consulta consulta;
        try {
            consulta = consultaAdminService.criar(form);
        } catch (RuntimeException e) {
            bindingResult.reject("erro", mensagem(e));
            adicionarListasApoio(usuario, model);
            return "area-tutor/consulta-novo";
        }
        redirectAttributes.addFlashAttribute("sucesso", "Consulta agendada com sucesso.");
        return "redirect:/mvc/area-tutor/consultas/" + consulta.getId();
    }

    @GetMapping("/{id}")
    public String visualizar(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID id, Model model) {
        Consulta consulta = buscarDoTutor(usuario, id);
        model.addAttribute("consulta", consulta);
        model.addAttribute("solicitacaoExame", solicitacaoExameRepository.findByConsulta(consulta).orElse(null));
        return "area-tutor/consulta-detalhe";
    }

    @PostMapping("/{id}/reagendar")
    public String reagendar(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID id,
                            @RequestParam @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE_TIME)
                            LocalDateTime dataHora, RedirectAttributes redirectAttributes) {
        buscarDoTutor(usuario, id);
        try {
            consultaAdminService.reagendar(id, dataHora);
            redirectAttributes.addFlashAttribute("sucesso", "Consulta reagendada com sucesso.");
        } catch (RuntimeException e) {
            redirectAttributes.addFlashAttribute("erro", mensagem(e));
        }
        return "redirect:/mvc/area-tutor/consultas/" + id;
    }

    @PostMapping("/{id}/cancelar")
    public String cancelar(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID id,
                           RedirectAttributes redirectAttributes) {
        buscarDoTutor(usuario, id);
        try {
            consultaAdminService.transicionar(id, StatusConsulta.CANCELADA);
            redirectAttributes.addFlashAttribute("sucesso", "Consulta cancelada.");
        } catch (RuntimeException e) {
            redirectAttributes.addFlashAttribute("erro", mensagem(e));
        }
        return "redirect:/mvc/area-tutor/consultas/" + id;
    }

    private boolean pertenceAoTutor(UUID animalId, Tutor tutor) {
        if (animalId == null) {
            return false;
        }
        return animalRepository.findById(animalId)
                .map(a -> a.getTutor().getId().equals(tutor.getId()))
                .orElse(false);
    }

    private Consulta buscarDoTutor(Usuario usuario, UUID id) {
        Consulta consulta = consultaAdminService.buscar(id);
        if (!consulta.getAnimal().getTutor().getId().equals(tutorAtual(usuario).getId())) {
            throw new EntityNotFoundException("Consulta não encontrada: " + id);
        }
        return consulta;
    }

    private Tutor tutorAtual(Usuario usuario) {
        Tutor tutor = tutorRepository.findByUsuario(usuario);
        if (tutor == null) {
            throw new EntityNotFoundException("Nenhum cadastro de tutor associado a este usuário");
        }
        return tutor;
    }

    private void adicionarListasApoio(Usuario usuario, Model model) {
        model.addAttribute("animais", animalRepository.findByTutor(tutorAtual(usuario)));
        model.addAttribute("veterinarios", veterinarioRepository.findAll());
    }

    private String mensagem(RuntimeException e) {
        return e.getMessage() != null ? e.getMessage() : "Erro ao processar a solicitação.";
    }
}
