package com.vetly.vetly_java.dto;

import java.math.BigDecimal;

/**
 * Linha do cursor devolvido por {@code PKG_VETLY_RELATORIO.prc_consultas_vet_status}.
 * {@code tipo}: DETALHE (veterinário + status), SUBTOTAL (veterinário) ou TOTAL (geral).
 */
public record RelatorioConsultaLinha(
        String veterinario,
        String status,
        long quantidade,
        BigDecimal valorTotal,
        String tipo) {

    public boolean isDetalhe()  { return "DETALHE".equals(tipo); }
    public boolean isSubtotal() { return "SUBTOTAL".equals(tipo); }
    public boolean isTotal()    { return "TOTAL".equals(tipo); }
}
