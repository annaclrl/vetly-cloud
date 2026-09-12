package com.vetly.vetly_java.mvc.service;

import com.vetly.vetly_java.dto.RegisterTutorDTO;
import com.vetly.vetly_java.dto.UsuarioResponse;
import com.vetly.vetly_java.model.Tutor;
import com.vetly.vetly_java.mvc.form.TutorCreateForm;
import com.vetly.vetly_java.mvc.form.TutorEditForm;
import com.vetly.vetly_java.repository.TutorRepository;
import com.vetly.vetly_java.repository.UsuarioRepository;
import com.vetly.vetly_java.service.AuthService;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
public class TutorAdminService {

    private final TutorRepository tutorRepository;
    private final UsuarioRepository usuarioRepository;
    private final AuthService authService;

    public TutorAdminService(TutorRepository tutorRepository, UsuarioRepository usuarioRepository, AuthService authService) {
        this.tutorRepository = tutorRepository;
        this.usuarioRepository = usuarioRepository;
        this.authService = authService;
    }

    public List<Tutor> listar() {
        return tutorRepository.findAll();
    }

    public Tutor buscar(UUID id) {
        return tutorRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Tutor não encontrado: " + id));
    }

    public UsuarioResponse criar(TutorCreateForm form) {
        return authService.registerTutor(new RegisterTutorDTO(
                form.getEmail(), form.getSenha(), form.getNome(), form.getCpf(), form.getTelefone()));
    }

    @Transactional
    public Tutor atualizar(UUID id, TutorEditForm form) {
        Tutor tutor = buscar(id);
        tutor.getPessoa().setNome(form.getNome());
        tutor.getPessoa().setTelefone(form.getTelefone());

        if (form.isLgpdAceito() && !tutor.isLgpdAceito()) {
            tutor.setDataLgpdAceito(LocalDate.now());
        }
        tutor.setLgpdAceito(form.isLgpdAceito() ? "S" : "N");

        if (form.isConsentimentoRede() && !tutor.isConsentimentoRede()) {
            tutor.setDataConsentimentoRede(LocalDate.now());
        } else if (!form.isConsentimentoRede()) {
            tutor.setDataConsentimentoRede(null);
        }
        tutor.setConsentimentoRede(form.isConsentimentoRede() ? "S" : "N");

        return tutorRepository.save(tutor);
    }

    @Transactional
    public void excluir(UUID id) {
        Tutor tutor = buscar(id);
        UUID usuarioId = tutor.getUsuario().getId();
        tutorRepository.delete(tutor);
        usuarioRepository.deleteById(usuarioId);
    }
}
