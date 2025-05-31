CREATE TABLE colleges (
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL UNIQUE
    -- 단과대 이름
);

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR NOT NULL UNIQUE,
  password_hash VARCHAR NOT NULL,
  nickname VARCHAR,
  college_id INTEGER REFERENCES colleges(id),
  major VARCHAR,
  profile_image VARCHAR,
  coin_balance INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE user_settings (
  user_id INTEGER PRIMARY KEY REFERENCES users(id),
  notify_enabled BOOLEAN DEFAULT true,
  theme VARCHAR DEFAULT 'default'
);

CREATE TABLE goals (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  title VARCHAR NOT NULL,
  category VARCHAR,
  start_date DATE,
  end_date DATE,
  repeat_rule VARCHAR,
  is_group_goal BOOLEAN DEFAULT false,
  completed BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE groups (
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  is_private BOOLEAN DEFAULT false,
  password VARCHAR,
  created_by INTEGER REFERENCES users(id),
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE group_members (
  group_id INTEGER REFERENCES groups(id),
  user_id INTEGER REFERENCES users(id),
  joined_at TIMESTAMP DEFAULT now(),
  PRIMARY KEY (group_id, user_id)
);

CREATE TABLE group_goals (
  id SERIAL PRIMARY KEY,
  group_id INTEGER REFERENCES groups(id),
  title VARCHAR NOT NULL,
  start_date DATE,
  end_date DATE,
  repeat_rule VARCHAR,
  completed BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE study_sessions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  goal_id INTEGER REFERENCES goals(id),
  subject VARCHAR,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP,
  duration INTEGER,
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE buildings (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  level INTEGER DEFAULT 1,
  theme VARCHAR,
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE building_items (
  id SERIAL PRIMARY KEY,
  building_id INTEGER REFERENCES buildings(id),
  item_type VARCHAR,
  unlock_rule VARCHAR,
  unlocked_at TIMESTAMP,
  is_installed BOOLEAN DEFAULT false
);

CREATE TABLE photo_submissions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  goal_id INTEGER REFERENCES goals(id),
  image_url TEXT NOT NULL,
  status VARCHAR DEFAULT 'PENDING',
  submitted_at TIMESTAMP DEFAULT now()
);

CREATE TABLE diary_entries (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT now()
);

