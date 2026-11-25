package com.aishop.storage;

import com.aishop.common.ApiException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Set;
import java.util.UUID;

@Component
public class LocalObjectStorage {
    private static final Set<String> ALLOWED_TYPES = Set.of("image/jpeg", "image/png", "image/webp");
    private final Path root;

    public LocalObjectStorage(@Value("${app.storage-root}") String root) {
        this.root = Path.of(root).toAbsolutePath().normalize();
    }

    public String store(UUID userId, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return null;
        }
        if (!ALLOWED_TYPES.contains(file.getContentType())) {
            throw new ApiException(HttpStatus.UNSUPPORTED_MEDIA_TYPE, "UNSUPPORTED_IMAGE", "仅支持 JPEG、PNG、WebP 图片", false);
        }
        String extension = switch (file.getContentType()) {
            case "image/jpeg" -> ".jpg";
            case "image/png" -> ".png";
            default -> ".webp";
        };
        try {
            Path userDirectory = root.resolve(userId.toString()).normalize();
            if (!userDirectory.startsWith(root)) {
                throw ApiException.badRequest("非法存储路径");
            }
            Files.createDirectories(userDirectory);
            String objectKey = userId + "/" + UUID.randomUUID() + extension;
            Path destination = root.resolve(objectKey).normalize();
            file.transferTo(destination);
            return objectKey;
        } catch (IOException exception) {
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, "STORAGE_ERROR", "图片保存失败", true);
        }
    }

    public Resource load(UUID userId, String objectKey) {
        if (objectKey == null || !objectKey.startsWith(userId + "/")) {
            throw ApiException.notFound("图片");
        }
        try {
            Path path = root.resolve(objectKey).normalize();
            if (!path.startsWith(root.resolve(userId.toString()))) {
                throw ApiException.notFound("图片");
            }
            Resource resource = new UrlResource(path.toUri());
            if (!resource.exists() || !resource.isReadable()) {
                throw ApiException.notFound("图片");
            }
            return resource;
        } catch (MalformedURLException exception) {
            throw ApiException.notFound("图片");
        }
    }

    public void delete(String objectKey) {
        if (objectKey == null) {
            return;
        }
        try {
            Files.deleteIfExists(root.resolve(objectKey).normalize());
        } catch (IOException ignored) {
        }
    }
}
