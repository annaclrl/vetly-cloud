package com.vetly.vetly_java.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/mvc")
public class AuthViewController {

    @GetMapping("/login")
    public String login(HttpServletRequest request) {
        // Cria a sessao antes de renderizar: o token CSRF do formulario precisa dela, e apos o logout
        // nao existe sessao. O <head> do template e grande o bastante para a resposta ser enviada
        // antes do formulario, e criar a sessao nesse ponto falha ("response has been committed").
        request.getSession(true);
        return "login";
    }
}
