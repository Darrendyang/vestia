package com.aishop.common;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
public class UserContext {
    private final UUID demoUserId;
    private final boolean demoMode;

    public UserContext(@Value("${app.demo-user-id}") UUID demoUserId,
                       @Value("${app.demo-mode}") boolean demoMode) {
        this.demoUserId = demoUserId;
        this.demoMode = demoMode;
    }

    public UUID requireUser(String header) {
        if (header == null || header.isBlank()) {
            if (demoMode) {
                return demoUserId;
            }
            throw new ApiException(HttpStatus.UNAUTHORIZED, "UNAUTHORIZED", "缺少用户身份", false);
        }
        try {
            return UUID.fromString(header);
        } catch (IllegalArgumentException exception) {
            throw ApiException.badRequest("X-User-Id 必须是合法 UUID");
        }
    }
}
