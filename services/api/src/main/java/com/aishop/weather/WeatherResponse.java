package com.aishop.weather;

public record WeatherResponse(
        double temperature,
        double precipitation,
        int weatherCode,
        String description,
        String source,
        String observedAt,
        double latitude,
        double longitude
) {
}
