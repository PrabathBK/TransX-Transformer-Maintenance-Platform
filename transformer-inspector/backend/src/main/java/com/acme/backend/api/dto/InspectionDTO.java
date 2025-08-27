package com.acme.backend.api.dto;

import com.acme.backend.domain.Inspection;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

public record InspectionDTO(
        UUID id,
        String inspectionNo,
        UUID transformerId,
        String transformerCode,
        String branch,
        LocalDate inspectionDate,
        LocalTime inspectionTime,
        LocalDate maintenanceDate,
        LocalTime maintenanceTime,
        Inspection.Status status,
        String inspectedBy,
        String notes,
        Instant createdAt,
        Instant updatedAt
) {}
