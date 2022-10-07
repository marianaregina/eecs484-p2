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
            WHERE f1.USER2_ID = friends.USER1_ID AND f2.USER1_ID = friends.USER2_ID
          );

-- SIXTH CASE: (u1, m) (u2, m) --> u1, u2 < m && u2 < u1
-- pair: (f2.USER1_ID, f1.USER1_ID)
CREATE VIEW sixth_case AS
    SELECT f2.USER1_ID AS USER1_ID, f1.USER1_ID AS USER2_ID, f1.USER2_ID AS MUTUAL
    FROM project2.Public_Friends f1, project2.Public_Friends f2
    WHERE f1.USER2_ID = f2.USER2_ID AND f1.USER1_ID != f2.USER1_ID AND f2.USER1_ID < f1.USER1_ID
          AND NOT EXISTS (
            SELECT friends.USER1_ID, friends.USER2_ID 
            FROM project2.Public_Friends friends
            WHERE f2.USER1_ID = friends.USER1_ID AND f1.USER1_ID = friends.USER2_ID
          );

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
        ORDER BY COUNT(*) DESC
    )
    WHERE ROWNUM <= 5;

SELECT h.USER1_ID AS USER1_ID, u1.FIRST_NAME AS U1_FIRST, u1.LAST_NAME AS U1_LAST, 
           h.USER2_ID AS USER2_ID, u2.FIRST_NAME AS U2_FIRST, u2.LAST_NAME AS U2_LAST, 
           m.MUTUAL AS M_ID, mut.FIRST_NAME AS M_FIRST, mut.LAST_NAME AS M_LAST
FROM has_mutuals h, mutuals m, project2.Public_Users u1, project2.Public_Users u2, project2.Public_Users mut
WHERE (h.USER1_ID = u1.USER_ID AND h.USER2_ID = u2.USER_ID 
      AND (m.USER1_ID = h.USER1_ID AND m.USER2_ID = h.USER2_ID) 
      AND m.MUTUAL = mut.USER_ID);