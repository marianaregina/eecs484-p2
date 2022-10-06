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