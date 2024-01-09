# Deep Dive into Postgres

## Internals of Postgres

```sql
-- Show the directory path where Postges is currently installed
SHOW data_directory;

-- Show identifier, and DB list.
SELECT oid, datname
FROM pg_database;

-- Show data about all objects in the Postgres.
SELECT * FROM pg_class;
```

## Heap File Layout

**Refer to** the section no.22 'Understanding the Internals of PostgreSQL'

## Index for Performance

- Index

  - Full Table Scan, Loading up data from hard drive to memory, demands large performance cost.
  - Isteand, Using index table can be a cost-effective alternative.

- How an index works

  - According to the index rule, organize data at the same level within a tree structure.
    - The most common index type in PostgreSQL is the B-tree index.
    - A B-tree index is a balanced tree structure where each node contains a range of key values and pointers to child nodes.
    - The leaf nodes of the tree contain pointers to the actual table rows.
  - Set helpers to the root node about how to retrieve the data.
  - Retrieve data based on the index.
  - Sort the result in the meaningful way.
  - Pros and Cons
    - Pros
      - It is cost-effective because unmatched data can be skipped in the tree structure.
      - No need to check the entire heap file.
    - Cons
      - Over-indexing reduces performance.
      - Index table consume a real disk space.
      - DB engine must also maitntain the index tables as well.

- Benchmarking

  - Ananlyze query

    ```sql
    EXPLAIN ANALYZE
    SELECT *
    FROM users
    WHERE username = 'Emil30';
    ```

    - Compare the execution time when there is an index and when there is not.

  - The Size of Index

    ```sql
    -- Check the size of 'users' table.
    SELECT pg_size_pretty(pg_relation_size('users'));
    -- Check the size of index table.
    SELECT pg_size_pretty(pg_relation_size('users_useranme_idx'));
    ```

    - Indexes are actual physical tables that cost time and money.
    - It takes more time at CUD.
    - **It's important to know what index to use.**

  - The type of index

    - B-Tree, Hash, GiST, GIN, BRIN etc...
    - However, rarely use any type other than B-Tree.

  - Index in Postgres
    - Postgres automatically creates an index for the pk column and for any 'unique' constraint which don't get listed under 'indexes'.
    - Instead, write query
    ```sql
    SELECT relname, relkind
    FROM pg_class
    WHERE relkind = 'i'; -- 'i' means index
    ```

## Behind the scenes

## The Query Processing Pipeline

- When you execute query, the query go through Parser → Rewrite → Planner, and then finally is gonna be executed.
- `EXPLAIN` & `EXPLAIN ANALYZE`
  - `EXPLAIN` - Build a query plan, but don't execute the query.
  - `EXPLAIN` - Build a query plan and execute it.
- In `EXPLAIN`, How can Postgres guess the query plan even it doesn't actually execute it.

  - Postgres analyzes tables in advance.

  ```sql
  SELECT *
  FROM pg_stats
  WHERE tablename = 'users';
  ```

## Advanced Query Tuning

- Definition for 'Cost'

  - _Amount of time_, not accurate but good enough

- How to find a certain user?

  - With index...
    1. Find the ID's of users with the username
    1. Get root node
    1. Jump to some randmon child page
    1. Process the values in that node
    1. Open the heapfile
    1. Jump to each block that has the users we are looking for
  - Without index...
    1. Open the heap file.
    2. Load all users from the first block
    3. Process each user with checking if it contains the specified username
    4. Repeat the process for the nextblock
  - However...
    - Loading data from random spots of a hard drive usually takes more time than loading data sequentially.

- Calculate The Real Cost

  - [Ref →](postgresql.org/docs/current/runtime-config-query.html)
  - Postgres already set the reasonable value for the constants.
  - Every cost constants is based on `seq_page_cost`

  ```txt
  Cost = (# pages read sequentially) * seq_page_cost
        + (# pages read at random) * random_page_cost
        + (# rows scanned) * cpu_tuple_cost
        * (# index entries scanned) * cpu_index_tuple_cost
        * (# times function/operator evaluated) * cpu_operator_cost
  ```

## Conclusion

- Knowing when and how to use index is of great importance in performance.
- In most cases, DB engine calculates whether it is good to use index or not by itself.
