package com.vetly.vetly_java.mvc.controller;

import com.vetly.vetly_java.repository.*;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/mvc")
public class DashboardController {

    private final TutorRepository tutorRepository;
    private final VeterinarioRepository veterinarioRepository;
    private final AnimalRepository animalRepository;
    private final ConsultaRepository consultaRepository;
    private final SolicitacaoExameRepository solicitacaoExameRepository;
    private final EspecieRepository especieRepository;
    private final EspecialidadeVetRepository especialidadeVetRepository;
    private final UsuarioRepository usuarioRepository;

    public DashboardController(TutorRepository tutorRepository, VeterinarioRepository veterinarioRepository,
                               AnimalRepository animalRepository, ConsultaRepository consultaRepository,
                               SolicitacaoExameRepository solicitacaoExameRepository, EspecieRepository especieRepository,
                               EspecialidadeVetRepository especialidadeVetRepository, UsuarioRepository usuarioRepository) {
        this.tutorRepository = tutorRepository;
        this.veterinarioRepository = veterinarioRepository;
        this.animalRepository = animalRepository;
        this.consultaRepository = consultaRepository;
        this.solicitacaoExameRepository = solicitacaoExameRepository;
        this.especieRepository = especieRepository;
        this.especialidadeVetRepository = especialidadeVetRepository;
        this.usuarioRepository = usuarioRepository;
    }

    @GetMapping("/")
    public String dashboard(Model model) {
        model.addAttribute("totalTutores", tutorRepository.count());
        model.addAttribute("totalVeterinarios", veterinarioRepository.count());
        model.addAttribute("totalAnimais", animalRepository.count());
        model.addAttribute("totalConsultas", consultaRepository.count());
        model.addAttribute("totalExames", solicitacaoExameRepository.count());
        model.addAttribute("totalEspecies", especieRepository.count());
        model.addAttribute("totalEspecialidades", especialidadeVetRepository.count());
        model.addAttribute("totalUsuarios", usuarioRepository.count());
        return "dashboard";
    }
}
