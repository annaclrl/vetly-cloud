package com.vetly.vetly_java.mvc.controller;

import com.vetly.vetly_java.dto.EspecialidadeVetRequest;
import com.vetly.vetly_java.model.EspecialidadeVet;
import com.vetly.vetly_java.model.NomeEspecialidade;
import com.vetly.vetly_java.repository.EspecialidadeVetRepository;
import com.vetly.vetly_java.service.EspecialidadeVetService;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/mvc/especialidades")
public class EspecialidadeVetMvcController {

    private final EspecialidadeVetService especialidadeVetService;
    private final EspecialidadeVetRepository especialidadeVetRepository;

    public EspecialidadeVetMvcController(EspecialidadeVetService especialidadeVetService,
                                         EspecialidadeVetRepository especialidadeVetRepository) {
        this.especialidadeVetService = especialidadeVetService;
        this.especialidadeVetRepository = especialidadeVetRepository;
    }

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("especialidades", especialidadeVetRepository.findAll());
        return "especialidades/lista";
    }

    @GetMapping("/novo")
    public String novoForm(Model model) {
        model.addAttribute("nomesDisponiveis", NomeEspecialidade.values());
        return "especialidades/novo";
    }

    @PostMapping
    public String criar(@RequestParam NomeEspecialidade nome, @RequestParam String descricao,
                        RedirectAttributes redirectAttributes) {
        try {
            especialidadeVetService.create(new EspecialidadeVetRequest(nome.name(), descricao));
            redirectAttributes.addFlashAttribute("sucesso", "Especialidade cadastrada com sucesso.");
        } catch (DataIntegrityViolationException e) {
            redirectAttributes.addFlashAttribute("erro", "Especialidade já cadastrada.");
        }
        return "redirect:/mvc/especialidades";
    }

    @GetMapping("/{id}/editar")
    public String editarForm(@PathVariable String id, Model model) {
        model.addAttribute("especialidade", especialidadeVetService.readById(id));
        model.addAttribute("nomesDisponiveis", NomeEspecialidade.values());
        return "especialidades/editar";
    }

    @PostMapping("/{id}/editar")
    public String atualizar(@PathVariable String id, @RequestParam NomeEspecialidade nome,
                            @RequestParam String descricao, RedirectAttributes redirectAttributes) {
        EspecialidadeVet especialidade = especialidadeVetService.readById(id);
        especialidade.setNome(nome);
        especialidade.setDescricao(descricao);
        especialidadeVetService.update(especialidade);
        redirectAttributes.addFlashAttribute("sucesso", "Especialidade atualizada com sucesso.");
        return "redirect:/mvc/especialidades";
    }

    @PostMapping("/{id}/excluir")
    public String excluir(@PathVariable String id, RedirectAttributes redirectAttributes) {
        try {
            especialidadeVetService.delete(id);
            redirectAttributes.addFlashAttribute("sucesso", "Especialidade excluída com sucesso.");
        } catch (DataIntegrityViolationException e) {
            redirectAttributes.addFlashAttribute("erro", "Não é possível excluir: especialidade em uso por veterinários.");
        }
        return "redirect:/mvc/especialidades";
    }
}
