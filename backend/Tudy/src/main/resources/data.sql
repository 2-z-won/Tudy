INSERT INTO colleges (id, name, code, description, created_at, updated_at) VALUES
  (1, 'Engineering', 'ENG', 'Engineering College', now(), now()),
  (2, 'Humanities', 'HUM', 'Humanities College', now(), now());

INSERT INTO departments (id, college_id, name, code, created_at, updated_at) VALUES
  (1, 1, 'Computer Science', 'CS', now(), now()),
  (2, 1, 'Mechanical Engineering', 'ME', now(), now()),
  (3, 2, 'History', 'HIS', now(), now());
