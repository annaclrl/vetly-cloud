package com.vetly.vetly_java.mvc.controller;

import com.vetly.vetly_java.model.Usuario;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice(basePackages = "com.vetly.vetly_java.mvc.controller")
public class MvcControllerAdvice {

    @ModelAttribute("usuarioLogado")
    public String usuarioLogado(Authentication authentication) {
        if (authentication == null || !(authentication.getPrincipal() instanceof Usuario usuario)) {
            return null;
        }
        return usuario.getEmail() + " (" + usuario.getRole() + ")";
    }
}
