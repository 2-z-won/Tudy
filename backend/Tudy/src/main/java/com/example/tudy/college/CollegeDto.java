package com.example.tudy.college;

import lombok.Data;

import java.time.LocalDateTime;

public class CollegeDto {

    @Data
    public static class Create {
        private String name;
        private String code;
        private String description;
    }

    @Data
    public static class Update {
        private String name;
        private String code;
        private String description;
    }

    @Data
    public static class Response {
        private Long id;
        private String name;
        private String code;
        private String description;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;
    }
}
