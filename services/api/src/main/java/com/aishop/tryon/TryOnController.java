package com.aishop.tryon;

import com.aishop.common.ApiException;
import com.aishop.common.UserContext;
import com.aishop.provider.ProviderRegistry;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/tryon-jobs")
public class TryOnController {
    private final ProviderRegistry providerRegistry;
    private final UserContext userContext;

    public TryOnController(ProviderRegistry providerRegistry, UserContext userContext) {
        this.providerRegistry = providerRegistry;
        this.userContext = userContext;
    }

    @PostMapping
    Map<String, String> create(@RequestHeader(value = "X-User-Id", required = false) String userHeader,
                               @RequestParam(defaultValue = "false") boolean consentConfirmed) {
        userContext.requireUser(userHeader);
        if (!consentConfirmed) {
            throw new ApiException(HttpStatus.PRECONDITION_REQUIRED, "CONSENT_REQUIRED", "试穿前需要单独确认人像处理授权", false);
        }
        boolean available = providerRegistry.statuses().stream().anyMatch(provider -> provider.key().equals("TRYON") && provider.available());
        if (!available) {
            throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE, "TRYON_PROVIDER_NOT_CONFIGURED",
                    "试穿 Provider 尚未配置。请先完成商业许可、隐私与效果评审。", true);
        }
        throw new ApiException(HttpStatus.NOT_IMPLEMENTED, "TRYON_ADAPTER_REQUIRED",
                "当前自定义 Provider 地址尚未声明适配器契约，未创建任务或上传人像。", false);
    }
}
