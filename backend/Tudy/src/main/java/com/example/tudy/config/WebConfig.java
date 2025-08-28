package com.example.tudy.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(false);
    }
    
    // S3 사용으로 인해 로컬 파일 서빙은 더 이상 필요 없음
    // @Override
    // public void addResourceHandlers(ResourceHandlerRegistry registry) {
    //     // S3를 사용하므로 로컬 파일 서빙 비활성화
    // }
} 