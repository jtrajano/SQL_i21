PRINT N'*** BEGIN - INSERT DEFAULT Replication Init  ***'

DECLARE @count INT
SELECT @count = COUNT(*) FROM tblSMRepInitStatus

	IF @count > 0
		BEGIN
	
			UPDATE tblSMRepInitStatus SET intStatus = 1

		END
	ELSE
		BEGIN
			INSERT INTO tblSMRepInitStatus(intId, intStatus) VALUES (1, 1)
		END


PRINT N'*** END - INSERT DEFAULT Replication Init ***'

