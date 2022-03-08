GO
	PRINT ('*****Begin EFT Default Bank*****')

	IF OBJECT_ID('tempdb..#TempUpdateEFTDefaultBank') IS NOT NULL
		DROP TABLE #TempUpdateEFTDefaultBank

	CREATE TABLE #TempUpdateEFTDefaultBank
	(
		[intEntityId]			INT	NOT NULL,
		[intEntityEFTInfoId]	INT	NOT NULL
	)

	INSERT INTO #TempUpdateEFTDefaultBank ([intEntityId], [intEntityEFTInfoId])
	SELECT intEntityId, intEntityEFTInfoId
	FROM tblEMEntityEFTInformation 
	WHERE ISNULL(ysnDefaultAccount, 0) <> 1
	ORDER BY intEntityId

	DECLARE temp_cursor CURSOR FOR
	SELECT [intEntityId], [intEntityEFTInfoId]
	FROM #TempUpdateEFTDefaultBank

	DECLARE @intEntityId			INT
	DECLARE @intEntityEFTInfoId		INT
	DECLARE @ErrMsg					NVARCHAR(MAX)

	OPEN temp_cursor
	FETCH NEXT FROM temp_cursor into @intEntityId, @intEntityEFTInfoId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--update only if no eft bank is default
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblEMEntityEFTInformation WHERE ysnDefaultAccount = 1 AND intEntityId = @intEntityId AND intEntityEFTInfoId <> @intEntityEFTInfoId)
		BEGIN
			UPDATE tblEMEntityEFTInformation 
			SET 
				ysnDefaultAccount = 1,
				ysnActive = 1
			WHERE intEntityEFTInfoId = @intEntityEFTInfoId
		END
		
		FETCH NEXT FROM temp_cursor into @intEntityId, @intEntityEFTInfoId
	END

	CLOSE temp_cursor
	DEALLOCATE temp_cursor

	PRINT ('*****End EFT Default Bank*****')
GO