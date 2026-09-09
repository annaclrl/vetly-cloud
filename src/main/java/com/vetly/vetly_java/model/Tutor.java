package com.vetly.vetly_java.model;

import jakarta.persistence.*;

import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "TB_TUTOR")
public class Tutor {

    @Id
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "ID_TUTOR")
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne
    @JoinColumn(name = "TB_USUARIO_ID_USUARIO", nullable = false)
    private Usuario usuario;

    @OneToOne
    @JoinColumn(name = "TB_PESSOA_ID_PESSOA", nullable = false)
    private Pessoa pessoa;

    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "FL_LGPD_ACEITO", nullable = false, length = 1)
    private String lgpdAceito;

    @Column(name = "DT_LGPD_ACEITO")
    private LocalDate dataLgpdAceito;

    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "FL_CONSENTIMENTO_REDE", nullable = false, length = 1)
    private String consentimentoRede;

    @Column(name = "DT_CONSENTIMENTO_REDE")
    private LocalDate dataConsentimentoRede;

    public Tutor() {
    }

    public Tutor(Usuario usuario, Pessoa pessoa) {
        this.usuario = usuario;
        this.pessoa = pessoa;
        this.lgpdAceito = "N";
        this.consentimentoRede = "N";
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
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

    public boolean isLgpdAceito() {
        return "S".equals(lgpdAceito);
    }

    public void setLgpdAceito(String lgpdAceito) {
        this.lgpdAceito = lgpdAceito;
    }

    public LocalDate getDataLgpdAceito() {
        return dataLgpdAceito;
    }

    public void setDataLgpdAceito(LocalDate dataLgpdAceito) {
        this.dataLgpdAceito = dataLgpdAceito;
    }

    public boolean isConsentimentoRede() {
        return "S".equals(consentimentoRede);
    }

    public void setConsentimentoRede(String consentimentoRede) {
        this.consentimentoRede = consentimentoRede;
    }

    public LocalDate getDataConsentimentoRede() {
        return dataConsentimentoRede;
    }

    public void setDataConsentimentoRede(LocalDate dataConsentimentoRede) {
        this.dataConsentimentoRede = dataConsentimentoRede;
    }
}
