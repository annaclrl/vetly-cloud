package com.vetly.vetly_java.service;

import com.vetly.vetly_java.dto.RegisterTutorDTO;
import com.vetly.vetly_java.dto.RegisterVeterinarioDTO;
import com.vetly.vetly_java.dto.UsuarioResponse;
import com.vetly.vetly_java.mapper.UsuarioMapper;
import com.vetly.vetly_java.model.*;
import com.vetly.vetly_java.repository.*;
import com.vetly.vetly_java.model.*;
import com.vetly.vetly_java.repository.*;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import org.jspecify.annotations.NonNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class AuthService implements UserDetailsService {
    private final UsuarioRepository usuarioRepository;
    private final EspecialidadeVetRepository especialidadeVetRepository;
    private final EspecieRepository especieRepository;
    private final PessoaRepository pessoaRepository;
    private final VeterinarioRepository veterinarioRepository;
    private final VeterinarioEspecialidadeRepository veterinarioEspecialidadeRepository;
    private final VeterinarioEspecieRepository veterinarioEspecieRepository;
    private final TutorRepository tutorRepository;
    private final UsuarioMapper mapper;

    @Autowired
    public AuthService(UsuarioRepository usuarioRepository, EspecialidadeVetRepository especialidadeVetRepository,
                       EspecieRepository especieRepository, VeterinarioRepository veterinarioRepository,
                       PessoaRepository pessoaRepository,
                       VeterinarioEspecialidadeRepository veterinarioEspecialidadeRepository,
                       VeterinarioEspecieRepository veterinarioEspecieRepository,
                       TutorRepository tutorRepository,
                       UsuarioMapper mapper) {
        this.usuarioRepository = usuarioRepository;
        this.especialidadeVetRepository = especialidadeVetRepository;
        this.especieRepository = especieRepository;
        this.mapper = mapper;
        this.veterinarioRepository = veterinarioRepository;
        this.pessoaRepository = pessoaRepository;
        this.veterinarioEspecialidadeRepository = veterinarioEspecialidadeRepository;
        this.veterinarioEspecieRepository = veterinarioEspecieRepository;
        this.tutorRepository = tutorRepository;
    }

    @Override
    public UserDetails loadUserByUsername(@NonNull String username) throws UsernameNotFoundException {
        UserDetails userDetails = usuarioRepository.findByEmail(username);
        if (userDetails == null) {
            throw new UsernameNotFoundException("Usuario nao encontrado: " + username);
        }
        return userDetails;
    }

    @Transactional
    public UsuarioResponse registerVeterinario(@Valid RegisterVeterinarioDTO dto) {
        if (usuarioRepository.findByEmail(dto.email()) != null) {
            throw new IllegalArgumentException("Email já cadastrado");
        }

        var usuario = new Usuario();
        usuario.setEmail(dto.email());
        usuario.setSenhaHash(new BCryptPasswordEncoder().encode(dto.senha()));
        usuario.setRole(UserRole.VETERINARIO);
        usuario.setFlagAtivo("S");
        usuarioRepository.save(usuario);

        var pessoa = new Pessoa();
        pessoa.setNome(dto.nome());
        pessoa.setTelefone(dto.telefone());
        pessoa.setCpf(dto.cpf());
        pessoaRepository.save(pessoa);

        // cria e salva veterinario ANTES das associativas
        var veterinario = new Veterinario();
        veterinario.setUsuario(usuario);
        veterinario.setCrmv(dto.crmv());
        veterinario.setPessoa(pessoa);
        veterinarioRepository.save(veterinario);

        // agora salva as associativas com o veterinario já persistido
        var nomesEspecialidades = dto.especialidades().stream()
                .map(nome -> NomeEspecialidade.valueOf(nome.toUpperCase()))
                .toList();
        especialidadeVetRepository.findByNomeIn(nomesEspecialidades).forEach(esp -> {
            var assoc = new VeterinarioEspecialidade();
            assoc.setId(UUID.randomUUID().toString());
            assoc.setVeterinario(veterinario);
            assoc.setEspecialidade(esp);
            veterinarioEspecialidadeRepository.save(assoc);
        });

        var nomesEspecies = dto.especies().stream()
                .map(nome -> NomeEspecie.valueOf(nome.toUpperCase()))
                .toList();
        especieRepository.findByNomeIn(nomesEspecies).forEach(esp -> {
            var assoc = new VeterinarioEspecie();
            assoc.setId(UUID.randomUUID().toString());
            assoc.setVeterinario(veterinario);
            assoc.setEspecie(esp);
            veterinarioEspecieRepository.save(assoc);
        });

        return mapper.usuarioToResponse(usuario);
    }

    @Transactional
    public UsuarioResponse registerTutor(@Valid RegisterTutorDTO dto) {
        if (usuarioRepository.findByEmail(dto.email()) != null) {
            throw new IllegalArgumentException("Email já cadastrado");
        }

        var usuario = new Usuario();
        usuario.setEmail(dto.email());
        usuario.setSenhaHash(new BCryptPasswordEncoder().encode(dto.senha()));
        usuario.setRole(UserRole.TUTOR);
        usuario.setFlagAtivo("S");
        usuarioRepository.save(usuario);

        var pessoa = new Pessoa();
        pessoa.setNome(dto.nome());
        pessoa.setTelefone(dto.telefone());
        pessoa.setCpf(dto.cpf());
        pessoaRepository.save(pessoa);

        var tutor = new Tutor(usuario, pessoa);
        tutorRepository.save(tutor);

        return mapper.usuarioToResponse(usuario);
    }
}
