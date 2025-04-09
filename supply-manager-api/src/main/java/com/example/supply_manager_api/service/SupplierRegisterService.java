package com.example.supply_manager_api.service;

import com.example.supply_manager_api.dto.SupplierRegisterDto;
import com.example.supply_manager_api.model.Company;
import com.example.supply_manager_api.model.Post;
import com.example.supply_manager_api.model.Supplier;
import com.example.supply_manager_api.model.User;
import com.example.supply_manager_api.repository.CompanyRepository;
import com.example.supply_manager_api.repository.PostRepository;
import com.example.supply_manager_api.repository.SupplierRegisterRepository;
import com.example.supply_manager_api.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class SupplierRegisterService {

    @Autowired
    private SupplierRegisterRepository supplierRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CompanyRepository companyRepository; // Репозиторий для работы с компаниями

    @Autowired
    private PostRepository postRepository;  // Допустим, у вас есть репозиторий для работы с должностями

    @Autowired
    private PasswordEncoder passwordEncoder;

    public void registerSupplier(SupplierRegisterDto supplierRegisterDto) {
        if (userRepository.existsByUsername(supplierRegisterDto.getUsername())) {
            throw new RuntimeException("Username already exists");
        }

        if (userRepository.existsByEmail(supplierRegisterDto.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        User user = new User();
        user.setUsername(supplierRegisterDto.getUsername());
        user.setPassword(passwordEncoder.encode(supplierRegisterDto.getPassword()));
        user.setEmail(supplierRegisterDto.getEmail());
        user.setRoleId(4L);

        userRepository.save(user);

        Supplier supplier = new Supplier();
        supplier.setContactPerson(supplierRegisterDto.getContactPerson());
        supplier.setPhoneNumber(supplierRegisterDto.getPhoneNumber());
        supplier.setEmail(supplierRegisterDto.getEmail());
        supplier.setAddress(supplierRegisterDto.getAddress());
        supplier.setCompanyId(getCompanyIdByName(supplierRegisterDto.getCompanyName()));
        supplier.setCompanyVersionId(getCompanyVersionIdByName(supplierRegisterDto.getCompanyName()));
        supplier.setPostId(getPostIdByPosition(supplierRegisterDto.getPosition()));

        supplierRepository.save(supplier);
    }

    // Получение ID компании по имени
    private Long getCompanyIdByName(String companyName) {
        Optional<Company> companyOptional = companyRepository.findByName(companyName); // Предполагается, что у вас есть метод в репозитории
        return companyOptional.map(Company::getId).orElseThrow(() -> new RuntimeException("Company not found"));
    }

    // Получение версии ID компании по имени
    private Long getCompanyVersionIdByName(String companyName) {
        Optional<Company> companyOptional = companyRepository.findByName(companyName); // Предполагается, что у вас есть метод в репозитории
        return companyOptional.map(Company::getVersionId).orElseThrow(() -> new RuntimeException("Company not found"));
    }

    // Получение ID поста по названию должности
    private Long getPostIdByPosition(String position) {
        Optional<Post> postOptional = postRepository.findByName(position); // Предполагается, что у вас есть метод в репозитории
        return postOptional.map(Post::getId).orElseThrow(() -> new RuntimeException("Post not found"));
    }
}