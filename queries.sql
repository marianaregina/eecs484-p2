-- Query 1 --
-- Finding longest and shortest
SELECT LENGTH(First_Name) AS len
FROM project2.Public_Users
ORDER BY len DESC;

-- Select all names with longest length in alphabetical order
SELECT DISTINCT First_Name
FROM project2.Public_Users
WHERE LENGTH(First_Name) = <n>
ORDER BY First_Name ASC;

-- Select all names with shortest length in alphabetical order
SELECT DISTINCT First_Name
FROM project2.Public_Users
WHERE LENGTH(First_Name) = <n>
ORDER BY First_Name ASC;

-- Get frequency of most common first name
SELECT *
FROM (
    SELECT COUNT(*) AS nameCount
    FROM project2.Public_Users
    GROUP BY First_Name
    ORDER BY nameCount DESC)
WHERE ROWNUM <= 1;

-- Get most common first name
SELECT First_Name
FROM (
    SELECT First_Name, COUNT(*) AS nameCount
    FROM project2.Public_Users
    GROUP BY First_Name
    ORDER BY nameCount DESC)
WHERE nameCount = <n>
ORDER BY First_Name ASC;

-- Query 2 --
SELECT U.USER_ID, U.First_Name, U.Last_Name
FROM project2.Public_Users U
LEFT JOIN (
    SELECT p1.USER_ID
    FROM project2.Public_Users p1
    MINUS 
    SELECT DISTINCT f1.USER1_ID
    FROM project2.Public_Friends f1
    MINUS
    SELECT DISTINCT f2.USER2_ID
    FROM project2.Public_Friends f2
) have_no_friends
ON have_no_friends.USER_ID = U.USER_ID
ORDER BY U.USER_ID ASC;

-- Query 3 --
SELECT U.USER_ID, U.First_Name, U.Last_Name
FROM project2.Public_Users U
LEFT JOIN project2.Public_User_Current_City C
ON (U.USER_ID = C.USER_ID)
LEFT JOIN project2.Public_User_Hometown_City H
ON (U.USER_ID = H.USER_ID)
WHERE C.CURRENT_CITY_ID IS NOT NULL 
    AND H.HOMETOWN_CITY_ID IS NOT NULL
    AND C.CURRENT_CITY_ID != H.HOMETOWN_CITY_ID
ORDER BY U.USER_ID ASC;

-- Query 4 --
LEFT JOIN project2.Public_Photos P
ON (T.TAG_PHOTO_ID = P.PHOTO_ID)
LEFT JOIN project2.Public_Albums A
ON (P.ALBUM_ID = A.ALBUM_ID)
LEFT JOIN project2.Public_Users U
ON (T.TAG_SUBJECT_ID = U.USER_ID)

-- get top N tags
CREATE VIEW top_n_tags AS
SELECT *
FROM
(
    SELECT T.TAG_PHOTO_ID, COUNT(*) AS num_tagged_users
    FROM project2.Public_Tags T
    GROUP BY T.TAG_PHOTO_ID
    ORDER BY num_tagged_users, T.TAG_PHOTO_ID ASC
)
WHERE ROWNUM <=5;

SELECT T.num_tagged_users, T.TAG_PHOTO_ID, P.PHOTO_LINK, U.USER_ID, U.First_Name, U.Last_Name
FROM top_n_tags T
LEFT JOIN project2.Public_Photos P
ON (T.TAG_PHOTO_ID = P.PHOTO_ID)
WHERE T.TAG_PHOTO_ID IS NOT NULL AND P.PHOTO_ID IS NOT NULL
LEFT JOIN project2.Public_Albums A
ON (P.ALBUM_ID = A.ALBUM_ID)
WHERE P.ALBUM_ID IS NOT NULL AND A.ALBUM_ID IS NOT NULL
LEFT JOIN project2.Public_Users U
ON (T.TAG_SUBJECT_ID = U.USER_ID)
WHERE T.TAG_SUBJECT_ID IS NOT NULL AND U.USER_ID IS NOT NULL
ORDER BY U.USER_ID ASC;


-- Query 5 --
-- need: each user's user id, first name, last name, photos tagged in together (photo id, link, album ID, album name)
-- conditions --
-- same gender, tagged in at least 1 common photo, not friends,
--      difference in birth years <= yearDiff
-- tags:


--  birth year and same gender - 818 rows
CREATE VIEW pairs AS
    SELECT u1.USER_ID AS USER1_ID, u2.USER_ID AS USER2_ID
    FROM project2.Public_Users u1, project2.Public_Users u2
    WHERE (abs(u1.YEAR_OF_BIRTH - u2.YEAR_OF_BIRTH) <= 2)
        AND (u1.GENDER = u2.GENDER)
        AND (u1.USER_ID < u2.USER_ID)
        AND (u1.USER_ID != u2.USER_ID);

-- not friends - 58 rows
CREATE VIEW already_friends AS
    SELECT p.USER1_ID AS USER1_ID, p.USER2_ID AS USER2_ID
    FROM pairs p, project2.Public_Friends f
    WHERE ((p.USER1_ID = f.USER1_ID)
        AND (p.USER2_ID = f.USER2_ID));

-- the rows that are returned are already friends -> remove from pairs table
SELECT *
FROM pairs p
MINUS
SELECT *
FROM already_friends;

-- pairs is left with every valid pair

CREATE VIEW tag_photos AS
    SELECT pairs.USER1_ID AS USER1_ID, pairs.USER2_ID AS USER2_ID, 
            T1.TAG_PHOTO_ID AS PHOTO_ID, P.PHOTO_LINK AS PHOTO_LINK, 
            A.ALBUM_ID AS ALBUM_ID, A.ALBUM_NAME AS ALBUM_NAME 
    FROM pairs, project2.Public_Tags T2, project2.Public_Tags T1 
        LEFT JOIN project2.Public_Photos P ON T1.TAG_PHOTO_ID = P.PHOTO_ID
        LEFT JOIN project2.Public_ALbums A ON P.ALBUM_ID = A.ALBUM_ID
    WHERE T1.TAG_PHOTO_ID = T2.TAG_PHOTO_ID 
            AND T1.TAG_SUBJECT_ID = pairs.USER1_ID
            AND T2.TAG_SUBJECT_ID = pairs.USER2_ID;

CREATE VIEW final_pairs AS
SELECT *
FROM (
    SELECT p.USER1_ID, p.USER2_ID
    FROM tag_photos t
    LEFT JOIN pairs p
    ON (t.USER1_ID = p.USER1_ID AND t.USER2_ID = p.USER2_ID)
    WHERE t.PHOTO_ID IS NOT NULL
    GROUP BY (p.USER1_ID, p.USER2_ID)
    ORDER BY COUNT(*) DESC, USER1_ID ASC, USER2_ID DESC
)
WHERE ROWNUM <= 2;

SELECT fp.USER1_ID, fp.USER2_ID,
        t.PHOTO_ID, t.PHOTO_LINK, t.ALBUM_ID, t.ALBUM_NAME,
        u1.First_Name, u1.Last_Name, u1.YEAR_OF_BIRTH,
        u2.First_Name, u2.Last_Name, u2.YEAR_OF_BIRTH
FROM final_pairs fp
LEFT JOIN project2.Public_Users u1
ON (u1.USER_ID = fp.USER1_ID)
LEFT JOIN project2.Public_Users u2
ON (u2.USER_ID = fp.USER2_ID)
LEFT JOIN tag_photos t
ON (t.USER1_ID = fp.USER1_ID AND t.USER2_ID = fp.USER2_ID);

DROP VIEWS!!!!
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

-- Query 7 --
SELECT *
FROM (
    SELECT C.STATE_NAME, COUNT(*) as eventCount
    FROM project2.Public_User_Events E
    LEFT JOIN project2.Public_Cities C
    ON E.EVENT_CITY_ID = C.CITY_ID
    GROUP BY C.STATE_NAME
    ORDER BY eventCount DESC
)
WHERE ROWNUM <= 1;

SELECT * FROM (
    SELECT C.STATE_NAME, COUNT(*) as eventCount
    FROM project2.Public_User_Events E
    LEFT JOIN project2.Public_Cities C
    ON E.EVENT_CITY_ID = C.CITY_ID
    GROUP BY C.STATE_NAME
    ORDER BY STATE_NAME ASC
)
WHERE eventCount = <n>;

-- Query 8 --
-- Get user's friends
CREATE VIEW user_friends AS
    SELECT f1.USER2_ID AS FRIEND_USER_ID
    FROM project2.Public_Friends f1
    WHERE f1.USER1_ID = <user_id>
    UNION
    SELECT f2.USER1_ID AS FRIEND_USER_ID
    FROM project2.Public_Friends f2
    WHERE f2.USER2_ID = <user_id>;

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


-- Query 9 --
SELECT u1.USER_ID, u1.First_Name, u1.Last_Name, u2.USER_ID, u2.First_Name, u2.Last_Name
FROM project2.Public_Users u1, project2.Public_Users u2
LEFT JOIN project2.Public_User_Hometown_City h1
ON (h1.USER_ID = u1.USER_ID)
LEFT JOIN project2.Public_User_Hometown_City h2
ON (h2.USER_ID = u2.USER_ID)
WHERE (u1.USER_ID != u2.USER_ID)
    AND (u1.Last_Name = u2.Last_Name)
    AND (h1.HOMETOWN_CITY_ID = h2.HOMETOWN_CITY_ID)
    AND (abs(u1.YEAR_OF_BIRTH - u2.YEAR_OF_BIRTH) < 10)
ORDER BY u1.USER_ID ASC, u2.USER_ID ASC;

