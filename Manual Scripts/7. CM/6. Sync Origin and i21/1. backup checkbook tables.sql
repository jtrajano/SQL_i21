-- CREATE THE BACKUP TABLES
SELECT	*
INTO	apcbkmst_bk
FROM	apcbkmst

SELECT	*
INTO	apchkmst_bk
FROM	apchkmst

-- CREATE THE i21fied tables. 
SELECT	*
INTO	apcbkmsti21fied
FROM	apcbkmst

SELECT	*
INTO	apchkmsti21fied
FROM	apchkmst
