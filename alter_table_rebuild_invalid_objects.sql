-- 1) ALTER COLUMN
ALTER TABLE OWNER_NAME.TABLE_NAME MODIFY (COLUMN_NAME VARCHAR2(80 BYTE));

-- 2) IDENTIFYING INVALID OBJECTS
SELECT OWNER, OBJECT_TYPE, OBJECT_NAME, STATUS
FROM   DBA_OBJECTS
WHERE  STATUS = 'INVALID' AND OWNER = 'OWNER_NAME'
ORDER BY OWNER, OBJECT_TYPE, OBJECT_NAME;

-- 3) RECOMPILE INVALID OBJECTS
ALTER PACKAGE OWNER_NAME.PACKAGE_NAME COMPILE;
ALTER PACKAGE OWNER_NAME.PACKAGE_NAME COMPILE BODY;

-- 4) IDENTIFYING INVALID OBJECTS
SELECT OWNER, OBJECT_TYPE, OBJECT_NAME, STATUS
FROM   DBA_OBJECTS
WHERE  STATUS = 'INVALID' AND OWNER = 'OWNER_NAME'
ORDER BY OWNER, OBJECT_TYPE, OBJECT_NAME;

-- 5) DESCRIBE TABLE
DESCRIBE OWNER_NAME.TABLE_NAME;