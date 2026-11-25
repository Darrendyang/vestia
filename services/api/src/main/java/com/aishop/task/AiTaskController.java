package com.aishop.task;

import com.aishop.common.ApiException;
import com.aishop.common.UserContext;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/tasks")
public class AiTaskController {
    private final AiTaskRepository taskRepository;
    private final UserContext userContext;

    public AiTaskController(AiTaskRepository taskRepository, UserContext userContext) {
        this.taskRepository = taskRepository;
        this.userContext = userContext;
    }

    @GetMapping("/{taskId}")
    AiTaskResponse get(@RequestHeader(value = "X-User-Id", required = false) String userHeader,
                       @PathVariable UUID taskId) {
        UUID userId = userContext.requireUser(userHeader);
        return taskRepository.findByIdAndUserId(taskId, userId)
                .map(AiTaskResponse::from)
                .orElseThrow(() -> ApiException.notFound("任务"));
    }
}
