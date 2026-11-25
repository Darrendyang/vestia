package com.aishop.recognition;

import com.aishop.storage.LocalObjectStorage;
import com.aishop.task.AiTask;
import com.aishop.task.AiTaskRepository;
import com.aishop.wardrobe.WardrobeItem;
import com.aishop.wardrobe.WardrobeItemRepository;
import org.springframework.core.io.Resource;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class RecognitionService {
    private final AiTaskRepository taskRepository;
    private final WardrobeItemRepository itemRepository;
    private final LocalObjectStorage storage;
    private final BaselineRecognitionProvider provider;

    public RecognitionService(AiTaskRepository taskRepository, WardrobeItemRepository itemRepository,
                              LocalObjectStorage storage, BaselineRecognitionProvider provider) {
        this.taskRepository = taskRepository;
        this.itemRepository = itemRepository;
        this.storage = storage;
        this.provider = provider;
    }

    @Async
    @Transactional
    public void recognize(UUID taskId) {
        AiTask task = taskRepository.findById(taskId).orElse(null);
        if (task == null || task.getStatus() != AiTask.Status.QUEUED) {
            return;
        }
        task.start();
        taskRepository.save(task);
        WardrobeItem item = itemRepository.findByIdAndUserId(task.getResourceId(), task.getUserId()).orElse(null);
        if (item == null) {
            task.fail("ITEM_NOT_FOUND");
            return;
        }
        try {
            Resource image = item.getImagePath() == null ? null : storage.load(item.getUserId(), item.getImagePath());
            BaselineRecognitionProvider.Result result = provider.recognize(image);
            item.completeRecognition(result.primaryColor(), result.confidence());
            task.succeed();
        } catch (Exception exception) {
            item.failRecognition();
            task.fail("IMAGE_RECOGNITION_FAILED");
        }
    }
}
