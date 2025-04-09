package com.example.supply_manager_api.controller;

import com.example.supply_manager_api.dto.ProductDto;
import com.example.supply_manager_api.model.ProductCategory;
import com.example.supply_manager_api.model.ProductStatus;
import com.example.supply_manager_api.model.ViewProduct;
import com.example.supply_manager_api.service.ProductService;
import com.example.supply_manager_api.service.ViewProductService;
import org.springframework.beans.factory.annotation.Autowired;
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
}