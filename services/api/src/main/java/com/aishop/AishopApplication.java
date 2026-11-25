package com.aishop;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@EnableAsync
@SpringBootApplication
public class AishopApplication {
    public static void main(String[] args) {
        SpringApplication.run(AishopApplication.class, args);
    }
}
