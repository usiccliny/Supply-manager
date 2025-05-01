package com.example.supply_manager_api.service;

import com.example.supply_manager_api.dto.ProductDto;
import com.example.supply_manager_api.model.*;
import com.example.supply_manager_api.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Service
public class ProductService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SupplierRegisterRepository supplierRepository;

    @Autowired
    private ProductStatusRepository productStatusRepository;

    @Autowired
    private ProductCategoryRepository productCategoryRepository;

    @Autowired
    private ProductRepository productRepository;

    /**
     * Метод для сохранения нового товара.
     */
    public void saveProduct(ProductDto productDto) {
        Product product = new Product();

        Long supplierId = getSupplierIdByUsername(productDto.getUsername());
        Long supplierVersionId = getSupplierVersionIdByUsername(productDto.getUsername());

        Long categoryProductId = getCategoryProductIdByName(productDto.getCategoryProduct());

        Long statusProductId = getStatusProductIdByName(productDto.getStatusProduct());

        product.setSupplierId(supplierId);
        product.setSupplierVersionId(supplierVersionId);
        product.setCategoryProductId(categoryProductId);
        product.setStatusId(statusProductId);
        product.setProductName(productDto.getProductName());
        product.setPrice(productDto.getPrice());
        product.setQuantity(productDto.getQuantity());

        productRepository.save(product);
    }

    // Метод для "удаления" товара (установка obsolete = true)
    public void markProductAsObsolete(Long id) {
        Product product = productRepository.findByIdAndObsoleteFalse(id)
                .orElseThrow(() -> new RuntimeException("Товар с ID " + id + " не найден."));

        // Устанавливаем флаг obsolete = true
        product.setObsolete(true);
        productRepository.save(product);
    }

    public List<ProductCategory> getAllProductCategories (){
        return productCategoryRepository.findAll();
    }

    public List<ProductStatus> getAllProductStatus (){
        return productStatusRepository.findAll();
    }

    /**
     * Получение email поставщика по имени пользователя (username).
     */
    private String getSupplierEmailByUsername(String username) {
        Optional<User> userOptional = userRepository.findByUsername(username);
        return userOptional.map(User::getEmail).orElseThrow(() -> new RuntimeException("Пользователь не найден"));
    }

    /**
     * Получение ID поставщика по имени пользователя (username).
     */
    private Long getSupplierIdByUsername(String username) {
        String email = getSupplierEmailByUsername(username);
        Optional<Supplier> supplierOptional = supplierRepository.findByEmail(email);
        return supplierOptional.map(Supplier::getSupplierId).orElseThrow(() -> new RuntimeException("Поставщик не найден"));
    }

    /**
     * Получение версии ID поставщика по имени пользователя (username).
     */
    private Long getSupplierVersionIdByUsername(String username) {
        String email = getSupplierEmailByUsername(username);
        Optional<Supplier> supplierOptional = supplierRepository.findByEmail(email);
        return supplierOptional.map(Supplier::getSupplierVersionId).orElseThrow(() -> new RuntimeException("Поставщик не найден"));
    }

    /**
     * Получение ID категории товара по названию.
     */
    private Long getCategoryProductIdByName(String categoryName) {
        return productCategoryRepository.findByName(categoryName)
                .map(ProductCategory::getId)
                .orElseThrow(() -> new RuntimeException("Категория товара не найдена"));
    }

    /**
     * Получение ID статуса товара по названию.
     */
    private Long getStatusProductIdByName(String statusName) {
        return productStatusRepository.findByName(statusName)
                .map(ProductStatus::getId)
                .orElseThrow(() -> new RuntimeException("Статус товара не найден"));
    }
}