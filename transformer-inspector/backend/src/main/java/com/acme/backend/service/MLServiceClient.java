package com.acme.backend.service;

import com.acme.backend.api.dto.DetectionResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

/**
 * Client for communicating with Python ML Service (Phase 2)
 * Sends image paths for inference and receives detection results
 */
@Service
public class MLServiceClient {
    
    private static final Logger log = LoggerFactory.getLogger(MLServiceClient.class);
    
    @Value("${app.ml-service.url:http://localhost:5000}")
    private String mlServiceUrl;
    
    private final RestTemplate restTemplate;
    
    public MLServiceClient() {
        this.restTemplate = new RestTemplate();
    }
    
    /**
     * Check if ML service is healthy and ready
     */
    public boolean isHealthy() {
        try {
            String url = mlServiceUrl + "/api/health";
            ResponseEntity<Map> response = restTemplate.getForEntity(url, Map.class);
            return response.getStatusCode().is2xxSuccessful();
        } catch (Exception e) {
            log.error("ML Service health check failed: {}", e.getMessage());
            return false;
        }
    }
    
    /**
     * Send image for anomaly detection (backward compatibility)
     * 
     * @param imagePath Absolute file path to the thermal image
     * @param confidenceThreshold Minimum confidence threshold (default 0.25)
     * @return DetectionResponse with bounding boxes and classifications
     */
    public DetectionResponse detectAnomalies(String imagePath, Double confidenceThreshold) {
        return detectAnomalies(imagePath, null, confidenceThreshold);
    }
    
    /**
     * Send both baseline and inspection images for anomaly detection with comparison
     * 
     * @param inspectionImagePath Absolute file path to the inspection thermal image
     * @param baselineImagePath Absolute file path to the baseline thermal image (optional)
     * @param confidenceThreshold Minimum confidence threshold (default 0.25)
     * @return DetectionResponse with bounding boxes and classifications
     */
    public DetectionResponse detectAnomalies(String inspectionImagePath, String baselineImagePath, Double confidenceThreshold) {
        try {
            String url = mlServiceUrl + "/api/detect";
            
            // Prepare request payload for both baseline and inspection images
            Map<String, Object> request = new HashMap<>();
            request.put("inspection_image_path", inspectionImagePath);
            if (baselineImagePath != null && !baselineImagePath.trim().isEmpty()) {
                request.put("baseline_image_path", baselineImagePath);
                log.info("🔍 Sending anomaly detection with baseline comparison");
                log.info("   Inspection: {}", inspectionImagePath);
                log.info("   Baseline: {}", baselineImagePath);
            } else {
                log.info("🔍 Sending anomaly detection without baseline");
                log.info("   Inspection: {}", inspectionImagePath);
            }
            request.put("confidence_threshold", confidenceThreshold != null ? confidenceThreshold : 0.25);
            
            // Set headers
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);
            
            // Call ML service
            ResponseEntity<DetectionResponse> response = restTemplate.postForEntity(
                url,
                entity,
                DetectionResponse.class
            );
            
            DetectionResponse result = response.getBody();
            
            if (result != null && result.success()) {
                log.info("Detection completed: {} detections found in {}ms",
                        result.detections().size(),
                        result.inferenceTimeMs());
                return result;
            } else {
                log.error("Detection failed: {}", result != null ? result.error() : "Unknown error");
                throw new RuntimeException("ML Service returned failure: " + 
                        (result != null ? result.error() : "Unknown error"));
            }
            
        } catch (Exception e) {
            log.error("Error calling ML service: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to communicate with ML service: " + e.getMessage(), e);
        }
    }
    
    /**
     * Get ML service information
     */
    public Map<String, Object> getServiceInfo() {
        try {
            String url = mlServiceUrl + "/api/health";
            ResponseEntity<Map> response = restTemplate.getForEntity(url, Map.class);
            return response.getBody();
        } catch (Exception e) {
            log.error("Failed to get ML service info: {}", e.getMessage());
            Map<String, Object> errorInfo = new HashMap<>();
            errorInfo.put("status", "unavailable");
            errorInfo.put("error", e.getMessage());
            return errorInfo;
        }
    }
}
