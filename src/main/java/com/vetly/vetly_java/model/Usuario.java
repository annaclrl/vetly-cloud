package com.vetly.vetly_java.model;

import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.jspecify.annotations.Nullable;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "TB_USUARIO")
public class Usuario implements UserDetails {

    @Id
    @Column(name = "ID_USUARIO")
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "EM_USUARIO", nullable = false, unique = true, length = 255)
    private String email;

    @Column(name = "RL_USUARIO", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private UserRole role;

    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "FL_ATV_USUARIO", nullable = false, length = 1)
    private String flagAtivo;


    @Column(name = "SEN_HASH_USUARIO", nullable = false, length = 255)
    private String senhaHash;

    public Usuario(String email, UserRole role, String flagAtivo, String senhaHash) {
        this.email = email;
        this.role = role;
        this.flagAtivo = flagAtivo;
        this.senhaHash = senhaHash;
    }

    public Usuario() {
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public UserRole getRole() {
        return role;
    }

    public void setRole(UserRole role) {
        this.role = role;
    }

    public String getFlagAtivo() {
        return flagAtivo;
    }

    public void setFlagAtivo(String flagAtivo) {
        this.flagAtivo = flagAtivo;
    }

    public String getSenhaHash() {
        return senhaHash;
    }

    public void setSenhaHash(String senhaHash) {
        this.senhaHash = senhaHash;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        if (UserRole.ADMIN.equals(this.role)) {
            return List.of(new SimpleGrantedAuthority("ROLE_ADMIN"), new SimpleGrantedAuthority("ROLE_USER"));
        } else{
            return List.of(new SimpleGrantedAuthority("ROLE_USER"));
        }
    }

    @Override
    public @Nullable String getPassword() {
        return senhaHash;
    }

    @Override
    public String getUsername() {
        return email;
    }
}