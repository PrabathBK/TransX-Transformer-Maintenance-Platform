package com.acme.backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import java.nio.file.Path;

@Configuration
public class StaticFileConfig implements WebMvcConfigurer {
    @Value("${app.storage.root}") private String root;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        Path base = Path.of(root).toAbsolutePath();
        registry.addResourceHandler("/files/**")
                .addResourceLocations("file:" + base + "/");
    }
}