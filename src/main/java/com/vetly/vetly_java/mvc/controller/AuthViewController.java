package com.vetly.vetly_java.mvc.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/mvc")
public class AuthViewController {

    @GetMapping("/login")
    public String login() {
        return "login";
    }
}
