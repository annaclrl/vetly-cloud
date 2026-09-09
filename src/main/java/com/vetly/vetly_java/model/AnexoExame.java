package com.vetly.vetly_java.model;

import jakarta.persistence.*;

import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "TB_ANEXO_EXAME")
public class AnexoExame {

    @Id
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(name = "ID_ANEXO_EXAME")
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "URL_ARQUIVO_ANEXO", nullable = false, length = 500)
    private String urlArquivo;

    @Column(name = "MIME_TYPE_ANEXO", nullable = false, length = 30)
    private String mimeType;

    @Column(name = "DT_UPLOAD_ANEXO", nullable = false)
    private LocalDate dataUpload;

    @ManyToOne
    @JoinColumn(name = "TB_SLC_EX_ITEM_ID_SLC_EX_ITEM")
    private SolicitacaoExameItem solicitacaoExameItem;

    public AnexoExame() {
    }

    public AnexoExame(UUID id, String urlArquivo, String mimeType, LocalDate dataUpload, SolicitacaoExameItem solicitacaoExameItem) {
        this.id = id;
        this.urlArquivo = urlArquivo;
        this.mimeType = mimeType;
        this.dataUpload = dataUpload;
        this.solicitacaoExameItem = solicitacaoExameItem;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getUrlArquivo() {
        return urlArquivo;
    }

    public void setUrlArquivo(String urlArquivo) {
        this.urlArquivo = urlArquivo;
    }

    public String getMimeType() {
        return mimeType;
    }

    public void setMimeType(String mimeType) {
        this.mimeType = mimeType;
    }

    public LocalDate getDataUpload() {
        return dataUpload;
    }

    public void setDataUpload(LocalDate dataUpload) {
        this.dataUpload = dataUpload;
    }

    public SolicitacaoExameItem getSolicitacaoExameItem() {
        return solicitacaoExameItem;
    }

    public void setSolicitacaoExameItem(SolicitacaoExameItem solicitacaoExameItem) {
        this.solicitacaoExameItem = solicitacaoExameItem;
    }
}
