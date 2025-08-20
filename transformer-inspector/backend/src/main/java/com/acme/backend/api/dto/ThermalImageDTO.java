package com.acme.backend.api.dto;

import com.acme.backend.domain.ThermalImage;
import java.time.Instant;

public record ThermalImageDTO(
        String id,                                // CHANGED from UUID -> String
        String transformerId,                     // CHANGED from UUID -> String
        ThermalImage.Type type,
        ThermalImage.EnvCondition envCondition,
        String uploader,
        Instant uploadedAt,
        String publicUrl,
        String originalFilename,
        Long sizeBytes,
        String contentType
) {}
