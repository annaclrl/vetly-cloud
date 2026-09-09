package com.vetly.vetly_java.security;

import com.vetly.vetly_java.model.UserRole;
import com.vetly.vetly_java.model.Usuario;
import com.vetly.vetly_java.repository.UsuarioRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * Cria o primeiro ADMIN no startup, se ainda não existir nenhum — sem isso,
 * ninguém consegue logar no painel num banco novo (só ADMIN autentica em
 * /mvc/**, e não há tela de auto-registro). Não faz nada se já existir um
 * ADMIN ou se vetly.admin.bootstrap.email/senha não estiverem configurados.
 */
@Component
public class AdminBootstrap implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(AdminBootstrap.class);

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;
    private final String email;
    private final String senha;

    public AdminBootstrap(UsuarioRepository usuarioRepository, PasswordEncoder passwordEncoder,
                          @Value("${vetly.admin.bootstrap.email:}") String email,
                          @Value("${vetly.admin.bootstrap.senha:}") String senha) {
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
        this.email = email;
        this.senha = senha;
    }

    @Override
    public void run(String... args) {
        if (usuarioRepository.existsByRole(UserRole.ADMIN)) {
            return;
        }
        if (email.isBlank() || senha.isBlank()) {
            log.warn("Nenhum usuario ADMIN existe e vetly.admin.bootstrap.email/senha nao estao " +
                    "configurados em application.properties — ninguem consegue logar em /mvc/login.");
            return;
        }
        Usuario admin = new Usuario(email, UserRole.ADMIN, "S", passwordEncoder.encode(senha));
        usuarioRepository.save(admin);
        log.info("ADMIN inicial criado: {}. So roda enquanto nao existir nenhum ADMIN — " +
                "nao ha tela de troca de senha no painel ainda, entao para trocar depois " +
                "atualize SEN_HASH_USUARIO (BCrypt) direto no banco.", email);
    }
}
