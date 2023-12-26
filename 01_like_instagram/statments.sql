-- Create 'users' table
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	username VARCHAR(30) NOT NULL,
    -- ↓ ✅ This ensure that the column returns a string value, not null or undefined.
	bio VARCHAR (500) NOT NULL DEFAULT '' 
	avater_url VARCHAR(255),
	phone VARCHAR(13),
	email VARCHAR(50),
	password VARCHAR(25),
	status VARCHAR(15),
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP -- ✅,
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	-- ↓ ✅ Requires either phone or email
	CHECK(COALESCE(phone, email) IS NOT NULL),
	CHECK(COALESCE(phone, password) IS NOT NULL)
)

-- Create 'posts' table
-- Create 'users' table
-- Create 'users' table
-- Create 'users' table