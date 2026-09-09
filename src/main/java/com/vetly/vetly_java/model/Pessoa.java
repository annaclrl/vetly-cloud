package com.vetly.vetly_java.model;

import jakarta.persistence.*;
import org.hibernate.annotations.JdbcType;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.UUID;

@Entity
@Table(
        name = "TB_PESSOA",
        uniqueConstraints = @UniqueConstraint(
                name = "TB_PESSOA_CPF_TEL_UN",
                columnNames = {"CPF_PESSOA", "TEL_PESSOA"}
        )
)
public class Pessoa {

    @Id
    @Column(name = "ID_PESSOA")
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "NM_PESSOA", nullable = false, length = 100)
    private String nome;

    @Column(name = "CPF_PESSOA", nullable = false, length = 11)
    private String cpf;

    @Column(name = "TEL_PESSOA", nullable = false, length = 15)
    private String telefone;

    public Pessoa(UUID id, String nome, String cpf, String telefone) {
        this.id = id;
        this.nome = nome;
        this.cpf = cpf;
        this.telefone = telefone;
    }

    public Pessoa() {

    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getCpf() {
        return cpf;
    }

    public void setCpf(String cpf) {
        this.cpf = cpf;
    }

    public String getTelefone() {
        return telefone;
    }

    public void setTelefone(String telefone) {
        this.telefone = telefone;
    }
}

