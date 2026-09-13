package com.vetly.vetly_java.controller;

import com.vetly.vetly_java.model.SolicitacaoExame;
import com.vetly.vetly_java.model.Tutor;
import com.vetly.vetly_java.model.Usuario;
import com.vetly.vetly_java.repository.SolicitacaoExameRepository;
import com.vetly.vetly_java.repository.TutorRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.UUID;

/**
 * Leitura das solicitações de exame dos animais do Tutor — RN-103/104: o
 * resultado só é exibido depois que o Veterinário libera explicitamente
 * cada item (isLiberadoResponsavel()); a lógica de ocultação fica no
 * template, nunca expondo o campo antes disso.
 */
@Controller
@RequestMapping("/mvc/area-tutor/exames")
public class AreaTutorExameController {

    private final SolicitacaoExameRepository solicitacaoExameRepository;
    private final TutorRepository tutorRepository;

    public AreaTutorExameController(SolicitacaoExameRepository solicitacaoExameRepository, TutorRepository tutorRepository) {
        this.solicitacaoExameRepository = solicitacaoExameRepository;
        this.tutorRepository = tutorRepository;
    }

    @GetMapping
    public String listar(@AuthenticationPrincipal Usuario usuario, Model model) {
        model.addAttribute("solicitacoes", solicitacaoExameRepository.findByConsulta_Animal_Tutor(tutorAtual(usuario)));
        return "area-tutor/exames-lista";
    }

    @GetMapping("/{id}")
    public String visualizar(@AuthenticationPrincipal Usuario usuario, @PathVariable UUID id, Model model) {
        SolicitacaoExame solicitacao = solicitacaoExameRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Solicitação de exame não encontrada: " + id));
        if (!solicitacao.getConsulta().getAnimal().getTutor().getId().equals(tutorAtual(usuario).getId())) {
            throw new EntityNotFoundException("Solicitação de exame não encontrada: " + id);
        }
        model.addAttribute("solicitacao", solicitacao);
        return "area-tutor/exame-detalhe";
    }

    private Tutor tutorAtual(Usuario usuario) {
        Tutor tutor = tutorRepository.findByUsuario(usuario);
        if (tutor == null) {
            throw new EntityNotFoundException("Nenhum cadastro de tutor associado a este usuário");
        }
        return tutor;
    }
}
