package com.example.supply_manager_api.service;

import com.example.supply_manager_api.dto.AttributeDto;
import com.example.supply_manager_api.model.Attribute;
import com.example.supply_manager_api.model.ProductAttribute;
import com.example.supply_manager_api.repository.AttributeRepository;
import com.example.supply_manager_api.repository.ProductAttributeRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class ProductAttributeService {

    @Autowired
    private ProductAttributeRepository productAttributeRepository;

    @Autowired
    private AttributeRepository attributeRepository;

    @PersistenceContext
    private EntityManager entityManager;

    // Добавить новый атрибут
    public AttributeDto addAttribute(Long productId, Long productVersionId, String attributeName, String attributeValue, String unit, String dataType) {
        // Создаем новый атрибут
        Attribute attribute = new Attribute();
        attribute.setName(attributeName);
        attribute.setType(dataType);
        attribute.setObsolete(false);
        attribute.setUnit(unit);
        attribute = attributeRepository.save(attribute);

        entityManager.clear();

        // Создаем связь с товаром
        ProductAttribute productAttribute = new ProductAttribute();
        productAttribute.setProductId(productId);
        productAttribute.setProductVersionId(productVersionId);
        productAttribute.setAttribute(attribute); // Устанавливаем связь с атрибутом
        productAttribute.setValue(attributeValue);
        productAttribute.setObsolete(false);
        ProductAttribute savedAttribute = productAttributeRepository.save(productAttribute);

        entityManager.clear();

        // Формируем DTO для ответа
        AttributeDto dto = new AttributeDto();
        dto.setAttributeId(savedAttribute.getId());
        dto.setName(attribute.getName());
        dto.setValue(savedAttribute.getValue());
        dto.setUnit(attribute.getUnit());
        dto.setType(attribute.getType());

        return dto;
    }

    // Изменить значение атрибута
    public AttributeDto updateAttribute(Long attributeId, String newValue) {
        ProductAttribute oldProductAttribute = productAttributeRepository.findByAttributeIdAndObsoleteFalse(attributeId)
                .orElseThrow(() -> new RuntimeException("Attribute not found"));

        entityManager.clear();

        ProductAttribute newProductAttribute = new ProductAttribute();
        newProductAttribute.setProductId(oldProductAttribute.getProductId());
        newProductAttribute.setProductVersionId(oldProductAttribute.getProductVersionId());
        newProductAttribute.setAttribute(oldProductAttribute.getAttribute());
        newProductAttribute.setValue(newValue);
        newProductAttribute.setObsolete(false);

        ProductAttribute savedNewAttribute = productAttributeRepository.save(newProductAttribute);

        Attribute attribute = oldProductAttribute.getAttribute(); // Используем существующий атрибут

        // Формируем DTO для ответа
        AttributeDto dto = new AttributeDto();
        dto.setAttributeId(savedNewAttribute.getId());
        dto.setName(attribute.getName());
        dto.setValue(savedNewAttribute.getValue());
        dto.setUnit(attribute.getUnit());
        dto.setType(attribute.getType());

        return dto;
    }

    // Удалить атрибут
    public void deleteAttribute(Long attributeId) {
        ProductAttribute productAttribute = productAttributeRepository.findByAttributeIdAndObsoleteFalse(attributeId)
                .orElseThrow(() -> new RuntimeException("Attribute not found"));
        productAttribute.setObsolete(true);
        productAttributeRepository.save(productAttribute);
    }
}