// src/main/java/com/acme/backend/repo/ThermalImageRepo.java
package com.acme.backend.repo;

import com.acme.backend.domain.ThermalImage;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface ThermalImageRepo extends MongoRepository<ThermalImage, String> {

    Page<ThermalImage> findByTransformerIdAndType(String transformerId, ThermalImage.Type type, Pageable pageable);

    Page<ThermalImage> findByTransformerId(String transformerId, Pageable pageable);

    Page<ThermalImage> findByType(ThermalImage.Type type, Pageable pageable);

    void deleteByTransformerId(String transformerId);
}
