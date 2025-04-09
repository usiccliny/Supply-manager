package com.example.supply_manager_api.repository;

import com.example.supply_manager_api.model.Post;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PostRepository extends JpaRepository<Post, Long> {
    Optional<Post> findByName(String name);
}