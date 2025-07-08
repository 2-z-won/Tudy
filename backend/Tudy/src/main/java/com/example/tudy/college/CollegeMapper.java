package com.example.tudy.college;

class CollegeMapper {
    static CollegeDto.Response toDto(College c) {
        CollegeDto.Response dto = new CollegeDto.Response();
        dto.setId(c.getId());
        dto.setName(c.getName());
        dto.setCode(c.getCode());
        dto.setDescription(c.getDescription());
        dto.setCreatedAt(c.getCreatedAt());
        dto.setUpdatedAt(c.getUpdatedAt());
        return dto;
    }

    static College fromCreate(CollegeDto.Create dto) {
        College c = new College();
        c.setName(dto.getName());
        c.setCode(dto.getCode());
        c.setDescription(dto.getDescription());
        return c;
    }

    static void updateEntity(College c, CollegeDto.Update dto) {
        if (dto.getName() != null) c.setName(dto.getName());
        if (dto.getCode() != null) c.setCode(dto.getCode());
        if (dto.getDescription() != null) c.setDescription(dto.getDescription());
    }
}
