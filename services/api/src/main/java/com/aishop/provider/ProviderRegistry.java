package com.aishop.provider;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class ProviderRegistry {
    private final String tryonUrl;
    private final String avatarUrl;
    private final String marketplaceApiKey;

    public ProviderRegistry(@Value("${TRYON_PROVIDER_URL:}") String tryonUrl,
                            @Value("${AVATAR_PROVIDER_URL:}") String avatarUrl,
                            @Value("${MARKETPLACE_API_KEY:}") String marketplaceApiKey) {
        this.tryonUrl = tryonUrl;
        this.avatarUrl = avatarUrl;
        this.marketplaceApiKey = marketplaceApiKey;
    }

    public List<ProviderStatus> statuses() {
        return List.of(
                new ProviderStatus("BASELINE_RECOGNITION", "Deterministic color baseline", true, "LOCAL", "Available; category recognition is not claimed."),
                new ProviderStatus("MULTIMODAL_RECOGNITION", "Multimodal wardrobe recognition", false, "UNCONFIGURED", "Configure an approved multimodal provider after quality evaluation."),
                new ProviderStatus("TRYON", "2D virtual try-on", !tryonUrl.isBlank(), tryonUrl.isBlank() ? "UNCONFIGURED" : "REMOTE", tryonUrl.isBlank() ? "Set TRYON_PROVIDER_URL after commercial and privacy review." : "Remote provider configured; quality gates still apply."),
                new ProviderStatus("AVATAR", "Calibrated digital avatar", !avatarUrl.isBlank(), avatarUrl.isBlank() ? "UNCONFIGURED" : "REMOTE", avatarUrl.isBlank() ? "No licensed avatar provider is configured." : "Remote provider configured; body-asset license review required."),
                new ProviderStatus("WEATHER", "Live weather", true, "REMOTE", "Open-Meteo automatic weather is enabled; location permission and fallback behavior are shown in the app."),
                new ProviderStatus("MARKETPLACE", "Official marketplace data", !marketplaceApiKey.isBlank(), marketplaceApiKey.isBlank() ? "UNCONFIGURED" : "REMOTE", marketplaceApiKey.isBlank() ? "No live prices, stock, or commission data are shown." : "Official marketplace adapter configured.")
        );
    }
}
