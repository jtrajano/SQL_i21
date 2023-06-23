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
			UPDATE tblEMEntityEFTInformation SET ysnDefaultAccount = 1 WHERE intEntityEFTInfoId = @intEntityEFTInfoId
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
			AND EXISTS(SELECT TOP 1 1 FROM tblEMEntity WHERE intEntityId = @intEntityId)
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

	-------------------------------------------------------------------------------------------------------------
	PRINT ('*****Begin ADD EFT Default Branch Code*****')

	IF OBJECT_ID('tempdb..#TempUpdateEFTBranchCode') IS NOT NULL
		DROP TABLE #TempUpdateEFTBranchCode

	CREATE TABLE #TempUpdateEFTBranchCode
	(
		[intEntityId]			INT	NOT NULL,
		[intEntityEFTInfoId]	INT	NOT NULL
	)

	INSERT INTO #TempUpdateEFTBranchCode ([intEntityId], [intEntityEFTInfoId])
	SELECT intEntityId, intEntityEFTInfoId
	FROM tblEMEntityEFTInformation 
	WHERE ISNULL([strBranchCode], '') = ''
	ORDER BY intEntityId

	DECLARE temp_cursor_branch_code CURSOR FOR
	SELECT [intEntityId], [intEntityEFTInfoId]
	FROM #TempUpdateEFTBranchCode

	OPEN temp_cursor_branch_code
	FETCH NEXT FROM temp_cursor_branch_code into @intEntityId, @intEntityEFTInfoId
	WHILE @@FETCH_STATUS = 0
	BEGIN

		UPDATE tblEMEntityEFTInformation 
		SET [strBranchCode] = 'XXX' WHERE intEntityEFTInfoId = @intEntityEFTInfoId
		
		FETCH NEXT FROM temp_cursor_branch_code into @intEntityId, @intEntityEFTInfoId
	END

	CLOSE temp_cursor_branch_code
	DEALLOCATE temp_cursor_branch_code

	PRINT ('*****End ADD EFT Default Branch Code*****')


	------------------------------------------------------------------------------------------------------
	PRINT ('*****BEGIN ADD EFT Domestic VALUE*****')
	--WE NEED TO CONVERT ALL EXISTING VALUE TO DOMESTIC WHEN THE DATABASE IS FROM 21.2 OR LOWER
	
	DECLARE @versionNo NVARCHAR(30)
	DECLARE @version INT

	SELECT TOP 1 @versionNo = strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC
	IF ISNULL(@versionNo, '') != ''
	BEGIN
		IF EXISTS (SELECT TOP 1 1 FROM dbo.fnSplitStringWithTrim(@versionNo, ','))
		BEGIN
			SELECT TOP 1 @version = CAST(Item AS INT) FROM fnSplitStringWithTrim(@versionNo, '.')
			IF ISNULL(@version, 0) != 0 AND @version < 22
			BEGIN
				IF OBJECT_ID('tempdb..#TempUpdateEFTInformation') IS NOT NULL
					DROP TABLE #TempUpdateEFTInformation

				CREATE TABLE #TempUpdateEFTInformation
				(
					[intEntityId]			INT	NOT NULL,
					[intEntityEFTInfoId]	INT	NOT NULL
				)

				INSERT INTO #TempUpdateEFTInformation ([intEntityId], [intEntityEFTInfoId])
				SELECT intEntityId, intEntityEFTInfoId
				FROM tblEMEntityEFTInformation
				ORDER BY intEntityId

				DECLARE temp_cursor_info CURSOR FOR
				SELECT [intEntityId], [intEntityEFTInfoId]
				FROM #TempUpdateEFTInformation

				OPEN temp_cursor_info
				FETCH NEXT FROM temp_cursor_info into @intEntityId, @intEntityEFTInfoId
				WHILE @@FETCH_STATUS = 0
				BEGIN
					UPDATE tblEMEntityEFTInformation SET ysnDomestic = 1 WHERE [intEntityEFTInfoId] = @intEntityEFTInfoId

					FETCH NEXT FROM temp_cursor_info into @intEntityId, @intEntityEFTInfoId
				END

				CLOSE temp_cursor_info
				DEALLOCATE temp_cursor_info
			END
		END
	END
	
	PRINT ('*****END ADD EFT Domestic VALUE*****')
	-- -------------------------------------------------------------------------------------------------------------------------------------------------
	-- Update NULL currency of EFT Information to Vendor Currency Id: EM-3199
	-- -------------------------------------------------------------------------------------------------------------------------------------------------
	PRINT ('*****NULL EFT/ACH CURRENCY ID FROM LOWER VERSION TO 22.1 OR HIGHER UPDATE TO VENDOR DEFAULT CURRENCY *****')
	
	DECLARE @intCurrencyId INT
	SELECT	TOP 1 @intCurrencyId = intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'USD'

	
	UPDATE	a
	SET		a.intCurrencyId = ISNULL(c.intCurrencyId, @intCurrencyId),
			a.strCurrency	= ISNULL(d.strCurrency, 'USD')
	FROM	tblEMEntityEFTInformation	AS a

			INNER JOIN tblEMEntity		AS b ON
			a.intEntityId = b.intEntityId
			
			INNER JOIN tblAPVendor		AS c ON
			b.intEntityId = c.intEntityId
			
			LEFT JOIN tblSMCurrency		AS d ON
			c.intCurrencyId = d.intCurrencyID

	WHERE	a.intCurrencyId IS NULL
	
	PRINT ('*****END NULL EFT/ACH CURRENCY ID FROM LOWER VERSION TO 22.1 OR HIGHER UPDATE TO VENDOR DEFAULT CURRENCY *****')

GO