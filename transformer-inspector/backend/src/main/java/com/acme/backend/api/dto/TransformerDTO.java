package com.acme.backend.api.dto;

import java.time.Instant;

public record TransformerDTO(
        String id,            // CHANGED from UUID -> String
        String code,
        String location,
        Integer capacityKVA,
        String region,
        String poleNo,
        String type,
        String locationDetails,
        Instant createdAt
        // If you keep updatedAt in the entity and want it here, add: Instant updatedAt
) {}
