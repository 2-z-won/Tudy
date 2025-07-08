package com.example.tudy.college;

class DepartmentMapper {
    static DepartmentDto.Response toDto(Department d) {
        DepartmentDto.Response dto = new DepartmentDto.Response();
        dto.setId(d.getId());
        dto.setName(d.getName());
        dto.setCode(d.getCode());
        dto.setCollegeId(d.getCollege().getId());
        dto.setCreatedAt(d.getCreatedAt());
        dto.setUpdatedAt(d.getUpdatedAt());
        return dto;
    }

    static Department fromCreate(DepartmentDto.Create dto, College college) {
        Department d = new Department();
        d.setName(dto.getName());
        d.setCode(dto.getCode());
        d.setCollege(college);
        return d;
    }

    static void updateEntity(Department d, DepartmentDto.Update dto) {
        if (dto.getName() != null) d.setName(dto.getName());
        if (dto.getCode() != null) d.setCode(dto.getCode());
    }
}
