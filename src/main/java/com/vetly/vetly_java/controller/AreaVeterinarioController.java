package com.vetly.vetly_java.controller;

import com.vetly.vetly_java.model.Usuario;
import com.vetly.vetly_java.model.Veterinario;
import com.vetly.vetly_java.repository.ConsultaRepository;
import com.vetly.vetly_java.repository.VeterinarioRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Área própria do Veterinário — apenas as consultas atribuídas a ele.
 * Responsabilidades e autorizações do papel VETERINARIO:
 * - iniciar e encerrar as consultas atribuídas a ele (RN-008);
 * - registrar evolução clínica e prontuário do animal atendido (RN-063, manual, sem IA);
 * - corrigir o prontuário em até 24h livremente, depois exige justificativa,
 *   sem nunca sobrescrever o original (RN-088/089);
 * - solicitar exames e liberar resultados ao tutor explicitamente (RN-103/104);
 * - acesso ao histórico do animal é concedido por evento clínico (colmeia) e
 *   expira ao fim do ciclo — todo acesso gera log visível ao tutor (RN-064..067).
 * Não pode: ver consultas ou prontuários de animais fora do seu próprio
 * atendimento, gerenciar outros veterinários/tutores ou acessar o painel
 * administrativo (/mvc/**).
 */
@Controller
@RequestMapping("/mvc/area-veterinario")
public class AreaVeterinarioController {

    private final VeterinarioRepository veterinarioRepository;
    private final ConsultaRepository consultaRepository;

    public AreaVeterinarioController(VeterinarioRepository veterinarioRepository, ConsultaRepository consultaRepository) {
        this.veterinarioRepository = veterinarioRepository;
        this.consultaRepository = consultaRepository;
    }

    @GetMapping
    public String home(@AuthenticationPrincipal Usuario usuario, Model model) {
        Veterinario veterinario = veterinarioRepository.findByUsuario(usuario);
        model.addAttribute("veterinario", veterinario);
        model.addAttribute("consultas", veterinario != null
                ? consultaRepository.findByVeterinario(veterinario, PageRequest.of(0, 20)).getContent()
                : java.util.List.of());
        return "area-veterinario";
    }
}
