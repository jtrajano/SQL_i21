GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportSalesperson')
	DROP PROCEDURE uspARImportSalesperson
GO

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
BEGIN
EXEC(
	'CREATE PROCEDURE [dbo].[uspARImportSalesperson]
	@SalespersonId NVARCHAR(3) = NULL,
	@Update BIT = 0,
	@Total INT = 0 OUTPUT

	AS

	--Make first a copy of agslsmst. This will use to track all salesperson already imported
	IF(OBJECT_ID(''dbo.tblARTempSalesperson'') IS NULL)
		SELECT * INTO tblARTempSalesperson FROM agslsmst
	
	--================================================
	--     UPDATE/INSERT IN ORIGIN	
	--================================================
	IF(@Update = 1 AND @SalespersonId IS NOT NULL) 
	BEGIN
		--UPDATE IF EXIST IN THE ORIGIN
		IF(EXISTS(SELECT 1 FROM agslsmst WHERE agsls_slsmn_id = UPPER(@SalespersonId)))
		BEGIN
			UPDATE agslsmst
				SET 
				agsls_slsmn_id = UPPER(S.strSalespersonId),
				agsls_name = SUBSTRING(E.strName,1,30),
				agsls_et_driver_yn = CASE WHEN S.strType = ''Driver'' THEN ''Y'' ELSE ''N'' END,
				agsls_email = E.strEmail,
				agsls_addr1 = CASE WHEN CHARINDEX(CHAR(10), S.strAddress) > 0 THEN SUBSTRING(SUBSTRING(S.strAddress,1,30), 0, CHARINDEX(CHAR(10),S.strAddress)) ELSE SUBSTRING(S.strAddress,1,30) END,
				agsls_addr2 = CASE WHEN CHARINDEX(CHAR(10), S.strAddress) > 0 THEN SUBSTRING(SUBSTRING(S.strAddress, CHARINDEX(CHAR(10),S.strAddress) + 1, LEN(S.strAddress)),1,30) ELSE NULL END,
				agsls_zip = SUBSTRING(S.strZipCode,1,10),
				agsls_city = SUBSTRING(S.strCity,1,20),
				agsls_state = SUBSTRING(S.strState,1,2),
				agsls_country = (CASE WHEN LEN(S.strCountry) = 3 THEN S.strCountry ELSE '''' END),
				agsls_phone = SUBSTRING(S.strPhone,1,15),
				agsls_dispatch_email = CASE WHEN S.strDispatchNotification = ''Email'' THEN ''E'' WHEN S.strDispatchNotification = ''Text'' THEN ''T'' WHEN S.strDispatchNotification = ''Both'' THEN ''B'' ELSE ''N'' END,
				agsls_textmsg_email = SUBSTRING(S.strTextMessage,1,50)
			FROM tblEntity E
				INNER JOIN tblARSalesperson S ON E.intEntityId = S.intEntityId
				WHERE S.strSalespersonId = @SalespersonId AND agsls_slsmn_id = UPPER(@SalespersonId)
		END
		--INSERT IF NOT EXIST IN THE ORIGIN
		ELSE
			INSERT INTO agslsmst(
				agsls_slsmn_id,
				agsls_name,
				agsls_et_driver_yn,
				agsls_email,
				agsls_addr1,
				agsls_addr2,
				agsls_zip,
				agsls_city,
				agsls_state,
				agsls_country,
				agsls_phone,
				agsls_dispatch_email,
				agsls_textmsg_email
			)
			SELECT 
				UPPER(S.strSalespersonId),
				SUBSTRING(E.strName,1,30),
				CASE WHEN S.strType = ''Driver'' THEN ''Y'' ELSE ''N'' END,
				E.strEmail,
				CASE WHEN CHARINDEX(CHAR(10), S.strAddress) > 0 THEN SUBSTRING(SUBSTRING(S.strAddress,1,30), 0, CHARINDEX(CHAR(10),S.strAddress)) ELSE SUBSTRING(S.strAddress,1,30) END,
				CASE WHEN CHARINDEX(CHAR(10), S.strAddress) > 0 THEN SUBSTRING(SUBSTRING(S.strAddress, CHARINDEX(CHAR(10),S.strAddress) + 1, LEN(S.strAddress)),1,30) ELSE NULL END,
				SUBSTRING(S.strZipCode,1,10),
				SUBSTRING(S.strCity,1,20),
				SUBSTRING(S.strState,1,2),
				(CASE WHEN LEN(S.strCountry) = 3 THEN S.strCountry ELSE '''' END),
				SUBSTRING(S.strPhone,1,15),
				CASE WHEN S.strDispatchNotification = ''Email'' THEN ''E'' WHEN S.strDispatchNotification = ''Text'' THEN ''T'' WHEN S.strDispatchNotification = ''Both'' THEN ''B'' ELSE ''N'' END,
				SUBSTRING(S.strTextMessage,1,50)
			FROM tblEntity E
				INNER JOIN tblARSalesperson S ON E.intEntityId = S.intEntityId
				WHERE S.strSalespersonId = @SalespersonId
	

	RETURN;
	END	


	--================================================
	--     ONE TIME ACCOUNT SYNCHRONIZATION	
	--================================================
	IF(@Update = 0 AND @SalespersonId IS NULL) 
	BEGIN
	
		--1 Time synchronization here
		PRINT ''1 Time Salesperson Synchronization''

		DECLARE @originSalespersonId		NVARCHAR(3)
		DECLARE @strSalespersonId			NVARCHAR (3)
		DECLARE	@strName					NVARCHAR (100)
		DECLARE @strType					NVARCHAR (20)
		DECLARE @strEmail					NVARCHAR (50)
		DECLARE	@strAddress					NVARCHAR (250)
		DECLARE @strZipCode					NVARCHAR (50)
		DECLARE	@strCity					NVARCHAR (50)
		DECLARE @strState					NVARCHAR (50)
		DECLARE	@strCountry					NVARCHAR (50)
		DECLARE @strPhone					NVARCHAR (50)
		DECLARE	@strDispatchNotification	NVARCHAR (50)
		DECLARE @strTextMessage				NVARCHAR (100)
	
		DECLARE @Counter INT = 0
    
		--Import only those are not yet imported
		SELECT agsls_slsmn_id INTO #tmpagslsmst 
			FROM agslsmst
		LEFT JOIN tblARSalesperson
			ON agslsmst.agsls_slsmn_id COLLATE Latin1_General_CI_AS = tblARSalesperson.strSalespersonId COLLATE Latin1_General_CI_AS
		WHERE tblARSalesperson.strSalespersonId IS NULL
		ORDER BY agslsmst.agsls_slsmn_id

		WHILE (EXISTS(SELECT 1 FROM #tmpagslsmst))
		BEGIN
		
			SELECT @originSalespersonId = agsls_slsmn_id FROM #tmpagslsmst

			SELECT TOP 1
				@strSalespersonId = agsls_slsmn_id,
				@strName = agsls_name,
				@strType = CASE WHEN agsls_et_driver_yn = ''Y'' THEN ''Driver'' ELSE ''Sales Representative'' END,
				@strEmail = ISNULL(LTRIM(RTRIM(agsls_email)),''''),
				@strAddress = ISNULL(agsls_addr1,'''') + CHAR(10) + ISNULL(agsls_addr2,''''),
				@strZipCode = agsls_zip,
				@strCity = agsls_city,
				@strState = agsls_state,
				@strCountry = agsls_country,
				@strPhone = agsls_phone,
				@strDispatchNotification = CASE WHEN agsls_dispatch_email = ''E'' THEN ''Email'' WHEN agsls_dispatch_email = ''T'' THEN ''Text'' WHEN agsls_dispatch_email = ''B'' THEN ''Both'' ELSE '''' END,
				@strTextMessage = agsls_textmsg_email
			FROM agslsmst
			WHERE agsls_slsmn_id = @originSalespersonId
		
			--INSERT Entity record for Salesperson
			INSERT [dbo].[tblEntity]	
			([strName], [strEmail], [strWebsite], [strInternalNotes],[ysnPrint1099],[str1099Name],[str1099Form],[str1099Type],[strFederalTaxId],[dtmW9Signed])
			VALUES						
			(@strName, @strEmail, '''', '''', 0, '''', '''', '''', NULL, NULL)
				
			DECLARE @EntityId INT
			SET @EntityId = SCOPE_IDENTITY()
		
			--INSERT Salesperson
			INSERT INTO [dbo].[tblARSalesperson]
			   ([intEntityId]
			   ,[strSalespersonId]
			   ,[strType]
			   ,[strPhone]
			   ,[strAddress]
			   ,[strZipCode]
			   ,[strCity]
			   ,[strState]
			   ,[strCountry]
			   ,[ysnActive]
			   ,[strDispatchNotification]
			   ,[strTextMessage]
			   ,[strCommission]
			   ,[dblPercent])
			VALUES
			   (@EntityId,
				@strSalespersonId,
				@strType,
				@strPhone,
				@strAddress,
				@strZipCode,
				@strCity,
				@strState,
				@strCountry,
				1,
				@strDispatchNotification,
				@strTextMessage,
				''None'',
				0)

			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END

			DELETE FROM #tmpagslsmst WHERE agsls_slsmn_id = @originSalespersonId
		
			SET @Counter += 1;

		END
	
	SET @Total = @Counter
	--To delete all record on temp table to determine if there are still record to import
	DELETE FROM tblARTempSalesperson

	END

	--================================================
	--     GET TO BE IMPORTED RECORDS	
	--================================================
	IF(@Update = 1 AND @SalespersonId IS NULL) 
	BEGIN
		SELECT @Total = COUNT(agsls_slsmn_id) from tblARTempSalesperson
	END'
)
END


IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
BEGIN
EXEC(
	'CREATE PROCEDURE [dbo].[uspARImportSalesperson]
	@SalespersonId NVARCHAR(3) = NULL,
	@Update BIT = 0,
	@Total INT = 0 OUTPUT

	AS

	--Make first a copy of ptslsmst. This will use to track all salesperson already imported
	IF(OBJECT_ID(''dbo.tblARTempSalesperson'') IS NULL)
		SELECT * INTO tblARTempSalesperson FROM ptslsmst
	
	--================================================
	--     UPDATE/INSERT IN ORIGIN	
	--================================================
	IF(@Update = 1 AND @SalespersonId IS NOT NULL) 
	BEGIN
		--UPDATE IF EXIST IN THE ORIGIN
		IF(EXISTS(SELECT 1 FROM ptslsmst WHERE ptsls_slsmn_id = UPPER(@SalespersonId)))
		BEGIN
			UPDATE ptslsmst
				SET 
				ptsls_slsmn_id = UPPER(S.strSalespersonId),
				ptsls_name = SUBSTRING(E.strName,1,30),
				ptsls_et_driver_yn = CASE WHEN S.strType = ''Driver'' THEN ''Y'' ELSE ''N'' END,
				ptsls_email = E.strEmail,
				ptsls_addr1 = CASE WHEN CHARINDEX(CHAR(10), S.strAddress) > 0 THEN SUBSTRING(SUBSTRING(S.strAddress,1,30), 0, CHARINDEX(CHAR(10),S.strAddress)) ELSE SUBSTRING(S.strAddress,1,30) END,
				ptsls_addr2 = CASE WHEN CHARINDEX(CHAR(10), S.strAddress) > 0 THEN SUBSTRING(SUBSTRING(S.strAddress, CHARINDEX(CHAR(10),S.strAddress) + 1, LEN(S.strAddress)),1,30) ELSE NULL END,
				ptsls_zip = SUBSTRING(S.strZipCode,1,10),
				ptsls_city = SUBSTRING(S.strCity,1,20),
				ptsls_state = SUBSTRING(S.strState,1,2),
				--ptsls_country = (CASE WHEN LEN(S.strCountry) = 3 THEN S.strCountry ELSE '''' END),
				ptsls_phone = SUBSTRING(S.strPhone,1,15),
				ptsls_dispatch_email = CASE WHEN S.strDispatchNotification = ''Email'' THEN ''Y'' ELSE ''N'' END,
				ptsls_textmsg_email = SUBSTRING(S.strTextMessage,1,50)
			FROM tblEntity E
				INNER JOIN tblARSalesperson S ON E.intEntityId = S.intEntityId
				WHERE S.strSalespersonId = @SalespersonId AND ptsls_slsmn_id = UPPER(@SalespersonId)
		END
		--INSERT IF NOT EXIST IN THE ORIGIN
		ELSE
			INSERT INTO ptslsmst(
				ptsls_slsmn_id,
				ptsls_name,
				ptsls_et_driver_yn,
				ptsls_email,
				ptsls_addr1,
				ptsls_addr2,
				ptsls_zip,
				ptsls_city,
				ptsls_state,
				--ptsls_country,
				ptsls_phone,
				ptsls_dispatch_email,
				ptsls_textmsg_email
			)
			SELECT 
				UPPER(S.strSalespersonId),
				SUBSTRING(E.strName,1,30),
				CASE WHEN S.strType = ''Driver'' THEN ''Y'' ELSE ''N'' END,
				E.strEmail,
				CASE WHEN CHARINDEX(CHAR(10), S.strAddress) > 0 THEN SUBSTRING(SUBSTRING(S.strAddress,1,30), 0, CHARINDEX(CHAR(10),S.strAddress)) ELSE SUBSTRING(S.strAddress,1,30) END,
				CASE WHEN CHARINDEX(CHAR(10), S.strAddress) > 0 THEN SUBSTRING(SUBSTRING(S.strAddress, CHARINDEX(CHAR(10),S.strAddress) + 1, LEN(S.strAddress)),1,30) ELSE NULL END,
				SUBSTRING(S.strZipCode,1,10),
				SUBSTRING(S.strCity,1,20),
				SUBSTRING(S.strState,1,2),
				--S.strCountry,
				SUBSTRING(S.strPhone,1,15),
				CASE WHEN S.strDispatchNotification = ''Email'' THEN ''Y'' ELSE ''N'' END,
				SUBSTRING(S.strTextMessage,1,50)
			FROM tblEntity E
				INNER JOIN tblARSalesperson S ON E.intEntityId = S.intEntityId
				WHERE S.strSalespersonId = @SalespersonId
	

	RETURN;
	END	


	--================================================
	--     ONE TIME ACCOUNT SYNCHRONIZATION	
	--================================================
	IF(@Update = 0 AND @SalespersonId IS NULL) 
	BEGIN
	
		--1 Time synchronization here
		PRINT ''1 Time Salesperson Synchronization''

		DECLARE @originSalespersonId		NVARCHAR(3)
		DECLARE @strSalespersonId			NVARCHAR (3)
		DECLARE	@strName					NVARCHAR (100)
		DECLARE @strType					NVARCHAR (20)
		DECLARE @strEmail					NVARCHAR (50)
		DECLARE	@strAddress					NVARCHAR (250)
		DECLARE @strZipCode					NVARCHAR (50)
		DECLARE	@strCity					NVARCHAR (50)
		DECLARE @strState					NVARCHAR (50)
		DECLARE	@strCountry					NVARCHAR (50)
		DECLARE @strPhone					NVARCHAR (50)
		DECLARE	@strDispatchNotification	NVARCHAR (50)
		DECLARE @strTextMessage				NVARCHAR (100)
	
		DECLARE @Counter INT = 0
    
		--Import only those are not yet imported
		SELECT ptsls_slsmn_id INTO #tmpptslsmst 
			FROM ptslsmst
		LEFT JOIN tblARSalesperson
			ON ptslsmst.ptsls_slsmn_id COLLATE Latin1_General_CI_AS = tblARSalesperson.strSalespersonId COLLATE Latin1_General_CI_AS
		WHERE tblARSalesperson.strSalespersonId IS NULL
		ORDER BY ptslsmst.ptsls_slsmn_id

		WHILE (EXISTS(SELECT 1 FROM #tmpptslsmst))
		BEGIN
		
			SELECT @originSalespersonId = ptsls_slsmn_id FROM #tmpptslsmst

			SELECT TOP 1
				@strSalespersonId = ptsls_slsmn_id,
				@strName = ptsls_name,
				@strType = CASE WHEN ptsls_et_driver_yn = ''Y'' THEN ''Driver'' ELSE ''Sales Representative'' END,
				@strEmail = ISNULL(LTRIM(RTRIM(ptsls_email)),''''),
				@strAddress = ISNULL(ptsls_addr1,'''') + CHAR(10) + ISNULL(ptsls_addr2,''''),
				@strZipCode = ptsls_zip,
				@strCity = ptsls_city,
				@strState = ptsls_state,
				@strCountry = (SELECT strCurrency FROM tblSMPreferences A INNER JOIN tblSMCurrency B ON A.strValue = B.intCurrencyID WHERE strPreference = ''defaultCurrency''),
				@strPhone = ptsls_phone,
				@strDispatchNotification = CASE WHEN ptsls_dispatch_email = ''Y'' THEN ''Email'' ELSE '''' END,
				@strTextMessage = ptsls_textmsg_email
			FROM ptslsmst
			WHERE ptsls_slsmn_id = @originSalespersonId
		
			--INSERT Entity record for Salesperson
			INSERT [dbo].[tblEntity]	
			([strName], [strEmail], [strWebsite], [strInternalNotes],[ysnPrint1099],[str1099Name],[str1099Form],[str1099Type],[strFederalTaxId],[dtmW9Signed])
			VALUES						
			(@strName, @strEmail, '''', '''', 0, '''', '''', '''', NULL, NULL)
				
			DECLARE @EntityId INT
			SET @EntityId = SCOPE_IDENTITY()
		
			--INSERT Salesperson
			INSERT INTO [dbo].[tblARSalesperson]
			   ([intEntityId]
			   ,[strSalespersonId]
			   ,[strType]
			   ,[strPhone]
			   ,[strAddress]
			   ,[strZipCode]
			   ,[strCity]
			   ,[strState]
			   ,[strCountry]
			   ,[ysnActive]
			   ,[strDispatchNotification]
			   ,[strTextMessage]
			   ,[strCommission]
			   ,[dblPercent])
			VALUES
			   (@EntityId,
				@strSalespersonId,
				@strType,
				@strPhone,
				@strAddress,
				@strZipCode,
				@strCity,
				@strState,
				@strCountry,
				1,
				@strDispatchNotification,
				@strTextMessage,
				''None'',
				0)

			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END

			DELETE FROM #tmpptslsmst WHERE ptsls_slsmn_id = @originSalespersonId
		
			SET @Counter += 1;

		END
	
	SET @Total = @Counter
	--To delete all record on temp table to determine if there are still record to import
	DELETE FROM tblARTempSalesperson

	END

	--================================================
	--     GET TO BE IMPORTED RECORDS	
	--================================================
	IF(@Update = 1 AND @SalespersonId IS NULL) 
	BEGIN
		SELECT @Total = COUNT(ptsls_slsmn_id) from tblARTempSalesperson
	END'
)
END