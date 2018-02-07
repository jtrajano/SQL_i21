PRINT N'*** BEGIN - INSERT DEFAULT Replication Result ***'

DECLARE @count INT
SELECT @count = COUNT(*) FROM tblSMReplicationSPResult  

IF @count = 0
BEGIN
	

	INSERT INTO [dbo].tblSMReplicationSPResult
           ([id]
           ,[result])
           
     VALUES(1,0)
           




END

PRINT N'*** END - INSERT DEFAULT Replication Result ***'

