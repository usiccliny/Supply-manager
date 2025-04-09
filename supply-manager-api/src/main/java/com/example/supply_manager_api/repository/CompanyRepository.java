package com.example.supply_manager_api.repository;

import com.example.supply_manager_api.model.Company;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CompanyRepository extends JpaRepository<Company, Long> {
   boolean existsByCompanyCode (String companyCode);
   Optional<Company> findByName(String Name);
}
