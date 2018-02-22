PRINT N'*** BEGIN - INSERT DEFAULT Replication Result ***'

BEGIN

	DECLARE @count3 INT
	SELECT @count3 = COUNT(*) FROM tblSMReplicationSPResult  

		IF @count3 = 0
		BEGIN
	

			INSERT INTO [dbo].tblSMReplicationSPResult
				   ([id]
				   ,[result])
           
			 VALUES(1,0)
           




		END
END
PRINT N'*** END - INSERT DEFAULT Replication Result ***'

