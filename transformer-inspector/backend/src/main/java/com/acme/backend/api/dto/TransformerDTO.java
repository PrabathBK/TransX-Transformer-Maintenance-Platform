package com.acme.backend.api.dto;
import java.time.Instant; import java.util.UUID;
public record TransformerDTO(UUID id, String code, String location, Integer capacityKVA, Instant createdAt) {}