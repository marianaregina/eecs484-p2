-- Query 4 --
-- get top N tags
SELECT * FROM (
    SELECT T.TAG_PHOTO_ID, COUNT(*) AS num_tagged_users
    FROM project2.Public_Tags T
    GROUP BY T.TAG_PHOTO_ID
    ORDER BY num_tagged_users DESC, T.TAG_PHOTO_ID ASC)
WHERE ROWNUM <=5;

SELECT U.USER_ID, U.First_Name, U.Last_Name,
        A.ALBUM_ID, A.ALBUM_NAME, P.PHOTO_ID, P.PHOTO_LINK
FROM project2.Public_Tags T
LEFT JOIN project2.Public_Users U
ON T.TAG_SUBJECT_ID = U.USER_ID
LEFT JOIN project2.Public_Photos P
ON P.PHOTO_ID = <n>
LEFT JOIN project2.Public_Albums A
ON P.ALBUM_ID = A.ALBUM_ID
WHERE T.TAG_PHOTO_ID = <n>
ORDER BY U.USER_ID ASC;