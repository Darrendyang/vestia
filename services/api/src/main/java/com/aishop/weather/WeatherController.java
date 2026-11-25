package com.aishop.weather;

import com.aishop.common.ApiException;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/weather")
public class WeatherController {
    private final OpenMeteoWeatherService weatherService;

    public WeatherController(OpenMeteoWeatherService weatherService) {
        this.weatherService = weatherService;
    }

    @GetMapping("/current")
    WeatherResponse current(@RequestParam double latitude, @RequestParam double longitude) {
        if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
            throw ApiException.badRequest("经纬度超出有效范围");
        }
        return weatherService.current(latitude, longitude);
    }
}
