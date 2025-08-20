package com.acme.backend.domain;

import jakarta.validation.constraints.NotNull;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.index.CompoundIndexes;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Document("thermal_images")
@CompoundIndexes({
        // helpful for listing/filters
        @CompoundIndex(name = "tx_type_time_idx", def = "{'transformerId': 1, 'type': 1, 'uploadedAt': -1}")
})
public class ThermalImage {

    public enum Type { BASELINE, MAINTENANCE }
    public enum EnvCondition { SUNNY, CLOUDY, RAINY }

    @Id
    private String id;                      // Mongo _id

    @NotNull
    @Indexed
    private String transformerId;           // store the Transformer’s id as String

    @NotNull
    private Type type;

    // required only when type == BASELINE
    private EnvCondition envCondition;

    private String originalFilename;
    private String storedFilename;
    private String contentType;
    private Long sizeBytes;
    private String uploader;
    private String publicUrl;

    @CreatedDate
    private Instant uploadedAt;

    // ---- getters/setters ----
    public String getId() { return id; }

    public String getTransformerId() { return transformerId; }
    public void setTransformerId(String transformerId) { this.transformerId = transformerId; }

    public Type getType() { return type; }
    public void setType(Type type) { this.type = type; }

    public EnvCondition getEnvCondition() { return envCondition; }
    public void setEnvCondition(EnvCondition envCondition) { this.envCondition = envCondition; }

    public String getOriginalFilename() { return originalFilename; }
    public void setOriginalFilename(String originalFilename) { this.originalFilename = originalFilename; }

    public String getStoredFilename() { return storedFilename; }
    public void setStoredFilename(String storedFilename) { this.storedFilename = storedFilename; }

    public String getContentType() { return contentType; }
    public void setContentType(String contentType) { this.contentType = contentType; }

    public Long getSizeBytes() { return sizeBytes; }
    public void setSizeBytes(Long sizeBytes) { this.sizeBytes = sizeBytes; }

    public String getUploader() { return uploader; }
    public void setUploader(String uploader) { this.uploader = uploader; }

    public String getPublicUrl() { return publicUrl; }
    public void setPublicUrl(String publicUrl) { this.publicUrl = publicUrl; }

    public Instant getUploadedAt() { return uploadedAt; }
}
