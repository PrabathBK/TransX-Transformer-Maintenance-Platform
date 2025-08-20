package com.acme.backend.repo;

import com.acme.backend.domain.Transformer;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface TransformerRepo extends MongoRepository<Transformer, String> {
    Page<Transformer> findByCodeContainingIgnoreCaseOrLocationContainingIgnoreCase(
            String code, String location, Pageable pageable);
}
