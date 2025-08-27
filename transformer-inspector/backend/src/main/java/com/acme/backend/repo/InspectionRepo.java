package com.acme.backend.repo;

import com.acme.backend.domain.Inspection;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.UUID;

public interface InspectionRepo extends JpaRepository<Inspection, UUID> {
    
    Page<Inspection> findByTransformerId(UUID transformerId, Pageable pageable);
    
    @Query("SELECT i FROM Inspection i WHERE " +
           "LOWER(i.inspectionNo) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
           "LOWER(i.transformer.code) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
           "LOWER(i.branch) LIKE LOWER(CONCAT('%', :q, '%'))")
    Page<Inspection> findBySearchQuery(@Param("q") String q, Pageable pageable);
    
    void deleteByTransformerId(UUID transformerId);
}
