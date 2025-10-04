package com.acme.backend.service;

import com.acme.backend.api.dto.*;
import com.acme.backend.domain.Annotation;
import com.acme.backend.domain.Inspection;
import com.acme.backend.domain.ThermalImage;
import com.acme.backend.domain.Transformer;
import com.acme.backend.repo.AnnotationRepo;
import com.acme.backend.repo.InspectionRepo;
import com.acme.backend.repo.ThermalImageRepo;
import com.acme.backend.repo.TransformerRepo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.nio.file.Paths;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * Service for managing inspections and triggering ML detection (Phase 2 & 3)
 */
@Service
@Transactional
public class InspectionService {
    
    private static final Logger log = LoggerFactory.getLogger(InspectionService.class);
    
    @Value("${app.storage.root:uploads}")
    private String storageRoot;
    
    private final InspectionRepo inspectionRepo;
    private final AnnotationRepo annotationRepo;
    private final TransformerRepo transformerRepo;
    private final ThermalImageRepo thermalImageRepo;
    private final MLServiceClient mlServiceClient;
    private final InspectionHistoryService historyService;
    
    public InspectionService(
            InspectionRepo inspectionRepo,
            AnnotationRepo annotationRepo,
            TransformerRepo transformerRepo,
            ThermalImageRepo thermalImageRepo,
            MLServiceClient mlServiceClient,
            InspectionHistoryService historyService) {
        this.inspectionRepo = inspectionRepo;
        this.annotationRepo = annotationRepo;
        this.transformerRepo = transformerRepo;
        this.thermalImageRepo = thermalImageRepo;
        this.mlServiceClient = mlServiceClient;
        this.historyService = historyService;
    }
    
    /**
     * Create a new inspection
     */
    public InspectionDTO createInspection(CreateInspectionRequest request) {
        Transformer transformer = transformerRepo.findById(request.transformerId())
                .orElseThrow(() -> new RuntimeException("Transformer not found"));
        
        ThermalImage baselineImage = null;
        if (request.baselineImageId() != null) {
            baselineImage = thermalImageRepo.findById(request.baselineImageId())
                    .orElseThrow(() -> new RuntimeException("Baseline image not found"));
        }
        
        Inspection inspection = new Inspection();
        inspection.setInspectionNumber(request.inspectionNumber());
        inspection.setTransformer(transformer);
        inspection.setBaselineImage(baselineImage);
        inspection.setBranch(request.branch());
        inspection.setWeatherCondition(request.weatherCondition());
        inspection.setInspectedBy(request.inspectedBy());
        inspection.setInspectedAt(request.inspectedAt() != null ? request.inspectedAt() : Instant.now());
        inspection.setNotes(request.notes());
        inspection.setStatus(Inspection.Status.DRAFT);
        
        inspection = inspectionRepo.save(inspection);
        log.info("Created inspection: {}", inspection.getInspectionNumber());
        
        return toDTO(inspection);
    }
    
    /**
     * Update inspection with uploaded thermal image and trigger detection
     */
    public InspectionDTO uploadInspectionImage(UUID inspectionId, UUID imageId) {
        Inspection inspection = inspectionRepo.findById(inspectionId)
                .orElseThrow(() -> new RuntimeException("Inspection not found"));
        
        ThermalImage image = thermalImageRepo.findById(imageId)
                .orElseThrow(() -> new RuntimeException("Image not found"));
        
        inspection.setInspectionImage(image);
        // Store as original image if not set (for editing annotations)
        if (inspection.getOriginalInspectionImage() == null) {
            inspection.setOriginalInspectionImage(image);
        }
        inspection.setStatus(Inspection.Status.IN_PROGRESS);
        
        inspection = inspectionRepo.save(inspection);
        log.info("Added inspection image to inspection: {}", inspection.getInspectionNumber());
        
        return toDTO(inspection);
    }
    
    /**
     * Remove inspection image from inspection (allows re-upload)
     */
    public InspectionDTO removeInspectionImage(UUID inspectionId) {
        Inspection inspection = inspectionRepo.findById(inspectionId)
                .orElseThrow(() -> new RuntimeException("Inspection not found"));
        
        if (inspection.getInspectionImage() == null) {
            throw new RuntimeException("No inspection image to remove");
        }
        
        // Clear the inspection image references
        inspection.setInspectionImage(null);
        inspection.setOriginalInspectionImage(null);
        
        // Reset status to DRAFT since we removed the image
        inspection.setStatus(Inspection.Status.DRAFT);
        
        // Clear any existing annotations since they're tied to the removed image
        annotationRepo.deleteByInspectionId(inspectionId);
        
        inspection = inspectionRepo.save(inspection);
        log.info("Removed inspection image from inspection: {}", inspection.getInspectionNumber());
        
        return toDTO(inspection);
    }
    
    /**
     * Trigger anomaly detection on inspection image with baseline comparison (Phase 2)
     */
    public DetectionResponse detectAnomalies(UUID inspectionId, Double confidenceThreshold) {
        Inspection inspection = inspectionRepo.findById(inspectionId)
                .orElseThrow(() -> new RuntimeException("Inspection not found"));
        
        if (inspection.getInspectionImage() == null) {
            throw new RuntimeException("No inspection image uploaded");
        }
        
        // Get absolute path to inspection image
        String inspectionImagePath = getAbsoluteImagePath(inspection.getInspectionImage());
        
        // Try to find a baseline image for comparison
        String baselineImagePath = null;
        UUID transformerId = inspection.getTransformer().getId();
        
        if (transformerId != null) {
            log.info("🔍 Looking for baseline images for transformer: {}", transformerId);
            
            // Get baseline images, prioritizing matching weather condition
            Page<ThermalImage> baselineImages = thermalImageRepo.findByTransformerIdAndType(
                transformerId, 
                ThermalImage.Type.BASELINE, 
                Pageable.ofSize(10)
            );
            
            ThermalImage selectedBaseline = null;
            
            // Try to match weather condition first
            if (inspection.getWeatherCondition() != null && baselineImages.hasContent()) {
                selectedBaseline = baselineImages.getContent().stream()
                    .filter(img -> inspection.getWeatherCondition().equals(img.getEnvCondition()))
                    .findFirst()
                    .orElse(null);
                    
                if (selectedBaseline != null) {
                    log.info("✅ Found baseline with matching weather: {}", inspection.getWeatherCondition());
                }
            }
            
            // If no weather match, use most recent baseline
            if (selectedBaseline == null && baselineImages.hasContent()) {
                selectedBaseline = baselineImages.getContent().get(0);  // Most recent due to default ordering
                log.info("📷 Using most recent baseline image (no weather match)");
            }
            
            if (selectedBaseline != null) {
                baselineImagePath = getAbsoluteImagePath(selectedBaseline);
                log.info("🖼️ Selected baseline: {}", baselineImagePath);
            } else {
                log.warn("⚠️ No baseline images found for transformer: {}", transformerId);
            }
        }
        
        log.info("🚀 Triggering anomaly detection for inspection: {}", inspection.getInspectionNumber());
        log.info("   Inspection image: {}", inspectionImagePath);
        log.info("   Baseline image: {}", baselineImagePath != null ? baselineImagePath : "None");
        
        // Call ML service with both images
        DetectionResponse response = mlServiceClient.detectAnomalies(inspectionImagePath, baselineImagePath, confidenceThreshold);
        
        // Save AI-generated annotations to database
        if (response.success() && response.detections() != null) {
            saveDetectionsAsAnnotations(inspection, response.detections());
        }
        
        return response;
    }
    
    /**
     * Save ML detection results as annotations with box numbering and history tracking
     */
    private void saveDetectionsAsAnnotations(Inspection inspection, List<DetectionResponse.Detection> detections) {
        List<Annotation> newAnnotations = new java.util.ArrayList<>();
        
        for (DetectionResponse.Detection detection : detections) {
            Annotation annotation = new Annotation();
            annotation.setInspection(inspection);
            annotation.setBboxX1(detection.bbox().x1());
            annotation.setBboxY1(detection.bbox().y1());
            annotation.setBboxX2(detection.bbox().x2());
            annotation.setBboxY2(detection.bbox().y2());
            annotation.setClassId(detection.classId());
            annotation.setClassName(detection.className());
            annotation.setConfidence(BigDecimal.valueOf(detection.confidence()));
            annotation.setSource(Annotation.Source.ai);
            annotation.setActionType(Annotation.ActionType.created);
            annotation.setCreatedBy("AI-YOLOv8");
            annotation.setIsActive(true);
            
            newAnnotations.add(annotation);
        }
        
        // Assign box numbers to all new annotations
        String inspectorName = inspection.getCurrentInspector() != null ? 
                              inspection.getCurrentInspector() : "AI-System";
        historyService.assignBoxNumbers(inspection.getId().toString(), newAnnotations, inspectorName);
        
        // Save all annotations
        for (Annotation annotation : newAnnotations) {
            annotationRepo.save(annotation);
        }
        
        // Log AI detection run in history
        java.util.Map<String, Object> metadata = new java.util.HashMap<>();
        metadata.put("model_type", "YOLOv8p2");
        metadata.put("total_detections", detections.size());
        metadata.put("confidence_threshold", "user_specified");
        
        historyService.logAIDetectionRun(inspection.getId().toString(), inspectorName, 
                                        newAnnotations, metadata);
        
        log.info("✅ Saved {} AI-generated annotations with box numbers for inspection: {}", 
                detections.size(), inspection.getInspectionNumber());
    }
    
    /**
     * Get all inspections with pagination
     */
    @Transactional(readOnly = true)
    public Page<InspectionDTO> getAllInspections(Pageable pageable) {
        return inspectionRepo.findRecentInspections(pageable).map(this::toDTO);
    }
    
    /**
     * Search inspections
     */
    @Transactional(readOnly = true)
    public Page<InspectionDTO> searchInspections(String query, Pageable pageable) {
        return inspectionRepo.findBySearchQuery(query, pageable).map(this::toDTO);
    }
    
    /**
     * Get inspections by transformer ID
     */
    @Transactional(readOnly = true)
    public Page<InspectionDTO> getInspectionsByTransformerId(UUID transformerId, Pageable pageable) {
        return inspectionRepo.findByTransformerId(transformerId, pageable).map(this::toDTO);
    }
    
    /**
     * Get inspection by ID
     */
    @Transactional(readOnly = true)
    public InspectionDTO getInspectionById(UUID id) {
        Inspection inspection = inspectionRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Inspection not found"));
        return toDTO(inspection);
    }
    
    /**
     * Update inspection status and notes
     */
    public InspectionDTO updateInspection(UUID id, Inspection.Status status, String notes) {
        Inspection inspection = inspectionRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Inspection not found"));
        
        if (status != null) {
            inspection.setStatus(status);
        }
        if (notes != null) {
            inspection.setNotes(notes);
        }
        
        inspection = inspectionRepo.save(inspection);
        return toDTO(inspection);
    }
    
    /**
     * Update inspection with annotated image (image showing bounding boxes)
     */
    public InspectionDTO updateAnnotatedImage(UUID inspectionId, UUID annotatedImageId) {
        Inspection inspection = inspectionRepo.findById(inspectionId)
                .orElseThrow(() -> new RuntimeException("Inspection not found"));
        
        ThermalImage annotatedImage = thermalImageRepo.findById(annotatedImageId)
                .orElseThrow(() -> new RuntimeException("Annotated image not found"));
        
        // Set the annotated image as the inspection image (this will be displayed on transformer page)
        inspection.setInspectionImage(annotatedImage);
        
        inspection = inspectionRepo.save(inspection);
        log.info("Updated inspection {} with annotated image: {}", inspection.getInspectionNumber(), annotatedImage.getOriginalFilename());
        
        return toDTO(inspection);
    }
    
    /**
     * Delete inspection and all related data (cascading delete)
     */
    @Transactional
    public void deleteInspection(UUID id) {
        // First, check if inspection exists
        if (!inspectionRepo.existsById(id)) {
            throw new RuntimeException("Inspection not found with id: " + id);
        }

        log.info("Deleting inspection {} and all related data...", id);
        
        // Delete all annotations for this inspection
        annotationRepo.deleteByInspectionId(id);
        log.debug("Deleted annotations for inspection: {}", id);
        
        // Delete all thermal images for this inspection 
        thermalImageRepo.deleteByInspectionId(id);
        log.debug("Deleted thermal images for inspection: {}", id);
        
        // Finally delete the inspection itself
        inspectionRepo.deleteById(id);
        log.info("Successfully deleted inspection: {}", id);
    }
    
    /**
     * Get absolute file system path for thermal image
     */
    private String getAbsoluteImagePath(ThermalImage image) {
        // Construct path: storageRoot/transformerId/type/filename
        UUID transformerId = image.getTransformer().getId();
        String type = image.getType().name().toLowerCase();
        String filename = image.getStoredFilename();
        
        // storageRoot is already an absolute path from application.properties
        return Paths.get(storageRoot,
                        transformerId.toString(),
                        type,
                        filename)
                    .toString();
    }
    
    /**
     * Convert Inspection entity to DTO
     */
    private InspectionDTO toDTO(Inspection inspection) {
        Long annotationCount = annotationRepo.countActiveByInspectionId(inspection.getId());
        
        return new InspectionDTO(
                inspection.getId(),
                inspection.getInspectionNumber(),
                inspection.getTransformer().getId(),
                inspection.getTransformer().getCode(),
                inspection.getBranch(),
                inspection.getBaselineImage() != null ? inspection.getBaselineImage().getId() : null,
                inspection.getBaselineImage() != null ? inspection.getBaselineImage().getPublicUrl() : null,
                inspection.getInspectionImage() != null ? inspection.getInspectionImage().getId() : null,
                inspection.getInspectionImage() != null ? inspection.getInspectionImage().getPublicUrl() : null,
                inspection.getOriginalInspectionImage() != null ? inspection.getOriginalInspectionImage().getId() : null,
                inspection.getOriginalInspectionImage() != null ? inspection.getOriginalInspectionImage().getPublicUrl() : null,
                inspection.getWeatherCondition(),
                inspection.getStatus(),
                inspection.getInspectedBy(),
                inspection.getCurrentInspector(),  // Phase 3: Current inspector tracking
                inspection.getInspectedAt(),
                inspection.getMaintenanceDate(),
                inspection.getNotes(),
                annotationCount,
                inspection.getCreatedAt(),
                inspection.getUpdatedAt()
        );
    }

    /**
     * Update current inspector for an inspection
     */
    @Transactional
    public void updateCurrentInspector(String inspectionId, String inspectorName) {
        log.info("👤 Updating current inspector for inspection {} to: {}", inspectionId, inspectorName);
        
        Inspection inspection = inspectionRepo.findById(UUID.fromString(inspectionId))
                .orElseThrow(() -> new RuntimeException("Inspection not found: " + inspectionId));
        
        String previousInspector = inspection.getCurrentInspector();
        inspection.setCurrentInspector(inspectorName);
        inspectionRepo.save(inspection);
        
        log.info("✅ Inspector updated from {} to {}", previousInspector, inspectorName);
    }

    /**
     * Complete an inspection and lock it for editing
     */
    @Transactional
    public void completeInspection(String inspectionId, String completedBy) {
        log.info("🏁 Completing inspection: {} by {}", inspectionId, completedBy);
        
        Inspection inspection = inspectionRepo.findById(UUID.fromString(inspectionId))
                .orElseThrow(() -> new RuntimeException("Inspection not found: " + inspectionId));
        
        inspection.setStatus(Inspection.Status.COMPLETED);
        inspection.setCompletedAt(Instant.now());
        inspection.setCompletedBy(completedBy);
        inspectionRepo.save(inspection);
        
        // Get statistics for history logging
        List<Annotation> annotations = annotationRepo.findActiveByInspectionId(inspection.getId());
        java.util.Map<String, Integer> classificationSummary = new java.util.HashMap<>();
        
        for (Annotation annotation : annotations) {
            String className = annotation.getClassName() != null ? annotation.getClassName() : "Unknown";
            classificationSummary.merge(className, 1, Integer::sum);
        }
        
        historyService.logInspectionCompleted(inspectionId, completedBy, 
                                            annotations.size(), classificationSummary);
        
        log.info("✅ Inspection completed with {} boxes", annotations.size());
    }
}
