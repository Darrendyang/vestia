package com.aishop.wardrobe;

import com.aishop.common.UserContext;
import com.aishop.recognition.RecognitionService;
import com.aishop.storage.LocalObjectStorage;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Size;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

@Validated
@RestController
@RequestMapping("/api/v1/wardrobe/items")
public class WardrobeController {
    private final WardrobeService wardrobeService;
    private final RecognitionService recognitionService;
    private final LocalObjectStorage storage;
    private final UserContext userContext;

    public WardrobeController(WardrobeService wardrobeService, RecognitionService recognitionService,
                              LocalObjectStorage storage, UserContext userContext) {
        this.wardrobeService = wardrobeService;
        this.recognitionService = recognitionService;
        this.storage = storage;
        this.userContext = userContext;
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    ResponseEntity<CreateWardrobeItemResponse> create(
            @RequestHeader(value = "X-User-Id", required = false) String userHeader,
            @RequestPart(value = "file", required = false) MultipartFile file,
            @RequestParam(required = false) Category category,
            @RequestParam(required = false) @Size(max = 40) String primaryColor,
            @RequestParam(required = false) @Size(max = 80) String brand,
            @RequestParam(required = false) @Size(max = 80) String material,
            @RequestParam(required = false) @Size(max = 300) String styleTags,
            @RequestParam(required = false) @Size(max = 30) String source) {
        UUID userId = userContext.requireUser(userHeader);
        WardrobeService.CreatedItem created = wardrobeService.create(userId, file, category, primaryColor, brand, material, styleTags, source);
        recognitionService.recognize(created.task().getId());
        return ResponseEntity.status(HttpStatus.ACCEPTED)
                .body(new CreateWardrobeItemResponse(WardrobeItemResponse.from(created.item()), created.task().getId()));
    }

    @GetMapping
    List<WardrobeItemResponse> list(@RequestHeader(value = "X-User-Id", required = false) String userHeader,
                                    @RequestParam(required = false) Category category,
                                    @RequestParam(required = false) ItemStatus status) {
        return wardrobeService.list(userContext.requireUser(userHeader), category, status).stream()
                .map(WardrobeItemResponse::from).toList();
    }

    @GetMapping("/{itemId}")
    WardrobeItemResponse get(@RequestHeader(value = "X-User-Id", required = false) String userHeader,
                             @PathVariable UUID itemId) {
        return WardrobeItemResponse.from(wardrobeService.get(userContext.requireUser(userHeader), itemId));
    }

    @PutMapping("/{itemId}")
    WardrobeItemResponse update(@RequestHeader(value = "X-User-Id", required = false) String userHeader,
                                @PathVariable UUID itemId,
                                @Valid @RequestBody UpdateWardrobeItemRequest request) {
        return WardrobeItemResponse.from(wardrobeService.update(userContext.requireUser(userHeader), itemId, request));
    }

    @DeleteMapping("/{itemId}")
    ResponseEntity<Void> delete(@RequestHeader(value = "X-User-Id", required = false) String userHeader,
                                @PathVariable UUID itemId) {
        wardrobeService.delete(userContext.requireUser(userHeader), itemId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping(value = "/{itemId}/image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    ResponseEntity<CreateWardrobeItemResponse> updateImage(
            @RequestHeader(value = "X-User-Id", required = false) String userHeader,
            @PathVariable UUID itemId,
            @RequestPart("file") MultipartFile file) {
        UUID userId = userContext.requireUser(userHeader);
        WardrobeService.CreatedItem updated = wardrobeService.updateImage(userId, itemId, file);
        recognitionService.recognize(updated.task().getId());
        return ResponseEntity.status(HttpStatus.ACCEPTED)
                .body(new CreateWardrobeItemResponse(WardrobeItemResponse.from(updated.item()), updated.task().getId()));
    }

    @GetMapping("/{itemId}/image")
    ResponseEntity<Resource> image(@RequestHeader(value = "X-User-Id", required = false) String userHeader,
                                   @PathVariable UUID itemId) {
        UUID userId = userContext.requireUser(userHeader);
        WardrobeItem item = wardrobeService.get(userId, itemId);
        Resource resource = storage.load(userId, item.getImagePath());
        MediaType mediaType = item.getImagePath().endsWith(".png") ? MediaType.IMAGE_PNG
                : item.getImagePath().endsWith(".webp") ? MediaType.valueOf("image/webp") : MediaType.IMAGE_JPEG;
        return ResponseEntity.ok()
                .contentType(mediaType)
                .header(HttpHeaders.CACHE_CONTROL, "private, max-age=300")
                .body(resource);
    }
}
