package com.vetly.vetly_java.model;

import jakarta.persistence.*;

import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "TB_SOLICITACAO_EXAME_ITEM")
public class SolicitacaoExameItem {

    @Id
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "ID_SOLICITACAO_EXAME_ITEM")
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "NM_EXAME", nullable = false, length = 100)
    private String nomeExame;

    @Column(name = "ST_EXAME", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private StatusExame status;

    @Column(name = "DT_SOLC_EXAME", nullable = false)
    private LocalDate dataSolicitacao;

    @Column(name = "DT_RES_EXAME")
    private LocalDate dataResultado;

    @Column(name = "DS_RES_EXAME", length = 500)
    private String descricaoResultado;

    @Column(name = "DT_ANALISE")
    private LocalDate dataAnalise;

    @Column(name = "DT_ENVIO_RESULTADO")
    private LocalDate dataEnvioResultado;

    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "FL_LIBERADO_RESPONSAVEL", nullable = false, length = 1)
    private String liberadoResponsavel;

    @Column(name = "DT_LIBERACAO_RESPONSAVEL")
    private LocalDate dataLiberacaoResponsavel;

    @ManyToOne
    @JoinColumn(name = "TB_SOLCT_EXAME_ID_SOLCT_EXAME", nullable = false)
    private SolicitacaoExame solicitacaoExame;

    @OneToMany(mappedBy = "solicitacaoExameItem", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<AnexoExame> anexos;

    public SolicitacaoExameItem() {
        this.anexos = new ArrayList<>();
    }

    public SolicitacaoExameItem(UUID id, String nomeExame, StatusExame status, LocalDate dataSolicitacao, LocalDate dataResultado, String descricaoResultado, LocalDate dataAnalise, LocalDate dataEnvioResultado, SolicitacaoExame solicitacaoExame, List<AnexoExame> anexos) {
        this.id = id;
        this.nomeExame = nomeExame;
        this.status = status;
        this.dataSolicitacao = dataSolicitacao;
        this.dataResultado = dataResultado;
        this.descricaoResultado = descricaoResultado;
        this.dataAnalise = dataAnalise;
        this.dataEnvioResultado = dataEnvioResultado;
        this.solicitacaoExame = solicitacaoExame;
        this.anexos = anexos;
        this.liberadoResponsavel = "N";
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getNomeExame() {
        return nomeExame;
    }

    public void setNomeExame(String nomeExame) {
        this.nomeExame = nomeExame;
    }

    public StatusExame getStatus() {
        return status;
    }

    public void setStatus(StatusExame status) {
        this.status = status;
    }

    public LocalDate getDataSolicitacao() {
        return dataSolicitacao;
    }

    public void setDataSolicitacao(LocalDate dataSolicitacao) {
        this.dataSolicitacao = dataSolicitacao;
    }

    public LocalDate getDataResultado() {
        return dataResultado;
    }

    public void setDataResultado(LocalDate dataResultado) {
        this.dataResultado = dataResultado;
    }

    public String getDescricaoResultado() {
        return descricaoResultado;
    }

    public void setDescricaoResultado(String descricaoResultado) {
        this.descricaoResultado = descricaoResultado;
    }

    public LocalDate getDataAnalise() {
        return dataAnalise;
    }

    public void setDataAnalise(LocalDate dataAnalise) {
        this.dataAnalise = dataAnalise;
    }

    public LocalDate getDataEnvioResultado() {
        return dataEnvioResultado;
    }

    public void setDataEnvioResultado(LocalDate dataEnvioResultado) {
        this.dataEnvioResultado = dataEnvioResultado;
    }

    public SolicitacaoExame getSolicitacaoExame() {
        return solicitacaoExame;
    }

    public void setSolicitacaoExame(SolicitacaoExame solicitacaoExame) {
        this.solicitacaoExame = solicitacaoExame;
    }

    public List<AnexoExame> getAnexos() {
        return anexos;
    }

    public void setAnexos(List<AnexoExame> anexos) {
        this.anexos = anexos;
    }

    public boolean isLiberadoResponsavel() {
        return "S".equals(liberadoResponsavel);
    }

    public void setLiberadoResponsavel(String liberadoResponsavel) {
        this.liberadoResponsavel = liberadoResponsavel;
    }

    public LocalDate getDataLiberacaoResponsavel() {
        return dataLiberacaoResponsavel;
    }

    public void setDataLiberacaoResponsavel(LocalDate dataLiberacaoResponsavel) {
        this.dataLiberacaoResponsavel = dataLiberacaoResponsavel;
    }
}