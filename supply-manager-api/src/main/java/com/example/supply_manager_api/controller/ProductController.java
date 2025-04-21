package com.example.supply_manager_api.controller;

import com.example.supply_manager_api.dto.AttributeDto;
import com.example.supply_manager_api.dto.ProductDto;
import com.example.supply_manager_api.model.ProductCard;
import com.example.supply_manager_api.model.ProductCategory;
import com.example.supply_manager_api.model.ProductStatus;
import com.example.supply_manager_api.model.ViewProduct;
import com.example.supply_manager_api.service.ProductAttributeService;
import com.example.supply_manager_api.service.ProductCardService;
import com.example.supply_manager_api.service.ProductService;
import com.example.supply_manager_api.service.ViewProductService;
import org.hibernate.annotations.UpdateTimestamp;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    @Autowired
    private ProductService productService;

    @Autowired
    private ViewProductService viewProductService;

    @Autowired
    private ProductCardService productCardService;

    @Autowired
    private ProductAttributeService productAttributeService;

    /**
     * Метод для добавления нового товара.
     */
    @PostMapping("/add")
    public ResponseEntity<String> addProduct(@RequestBody ProductDto productDto) {
        try {
            productService.saveProduct(productDto);
            return ResponseEntity.ok("Товар успешно добавлен");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Ошибка при добавлении товара: " + e.getMessage());
        }
    }

    // Обновление товара
    @PutMapping("/update")
    public ResponseEntity<String> updateProduct(@RequestBody ProductDto updatedProduct) {
        try {
            productService.saveProduct(updatedProduct);
            return ResponseEntity.ok("Товар успешно обновлен.");
        } catch (Exception e) {
          return ResponseEntity.badRequest().body("Ошибка при обновлении товара: " + e.getMessage());
        }
    }

    // Удаление товара
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<String> deleteProduct(@PathVariable Long id) {
        productService.markProductAsObsolete(id);
        return ResponseEntity.ok("Товар успешно удален.");
    }

    @GetMapping("/status")
    public List<ProductStatus> getAllProductStatus(){
        return productService.getAllProductStatus();
    }

    @GetMapping("/category")
    public List<ProductCategory> getAllProductCategories(){
        return productService.getAllProductCategories();
    }

    @GetMapping("/catalog")
    public List<ViewProduct> getAllProducts(){
        return viewProductService.getAllProducts();
    }

    @GetMapping("/{id}")
    public ProductCard getProductCardById(@PathVariable Long id) {
        return productCardService.getProductCardById(id);
    }

    // Добавить новый атрибут
    @PostMapping("/{productId}/attributes/add")
    public ResponseEntity<AttributeDto> addAttribute(
            @PathVariable Long productId,
            @RequestBody AttributeDto request) {
        // Вызываем сервис для добавления атрибута
        AttributeDto createdAttribute = productAttributeService.addAttribute(
                productId,
                request.getProductVersionId(),
                request.getName(),
                request.getValue(),
                request.getUnit(),
                request.getType()
        );

        // Возвращаем созданный атрибут с HTTP-статусом 201 (Created)
        return ResponseEntity.status(HttpStatus.CREATED).body(createdAttribute);
    }

    // Изменить значение атрибута
    @PutMapping("/{productId}/attributes/{attributeId}")
    public ResponseEntity<AttributeDto> updateAttribute(
            @PathVariable Long attributeId,
            @RequestParam String value) {
        AttributeDto updatedAttribute = productAttributeService.updateAttribute(attributeId, value);

        // Возвращаем созданный атрибут с HTTP-статусом 200 (OK)
        return ResponseEntity.ok(updatedAttribute);
    }

    // Удалить атрибут
    @DeleteMapping("/{id}/attributes/{attributeId}")
    public void deleteAttribute(@PathVariable Long attributeId) {
        productAttributeService.deleteAttribute(attributeId);
    }
}