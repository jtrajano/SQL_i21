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
-------------------------------------------------------------------------------------------------------------
	PRINT ('*****Begin ADD EFT Header table*****')

	IF OBJECT_ID('tempdb..#TempUpdateEFTHeader') IS NOT NULL
		DROP TABLE #TempUpdateEFTHeader

	CREATE TABLE #TempUpdateEFTHeader
	(
		[intEntityId]			INT	NOT NULL,
		[intEntityEFTInfoId]	INT	NOT NULL
	)

	INSERT INTO #TempUpdateEFTHeader ([intEntityId], [intEntityEFTInfoId])
	SELECT intEntityId, intEntityEFTInfoId
	FROM tblEMEntityEFTInformation 
	WHERE ISNULL([intEntityEFTHeaderId], 0) = 0
	ORDER BY intEntityId

	DECLARE temp_cursor_header CURSOR FOR
	SELECT [intEntityId], [intEntityEFTInfoId]
	FROM #TempUpdateEFTHeader

	DECLARE @intNewHeaderId			INT

	OPEN temp_cursor_header
	FETCH NEXT FROM temp_cursor_header into @intEntityId, @intEntityEFTInfoId
	WHILE @@FETCH_STATUS = 0
	BEGIN

		IF ISNULL(@intEntityId, 0) <> 0 AND EXISTS(SELECT TOP 1 1 FROM tblEMEntity WHERE intEntityId = @intEntityId)
			AND NOT EXISTS (SELECT TOP 1 1 FROM tblEMEntityEFTHeader WHERE intEntityId = @intEntityId)
		BEGIN
			INSERT INTO [tblEMEntityEFTHeader] ([intEntityId], [intConcurrencyId])
			VALUES (@intEntityId, 1)
			
			SET @intNewHeaderId = SCOPE_IDENTITY();

			IF ISNULL(@intNewHeaderId, 0) <> 0
			BEGIN
				UPDATE tblEMEntityEFTInformation 
				SET [intEntityEFTHeaderId] = @intNewHeaderId WHERE intEntityEFTInfoId = @intEntityEFTInfoId
			END
		END
		ELSE IF EXISTS (SELECT TOP 1 1 FROM tblEMEntityEFTHeader WHERE intEntityId = @intEntityId)
		BEGIN
			UPDATE tblEMEntityEFTInformation 
			SET 
				intEntityEFTHeaderId = (SELECT TOP 1 intEntityEFTHeaderId FROM tblEMEntityEFTHeader WHERE intEntityId = @intEntityId)
			WHERE intEntityEFTInfoId = @intEntityEFTInfoId
		END
		
		FETCH NEXT FROM temp_cursor_header into @intEntityId, @intEntityEFTInfoId
	END

	CLOSE temp_cursor_header
	DEALLOCATE temp_cursor_header

	PRINT ('*****End ADD EFT Header table*****')
GO