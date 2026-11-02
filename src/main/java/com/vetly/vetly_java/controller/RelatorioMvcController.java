package com.vetly.vetly_java.controller;

import com.vetly.vetly_java.model.StatusConsulta;
import com.vetly.vetly_java.service.RelatorioConsultasService;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

/** Relatório gerencial calculado no banco (PKG_VETLY_RELATORIO). Só ADMIN (regra padrão de /mvc/**). */
@Controller
@RequestMapping("/mvc/relatorios")
public class RelatorioMvcController {

    private final RelatorioConsultasService relatorioConsultasService;

    public RelatorioMvcController(RelatorioConsultasService relatorioConsultasService) {
        this.relatorioConsultasService = relatorioConsultasService;
    }

    @GetMapping("/consultas")
    public String consultas(@RequestParam(required = false) StatusConsulta status, Model model) {
        model.addAttribute("status", status);
        model.addAttribute("statusDisponiveis", StatusConsulta.values());
        try {
            model.addAttribute("linhas", relatorioConsultasService.consultasPorVeterinarioEStatus(status));
        } catch (DataAccessException e) {
            model.addAttribute("erro", "Não foi possível gerar o relatório no banco de dados. "
                    + "Verifique se a migration V10 foi aplicada.");
        }
        return "relatorios/consultas";
    }
}
