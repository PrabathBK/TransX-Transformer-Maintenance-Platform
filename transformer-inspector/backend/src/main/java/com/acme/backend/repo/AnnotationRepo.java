// package com.acme.backend.repo;

// import com.acme.backend.domain.Annotation;
// import org.springframework.data.jpa.repository.JpaRepository;
// import org.springframework.data.jpa.repository.Query;
// import org.springframework.data.repository.query.Param;

// import java.util.List;
// import java.util.UUID;

// /**
//  * Repository for Annotation entity (Phase 2 & 3)
//  */
// public interface AnnotationRepo extends JpaRepository<Annotation, UUID> {
    
//     /**
//      * Find all active annotations for an inspection
//      */
//     @Query("SELECT a FROM Annotation a WHERE a.inspection.id = :inspectionId AND a.isActive = true")
//     List<Annotation> findActiveByInspectionId(@Param("inspectionId") UUID inspectionId);
    
//     /**
//      * Find all annotations (including inactive) for an inspection
//      */
//     List<Annotation> findByInspectionId(UUID inspectionId);
    
//     /**
//      * Find annotations by source (ai or human)
//      */
//     @Query("SELECT a FROM Annotation a WHERE a.inspection.id = :inspectionId AND a.source = :source AND a.isActive = true")
//     List<Annotation> findByInspectionIdAndSource(
//         @Param("inspectionId") UUID inspectionId,
//         @Param("source") Annotation.Source source
//     );
    
//     /**
//      * Find annotation history (all versions) for a specific annotation
//      */
//     @Query("SELECT a FROM Annotation a WHERE a.id = :annotationId OR a.parentAnnotation.id = :annotationId ORDER BY a.version DESC")
//     List<Annotation> findAnnotationHistory(@Param("annotationId") UUID annotationId);
    
//     /**
//      * Get version history for an inspection
//      */
//     @Query("SELECT a FROM Annotation a WHERE a.inspection.id = :inspectionId ORDER BY a.version DESC, a.createdAt DESC")
//     List<Annotation> findVersionHistory(@Param("inspectionId") UUID inspectionId);
    
//     /**
//      * Count active annotations by inspection
//      */
//     @Query("SELECT COUNT(a) FROM Annotation a WHERE a.inspection.id = :inspectionId AND a.isActive = true")
//     Long countActiveByInspectionId(@Param("inspectionId") UUID inspectionId);
    
//     /**
//      * Delete all annotations for an inspection
//      */
//     void deleteByInspectionId(UUID inspectionId);
// }

<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
package com.acme.backend.repo;

import com.acme.backend.domain.Annotation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

/**
 * Repository for Annotation entity (Phase 2 & 3)
 */
public interface AnnotationRepo extends JpaRepository<Annotation, UUID> {
    
    /**
     * Find all active annotations for an inspection
     */
    @Query("SELECT a FROM Annotation a WHERE a.inspection.id = :inspectionId AND a.isActive = true")
    List<Annotation> findActiveByInspectionId(@Param("inspectionId") UUID inspectionId);
    
    /**
     * Find all annotations (including inactive) for an inspection
     */
    List<Annotation> findByInspectionId(UUID inspectionId);
    
    /**
     * Find annotations by source (ai or human)
     */
    @Query("SELECT a FROM Annotation a WHERE a.inspection.id = :inspectionId AND a.source = :source AND a.isActive = true")
    List<Annotation> findByInspectionIdAndSource(
        @Param("inspectionId") UUID inspectionId,
        @Param("source") Annotation.Source source
    );
    
    /**
     * Find annotation history (all versions) for a specific annotation
     */
    @Query("SELECT a FROM Annotation a WHERE a.id = :annotationId OR a.parentAnnotation.id = :annotationId ORDER BY a.version DESC")
    List<Annotation> findAnnotationHistory(@Param("annotationId") UUID annotationId);
    
    /**
     * Get version history for an inspection
     */
    @Query("SELECT a FROM Annotation a WHERE a.inspection.id = :inspectionId ORDER BY a.version DESC, a.createdAt DESC")
    List<Annotation> findVersionHistory(@Param("inspectionId") UUID inspectionId);
    
    /**
     * Count active annotations by inspection
     */
    @Query("SELECT COUNT(a) FROM Annotation a WHERE a.inspection.id = :inspectionId AND a.isActive = true")
    Long countActiveByInspectionId(@Param("inspectionId") UUID inspectionId);
    
    /**
     * Delete all annotations for an inspection
     */
    void deleteByInspectionId(UUID inspectionId);

    // ------------------ NEW METHODS ------------------

    /**
     * Find all flagged annotations for an inspection
     */
    @Query("SELECT a FROM Annotation a WHERE a.inspection.id = :inspectionId AND a.flagged = true AND a.isActive = true")
    List<Annotation> findFlaggedByInspectionId(@Param("inspectionId") UUID inspectionId);

    /**
     * Find annotations by severity score threshold
     */
    @Query("SELECT a FROM Annotation a WHERE a.inspection.id = :inspectionId AND a.severityScore >= :minScore AND a.isActive = true")
    List<Annotation> findBySeverityAbove(
        @Param("inspectionId") UUID inspectionId,
        @Param("minScore") java.math.BigDecimal minScore
    );

    /**
     * Find annotations ordered by annotationNumber (useful for UI display)
     */
    @Query("SELECT a FROM Annotation a WHERE a.inspection.id = :inspectionId AND a.isActive = true ORDER BY a.annotationNumber ASC")
    List<Annotation> findOrderedByNumber(@Param("inspectionId") UUID inspectionId);
<<<<<<< Updated upstream
=======

    @Query("SELECT a FROM Annotation a WHERE a.inspection.id = :inspectionId ORDER BY a.createdAt DESC")
    List<Annotation> findAllByInspectionIdWithHistory(@Param("inspectionId") UUID inspectionId);

>>>>>>> Stashed changes
}
