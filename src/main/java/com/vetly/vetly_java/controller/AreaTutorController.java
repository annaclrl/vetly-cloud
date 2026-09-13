package com.vetly.vetly_java.controller;

import com.vetly.vetly_java.model.Tutor;
import com.vetly.vetly_java.model.Usuario;
import com.vetly.vetly_java.repository.AnimalRepository;
import com.vetly.vetly_java.repository.ConsultaRepository;
import com.vetly.vetly_java.repository.TutorRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Área própria do Tutor — apenas os dados do próprio tutor logado (RN-063:
 * prontuário e histórico pertencem ao animal/tutor, não são visão administrativa).
 * Responsabilidades e autorizações do papel TUTOR:
 * - agendar, cancelar e remarcar consultas para seus próprios animais (RN-001..013);
 * - manter o cadastro dos seus animais (peso, espécie, alergias, vacinação);
 * - ocultar itens do histórico clínico, exceto alertas de segurança (RN-068);
 * - consultar o log de acesso ao prontuário dos seus animais (RN-067);
 * - solicitar exames e receber resultados após liberação do veterinário (RN-103/104).
 * Não pode: ver ou alterar dados de outros tutores, editar prontuário (esse é
 * produzido pelo veterinário) ou acessar o painel administrativo (/mvc/**).
 */
@Controller
@RequestMapping("/mvc/area-tutor")
public class AreaTutorController {

    private final TutorRepository tutorRepository;
    private final AnimalRepository animalRepository;
    private final ConsultaRepository consultaRepository;

    public AreaTutorController(TutorRepository tutorRepository, AnimalRepository animalRepository,
                                ConsultaRepository consultaRepository) {
        this.tutorRepository = tutorRepository;
        this.animalRepository = animalRepository;
        this.consultaRepository = consultaRepository;
    }

    @GetMapping
    public String home(@AuthenticationPrincipal Usuario usuario, Model model) {
        Tutor tutor = tutorRepository.findByUsuario(usuario);
        model.addAttribute("tutor", tutor);
        model.addAttribute("animais", tutor != null ? animalRepository.findByTutor(tutor) : java.util.List.of());
        model.addAttribute("consultas", tutor != null
                ? consultaRepository.findByAnimal_Tutor(tutor, PageRequest.of(0, 20)).getContent()
                : java.util.List.of());
        return "area-tutor";
    }
}
