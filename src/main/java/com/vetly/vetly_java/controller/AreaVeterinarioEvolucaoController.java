package com.vetly.vetly_java.controller;

import com.vetly.vetly_java.model.Consulta;
import com.vetly.vetly_java.model.EvolucaoClinica;
import com.vetly.vetly_java.model.Usuario;
import com.vetly.vetly_java.model.Veterinario;
import com.vetly.vetly_java.repository.ConsultaRepository;
import com.vetly.vetly_java.repository.EvolucaoClinicaRepository;
import com.vetly.vetly_java.repository.VeterinarioRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.UUID;

/**
 * Registro de evolução clínica pelo Veterinário — 1:1 com a própria consulta
 * (RN-063/Colmeia, detalhe interno do Prontuário, conforme java-scope.md).
 * Só o veterinário da própria consulta pode registrá-la; alerta de segurança
 * marcado aqui nunca poderá ser ocultado pelo Tutor (RN-068).
 */
@Controller
@RequestMapping("/mvc/area-veterinario/consultas/{consultaId}/evolucao")
public class AreaVeterinarioEvolucaoController {

    private final ConsultaRepository consultaRepository;
    private final EvolucaoClinicaRepository evolucaoClinicaRepository;
    private final VeterinarioRepository veterinarioRepository;

    public AreaVeterinarioEvolucaoController(ConsultaRepository consultaRepository,
                                              EvolucaoClinicaRepository evolucaoClinicaRepository,
                                              VeterinarioRepository veterinarioRepository) {
        this.consultaRepository = consultaRepository;
        this.evolucaoClinicaRepository = evolucaoClinicaRepository;
        this.veterinarioRepository = veterinarioRepository;
    }

    @PostMapping
    public String registrar(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID consultaId,
                            @RequestParam String anotacoes, @RequestParam(required = false) Boolean alertaSeguranca,
                            RedirectAttributes redirectAttributes) {
        Consulta consulta = buscarDoVeterinario(usuario, consultaId);
        if (evolucaoClinicaRepository.findByConsulta(consulta).isPresent()) {
            redirectAttributes.addFlashAttribute("erro", "Esta consulta já possui uma evolução clínica registrada.");
            return "redirect:/mvc/area-veterinario/consultas/" + consultaId;
        }
        EvolucaoClinica evolucao = new EvolucaoClinica(UUID.randomUUID(), anotacoes, consulta);
        evolucao.setAlertaSeguranca(Boolean.TRUE.equals(alertaSeguranca) ? "S" : "N");
        evolucaoClinicaRepository.save(evolucao);
        redirectAttributes.addFlashAttribute("sucesso", "Evolução clínica registrada com sucesso.");
        return "redirect:/mvc/area-veterinario/consultas/" + consultaId;
    }

    private Consulta buscarDoVeterinario(Usuario usuario, UUID consultaId) {
        Consulta consulta = consultaRepository.findById(consultaId)
                .orElseThrow(() -> new EntityNotFoundException("Consulta não encontrada: " + consultaId));
        Veterinario veterinario = veterinarioRepository.findByUsuario(usuario);
        if (veterinario == null || !consulta.getVeterinario().getId().equals(veterinario.getId())) {
            throw new EntityNotFoundException("Consulta não encontrada: " + consultaId);
        }
        return consulta;
    }
}
