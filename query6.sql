-- FIRST CASE: (m, u1) (m, u2) --> m < u1, u2 && u1 < u2
-- pair: (f1.USER2_ID, f2.USER2_ID)
CREATE VIEW first_case AS
    SELECT f1.USER2_ID AS USER1_ID, f2.USER2_ID AS USER2_ID, f1.USER1_ID AS MUTUAL
    FROM project2.Public_Friends f1, project2.Public_Friends f2
    WHERE f1.USER1_ID = f2.USER1_ID AND f1.USER2_ID != f2.USER2_ID AND f1.USER2_ID < f2.USER2_ID
          AND NOT EXISTS (
            SELECT friends.USER1_ID, friends.USER2_ID 
            FROM project2.Public_Friends friends
            WHERE f1.USER2_ID = friends.USER1_ID AND f2.USER2_ID = friends.USER2_ID
          );

-- SECOND CASE: (m, u1) (m, u2) --> m < u1, u2 && u2 < u1
-- pair: (f2.USER2_ID, f1.USER2_ID)
CREATE VIEW second_case AS
    SELECT f2.USER2_ID AS USER1_ID, f1.USER2_ID AS USER2_ID, f1.USER1_ID AS MUTUAL
    FROM project2.Public_Friends f1, project2.Public_Friends f2
    WHERE f1.USER1_ID = f2.USER1_ID AND f1.USER2_ID != f2.USER2_ID AND f2.USER2_ID < f1.USER2_ID
          AND NOT EXISTS (
            SELECT friends.USER1_ID, friends.USER2_ID 
            FROM project2.Public_Friends friends
            WHERE f2.USER2_ID = friends.USER1_ID AND f1.USER2_ID = friends.USER2_ID
          );

-- THIRD CASE: (m, u1) (u2, m) --> u2 < m < u1 
-- pair: (f2.USER1_ID, f1.USER2_ID)
CREATE VIEW third_case AS
    SELECT f2.USER1_ID AS USER1_ID, f1.USER2_ID AS USER2_ID, f1.USER1_ID AS MUTUAL
    FROM project2.Public_Friends f1, project2.Public_Friends f2
    WHERE f1.USER1_ID = f2.USER2_ID AND f1.USER2_ID != f2.USER1_ID AND f2.USER1_ID < f1.USER2_ID
          AND NOT EXISTS (
            SELECT friends.USER1_ID, friends.USER2_ID 
            FROM project2.Public_Friends friends
            WHERE f2.USER1_ID = friends.USER1_ID AND f1.USER2_ID = friends.USER2_ID
          );

-- FOURTH CASE: (u1, m) (m, u2) --> u1 < m < u2
-- pair: (f1.USER1_ID, f2.USER2_ID)
CREATE VIEW fourth_case AS
    SELECT f1.USER1_ID AS USER1_ID, f2.USER2_ID AS USER2_ID, f1.USER2_ID AS MUTUAL
    FROM project2.Public_Friends f1, project2.Public_Friends f2
    WHERE f1.USER2_ID = f2.USER1_ID AND f1.USER1_ID != f2.USER2_ID AND f1.USER1_ID < f2.USER2_ID
          AND NOT EXISTS (
            SELECT friends.USER1_ID, friends.USER2_ID 
            FROM project2.Public_Friends friends
            WHERE f1.USER1_ID = friends.USER1_ID AND f2.USER2_ID = friends.USER2_ID
          );

-- FIFTH CASE: (u1, m) (u2, m) --> u1, u2 < m && u1 < u2
-- pair: (f1.USER2_ID, f2.USER1_ID)
CREATE VIEW fifth_case AS
    SELECT f1.USER1_ID AS USER1_ID, f2.USER1_ID AS USER2_ID, f1.USER2_ID AS MUTUAL
    FROM project2.Public_Friends f1, project2.Public_Friends f2
    WHERE f1.USER2_ID = f2.USER2_ID AND f1.USER1_ID != f2.USER1_ID AND f1.USER1_ID < f2.USER1_ID
          AND NOT EXISTS (
            SELECT friends.USER1_ID, friends.USER2_ID 
            FROM project2.Public_Friends friends
            WHERE f1.USER2_ID = friends.USER1_ID AND f2.USER1_ID = friends.USER2_ID);

-- SIXTH CASE: (u1, m) (u2, m) --> u1, u2 < m && u2 < u1
-- pair: (f2.USER1_ID, f1.USER1_ID)
CREATE VIEW sixth_case AS
    SELECT f2.USER1_ID AS USER1_ID, f1.USER1_ID AS USER2_ID, f1.USER2_ID AS MUTUAL
    FROM project2.Public_Friends f1, project2.Public_Friends f2
    WHERE f1.USER2_ID = f2.USER2_ID AND f1.USER1_ID != f2.USER1_ID AND f2.USER1_ID < f1.USER1_ID
          AND NOT EXISTS (
            SELECT friends.USER1_ID, friends.USER2_ID 
            FROM project2.Public_Friends friends
            WHERE f2.USER1_ID = friends.USER1_ID AND f1.USER1_ID = friends.USER2_ID);

CREATE VIEW mutuals AS
    SELECT * FROM first_case
    UNION
    SELECT * FROM second_case
    UNION
    SELECT * FROM third_case
    UNION
    SELECT * FROM fourth_case
    UNION
    SELECT * FROM fifth_case
    UNION
    SELECT * FROM sixth_case;

-- creates view has_mutuals with user1 id, user2 id, # of mutuals
-- groups by pair, sorts by num mutuals, takes top 5
CREATE VIEW has_mutuals AS
    SELECT * 
    FROM (
        SELECT USER1_ID, USER2_ID, COUNT(*) AS num_mutuals
        FROM mutuals m
        GROUP BY (USER1_ID, USER2_ID)
        HAVING COUNT (*) >= 1
        ORDER BY COUNT(*) DESC)
    WHERE ROWNUM <= 5;

CREATE VIEW PAIRS AS
SELECT H.USER1_ID AS U1_ID, U1.FIRST_NAME AS U1_FNAME, U1.LAST_NAME AS U1_LNAME,
        H.USER2_ID AS U2_ID, U2.FIRST_NAME AS U2_FNAME, U2.LAST_NAME AS U2_LNAME
FROM has_mutuals H, project2.Public_Users U1, project2.Public_Users U2
WHERE U1.USER_ID = H.USER1_ID AND U2.USER_ID = H.USER2_ID;


CREATE VIEW MUTS AS
SELECT U.USER_ID, U.FIRST_NAME, U.LAST_NAME
FROM mutuals M
LEFT JOIN project2.Public_Users U
ON U.USER_ID = M.MUTUAL
WHERE M.USER1_ID = 710 AND M.USER2_ID = 728
ORDER BY U.USER_ID;

DROP VIEW PAIRS;
DROP VIEW MUTS; 
DROP VIEW first_case;
DROP VIEW second_case;
DROP VIEW third_case;
DROP VIEW fourth_case;
DROP VIEW fifth_case;
DROP VIEW sixth_case;
DROP VIEW mutuals;
DROP VIEW has_mutuals;