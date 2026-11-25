package com.aishop.weather;

import com.aishop.common.ApiException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Locale;

@Service
public class OpenMeteoWeatherService {
    private final HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public WeatherResponse current(double latitude, double longitude) {
        String url = String.format(Locale.US,
                "https://api.open-meteo.com/v1/forecast?latitude=%.5f&longitude=%.5f&current=temperature_2m,precipitation,rain,weather_code,wind_speed_10m&timezone=auto",
                latitude, longitude);
        try {
            HttpRequest request = HttpRequest.newBuilder(URI.create(url)).timeout(Duration.ofSeconds(8)).GET().build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) {
                throw new IllegalStateException("Weather provider returned " + response.statusCode());
            }
            JsonNode current = objectMapper.readTree(response.body()).path("current");
            int code = current.path("weather_code").asInt();
            return new WeatherResponse(current.path("temperature_2m").asDouble(), current.path("precipitation").asDouble(),
                    code, description(code), "Open-Meteo", current.path("time").asText(), latitude, longitude);
        } catch (Exception exception) {
            throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE, "WEATHER_UNAVAILABLE", "实时天气暂时不可用，请稍后重试", true);
        }
    }

    private String description(int code) {
        return switch (code) {
            case 0 -> "晴";
            case 1 -> "大部晴朗";
            case 2 -> "局部多云";
            case 3 -> "阴";
            case 45, 48 -> "雾";
            case 51, 53, 55, 56, 57 -> "毛毛雨";
            case 61, 66 -> "小雨";
            case 63, 67 -> "中雨";
            case 65 -> "大雨";
            case 71, 73, 75, 77 -> "雪";
            case 80, 81 -> "阵雨";
            case 82 -> "强阵雨";
            case 85, 86 -> "阵雪";
            case 95 -> "雷雨";
            case 96, 99 -> "雷雨伴冰雹";
            default -> "未知天气";
        };
    }
}
