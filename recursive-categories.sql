-- Find all descendants of a category
-- Including their levels
-- Including their path
-- Make it look like a hierarchy

-- Output
--  id |        ?column?        | parent_id | level |     path      
-- ----+------------------------+-----------+-------+---------------
--   1 | Root                   |           |     0 | 1
--   2 |     Node 1             |         1 |     1 | 1 > 2
--   3 |     Node 2             |         1 |     1 | 1 > 3
--   4 |         Node 2.1       |         3 |     2 | 1 > 3 > 4
--   5 |             Node 2.1.1 |         4 |     3 | 1 > 3 > 4 > 5
--   6 |     Node 3             |         1 |     1 | 1 > 6
--   7 |         Node 3.1       |         6 |     2 | 1 > 6 > 7
-- (7 rows)


DROP TABLE IF EXISTS category;
CREATE TABLE category (
    id int unique not null,
    name varchar(50) not null,
    parent_id int,
    
    CONSTRAINT fk_parent
      FOREIGN KEY(parent_id) 
      REFERENCES category(id)
);

-- Data
INSERT INTO category VALUES 
    (1, 'Root', NULL),
    (2, 'Node 1', 1),
    (3, 'Node 2', 1),
    (4, 'Node 2.1', 3),
    (5, 'Node 2.1.1', 4),
    (6, 'Node 3', 1),
    (7, 'Node 3.1', 6);

WITH RECURSIVE tree AS (
    SELECT 
        id,
        repeat(' ', 0) || name,
        parent_id,
        0 as level,
        id::VARCHAR as path
    FROM category
    WHERE id=1
    
    UNION
    
    SELECT 
        c.id,
        repeat(' ', (tree.level+1)*4) || c.name,
        c.parent_id,
        tree.level + 1 as level,
        tree.path || ' > ' || c.id::VARCHAR
    FROM category c
    JOIN tree on c.parent_id = tree.id
    
)
SELECT * FROM tree ORDER BY path
