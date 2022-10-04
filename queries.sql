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
WHERE nameCount = <n>;

-- Query 2 --
SELECT p1.USER_ID, First_Name, Last_Name
FROM project2.Public_Users p1
MINUS 
SELECT DISTINCT f1.USER1_ID
FROM project2.Public_Friends f1
MINUS
SELECT DISTINCT f2.USER2_ID
FROM project2.Public_Friends f2;

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

SELECT num_tagged_users, T.TAG_PHOTO_ID, P.PHOTO_LINK, U.USER_ID, U.First_Name, U.Last_Name
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

-- Query 6 --

-- Query 7 --
SELECT C.STATE_NAME, COUNT(*)
FROM project2.Public_User_Events E
LEFT JOIN project2.Public_Cities C
ON E.EVENT_CITY_ID = C.CITY_ID
GROUP BY C.STATE_NAME
ORDER BY COUNT(*) DESC;

-- Query 8 --

-- Query 9 --


