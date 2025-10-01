package com.acme.backend.api.dto;

import java.util.List;
import java.util.Map;

/**
 * Response DTO from ML service detection (Phase 2)
 */
public record DetectionResponse(
        Boolean success,
        List<Detection> detections,
        ImageDimensions imageDimensions,
        Double inferenceTimeMs,
        ModelInfo modelInfo,
        String error
) {
    /**
     * Individual detection result
     */
    public record Detection(
            String id,
            Integer classId,
            String className,
            Double confidence,
            BoundingBox bbox,
            List<Integer> color,
            String source
    ) {}
    
    /**
     * Bounding box coordinates
     */
    public record BoundingBox(
            Integer x1,
            Integer y1,
            Integer x2,
            Integer y2
    ) {}
    
    /**
     * Image dimensions
     */
    public record ImageDimensions(
            Integer width,
            Integer height
    ) {}
    
    /**
     * Model information
     */
    public record ModelInfo(
            String type,
            Map<String, String> classes
    ) {}
}
