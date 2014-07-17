GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportSalesperson')
	DROP PROCEDURE uspARImportAccount
GO


IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
BEGIN
EXEC(
	'CREATE PROCEDURE uspARImportSalesperson
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
		IF(EXISTS(SELECT 1 FROM agslsmst WHERE agsls_slsmn_id = @SalespersonId))
		BEGIN
			UPDATE agslsmst
				SET 
				agsls_slsmn_id = S.strSalespersonId,
				agsls_name = E.strName,
				agsls_et_driver_yn = CASE WHEN S.strType = ''Driver'' THEN ''Y'' ELSE ''N'' END,
				agsls_email = E.strEmail,
				agsls_addr1 = CASE WHEN CHARINDEX(CHAR(10), S.strAddress) > 0 THEN SUBSTRING(S.strAddress, 0, CHARINDEX(CHAR(10),S.strAddress)) ELSE S.strAddress END,
				agsls_addr2 = CASE WHEN CHARINDEX(CHAR(10), S.strAddress) > 0 THEN SUBSTRING(S.strAddress, CHARINDEX(CHAR(10),S.strAddress), LEN(S.strAddress)) ELSE NULL END,
				agsls_zip = S.strZipCode,
				agsls_city = S.strCity,
				agsls_state = S.strState,
				agsls_country = S.strCountry,
				agsls_phone = S.strPhone,
				agsls_dispatch_email = CASE WHEN S.strType = ''Email'' THEN ''Y'' ELSE ''N'' END,
				agsls_textmsg_email = S.strTextMessage
			FROM tblEntity E
				INNER JOIN tblARSalesperson S ON E.intEntityId = S.intEntityId
				WHERE S.strSalespersonId = @SalespersonId AND agsls_slsmn_id = @SalespersonId
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
				S.strSalespersonId,
				E.strName,
				CASE WHEN S.strType = ''Driver'' THEN ''Y'' ELSE ''N'' END,
				E.strEmail,
				CASE WHEN CHARINDEX(CHAR(10), S.strAddress) > 0 THEN SUBSTRING(S.strAddress, 0, CHARINDEX(CHAR(10),S.strAddress)) ELSE S.strAddress END,
				CASE WHEN CHARINDEX(CHAR(10), S.strAddress) > 0 THEN SUBSTRING(S.strAddress, CHARINDEX(CHAR(10),S.strAddress), LEN(S.strAddress)) ELSE NULL END,
				S.strZipCode,
				S.strCity,
				S.strState,
				S.strCountry,
				S.strPhone,
				CASE WHEN S.strType = ''Email'' THEN ''Y'' ELSE ''N'' END,
				S.strTextMessage
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
				@strEmail = ISNULL(agsls_email,''''),
				@strAddress = ISNULL(agsls_addr1,'''') + CHAR(10) + ISNULL(agsls_addr2,''''),
				@strZipCode = agsls_zip,
				@strCity = agsls_city,
				@strState = agsls_state,
				@strCountry = agsls_country,
				@strPhone = agsls_phone,
				@strDispatchNotification = CASE WHEN agsls_dispatch_email = ''Y'' THEN ''Email'' ELSE ''Phone'' END,
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
			   ,[strEmail]
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
				@strEmail,
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