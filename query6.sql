-- Query 6 --
CREATE VIEW mutuals AS
    SELECT u1.USER1_ID AS USER1_ID, u2.USER2_ID AS USER2_ID, u1.USER2_ID AS MUTUAL
    FROM project2.Public_Friends u1, project2.Public_Friends u2, project2.Public_Friends f
    WHERE u1.USER2_ID = u2.USER1_ID
          AND (u1.USER1_ID < u2.USER2_ID)
          AND (u1.USER1_ID != u2.USER2_ID)
          AND NOT EXISTS ( 
                SELECT USER1_ID, USER2_ID 
                FROM project2.Public_Friends f
                WHERE u1.USER1_ID = f.USER1_ID AND u2.USER2_ID = f.USER2_ID
          );

CREATE VIEW has_mutuals AS
    SELECT m.USER1_ID AS USER1_ID, m.USER2_ID AS USER2_ID
    FROM mutuals m;

-- CREATE VIEW already_friends AS
--     SELECT u1.USER_ID AS USER1_ID, u2.USER_ID AS USER2_ID
--     FROM project2.Public_Users u1, project2.Public_Users u2, project2.Public_Friends f
--     WHERE (u1.USER_ID < u2.USER_ID)
--         AND (u1.USER_ID != u2.USER_ID) 
--         AND ((u1.USER_ID = f.USER1_ID)
--         AND (u2.USER_ID = f.USER2_ID));

-- SELECT *
-- FROM has_mutuals
-- MINUS
-- SELECT *
-- FROM already_friends;

-- SELECT *
-- FROM (
--     SELECT * FROM has_mutuals m
--     GROUP BY (m.USER1_ID, m.USER2_ID) 
--     ORDER BY COUNT(*) DESC, m.USER1_ID ASC, m.USER2_ID ASC
-- )
-- WHERE ROWNUM <=5;

SELECT *
FROM (
    SELECT *
    FROM has_mutuals m
    GROUP BY (m.USER1_ID, m.USER2_ID)
    HAVING COUNT(*) > 1
    ORDER BY COUNT(*) DESC, m.USER1_ID ASC, m.USER2_ID ASC
)
WHERE ROWNUM <= 5;

SELECT * 
FROM (
    SELECT u1.USER_ID AS USER1_ID, u1.FIRST_NAME AS U1_FIRST, u1.LAST_NAME AS U1_LAST, 
        u2.USER_ID AS USER2_ID, u2.FIRST_NAME AS U2_FIRST, u2.LAST_NAME AS U2_LAST, 
        m.USER_ID AS M_ID, m.FIRST_NAME AS M_FIRST, m.LAST_NAME AS M_LAST
    FROM has_mutuals h
    LEFT JOIN mutuals m ON h.USER1_ID = m.USER1_ID
    LEFT JOIN project2.Public_Users u1 ON u1.USER_ID = mutuals.USER1_ID
    LEFT JOIN project2.Public_Users u2 ON u2.USER_ID = mutuals.USER2_ID
    LEFT JOIN project2.Public_Users m ON m.USER_ID = mutuals.MUTUAL
)
WHERE ROWNUM <= 5;