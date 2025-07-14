DROP TABLE IF EXISTS diary_entries;
DROP TABLE IF EXISTS photo_submissions;
DROP TABLE IF EXISTS building_items;
DROP TABLE IF EXISTS buildings;
DROP TABLE IF EXISTS study_sessions;
DROP TABLE IF EXISTS group_goals;
DROP TABLE IF EXISTS group_members;
DROP TABLE IF EXISTS groups;
DROP TABLE IF EXISTS goals;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS user_settings;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS colleges;

CREATE TABLE colleges (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE
    -- 단과대 이름
);

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  nickname VARCHAR(255),
  college_id INTEGER REFERENCES colleges(id),
  major VARCHAR(255),
  college VARCHAR(255),
  profile_image VARCHAR(255),
  coin_balance INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE user_settings (
  user_id INTEGER PRIMARY KEY REFERENCES users(id),
  notify_enabled BOOLEAN DEFAULT true,
  theme VARCHAR(255) DEFAULT 'default'
);

CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  color INTEGER NOT NULL,
  user_id INTEGER REFERENCES users(id),
  UNIQUE (user_id, name)
);

CREATE TABLE goals (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  title VARCHAR(255) NOT NULL,
  category_id INTEGER REFERENCES categories(id),
  start_date DATE,
  end_date DATE,
  is_group_goal BOOLEAN DEFAULT false,
  completed BOOLEAN DEFAULT false,
  group_id INTEGER,
  proof_image VARCHAR(255),
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE groups (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  is_private BOOLEAN DEFAULT false,
  password VARCHAR(255),
  created_by INTEGER REFERENCES users(id),
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE group_members (
  id SERIAL PRIMARY KEY,
  group_id INTEGER REFERENCES groups(id),
  user_id INTEGER REFERENCES users(id),
  joined_at TIMESTAMP DEFAULT now()
);

CREATE TABLE group_goals (
  id SERIAL PRIMARY KEY,
  group_id INTEGER REFERENCES groups(id),
  title VARCHAR(255) NOT NULL,
  start_date DATE,
  end_date DATE,
  repeat_rule VARCHAR(255),
  completed BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE study_sessions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  goal_id INTEGER REFERENCES goals(id),
  subject VARCHAR(255),
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP,
  duration INTEGER,
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE buildings (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  level INTEGER DEFAULT 1,
  theme VARCHAR(255),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE building_items (
  id SERIAL PRIMARY KEY,
  building_id INTEGER REFERENCES buildings(id),
  item_type VARCHAR(255),
  unlock_rule VARCHAR(255),
  unlocked_at TIMESTAMP,
  is_installed BOOLEAN DEFAULT false
);

CREATE TABLE photo_submissions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  goal_id INTEGER REFERENCES goals(id),
  image_url TEXT NOT NULL,
  status VARCHAR(255) DEFAULT 'PENDING',
  submitted_at TIMESTAMP DEFAULT now()
);

CREATE TABLE diary_entries (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT now()
);

