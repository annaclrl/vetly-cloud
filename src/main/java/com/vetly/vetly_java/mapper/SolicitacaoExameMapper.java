package com.vetly.vetly_java.mapper;

import com.vetly.vetly_java.dto.SolicitacaoExameRequest;
import com.vetly.vetly_java.model.Consulta;
import com.vetly.vetly_java.model.SolicitacaoExame;
import com.vetly.vetly_java.model.SolicitacaoExameItem;
import com.vetly.vetly_java.model.StatusExame;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Component
public class SolicitacaoExameMapper {

    public SolicitacaoExame solicitacaoExameRequestToSolicitacaoExame(SolicitacaoExameRequest request, Consulta consulta) {
        SolicitacaoExame solicitacao = new SolicitacaoExame();
        solicitacao.setObservacao(request.observacao());
        solicitacao.setConsulta(consulta);

        List<SolicitacaoExameItem> itens = new ArrayList<>();
        for (SolicitacaoExameRequest.ItemRequest itemRequest : request.itens()) {
            SolicitacaoExameItem item = new SolicitacaoExameItem();
            item.setNomeExame(itemRequest.nomeExame());
            item.setStatus(StatusExame.SOLICITADO);
            item.setDataSolicitacao(LocalDate.now());
            item.setLiberadoResponsavel("N");
            item.setSolicitacaoExame(solicitacao);
            itens.add(item);
        }
        solicitacao.setItens(itens);
        return solicitacao;
    }
}
