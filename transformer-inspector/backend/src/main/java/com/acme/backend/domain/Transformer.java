package com.acme.backend.domain;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Document("transformers")                 // Mongo collection
public class Transformer {

    @Id
    private String id;                    // Mongo _id (String). Expose as String in DTOs.

    @NotBlank
    @Indexed(unique = true)               // replaces @UniqueConstraint(columnNames = "code")
    private String code;                  // "Transformer No."

    // --- Existing Phase-1 fields ---
    @NotBlank
    private String location;

    @Positive
    private Integer capacityKVA;

    // --- Optional fields ---
    private String region;                // Regions (free text for now)
    private String poleNo;                // Pole No.
    private String type;                  // e.g., "Bulk", "Distribution"
    private String locationDetails;       // Notes / details

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;

    // getters/setters
    public String getId() { return id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public Integer getCapacityKVA() { return capacityKVA; }
    public void setCapacityKVA(Integer capacityKVA) { this.capacityKVA = capacityKVA; }

    public String getRegion() { return region; }
    public void setRegion(String region) { this.region = region; }

    public String getPoleNo() { return poleNo; }
    public void setPoleNo(String poleNo) { this.poleNo = poleNo; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getLocationDetails() { return locationDetails; }
    public void setLocationDetails(String locationDetails) { this.locationDetails = locationDetails; }

    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
}
