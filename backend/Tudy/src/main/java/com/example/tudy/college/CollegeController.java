package com.example.tudy.college;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/colleges")
@RequiredArgsConstructor
public class CollegeController {
    private final CollegeService collegeService;

    @GetMapping
    public ResponseEntity<List<CollegeDto.Response>> list() {
        List<CollegeDto.Response> list = collegeService.findAll().stream()
                .map(CollegeMapper::toDto)
                .toList();
        return ResponseEntity.ok(list);
    }

    @GetMapping("/{id}")
    public ResponseEntity<CollegeDto.Response> get(@PathVariable Long id) {
        return ResponseEntity.ok(CollegeMapper.toDto(collegeService.findById(id)));
    }

    @PostMapping
    public ResponseEntity<CollegeDto.Response> create(@RequestBody CollegeDto.Create request) {
        College college = collegeService.create(request);
        return ResponseEntity.ok(CollegeMapper.toDto(college));
    }

    @PutMapping("/{id}")
    public ResponseEntity<CollegeDto.Response> update(@PathVariable Long id,
                                                      @RequestBody CollegeDto.Update request) {
        College college = collegeService.update(id, request);
        return ResponseEntity.ok(CollegeMapper.toDto(college));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        collegeService.delete(id);
        return ResponseEntity.ok().build();
    }
}
