package com.acme.backend.domain;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.Instant;
import java.util.UUID;

@Entity @Table(name = "transformers", uniqueConstraints = @UniqueConstraint(columnNames = "code"))
public class Transformer {
    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @NotBlank private String code;
    @NotBlank private String location;
    @Positive private Integer capacityKVA;

    @CreationTimestamp private Instant createdAt;
    @UpdateTimestamp private Instant updatedAt;

    public UUID getId() { return id; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public Integer getCapacityKVA() { return capacityKVA; }
    public void setCapacityKVA(Integer capacityKVA) { this.capacityKVA = capacityKVA; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
}