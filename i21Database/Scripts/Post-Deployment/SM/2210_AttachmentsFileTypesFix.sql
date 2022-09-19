GO
PRINT('/*******************  BEGIN FILE TYPE FIX *******************/')

UPDATE		tblSMAttachment
SET			strFileType = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(strFileType, CHAR(10), CHAR(32)),CHAR(13), CHAR(32)),CHAR(160), CHAR(32)),CHAR(9),CHAR(32))))

PRINT('/*******************  END FILE TYPE FIX *******************/')

GO