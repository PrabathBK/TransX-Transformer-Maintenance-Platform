package com.acme.backend.api;

import com.acme.backend.api.dto.CreateInspectionReq;
import com.acme.backend.api.dto.InspectionDTO;
import com.acme.backend.domain.Inspection;
import com.acme.backend.repo.InspectionRepo;
import com.acme.backend.repo.TransformerRepo;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/inspections")
public class InspectionController {

    private final InspectionRepo inspectionRepo;
    private final TransformerRepo transformerRepo;

    public InspectionController(InspectionRepo inspectionRepo, TransformerRepo transformerRepo) {
        this.inspectionRepo = inspectionRepo;
        this.transformerRepo = transformerRepo;
    }

    @PostMapping
    public InspectionDTO create(@Valid @RequestBody CreateInspectionReq req) {
        var transformer = transformerRepo.findById(req.transformerId()).orElseThrow();
        
        var inspection = new Inspection();
        inspection.setInspectionNo(req.inspectionNo());
        inspection.setTransformer(transformer);
        inspection.setBranch(req.branch());
        inspection.setInspectionDate(req.inspectionDate());
        inspection.setInspectionTime(req.inspectionTime());
        inspection.setMaintenanceDate(req.maintenanceDate());
        inspection.setMaintenanceTime(req.maintenanceTime());
        inspection.setInspectedBy(req.inspectedBy());
        inspection.setNotes(req.notes());
        inspection.setStatus(Inspection.Status.IN_PROGRESS);
        
        inspectionRepo.save(inspection);
        return toDTO(inspection);
    }

    @GetMapping
    public Page<InspectionDTO> list(
            @RequestParam(defaultValue = "") String q,
            @RequestParam(required = false) UUID transformerId,
            Pageable pageable
    ) {
        if (transformerId != null) {
            return inspectionRepo.findByTransformerId(transformerId, pageable).map(this::toDTO);
        }
        
        if (q.trim().isEmpty()) {
            return inspectionRepo.findAll(pageable).map(this::toDTO);
        }
        
        return inspectionRepo.findBySearchQuery(q, pageable).map(this::toDTO);
    }

    @GetMapping("/{id}")
    public InspectionDTO get(@PathVariable UUID id) {
        return inspectionRepo.findById(id).map(this::toDTO).orElseThrow();
    }

    @PutMapping("/{id}")
    public InspectionDTO update(@PathVariable UUID id, @Valid @RequestBody CreateInspectionReq req) {
        var inspection = inspectionRepo.findById(id).orElseThrow();
        var transformer = transformerRepo.findById(req.transformerId()).orElseThrow();
        
        inspection.setInspectionNo(req.inspectionNo());
        inspection.setTransformer(transformer);
        inspection.setBranch(req.branch());
        inspection.setInspectionDate(req.inspectionDate());
        inspection.setInspectionTime(req.inspectionTime());
        inspection.setMaintenanceDate(req.maintenanceDate());
        inspection.setMaintenanceTime(req.maintenanceTime());
        inspection.setInspectedBy(req.inspectedBy());
        inspection.setNotes(req.notes());
        
        inspectionRepo.save(inspection);
        return toDTO(inspection);
    }

    @PutMapping("/{id}/status")
    public InspectionDTO updateStatus(@PathVariable UUID id, @RequestParam Inspection.Status status) {
        var inspection = inspectionRepo.findById(id).orElseThrow();
        inspection.setStatus(status);
        inspectionRepo.save(inspection);
        return toDTO(inspection);
    }

    @DeleteMapping("/{id}")
    @Transactional
    public void delete(@PathVariable UUID id) {
        inspectionRepo.deleteById(id);
    }

    private InspectionDTO toDTO(Inspection i) {
        return new InspectionDTO(
                i.getId(),
                i.getInspectionNo(),
                i.getTransformer().getId(),
                i.getTransformer().getCode(),
                i.getBranch(),
                i.getInspectionDate(),
                i.getInspectionTime(),
                i.getMaintenanceDate(),
                i.getMaintenanceTime(),
                i.getStatus(),
                i.getInspectedBy(),
                i.getNotes(),
                i.getCreatedAt(),
                i.getUpdatedAt()
        );
    }
}
