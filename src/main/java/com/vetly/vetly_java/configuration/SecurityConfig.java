package com.vetly.vetly_java.configuration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;

/**
 * Segurança única da aplicação — server-side (Thymeleaf) sob /mvc/**, com
 * login por formulário e sessão. Três papéis, três áreas:
 * - ADMIN: painel completo (gestão de tutores, veterinários, animais, consultas, exames etc.)
 * - TUTOR: área própria em /mvc/area-tutor/** (seus animais, consultas, prontuários)
 * - VETERINARIO: área própria em /mvc/area-veterinario/** (suas consultas, prontuários que produziu)
 * Cadastro (auto-registro de Tutor/Veterinário) é público em /mvc/cadastro.
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity httpSecurity) throws Exception {
        return httpSecurity
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/mvc/login", "/mvc/logout", "/mvc/cadastro", "/mvc/cadastro/**").permitAll()
                        .requestMatchers("/mvc/area-tutor", "/mvc/area-tutor/**").hasRole("TUTOR")
                        .requestMatchers("/mvc/area-veterinario", "/mvc/area-veterinario/**").hasRole("VETERINARIO")
                        .anyRequest().hasRole("ADMIN")
                )
                .formLogin(form -> form
                        .loginPage("/mvc/login")
                        .loginProcessingUrl("/mvc/login")
                        .successHandler(successHandler())
                        .failureUrl("/mvc/login?erro")
                        .permitAll()
                )
                .logout(logout -> logout
                        .logoutUrl("/mvc/logout")
                        .logoutSuccessUrl("/mvc/login?logout")
                        .permitAll()
                )
                .build();
    }

    /**
     * Cada papel tem sua própria home: ADMIN cai no painel, TUTOR e VETERINARIO
     * caem na respectiva área restrita — evita que Tutor/Veterinário batam
     * num /mvc/ que exige ROLE_ADMIN logo após o login.
     */
    @Bean
    public AuthenticationSuccessHandler successHandler() {
        return (request, response, authentication) -> {
            boolean admin = authentication.getAuthorities().stream()
                    .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
            boolean veterinario = authentication.getAuthorities().stream()
                    .anyMatch(a -> a.getAuthority().equals("ROLE_VETERINARIO"));
            if (admin) {
                response.sendRedirect(request.getContextPath() + "/mvc/");
            } else if (veterinario) {
                response.sendRedirect(request.getContextPath() + "/mvc/area-veterinario");
            } else {
                response.sendRedirect(request.getContextPath() + "/mvc/area-tutor");
            }
        };
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
