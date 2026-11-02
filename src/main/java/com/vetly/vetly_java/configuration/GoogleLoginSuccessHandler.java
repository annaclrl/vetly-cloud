package com.vetly.vetly_java.configuration;

import com.vetly.vetly_java.model.Usuario;
import com.vetly.vetly_java.repository.UsuarioRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.stereotype.Component;

import java.io.IOException;

/**
 * Após autenticar no Google, só vincula a um Usuario já existente (por e-mail verificado).
 * A autenticação OIDC é trocada por uma com o próprio Usuario como principal, mantendo
 * compatíveis os @AuthenticationPrincipal Usuario dos controllers e o redirecionamento por papel.
 * Sem conta correspondente (ou inativa), a sessão é descartada e volta ao login.
 */
@Component
public class GoogleLoginSuccessHandler implements AuthenticationSuccessHandler {

    private final UsuarioRepository usuarioRepository;
    private final AuthenticationSuccessHandler roleRedirectHandler;
    private final HttpSessionSecurityContextRepository contextRepository = new HttpSessionSecurityContextRepository();

    public GoogleLoginSuccessHandler(UsuarioRepository usuarioRepository,
                                     @org.springframework.beans.factory.annotation.Qualifier("successHandler")
                                     AuthenticationSuccessHandler roleRedirectHandler) {
        this.usuarioRepository = usuarioRepository;
        this.roleRedirectHandler = roleRedirectHandler;
    }

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                        Authentication authentication) throws IOException, jakarta.servlet.ServletException {
        Usuario usuario = null;
        if (authentication.getPrincipal() instanceof OidcUser oidc
                && Boolean.TRUE.equals(oidc.getEmailVerified()) && oidc.getEmail() != null) {
            usuario = usuarioRepository.findByEmail(oidc.getEmail());
        }
        if (usuario == null || !"S".equals(usuario.getFlagAtivo())) {
            SecurityContextHolder.clearContext();
            if (request.getSession(false) != null) {
                request.getSession(false).invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/mvc/login?googleSemConta");
            return;
        }

        var token = UsernamePasswordAuthenticationToken.authenticated(usuario, null, usuario.getAuthorities());
        SecurityContext context = SecurityContextHolder.createEmptyContext();
        context.setAuthentication(token);
        SecurityContextHolder.setContext(context);
        contextRepository.saveContext(context, request, response);
        roleRedirectHandler.onAuthenticationSuccess(request, response, token);
    }
}
