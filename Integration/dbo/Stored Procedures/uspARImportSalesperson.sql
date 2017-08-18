﻿GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportSalesperson')
	DROP PROCEDURE uspARImportSalesperson
GO

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
BEGIN
EXEC('CREATE PROCEDURE [dbo].[uspARImportSalesperson]
	@SalespersonId NVARCHAR(3) = NULL,
	@Update BIT = 0,
	@Total INT = 0 OUTPUT

	AS
	BEGIN
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
				agsls_email = F.strEmail,
				agsls_addr1 = CASE WHEN CHARINDEX(CHAR(10), D.strAddress) > 0 THEN SUBSTRING(SUBSTRING(D.strAddress,1,30), 0, CHARINDEX(CHAR(10),D.strAddress)) ELSE SUBSTRING(D.strAddress,1,30) END,
				agsls_addr2 = CASE WHEN CHARINDEX(CHAR(10), D.strAddress) > 0 THEN SUBSTRING(SUBSTRING(D.strAddress, CHARINDEX(CHAR(10),D.strAddress) + 1, LEN(D.strAddress)),1,30) ELSE NULL END,
				agsls_zip = SUBSTRING(D.strZipCode,1,10),
				agsls_city = SUBSTRING(D.strCity,1,20),
				agsls_state = SUBSTRING(D.strState,1,2),
				agsls_country = (CASE WHEN LEN(D.strCountry) = 3 THEN D.strCountry ELSE '''' END),
				agsls_phone = SUBSTRING(P.strPhone,1,15),
				agsls_dispatch_email = CASE WHEN S.strDispatchNotification = ''Email'' THEN ''E'' WHEN S.strDispatchNotification = ''Text'' THEN ''T'' WHEN S.strDispatchNotification = ''Both'' THEN ''B'' ELSE ''N'' END,
				agsls_textmsg_email = SUBSTRING(S.strTextMessage,1,50)
			FROM tblEMEntity E
				JOIN tblEMEntityToContact C
					on E.intEntityId = C.intEntityId AND ysnDefaultContact = 1
				JOIN tblEMEntity F
					on C.intEntityContactId = F.intEntityId
				JOIN tblEMEntityLocation D
					on E.intEntityId = D.intEntityId and ysnDefaultLocation = 1
				INNER JOIN tblARSalesperson S ON E.intEntityId = S.intEntitySalespersonId
				LEFT JOIN tblEMEntityPhoneNumber P ON P.intEntityId = F.intEntityId
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
				CASE WHEN CHARINDEX(CHAR(10), D.strAddress) > 0 THEN SUBSTRING(SUBSTRING(D.strAddress,1,30), 0, CHARINDEX(CHAR(10),D.strAddress)) ELSE SUBSTRING(D.strAddress,1,30) END,
				CASE WHEN CHARINDEX(CHAR(10), D.strAddress) > 0 THEN SUBSTRING(SUBSTRING(D.strAddress, CHARINDEX(CHAR(10),D.strAddress) + 1, LEN(D.strAddress)),1,30) ELSE NULL END,
				SUBSTRING(D.strZipCode,1,10),
				SUBSTRING(D.strCity,1,20),
				SUBSTRING(D.strState,1,2),
				(CASE WHEN LEN(D.strCountry) = 3 THEN D.strCountry ELSE '''' END),
				SUBSTRING(P.strPhone,1,15),
				CASE WHEN S.strDispatchNotification = ''Email'' THEN ''E'' WHEN S.strDispatchNotification = ''Text'' THEN ''T'' WHEN S.strDispatchNotification = ''Both'' THEN ''B'' ELSE ''N'' END,
				SUBSTRING(S.strTextMessage,1,50)
			FROM tblEMEntity E
				JOIN tblEMEntityToContact C
					on E.intEntityId = C.intEntityId AND ysnDefaultContact = 1
				JOIN tblEMEntity F
					on C.intEntityContactId = F.intEntityId
				JOIN tblEMEntityLocation D
					on E.intEntityId = D.intEntityId and ysnDefaultLocation = 1
				INNER JOIN tblARSalesperson S ON E.intEntityId = S.intEntitySalespersonId
				LEFT JOIN tblEMEntityPhoneNumber P ON P.intEntityId = F.intEntityId
				WHERE S.strSalespersonId = @SalespersonId
	

	RETURN;
	END	


	--================================================
	--     ONE TIME SALESPERSON SYNCHRONIZATION	
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
				@strName = ISNULL(agsls_name, ''''),
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
			INSERT [dbo].[tblEMEntity]	
			([strEntityNo], [strName], [strEmail], [strWebsite], [strInternalNotes],[ysnPrint1099],[str1099Name],[str1099Form],[str1099Type],[strFederalTaxId],[dtmW9Signed], [strContactNumber])					
			SELECT @strSalespersonId, @strName, @strEmail, '''', '''', 0, '''', '''', '''', NULL, NULL, ''''
				
			DECLARE @EntityId INT
			SET @EntityId = SCOPE_IDENTITY()

			INSERT [dbo].[tblEMEntity]	
			([strName], [strEmail], [strWebsite], [strInternalNotes],[ysnPrint1099],[str1099Name],[str1099Form],[str1099Type],[strFederalTaxId],[dtmW9Signed], [strContactNumber], [strPhone])
			SELECT @strName, @strEmail, '''', '''', 0, '''', '''', '''', NULL, NULL, '''', ISNULL(LTRIM(RTRIM(@strPhone)),'''')
			
			DECLARE @EntityContactId INT
			SET @EntityContactId = SCOPE_IDENTITY()

			INSERT INTO tblEMEntityLocation(intEntityId, strLocationName, strAddress, strZipCode, strCity, strState, strCountry, ysnDefaultLocation)
			SELECT @EntityId, @strSalespersonId + '' Location'', 
			ISNULL(LTRIM(RTRIM(@strAddress)),''''), 
			ISNULL(LTRIM(RTRIM(@strZipCode)),''''), 
			ISNULL(LTRIM(RTRIM(@strCity)),''''), 
			ISNULL(LTRIM(RTRIM(@strState)),''''), 
			ISNULL(LTRIM(RTRIM(@strCountry)),''''), 1
			
			insert into tblEMEntityToContact(intEntityId, intEntityContactId, ysnPortalAccess, ysnDefaultContact, intConcurrencyId)		
			select @EntityId, @EntityContactId, 0, 1, 1

			declare @intCountryId int
			select top 1 @intCountryId = intCountryID from tblSMCountry where strCountry = ''United States''
			INSERT INTO tblEMEntityPhoneNumber(intEntityId, strPhone, intCountryId)
			select top 1 @EntityContactId,ISNULL(LTRIM(RTRIM(@strPhone)),''''), isnull(intDefaultCountryId, @intCountryId) from tblSMCompanyPreference

			insert into tblEMEntityType(intEntityId, strType, intConcurrencyId)
			select @EntityId, ''Salesperson'', 0
			
			--INSERT Salesperson
			INSERT INTO [dbo].[tblARSalesperson]
			   ([intEntitySalespersonId]
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
			   ,[dblPercent]
			   ,[strAltEmail]
			   ,[strAltPhone]
			   ,[strFax]
			   ,[strMobile]
			   ,[strReason]
			   ,[strSpouse]
			   ,[strTitle])
			VALUES
			   (@EntityId,
				@strSalespersonId,
				@strType,
				ISNULL(LTRIM(RTRIM(@strPhone)),''''),
				ISNULL(LTRIM(RTRIM(@strAddress)),''''),
				ISNULL(LTRIM(RTRIM(@strZipCode)),''''),
				ISNULL(LTRIM(RTRIM(@strCity)),''''),
				ISNULL(LTRIM(RTRIM(@strState)),''''),
				ISNULL(LTRIM(RTRIM(@strCountry)),''''),
				1,
				ISNULL(LTRIM(RTRIM(@strDispatchNotification)),''''),
				ISNULL(LTRIM(RTRIM(@strTextMessage)),''''),
				''None'',
				0,
				'''',
				'''',
				'''',
				'''',
				'''',
				'''',
				'''')

			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END

			DELETE FROM #tmpagslsmst WHERE agsls_slsmn_id = @originSalespersonId
		
			SET @Counter += 1;

		END
	
	SET @Total = @Counter
	

	END

	--================================================
	--     GET TO BE IMPORTED RECORDS	
	--================================================
	IF(@Update = 1 AND @SalespersonId IS NULL) 
	BEGIN
		SELECT @Total = COUNT(agsls_slsmn_id)  
			FROM agslsmst
		LEFT JOIN tblARSalesperson
			ON agslsmst.agsls_slsmn_id COLLATE Latin1_General_CI_AS = tblARSalesperson.strSalespersonId COLLATE Latin1_General_CI_AS
		WHERE tblARSalesperson.strSalespersonId IS NULL
	END
	END'
)
END


IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
BEGIN
EXEC('CREATE PROCEDURE [dbo].[uspARImportSalesperson]
	@SalespersonId NVARCHAR(3) = NULL,
	@Update BIT = 0,
	@Total INT = 0 OUTPUT

	AS
	BEGIN
	
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
				ptsls_email = F.strEmail,
				ptsls_addr1 = CASE WHEN CHARINDEX(CHAR(10), D.strAddress) > 0 THEN SUBSTRING(SUBSTRING(D.strAddress,1,30), 0, CHARINDEX(CHAR(10),D.strAddress)) ELSE SUBSTRING(D.strAddress,1,30) END,
				ptsls_addr2 = CASE WHEN CHARINDEX(CHAR(10), D.strAddress) > 0 THEN SUBSTRING(SUBSTRING(D.strAddress, CHARINDEX(CHAR(10),D.strAddress) + 1, LEN(D.strAddress)),1,30) ELSE NULL END,
				ptsls_zip = SUBSTRING(D.strZipCode,1,10),
				ptsls_city = SUBSTRING(D.strCity,1,20),
				ptsls_state = SUBSTRING(D.strState,1,2),
				--ptsls_country = (CASE WHEN LEN(D.strCountry) = 3 THEN D.strCountry ELSE '''' END),
				ptsls_phone = SUBSTRING(P.strPhone,1,15),
				ptsls_dispatch_email = CASE WHEN S.strDispatchNotification = ''Email'' THEN ''Y'' ELSE ''N'' END,
				ptsls_textmsg_email = SUBSTRING(S.strTextMessage,1,50)
			FROM tblEMEntity E
				JOIN tblEMEntityToContact C
					on E.intEntityId = C.intEntityId AND ysnDefaultContact = 1
				JOIN tblEMEntity F
					on C.intEntityContactId = F.intEntityId
				JOIN tblEMEntityLocation D
					on E.intEntityId = D.intEntityId and ysnDefaultLocation = 1
				INNER JOIN tblARSalesperson S ON E.intEntityId = S.intEntitySalespersonId
				LEFT JOIN tblEMEntityPhoneNumber P ON P.intEntityId = F.intEntityId
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
				CASE WHEN CHARINDEX(CHAR(10), D.strAddress) > 0 THEN SUBSTRING(SUBSTRING(D.strAddress,1,30), 0, CHARINDEX(CHAR(10),D.strAddress)) ELSE SUBSTRING(D.strAddress,1,30) END,
				CASE WHEN CHARINDEX(CHAR(10), D.strAddress) > 0 THEN SUBSTRING(SUBSTRING(D.strAddress, CHARINDEX(CHAR(10),D.strAddress) + 1, LEN(D.strAddress)),1,30) ELSE NULL END,
				SUBSTRING(D.strZipCode,1,10),
				SUBSTRING(D.strCity,1,20),
				SUBSTRING(D.strState,1,2),
				--S.strCountry,
				SUBSTRING(P.strPhone,1,15),
				CASE WHEN S.strDispatchNotification = ''Email'' THEN ''Y'' ELSE ''N'' END,
				SUBSTRING(S.strTextMessage,1,50)
			FROM tblEMEntity E
				JOIN tblEMEntityToContact C
					on E.intEntityId = C.intEntityId AND ysnDefaultContact = 1
				JOIN tblEMEntity F
					on C.intEntityContactId = F.intEntityId
				JOIN tblEMEntityLocation D
					on E.intEntityId = D.intEntityId and ysnDefaultLocation = 1
				INNER JOIN tblARSalesperson S ON E.intEntityId = S.intEntitySalespersonId
				LEFT JOIN tblEMEntityPhoneNumber P ON P.intEntityId = F.intEntityId
				WHERE S.strSalespersonId = @SalespersonId
	

	RETURN;
	END	


	--================================================
	--     ONE TIME SALESPERSON SYNCHRONIZATION	
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
		DECLARE @strSystem					NVARCHAR (2)
		DECLARE @tmpptslsmst TABLE
		(
		strSalesManId nvarchar(10),
		strSystem nvarchar(2)
		)		
	
		DECLARE @Counter INT = 0
    
		--Import only those are not yet imported
		INSERT INTO @tmpptslsmst
			SELECT ptsls_slsmn_id, ''PT'' FROM ptslsmst
			LEFT JOIN tblARSalesperson
				ON ptslsmst.ptsls_slsmn_id COLLATE Latin1_General_CI_AS = tblARSalesperson.strSalespersonId COLLATE Latin1_General_CI_AS
			WHERE tblARSalesperson.strSalespersonId IS NULL
			UNION ALL 
			SELECT trdrv_driver, ''TR'' FROM trdrvmst
			LEFT JOIN tblARSalesperson
				ON trdrvmst.trdrv_driver COLLATE Latin1_General_CI_AS = tblARSalesperson.strSalespersonId COLLATE Latin1_General_CI_AS
			WHERE tblARSalesperson.strSalespersonId IS NULL		

		WHILE (EXISTS(SELECT 1 FROM @tmpptslsmst))
		BEGIN
		
			SELECT @originSalespersonId = strSalesManId,@strSystem = strSystem FROM @tmpptslsmst
			IF @strSystem = ''PT''
			BEGIN 
				SELECT TOP 1
					@strSalespersonId = ptsls_slsmn_id,
					@strName = ISNULL(ptsls_name, ''''),
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
			END
			
			IF @strSystem = ''TR''
			BEGIN 
				SELECT TOP 1
					@strSalespersonId = trdrv_driver,
					@strName = ISNULL(trdrv_name, ''''),
					@strType = ''Driver'' ,
					@strEmail = '''',
					@strAddress = '''',
					@strZipCode = '''',
					@strCity = '''',
					@strState = '''',
					@strCountry = (SELECT strCurrency FROM tblSMPreferences A INNER JOIN tblSMCurrency B ON A.strValue = B.intCurrencyID WHERE strPreference = ''defaultCurrency''),
					@strPhone = '''',
					@strDispatchNotification = '''',
					@strTextMessage = ''''					
				FROM trdrvmst
				WHERE trdrv_driver = @originSalespersonId
			END			
		
			--INSERT Entity record for Salesperson			
			INSERT [dbo].[tblEMEntity]	
			([strEntityNo], [strName], [strEmail], [strWebsite], [strInternalNotes],[ysnPrint1099],[str1099Name],[str1099Form],[str1099Type],[strFederalTaxId],[dtmW9Signed], [strContactNumber])					
			SELECT @strSalespersonId, @strName, @strEmail, '''', '''', 0, '''', '''', '''', NULL, NULL, ''''
				
			DECLARE @EntityId INT
			SET @EntityId = SCOPE_IDENTITY()

			INSERT [dbo].[tblEMEntity]	
			([strName], [strEmail], [strWebsite], [strInternalNotes],[ysnPrint1099],[str1099Name],[str1099Form],[str1099Type],[strFederalTaxId],[dtmW9Signed], [strContactNumber], [strPhone])
			SELECT @strName, @strEmail, '''', '''', 0, '''', '''', '''', NULL, NULL, '''', ISNULL(LTRIM(RTRIM(@strPhone)),'''')
			
			DECLARE @EntityContactId INT
			SET @EntityContactId = SCOPE_IDENTITY()

			INSERT INTO tblEMEntityLocation(intEntityId, strLocationName, strAddress, strZipCode, strCity, strState, strCountry, ysnDefaultLocation)
			SELECT @EntityId, @strSalespersonId + '' Location'', ISNULL(LTRIM(RTRIM(@strAddress)),''''), ISNULL(LTRIM(RTRIM(@strZipCode)),''''), ISNULL(LTRIM(RTRIM(@strCity)),''''), ISNULL(LTRIM(RTRIM(@strState)),''''), ISNULL(LTRIM(RTRIM(@strCountry)),''''), 1

			
			insert into tblEMEntityToContact(intEntityId, intEntityContactId, ysnPortalAccess, ysnDefaultContact, intConcurrencyId)		
			select @EntityId, @EntityContactId, 0, 1, 1

			declare @intCountryId int
			select top 1 @intCountryId = intCountryID from tblSMCountry where strCountry = ''United States''
			INSERT INTO tblEMEntityPhoneNumber(intEntityId, strPhone, intCountryId)
			select top 1 @EntityContactId,ISNULL(LTRIM(RTRIM(@strPhone)),''''), isnull(intDefaultCountryId, @intCountryId) from tblSMCompanyPreference

			insert into tblEMEntityType(intEntityId, strType, intConcurrencyId)
			select @EntityId, ''Salesperson'', 0
		
			--INSERT Salesperson
			INSERT INTO [dbo].[tblARSalesperson]
			   ([intEntitySalespersonId]
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
			   ,[dblPercent]
			   ,[strAltEmail]
			   ,[strAltPhone]
			   ,[strFax]
			   ,[strMobile]
			   ,[strReason]
			   ,[strSpouse]
			   ,[strTitle])
			VALUES
			   (@EntityId,
				CASE WHEN @strSystem = ''PT'' THEN @strSalespersonId ELSE NULL END,
				@strType,
				ISNULL(LTRIM(RTRIM(@strPhone)),''''),
				ISNULL(LTRIM(RTRIM(@strAddress)),''''),
				ISNULL(LTRIM(RTRIM(@strZipCode)),''''),
				ISNULL(LTRIM(RTRIM(@strCity)),''''),
				ISNULL(LTRIM(RTRIM(@strState)),''''),
				ISNULL(LTRIM(RTRIM(@strCountry)),''''),
				1,
				ISNULL(LTRIM(RTRIM(@strDispatchNotification)),''''),
				ISNULL(LTRIM(RTRIM(@strTextMessage)),''''),
				''None'',
				0,
				'''',
				'''',
				'''',
				'''',
				'''',
				'''',
				'''')

			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END

			DELETE FROM @tmpptslsmst WHERE strSalesManId = @originSalespersonId
		
			SET @Counter += 1;

		END
	
	SET @Total = @Counter

	END

	--================================================
	--     GET TO BE IMPORTED RECORDS	
	--================================================
	IF(@Update = 1 AND @SalespersonId IS NULL) 
	BEGIN
		SELECT @Total = COUNT(ptsls_slsmn_id)
			FROM ptslsmst
		LEFT JOIN tblARSalesperson
			ON ptslsmst.ptsls_slsmn_id COLLATE Latin1_General_CI_AS = tblARSalesperson.strSalespersonId COLLATE Latin1_General_CI_AS
		WHERE tblARSalesperson.strSalespersonId IS NULL
		
		SELECT @Total = @Total + COUNT(trdrv_driver)
			FROM trdrvmst
		LEFT JOIN tblARSalesperson
			ON trdrvmst.trdrv_driver COLLATE Latin1_General_CI_AS = tblARSalesperson.strSalespersonId COLLATE Latin1_General_CI_AS
		WHERE tblARSalesperson.strSalespersonId IS NULL		
	END
	END'
)

END

