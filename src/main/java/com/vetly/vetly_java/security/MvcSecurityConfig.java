package com.vetly.vetly_java.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Segurança única da aplicação — painel administrativo server-side (Thymeleaf)
 * sob /mvc/**, com login por formulário e sessão. Só ADMIN acessa; TUTOR e
 * VETERINARIO existem apenas como dados de cadastro geridos pelo painel.
 */
@Configuration
@EnableWebSecurity
public class MvcSecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity httpSecurity) throws Exception {
        return httpSecurity
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/mvc/login").permitAll()
                        .anyRequest().hasRole("ADMIN")
                )
                .formLogin(form -> form
                        .loginPage("/mvc/login")
                        .loginProcessingUrl("/mvc/login")
                        .defaultSuccessUrl("/mvc/", true)
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

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
