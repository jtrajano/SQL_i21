-- CREATE THE BACKUP TABLES
SELECT	*
INTO	apcbkmst_bk
FROM	apcbkmst

SELECT	*
INTO	apchkmst_bk
FROM	apchkmst

-- CREATE THE BASE TABLES FOR LEGACY. 
SELECT	*
INTO	apcbkmst_legacy
FROM	apcbkmst

SELECT	*
INTO	apchkmst_legacy
FROM	apchkmst
