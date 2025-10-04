// package com.acme.backend.api.dto;

// import com.acme.backend.domain.Annotation;

// import java.math.BigDecimal;
// import java.time.Instant;
// import java.util.UUID;

// /**
//  * DTO for Annotation entity (Phase 2 & 3)
//  */
// public record AnnotationDTO(
//         UUID id,
//         UUID inspectionId,
//         Integer version,
//         BoundingBox bbox,
//         Integer classId,
//         String className,
//         BigDecimal confidence,
//         Annotation.Source source,
//         Annotation.ActionType actionType,
//         String createdBy,
//         Instant createdAt,
//         String modifiedBy,
//         Instant modifiedAt,
//         UUID parentAnnotationId,
//         Boolean isActive,
//         String comments
// ) {
//     /**
//      * Nested record for bounding box coordinates
//      */
//     public record BoundingBox(
//             Integer x1,
//             Integer y1,
//             Integer x2,
//             Integer y2
//     ) {
//         public Integer width() {
//             return x2 - x1;
//         }
        
//         public Integer height() {
//             return y2 - y1;
//         }
//     }
// }


package com.acme.backend.api.dto;

import com.acme.backend.domain.Annotation;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * DTO for Annotation entity (Phase 2 & 3 + extended fields)
 */
public record AnnotationDTO(
        UUID id,
        UUID inspectionId,
        Integer version,
        BoundingBox bbox,
        Integer classId,
        String className,
        BigDecimal confidence,
        Annotation.Source source,
        Annotation.ActionType actionType,
        String createdBy,
        Instant createdAt,
        String modifiedBy,
        Instant modifiedAt,
        UUID parentAnnotationId,
        Boolean isActive,
        String comments,

        // -------- NEW FIELDS --------
        Integer annotationNumber,   // sequential number for each box
        Long sizePx,                // computed size of the box in pixels
        BigDecimal severityScore,   // anomaly severity (from model or manual)
        Boolean flagged             // unsure / flagged manually ⚠️
) {
    /**
     * Nested record for bounding box coordinates
     */
    public record BoundingBox(
            Integer x1,
            Integer y1,
            Integer x2,
            Integer y2
    ) {
        public Integer width() {
            return x2 - x1;
        }

        public Integer height() {
            return y2 - y1;
        }
    }
}


