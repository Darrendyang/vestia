package com.aishop.shopping;

import com.aishop.common.UserContext;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/shopping/analyses")
public class ShoppingAnalysisController {
    private final ShoppingAnalysisService analysisService;
    private final UserContext userContext;

    public ShoppingAnalysisController(ShoppingAnalysisService analysisService, UserContext userContext) {
        this.analysisService = analysisService;
        this.userContext = userContext;
    }

    @PostMapping
    ShoppingAnalysisResponse analyze(@RequestHeader(value = "X-User-Id", required = false) String userHeader,
                                     @Valid @RequestBody ShoppingAnalysisRequest request) {
        UUID userId = userContext.requireUser(userHeader);
        return analysisService.analyze(userId, request);
    }

    @GetMapping
    List<ShoppingAnalysisResponse> history(@RequestHeader(value = "X-User-Id", required = false) String userHeader) {
        return analysisService.history(userContext.requireUser(userHeader));
    }
}
