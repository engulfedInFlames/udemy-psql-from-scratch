- Old-fashioned Like System (Bookmark System)

  - Should not ❌
    - To figure out which users like a particular post
    - To remove a like if a user gets deleted
    - To implement like table by adding column 'liked_type (post or comment)' (Polymorphic association)
  - Should ⭕
    - Add a unique constraint with `UNIQUE(user_id, post_id)` in likes table

```sql
-- Bad example (Polymorphic association)
CREATE TABLE likes (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    like_id INTEGER,
    liked_type VARCHAR(),
    -- Cannot add FOREIGN KEY constraint to liked_type column.
);

-- Not worst example
-- Good if there are only a few columns as like types.
CREATE TABLE likes (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    post_id INTEGER,
    comment_id INTEGER,
    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(post_id) REFERENCES posts(id),
    FOREIGN KEY(comment_id) REFERENCES comments(id),
)

ADD CHECK of (
    COALESCE((post_id)::BOOLEAN::INTEGER, 0)
    +
    COALESCE((comment_id)::BOOLEAN::INTEGER, 0)
) = 1
```

- Best Practice for Like System

  - Each type of like gets its own table! Simple and Straightforward
  - Downside: How do we aggregate all the different kinds of likes inside the application.
    - Solution: Union or View table

- Hashtags

  - For performance concern, we are using 3 tables, hashtags, hashtags_posts, posts.
    - Prevent duplication
    - VARCHAR takes up more space than INTEGER

- Why aren't we storing some kind of plain numbers like posts, follwers, follwing, etc?

  - Counting just the number of things is simple and straightforward.
  - So-called 'derived data' is not often stored in DB for performance reason.

- Rules around validation

  - Doesn't require validation at the DB level in the following cases
    - If the value might change frequently...
    - If the value are complex...
  - Requires validation in the following case
    - If we want to have the right type or domain of value

- Restore dummy data
  1. Right-click the DB icon
  2. Select the sql file
  3. Configure
     - Type of objects
       - Only date ✅
     - Do not save
       - Onwer ✅
     - Queries
       - Single transaction ✅
     - Disable
       - Trigger ✅
