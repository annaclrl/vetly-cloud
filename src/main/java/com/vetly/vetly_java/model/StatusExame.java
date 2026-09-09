package com.vetly.vetly_java.model;

/**
 * Ciclo de vida de um item de solicitacao de exame.
 *
 * <p>Fluxo: {@link #SOLICITADO} ou {@link #AGUARDANDO_RESULTADO} → o vet registra o laudo
 * ({@link #ANALISADO}) → o vet libera explicitamente ao Responsavel
 * ({@link #RESULTADO_ENVIADO}).
 *
 * <p><strong>Semantica de {@code RESULTADO_ENVIADO}</strong> (decidida em 2026-09-05,
 * registrada em {@code project-context/docs/java-database-alignment.md} §2.7): significa
 * <em>liberado ao Responsavel</em>, nao "enviado ao veterinario". O nome herdado do schema
 * e ambiguo, mas nao existe estado separado para "o vet recebeu o resultado" no v1 —
 * registrar o laudo e {@link #ANALISADO}, e so a liberacao explicita (RN-104) move o item
 * para ca, junto com {@code FL_LIBERADO_RESPONSAVEL = 'S'}.
 */
public enum StatusExame {
    AGUARDANDO_RESULTADO, ANALISADO, CANCELADO, RESULTADO_ENVIADO, SOLICITADO
}
