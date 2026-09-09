package com.vetly.vetly_java.model;

import jakarta.persistence.*;

import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.UUID;

@Entity
@Table(name = "TB_EVOLUCAO_CLINICA")
public class EvolucaoClinica {
    @Id
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "ID_EVOLUCAO_CLINICA")
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "ANT_EVOLUCAO_CLINICA", nullable = false, length = 2000)
    private String anotacoes;

    @OneToOne
    @JoinColumn(name = "TB_CONSULTA_ID_CONSULTA", nullable = false, unique = true)
    private Consulta consulta;

    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "FL_OCULTO_RESPONSAVEL", nullable = false, length = 1)
    private String ocultoResponsavel;

    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "FL_ALERTA_SEGURANCA", nullable = false, length = 1)
    private String alertaSeguranca;

    public EvolucaoClinica() {
    }

    public EvolucaoClinica(UUID id, String anotacoes, Consulta consulta) {
        this.id = id;
        this.anotacoes = anotacoes;
        this.consulta = consulta;
        this.ocultoResponsavel = "N";
        this.alertaSeguranca = "N";
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getAnotacoes() {
        return anotacoes;
    }

    public void setAnotacoes(String anotacoes) {
        this.anotacoes = anotacoes;
    }

    public Consulta getConsulta() {
        return consulta;
    }

    public void setConsulta(Consulta consulta) {
        this.consulta = consulta;
    }

    public boolean isOcultoResponsavel() {
        return "S".equals(ocultoResponsavel);
    }

    public void setOcultoResponsavel(String ocultoResponsavel) {
        this.ocultoResponsavel = ocultoResponsavel;
    }

    public boolean isAlertaSeguranca() {
        return "S".equals(alertaSeguranca);
    }

    public void setAlertaSeguranca(String alertaSeguranca) {
        this.alertaSeguranca = alertaSeguranca;
    }
}
