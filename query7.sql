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