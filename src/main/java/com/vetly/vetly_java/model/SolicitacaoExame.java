package com.vetly.vetly_java.model;

import jakarta.persistence.*;

import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "TB_SOLICITACAO_EXAME")
public class SolicitacaoExame {

    @Id
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "ID_SOLICITACAO_EXAME")
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "OBS_SOLICITACAO", length = 300)
    private String observacao;

    @OneToOne
    @JoinColumn(name = "TB_CONSULTA_ID_CONSULTA", unique = true)
    private Consulta consulta;

    @OneToMany(mappedBy = "solicitacaoExame", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<SolicitacaoExameItem> itens;

    public SolicitacaoExame() {
    }

    public SolicitacaoExame(UUID id, String observacao, Consulta consulta, List<SolicitacaoExameItem> itens) {
        this.id = id;
        this.observacao = observacao;
        this.consulta = consulta;
        this.itens = itens;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getObservacao() {
        return observacao;
    }

    public void setObservacao(String observacao) {
        this.observacao = observacao;
    }

    public Consulta getConsulta() {
        return consulta;
    }

    public void setConsulta(Consulta consulta) {
        this.consulta = consulta;
    }

    public List<SolicitacaoExameItem> getItens() {
        return itens;
    }

    public void setItens(List<SolicitacaoExameItem> itens) {
        this.itens = itens;
    }
}
