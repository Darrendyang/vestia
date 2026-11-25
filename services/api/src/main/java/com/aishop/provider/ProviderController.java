package com.aishop.provider;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/providers")
public class ProviderController {
    private final ProviderRegistry providerRegistry;

    public ProviderController(ProviderRegistry providerRegistry) {
        this.providerRegistry = providerRegistry;
    }

    @GetMapping
    List<ProviderStatus> statuses() {
        return providerRegistry.statuses();
    }
}
