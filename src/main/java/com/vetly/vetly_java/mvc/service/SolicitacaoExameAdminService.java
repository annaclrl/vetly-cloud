package com.vetly.vetly_java.mvc.service;

import com.vetly.vetly_java.dto.SolicitacaoExameRequest;
import com.vetly.vetly_java.mapper.SolicitacaoExameMapper;
import com.vetly.vetly_java.model.Consulta;
import com.vetly.vetly_java.model.SolicitacaoExame;
import com.vetly.vetly_java.model.SolicitacaoExameItem;
import com.vetly.vetly_java.model.StatusExame;
import com.vetly.vetly_java.repository.ConsultaRepository;
import com.vetly.vetly_java.repository.SolicitacaoExameItemRepository;
import com.vetly.vetly_java.repository.SolicitacaoExameRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
public class SolicitacaoExameAdminService {

    private final SolicitacaoExameRepository solicitacaoExameRepository;
    private final SolicitacaoExameItemRepository solicitacaoExameItemRepository;
    private final ConsultaRepository consultaRepository;
    private final SolicitacaoExameMapper mapper;

    public SolicitacaoExameAdminService(SolicitacaoExameRepository solicitacaoExameRepository,
                                        SolicitacaoExameItemRepository solicitacaoExameItemRepository,
                                        ConsultaRepository consultaRepository, SolicitacaoExameMapper mapper) {
        this.solicitacaoExameRepository = solicitacaoExameRepository;
        this.solicitacaoExameItemRepository = solicitacaoExameItemRepository;
        this.consultaRepository = consultaRepository;
        this.mapper = mapper;
    }

    public List<SolicitacaoExame> listar() {
        return solicitacaoExameRepository.findAll();
    }

    public SolicitacaoExame buscar(UUID id) {
        return solicitacaoExameRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Solicitação de exame não encontrada: " + id));
    }

    public SolicitacaoExame criar(UUID consultaId, String observacao, List<String> nomesExames) {
        Consulta consulta = consultaRepository.findById(consultaId)
                .orElseThrow(() -> new EntityNotFoundException("Consulta não encontrada: " + consultaId));
        if (solicitacaoExameRepository.findByConsulta(consulta).isPresent()) {
            throw new IllegalArgumentException("Já existe uma solicitação de exame para esta consulta");
        }

        List<SolicitacaoExameRequest.ItemRequest> itens = nomesExames.stream()
                .map(String::trim)
                .filter(nome -> !nome.isBlank())
                .map(SolicitacaoExameRequest.ItemRequest::new)
                .toList();
        if (itens.isEmpty()) {
            throw new IllegalArgumentException("Informe ao menos um exame");
        }

        SolicitacaoExameRequest request = new SolicitacaoExameRequest(observacao, itens);
        SolicitacaoExame solicitacao = mapper.solicitacaoExameRequestToSolicitacaoExame(request, consulta);
        return solicitacaoExameRepository.save(solicitacao);
    }

    public SolicitacaoExameItem registrarResultado(UUID itemId, String descricaoResultado) {
        SolicitacaoExameItem item = buscarItem(itemId);
        if (item.getStatus() != StatusExame.SOLICITADO && item.getStatus() != StatusExame.AGUARDANDO_RESULTADO) {
            throw new IllegalArgumentException(
                    "Só é possível registrar resultado a partir de SOLICITADO ou AGUARDANDO_RESULTADO — status atual: " + item.getStatus());
        }
        item.setDescricaoResultado(descricaoResultado);
        item.setDataResultado(LocalDate.now());
        item.setDataAnalise(LocalDate.now());
        item.setStatus(StatusExame.ANALISADO);
        return solicitacaoExameItemRepository.save(item);
    }

    public SolicitacaoExameItem liberarParaResponsavel(UUID itemId) {
        SolicitacaoExameItem item = buscarItem(itemId);
        if (item.getStatus() != StatusExame.ANALISADO) {
            throw new IllegalArgumentException(
                    "Só é possível liberar ao Responsável um exame já ANALISADO — status atual: " + item.getStatus());
        }
        item.setLiberadoResponsavel("S");
        item.setDataLiberacaoResponsavel(LocalDate.now());
        item.setStatus(StatusExame.RESULTADO_ENVIADO);
        return solicitacaoExameItemRepository.save(item);
    }

    public SolicitacaoExameItem cancelar(UUID itemId) {
        SolicitacaoExameItem item = buscarItem(itemId);
        if (item.getStatus() == StatusExame.RESULTADO_ENVIADO || item.getStatus() == StatusExame.CANCELADO) {
            throw new IllegalArgumentException(
                    "Não é possível cancelar um exame já enviado ou já cancelado — status atual: " + item.getStatus());
        }
        item.setStatus(StatusExame.CANCELADO);
        return solicitacaoExameItemRepository.save(item);
    }

    public SolicitacaoExameItem buscarItem(UUID itemId) {
        return solicitacaoExameItemRepository.findById(itemId)
                .orElseThrow(() -> new EntityNotFoundException("Item de solicitação de exame não encontrado: " + itemId));
    }
}
