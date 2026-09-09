package com.vetly.vetly_java.model;

import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "TB_VETERINARIO")
public class Veterinario {

    @Id
    @Column(name = "ID_VETERINARIO")
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "CRMV_VETERINARIO", nullable = false, unique = true, length = 20)
    private String crmv;

    @OneToOne
    @JoinColumn(name = "TB_USUARIO_ID_USUARIO", nullable = false)
    private Usuario usuario;

    @OneToOne
    @JoinColumn(name = "TB_PESSOA_ID_PESSOA", nullable = false)
    private Pessoa pessoa;

    @OneToMany(mappedBy = "veterinario")
    private List<VeterinarioEspecialidade> especialidades;

    @OneToMany(mappedBy = "veterinario")
    private List<VeterinarioEspecie> especies;

    public Veterinario(UUID id, String crmv, Usuario usuario, Pessoa pessoa, List<VeterinarioEspecialidade> especialidades,
                       List<VeterinarioEspecie> especies) {
        this.id = id;
        this.crmv = crmv;
        this.usuario = usuario;
        this.pessoa = pessoa;
        this.especialidades = especialidades;
        this.especies = especies;
    }

    public Veterinario() {

    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getCrmv() {
        return crmv;
    }

    public void setCrmv(String crmv) {
        this.crmv = crmv;
    }

    public Usuario getUsuario() {
        return usuario;
    }

    public void setUsuario(Usuario usuario) {
        this.usuario = usuario;
    }

    public Pessoa getPessoa() {
        return pessoa;
    }

    public void setPessoa(Pessoa pessoa) {
        this.pessoa = pessoa;
    }

    public List<VeterinarioEspecialidade> getEspecialidades() {
        return especialidades;
    }

    public void setEspecialidades(List<VeterinarioEspecialidade> especialidades) {
        this.especialidades = especialidades;
    }

    public List<VeterinarioEspecie> getEspecies() {
        return especies;
    }

    public void setEspecies(List<VeterinarioEspecie> especies) {
        this.especies = especies;
    }
}
