-- Query 9 --
SELECT u1.USER_ID AS U1_ID, u1.First_Name AS U1_FIRST, u1.Last_Name AS U2_LAST,
        u2.USER_ID AS U2_ID, u2.First_Name AS U2_FIRST, u2.Last_Name AS U2_LAST
FROM project2.Public_Users u1
INNER JOIN Project2.Public_Users u2
ON u1.USER_ID != u2.USER_ID
LEFT JOIN project2.Public_User_Hometown_City h1
ON h1.USER_ID = u1.USER_ID
LEFT JOIN project2.Public_User_Hometown_City h2
ON h2.USER_ID = u2.USER_ID
LEFT JOIN project2.Public_Friends f
ON ((f.USER1_ID = u1.USER_ID AND f.USER2_ID = u2.USER_ID)
    OR ((f.USER1_ID = u2.USER_ID AND f.USER2_ID = u1.USER_ID)))
WHERE (u1.USER_ID != u2.USER_ID)
    AND (u1.Last_Name = u2.Last_Name)
    AND (h1.HOMETOWN_CITY_ID = h2.HOMETOWN_CITY_ID)
    AND (abs(u1.YEAR_OF_BIRTH - u2.YEAR_OF_BIRTH) < 10)
    AND ((f.USER1_ID = u1.USER_ID AND f.USER2_ID = u2.USER_ID)
    OR ((f.USER1_ID = u2.USER_ID AND f.USER2_ID = u1.USER_ID)))
ORDER BY u1.USER_ID ASC, u2.USER_ID ASC;

SELECT U1.USER_ID AS U1_ID
FROM
    (SELECT U1.USER_ID, H1.HOMETOWN_CITY_ID
    FROM project2.Public_Users U1
    LEFT JOIN project2.Public_User_Hometown_City H1
    ON U1.USER_ID = H1.HOMETOWN_CITY_ID) U1_CITY

INNER JOIN
    (SELECT U2.USER_ID, H2.HOMETOWN_CITY_ID
    FROM project2.Public_Users U2
    LEFT JOIN project2.Public_User_Hometown_City H2
    ON U2.USER_ID = H2.USER_ID) U2_CITY