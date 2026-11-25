package com.aishop.common;

import java.time.Instant;

public record ApiError(String code, String message, boolean retryable, String requestId, Instant timestamp) {
    public static ApiError of(String code, String message, boolean retryable, String requestId) {
        return new ApiError(code, message, retryable, requestId, Instant.now());
    }
}
