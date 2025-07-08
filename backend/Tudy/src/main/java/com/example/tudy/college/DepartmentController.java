package com.example.tudy.college;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/colleges/{collegeId}/departments")
@RequiredArgsConstructor
public class DepartmentController {
    private final DepartmentService departmentService;

    @GetMapping
    public ResponseEntity<List<DepartmentDto.Response>> list(@PathVariable Long collegeId) {
        List<DepartmentDto.Response> list = departmentService.findAllByCollege(collegeId).stream()
                .map(DepartmentMapper::toDto)
                .toList();
        return ResponseEntity.ok(list);
    }

    @GetMapping("/{id}")
    public ResponseEntity<DepartmentDto.Response> get(@PathVariable Long collegeId,
                                                      @PathVariable Long id) {
        Department dept = departmentService.findById(id);
        return ResponseEntity.ok(DepartmentMapper.toDto(dept));
    }

    @PostMapping
    public ResponseEntity<DepartmentDto.Response> create(@PathVariable Long collegeId,
                                                         @RequestBody DepartmentDto.Create request) {
        Department dept = departmentService.create(collegeId, request);
        return ResponseEntity.ok(DepartmentMapper.toDto(dept));
    }

    @PutMapping("/{id}")
    public ResponseEntity<DepartmentDto.Response> update(@PathVariable Long collegeId,
                                                         @PathVariable Long id,
                                                         @RequestBody DepartmentDto.Update request) {
        Department dept = departmentService.update(id, request);
        return ResponseEntity.ok(DepartmentMapper.toDto(dept));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long collegeId, @PathVariable Long id) {
        departmentService.delete(id);
        return ResponseEntity.ok().build();
    }
}
