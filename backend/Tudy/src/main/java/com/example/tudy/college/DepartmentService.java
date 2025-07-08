package com.example.tudy.college;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DepartmentService {
    private final DepartmentRepository departmentRepository;
    private final CollegeRepository collegeRepository;

    public List<Department> findAllByCollege(Long collegeId) {
        College college = collegeRepository.findById(collegeId)
                .orElseThrow(() -> new EntityNotFoundException("College not found"));
        return departmentRepository.findByCollege(college);
    }

    public Department findById(Long id) {
        return departmentRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Department not found"));
    }

    public Department create(Long collegeId, DepartmentDto.Create request) {
        College college = collegeRepository.findById(collegeId)
                .orElseThrow(() -> new EntityNotFoundException("College not found"));
        Department department = DepartmentMapper.fromCreate(request, college);
        return departmentRepository.save(department);
    }

    public Department update(Long id, DepartmentDto.Update request) {
        Department department = findById(id);
        DepartmentMapper.updateEntity(department, request);
        return departmentRepository.save(department);
    }

    public void delete(Long id) {
        departmentRepository.deleteById(id);
    }
}
