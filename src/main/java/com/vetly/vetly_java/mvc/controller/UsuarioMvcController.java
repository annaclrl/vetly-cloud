package com.vetly.vetly_java.mvc.controller;

import com.vetly.vetly_java.mvc.service.UsuarioAdminService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.UUID;

@Controller
@RequestMapping("/mvc/usuarios")
public class UsuarioMvcController {

    private final UsuarioAdminService usuarioAdminService;

    public UsuarioMvcController(UsuarioAdminService usuarioAdminService) {
        this.usuarioAdminService = usuarioAdminService;
    }

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("usuarios", usuarioAdminService.listar());
        return "usuarios/lista";
    }

    @GetMapping("/{id}")
    public String visualizar(@PathVariable UUID id, Model model) {
        model.addAttribute("usuario", usuarioAdminService.buscar(id));
        return "usuarios/detalhe";
    }

    @PostMapping("/{id}/alternar-ativo")
    public String alternarAtivo(@PathVariable UUID id, RedirectAttributes redirectAttributes) {
        usuarioAdminService.alternarAtivo(id);
        redirectAttributes.addFlashAttribute("sucesso", "Status do usuário atualizado.");
        return "redirect:/mvc/usuarios/" + id;
    }
}
