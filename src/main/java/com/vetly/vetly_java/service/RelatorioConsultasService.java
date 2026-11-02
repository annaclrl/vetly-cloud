package com.vetly.vetly_java.service;

import com.vetly.vetly_java.dto.RelatorioConsultaLinha;
import com.vetly.vetly_java.model.StatusConsulta;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Service;

import java.sql.Types;
import java.util.List;
import java.util.Map;

/**
 * Consome o pacote Oracle {@code PKG_VETLY_RELATORIO} (entregue pela migration V10).
 *
 * <p>O contrato com o banco é só "procedure com OUT SYS_REFCURSOR": nada aqui depende de
 * onde a aplicação roda. A conexão vem do {@code DataSource} (variáveis de ambiente), e a
 * chamada declara os parâmetros explicitamente em vez de consultar o dicionário de dados
 * do Oracle, de modo que funciona igual com usuário dono do schema, sinônimo ou
 * permissão apenas de EXECUTE.
 */
@Service
public class RelatorioConsultasService {

    private final SimpleJdbcCall chamada;

    public RelatorioConsultasService(JdbcTemplate jdbcTemplate) {
        this.chamada = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("PKG_VETLY_RELATORIO")
                .withProcedureName("PRC_CONSULTAS_VET_STATUS")
                .withoutProcedureColumnMetaDataAccess()
                .declareParameters(
                        new SqlParameter("P_STATUS", Types.VARCHAR),
                        new SqlOutParameter("P_RESULTADO", Types.REF_CURSOR,
                                (rs, linha) -> new RelatorioConsultaLinha(
                                        rs.getString("NM_VETERINARIO"),
                                        rs.getString("ST_CONSULTA"),
                                        rs.getLong("QT_CONSULTAS"),
                                        rs.getBigDecimal("VL_TOTAL"),
                                        rs.getString("TP_LINHA"))));
    }

    /**
     * @param status filtro opcional; {@code null} traz todos os status
     * @return detalhes por veterinário/status, com subtotais e total geral, já ordenados
     */
    @SuppressWarnings("unchecked")
    public List<RelatorioConsultaLinha> consultasPorVeterinarioEStatus(StatusConsulta status) {
        Map<String, Object> saida = chamada.execute(
                new MapSqlParameterSource("P_STATUS", status == null ? null : status.name()));
        return (List<RelatorioConsultaLinha>) saida.get("P_RESULTADO");
    }
}
