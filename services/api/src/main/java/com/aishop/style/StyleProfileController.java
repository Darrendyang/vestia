package com.aishop.style;

import com.aishop.common.UserContext;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/style-profile")
public class StyleProfileController {
    private final StyleProfileService styleProfileService;
    private final UserContext userContext;

    public StyleProfileController(StyleProfileService styleProfileService, UserContext userContext) {
        this.styleProfileService = styleProfileService;
        this.userContext = userContext;
    }

    @GetMapping("/current")
    StyleProfileResponse current(@RequestHeader(value = "X-User-Id", required = false) String userHeader) {
        UUID userId = userContext.requireUser(userHeader);
        return styleProfileService.current(userId);
    }
}
