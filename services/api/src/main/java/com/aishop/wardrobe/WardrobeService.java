package com.aishop.wardrobe;

import com.aishop.common.ApiException;
import com.aishop.storage.LocalObjectStorage;
import com.aishop.task.AiTask;
import com.aishop.task.AiTaskRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

@Service
public class WardrobeService {
    private final WardrobeItemRepository itemRepository;
    private final AiTaskRepository taskRepository;
    private final LocalObjectStorage storage;

    public WardrobeService(WardrobeItemRepository itemRepository, AiTaskRepository taskRepository,
                           LocalObjectStorage storage) {
        this.itemRepository = itemRepository;
        this.taskRepository = taskRepository;
        this.storage = storage;
    }

    @Transactional
    public CreatedItem create(UUID userId, MultipartFile file, Category category, String primaryColor,
                              String brand, String material, String styleTags, String source) {
        String imagePath = storage.store(userId, file);
        String actualSource = source == null || source.isBlank() ? (imagePath == null ? "MANUAL" : "PHOTO") : source;
        WardrobeItem item = new WardrobeItem(userId, category, primaryColor, brand, material, styleTags, actualSource, imagePath);
        itemRepository.save(item);
        AiTask task = taskRepository.save(new AiTask(userId, AiTask.Type.WARDROBE_RECOGNITION, item.getId()));
        return new CreatedItem(item, task);
    }

    @Transactional(readOnly = true)
    public List<WardrobeItem> list(UUID userId, Category category, ItemStatus status) {
        return itemRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .filter(item -> category == null || item.getCategory() == category)
                .filter(item -> status == null || item.getStatus() == status)
                .toList();
    }

    @Transactional(readOnly = true)
    public WardrobeItem get(UUID userId, UUID itemId) {
        return itemRepository.findByIdAndUserId(itemId, userId).orElseThrow(() -> ApiException.notFound("衣物"));
    }

    @Transactional
    public WardrobeItem update(UUID userId, UUID itemId, UpdateWardrobeItemRequest request) {
        WardrobeItem item = get(userId, itemId);
        item.update(request.category(), request.primaryColor(), request.brand(), request.material(),
                request.styleTags(), request.status());
        return item;
    }

    @Transactional
    public CreatedItem updateImage(UUID userId, UUID itemId, MultipartFile file) {
        WardrobeItem item = get(userId, itemId);
        String previousImage = item.getImagePath();
        String imagePath = storage.store(userId, file);
        if (imagePath == null) {
            throw ApiException.badRequest("请选择需要上传的图片");
        }
        item.replaceImage(imagePath);
        AiTask task = taskRepository.save(new AiTask(userId, AiTask.Type.WARDROBE_RECOGNITION, item.getId()));
        storage.delete(previousImage);
        return new CreatedItem(item, task);
    }

    @Transactional
    public void delete(UUID userId, UUID itemId) {
        WardrobeItem item = get(userId, itemId);
        itemRepository.delete(item);
        storage.delete(item.getImagePath());
    }

    public record CreatedItem(WardrobeItem item, AiTask task) {
    }
}
