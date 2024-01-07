-- Create 'users' table
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	username VARCHAR(30) NOT NULL,
	-- ↓ ✅ This ensure that the column returns a string value, not null or undefined.
	bio VARCHAR(400),
	avatar VARCHAR(200),
	phone VARCHAR(25),
	email VARCHAR(40),
	password VARCHAR(50),
	status VARCHAR(15),
	-- ↓ ✅ Requires either phone or email
	CHECK(COALESCE(phone, email) IS NOT NULL)
	-- CHECK(COALESCE(phone, password) IS NOT NULL)
);

-- Create 'posts' table
CREATE TABLE posts (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	url VARCHAR(200) NOT NULL,
	caption VARCHAR(240),
	lat REAL CHECK(lat IS NULL OR (lat >= -90 AND lat <= 90)), 
	lng REAL CHECK(lng IS NULL OR (lng >= -180 AND lng <= 180)),
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE
);

-- Create 'comments' table
CREATE TABLE comments (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	contents VARCHAR(240) NOT NULL,
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE
);

-- Create 'likes' table
CREATE TABLE likes (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE,
	comment_id INTEGER REFERENCES comments(id) ON DELETE CASCADE,
	-- ↓ ✅ 
	CHECK(
		COALESCE((post_id)::BOOLEAN::INTEGER, 0)
		+
		COALESCE((comment_id)::BOOLEAN::INTEGER, 0)
		= 1
	),
	UNIQUE(user_id, post_id, comment_id)
);

-- Create 'photo_tags' table
CREATE TABLE photo_tags (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
	x INTEGER NOT NULL,
	y INTEGER NOT NULL,
	UNIQUE(user_id, post_id)
);

-- Create 'caption_tags' table
CREATE TABLE caption_tags (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
	-- ↓ ✅ Is it desirable to send a methion multiple times to the same person?
	UNIQUE(user_id, post_id)
);

-- Create 'hashtags' table
CREATE TABLE hashtags (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	title VARCHAR(20) NOT NULL UNIQUE
);

-- Create 'hashtags_posts' table
CREATE TABLE hashtags_posts (
	id SERIAL PRIMARY KEY,
	hashtag_id INTEGER NOT NULL REFERENCES hashtags(id) ON DELETE CASCADE,
	post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
	UNIQUE(hashtag_id, post_id)
);

-- Create 'followers' table
CREATE TABLE followers (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	leader_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	follower_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	UNIQUE(leader_id, follower_id)
);


