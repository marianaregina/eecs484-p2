-- Query 2 --
SELECT U.USER_ID, U.First_Name, U.Last_Name
FROM project2.Public_Users U
INNER JOIN (
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