package com.aishop.outfit;

import com.aishop.common.UserContext;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/outfits/recommendations")
public class OutfitController {
    private final RecommendationService recommendationService;
    private final UserContext userContext;

    public OutfitController(RecommendationService recommendationService, UserContext userContext) {
        this.recommendationService = recommendationService;
        this.userContext = userContext;
    }

    @PostMapping
    RecommendOutfitsResponse recommend(@RequestHeader(value = "X-User-Id", required = false) String userHeader,
                                       @Valid @RequestBody RecommendOutfitsRequest request) {
        return recommendationService.recommend(userContext.requireUser(userHeader), request);
    }

    @GetMapping
    List<OutfitResponse> list(@RequestHeader(value = "X-User-Id", required = false) String userHeader) {
        return recommendationService.list(userContext.requireUser(userHeader));
    }

    @PostMapping("/{recommendationId}/feedback")
    OutfitResponse feedback(@RequestHeader(value = "X-User-Id", required = false) String userHeader,
                            @PathVariable UUID recommendationId,
                            @Valid @RequestBody OutfitFeedbackRequest request) {
        return recommendationService.feedback(userContext.requireUser(userHeader), recommendationId, request);
    }
}
