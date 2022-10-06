
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
        LEFT JOIN project2.Public_Albums A ON P.ALBUM_ID = A.ALBUM_ID
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
WHERE ROWNUM <= 5;

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

DROP VIEW pairs;
DROP VIEW already_friends;
DROP VIEW tag_photos;
DROP VIEW final_pairs;