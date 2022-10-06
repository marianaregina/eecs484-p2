-- Query 9 --
SELECT u1.USER_ID, u1.First_Name, u1.Last_Name, u2.USER_ID, u2.First_Name, u2.Last_Name
FROM project2.Public_Users u1, project2.Public_Users u2
LEFT JOIN project2.Public_User_Hometown_City h1
ON h1.USER_ID = u1.USER_ID
LEFT JOIN project2.Public_User_Hometown_City h2
ON h2.USER_ID = u2.USER_ID
WHERE (u1.USER_ID != u2.USER_ID)
    AND (u1.Last_Name = u2.Last_Name)
    AND (h1.HOMETOWN_CITY_ID = h2.HOMETOWN_CITY_ID)
    AND (abs(u1.YEAR_OF_BIRTH - u2.YEAR_OF_BIRTH) < 10)
ORDER BY u1.USER_ID ASC, u2.USER_ID ASC;