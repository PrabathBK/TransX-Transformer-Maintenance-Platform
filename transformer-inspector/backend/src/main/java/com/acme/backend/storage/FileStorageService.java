package com.acme.backend.storage;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.*;
import java.util.UUID;

@Service
public class FileStorageService {
    @Value("${app.storage.root}") private String root;
    @Value("${app.server.public-base-url}") private String publicBase;

    // CHANGED: transformerId is String (Mongo @Id)
    public StoredFile store(String transformerId, String type, MultipartFile file) throws IOException {
        Path dir = Path.of(root, transformerId, type.toLowerCase());
        Files.createDirectories(dir);

        String original = StringUtils.cleanPath(file.getOriginalFilename());
        String stored = UUID.randomUUID() + (original.isBlank() ? "" : "_" + original);

        Path dest = dir.resolve(stored);
        try (var in = file.getInputStream()) {
            Files.copy(in, dest, StandardCopyOption.REPLACE_EXISTING);
        }

        String publicUrl = publicBase + "/files/" + transformerId + "/" + type.toLowerCase() + "/" + stored;
        return new StoredFile(stored, publicUrl, file.getContentType(), file.getSize());
    }

    public record StoredFile(String storedName, String publicUrl, String contentType, long size) {}
}
