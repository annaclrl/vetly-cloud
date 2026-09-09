package com.vetly.vetly_java.mvc.service;

import com.vetly.vetly_java.dto.RegisterVeterinarioDTO;
import com.vetly.vetly_java.dto.UsuarioResponse;
import com.vetly.vetly_java.model.NomeEspecialidade;
import com.vetly.vetly_java.model.NomeEspecie;
import com.vetly.vetly_java.model.Veterinario;
import com.vetly.vetly_java.model.VeterinarioEspecialidade;
import com.vetly.vetly_java.model.VeterinarioEspecie;
import com.vetly.vetly_java.mvc.form.VeterinarioCreateForm;
import com.vetly.vetly_java.mvc.form.VeterinarioEditForm;
import com.vetly.vetly_java.repository.EspecialidadeVetRepository;
import com.vetly.vetly_java.repository.EspecieRepository;
import com.vetly.vetly_java.repository.VeterinarioEspecialidadeRepository;
import com.vetly.vetly_java.repository.VeterinarioEspecieRepository;
import com.vetly.vetly_java.repository.VeterinarioRepository;
import com.vetly.vetly_java.service.AuthService;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class VeterinarioAdminService {

    private final VeterinarioRepository veterinarioRepository;
    private final EspecialidadeVetRepository especialidadeVetRepository;
    private final EspecieRepository especieRepository;
    private final VeterinarioEspecialidadeRepository veterinarioEspecialidadeRepository;
    private final VeterinarioEspecieRepository veterinarioEspecieRepository;
    private final AuthService authService;

    public VeterinarioAdminService(VeterinarioRepository veterinarioRepository,
                                   EspecialidadeVetRepository especialidadeVetRepository,
                                   EspecieRepository especieRepository,
                                   VeterinarioEspecialidadeRepository veterinarioEspecialidadeRepository,
                                   VeterinarioEspecieRepository veterinarioEspecieRepository,
                                   AuthService authService) {
        this.veterinarioRepository = veterinarioRepository;
        this.especialidadeVetRepository = especialidadeVetRepository;
        this.especieRepository = especieRepository;
        this.veterinarioEspecialidadeRepository = veterinarioEspecialidadeRepository;
        this.veterinarioEspecieRepository = veterinarioEspecieRepository;
        this.authService = authService;
    }

    public List<Veterinario> listar() {
        return veterinarioRepository.findAll();
    }

    public Veterinario buscar(UUID id) {
        return veterinarioRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Veterinário não encontrado: " + id));
    }

    public UsuarioResponse criar(VeterinarioCreateForm form) {
        return authService.registerVeterinario(new RegisterVeterinarioDTO(
                form.getEmail(), form.getSenha(), form.getCrmv(), form.getNome(), form.getCpf(), form.getTelefone(),
                form.getEspecialidades(), form.getEspecies()));
    }

    @Transactional
    public Veterinario atualizar(UUID id, VeterinarioEditForm form) {
        Veterinario veterinario = buscar(id);
        veterinario.getPessoa().setNome(form.getNome());
        veterinario.getPessoa().setTelefone(form.getTelefone());
        veterinario.setCrmv(form.getCrmv());
        veterinarioRepository.save(veterinario);

        veterinarioEspecialidadeRepository.deleteAll(veterinario.getEspecialidades());
        List<NomeEspecialidade> nomesEspecialidades = form.getEspecialidades().stream()
                .map(nome -> NomeEspecialidade.valueOf(nome.toUpperCase()))
                .toList();
        especialidadeVetRepository.findByNomeIn(nomesEspecialidades).forEach(esp -> {
            var assoc = new VeterinarioEspecialidade();
            assoc.setId(UUID.randomUUID().toString());
            assoc.setVeterinario(veterinario);
            assoc.setEspecialidade(esp);
            veterinarioEspecialidadeRepository.save(assoc);
        });

        veterinarioEspecieRepository.deleteAll(veterinario.getEspecies());
        List<NomeEspecie> nomesEspecies = form.getEspecies().stream()
                .map(nome -> NomeEspecie.valueOf(nome.toUpperCase()))
                .toList();
        especieRepository.findByNomeIn(nomesEspecies).forEach(esp -> {
            var assoc = new VeterinarioEspecie();
            assoc.setId(UUID.randomUUID().toString());
            assoc.setVeterinario(veterinario);
            assoc.setEspecie(esp);
            veterinarioEspecieRepository.save(assoc);
        });

        return veterinario;
    }

    public void excluir(UUID id) {
        veterinarioRepository.deleteById(id);
    }
}
