package com.example.tudy.college;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CollegeService {
    private final CollegeRepository collegeRepository;

    public List<College> findAll() {
        return collegeRepository.findAll();
    }

    public College findById(Long id) {
        return collegeRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("College not found"));
    }

    public College create(CollegeDto.Create request) {
        College college = CollegeMapper.fromCreate(request);
        return collegeRepository.save(college);
    }

    public College update(Long id, CollegeDto.Update request) {
        College college = findById(id);
        CollegeMapper.updateEntity(college, request);
        return collegeRepository.save(college);
    }

    public void delete(Long id) {
        collegeRepository.deleteById(id);
    }
}
