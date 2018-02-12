/*****CLEAN EXISTING RECORD*******/
PRINT N'*** BEGIN Replication Init Status'
DECLARE @count INT
SELECT @count = COUNT(*) FROM tblSMRepInitStatus  

IF @count > 0
BEGIN
	
	DELETE FROM tblSMRepInitStatus


END

PRINT N'*** END - Replication Init status ***'

