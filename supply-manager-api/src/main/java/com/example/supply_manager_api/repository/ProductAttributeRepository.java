package com.example.supply_manager_api.repository;

import com.example.supply_manager_api.model.ProductAttribute;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductAttributeRepository extends JpaRepository<ProductAttribute, Long> {

    // Найти все атрибуты для конкретного товара
    List<ProductAttribute> findByProductId(Long productId);

    // Найти конкретный атрибут для товара
    Optional<ProductAttribute> findByIdAndProductId(
            Long id, Long productId);

    Optional<ProductAttribute> findByAttributeIdAndObsoleteFalse(Long attributeId);

    // Удалить атрибут (логическое удаление)
    //void markAsObsolete(Long id, Long productId);
}