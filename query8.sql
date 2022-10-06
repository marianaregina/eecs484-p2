-- Query 8 --
-- Get user's friends
CREATE VIEW user_friends AS
    SELECT f1.USER2_ID AS FRIEND_USER_ID
    FROM project2.Public_Friends f1
    WHERE f1.USER1_ID = 215
    UNION
    SELECT f2.USER1_ID AS FRIEND_USER_ID
    FROM project2.Public_Friends f2
    WHERE f2.USER2_ID = 215;

-- Get youngest friend
SELECT *
FROM (
    SELECT u.USER_ID, u.First_Name, u.Last_Name
    FROM project2.Public_Users u
    LEFT JOIN user_friends f
    ON f.FRIEND_USER_ID = u.USER_ID
    ORDER BY SUM(u.MONTH_OF_BIRTH, u.DAY_OF_BIRTH, u.YEAR_OF_BIRTH) ASC, u.USER_ID DESC;
)
WHERE ROWNUM <= 1;

-- Get oldest friend
SELECT *
FROM (
    SELECT u.USER_ID, u.First_Name, u.Last_Name
    FROM project2.Public_Users u
    LEFT JOIN user_friends f
    ON f.FRIEND_USER_ID = u.USER_ID
    ORDER BY SUM(u.MONTH_OF_BIRTH, u.DAY_OF_BIRTH, u.YEAR_OF_BIRTH) DESC, u.USER_ID DESC;
)
WHERE ROWNUM <= 1;