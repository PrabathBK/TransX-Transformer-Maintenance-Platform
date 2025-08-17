package com.acme.backend.api.dto;
import jakarta.validation.constraints.NotBlank; import jakarta.validation.constraints.Positive;
public record CreateTransformerReq(@NotBlank String code, @NotBlank String location, @Positive Integer capacityKVA) {}