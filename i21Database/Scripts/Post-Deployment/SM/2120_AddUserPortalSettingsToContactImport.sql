GO

IF EXISTS (SELECT TOP 1 1 FROM [dbo].[tblSMCSVDynamicImportParameter] WHERE intCSVDynamicImportId = 1 AND strColumnName = 'portal')
BEGIN
	--Remove the column 'Portal Password' to the Contact Import spreadsheet

	DELETE FROM [dbo].[tblSMCSVDynamicImportParameter] WHERE intCSVDynamicImportId = 1 AND strColumnName = 'portal'
END

GO

IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[tblSMCSVDynamicImportParameter] WHERE intCSVDynamicImportId = 1 AND strColumnName = 'portalUserRole') 
BEGIN
	--Add the column 'Portal User Role' to the Contact Import spreadsheet

	INSERT INTO [dbo].[tblSMCSVDynamicImportParameter]
           ([intCSVDynamicImportId]
		   ,[strColumnName]
           ,[strDisplayName]
           ,[ysnRequired]
           ,[intConcurrencyId])
     VALUES
           (1
		   ,'portalUserRole'
           ,'Portal User Role'
           ,0
           ,0)
END

GO

IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[tblSMCSVDynamicImportParameter] WHERE intCSVDynamicImportId = 1 AND strColumnName = 'portalPassword') 
BEGIN
	--Add the column 'Portal Password' to the Contact Import spreadsheet

	INSERT INTO [dbo].[tblSMCSVDynamicImportParameter]
           ([intCSVDynamicImportId]
		   ,[strColumnName]
           ,[strDisplayName]
           ,[ysnRequired]
           ,[intConcurrencyId])
     VALUES
           (1
		   ,'portalPassword'
           ,'Portal Password'
           ,0
           ,0)
END

GO

--Update contact import commands

UPDATE [dbo].[tblSMCSVDynamicImport]
SET strCommand = N'
	DECLARE @EntityId 			INT
	DECLARE @EntityLocationId 	INT
	DECLARE @UserRoleId		    INT
	DECLARE @IsValid BIT
	
	--DECLARE @ValidationMessage NVARCHAR(MAX)
	SET @IsValid = 1

	DECLARE @ContactMethod	NVARCHAR(100)
	DECLARE @ActiveStr		NVARCHAR(100)
	DECLARE @ActiveBit		BIT
	DECLARE @RankStr		NVARCHAR(100)
	DECLARE @Rank			INT
	DECLARE @PortalBit		BIT
	DECLARE @Phone			NVARCHAR(100)
	DECLARE @Mobile			NVARCHAR(100)
	DECLARE @LocationName	NVARCHAR(100)
	DECLARE @PortalUserRole NVARCHAR(100)
	DECLARE @PortalPassword NVARCHAR(100)
	DECLARE @Email          NVARCHAR(100)

	SET @ValidationMessage	= ''''
	SET @ContactMethod		= ''@contactMethod@''
	SET @ActiveStr			= LOWER(''@active@'')
	SET @ActiveBit			= 0
	SET @RankStr			= ''@rank@''
	SET @Rank				= 1
	SET @PortalBit			= 0
	SET @Phone				= ''@phone@''
	SET @Mobile				= ''@mobile@''
	SET @LocationName		= ''@locname@''
	SET @PortalPassword     = ''@portalPassword@''
	SET @PortalUserRole     = ''@portalUserRole@''
	SET @UserRoleId         = 0
	SET @Email              = ''@email@''

	DECLARE @EmailDistribution NVARCHAR(MAX)
	DECLARE @EmailDistributionList NVARCHAR(MAX)
	DECLARE @EmailDistributionValid NVARCHAR(MAX)
	DECLARE @EmailDistributionInvalid NVARCHAR(MAX)

	SET @EmailDistributionList = ''Invoices,Transport Quote,Statements,AP remittance,AR Remittance,Contracts,Sales Order,Credit Memo,Quote Order,Scale,Storage,Cash,Cash Refund,Debit Memo,Customer Prepayment,CF Invoice,Letter,PR Remittance,Dealer CC Notification,Purchase Order,Settlement''
	SET @EmailDistribution = ''@emailDistribution@''

	select @EmailDistributionInvalid = COALESCE(@EmailDistributionInvalid + '','', '''') + RTRIM(LTRIM(a.Item))
		from dbo.fnSplitString(@EmailDistribution, '','') a
			left join dbo.fnSplitString(@EmailDistributionList, '','') b
			on ltrim(rtrim(a.Item)) = b.Item
			where b.Item is null


	select @EmailDistributionValid = COALESCE(@EmailDistributionValid + '','', '''') + RTRIM(LTRIM(a.Item))
		from dbo.fnSplitString(@EmailDistribution, '','') a
			left join dbo.fnSplitString(@EmailDistributionList, '','') b
			on ltrim(rtrim(a.Item)) = b.Item
			where b.Item is not null

	SET @EmailDistributionInvalid	= ISNULL(@EmailDistributionInvalid, '''')
	SET @EmailDistributionValid		= ISNULL(@EmailDistributionValid, '''')

	IF @ContactMethod <> '''' AND @ContactMethod NOT IN (''Email'', ''Phone'', ''Email or Phone'')
	BEGIN
		SET @ValidationMessage = @ValidationMessage + '',Contact Method ['' + @ContactMethod + ''] setting it to Blank''
		SET @ContactMethod = ''''
	END

	IF ISNULL(@EmailDistributionInvalid, '''') <> ''''
	BEGIN
		SET @ValidationMessage = @ValidationMessage + '',Email Distribution ['' + @EmailDistributionInvalid + ''] has been exluded for the email distribution''
	END

	IF @ActiveStr = ''1'' OR @ActiveStr = ''yes'' OR @ActiveStr = ''true''
	BEGIN
		SET @ActiveBit = 1
	END
	ELSE IF lower(@ActiveStr) NOT IN (''1'', ''0'', ''yes'', ''no'', ''true'', ''false'')
	BEGIN
		SET @ValidationMessage = @ValidationMessage + '',Active ['' + @ActiveStr + ''] should only be (0, 1, Yes, No, True, False)''
	END
	
	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblSMUserRole WHERE strName = @PortalUserRole) AND ISNULL(@PortalUserRole, '''') <> ''''
	BEGIN
		SELECT TOP 1 @UserRoleId = intUserRoleID FROM dbo.tblSMUserRole WHERE strName = @PortalUserRole
		SET @PortalBit = 1
	END
	ELSE IF ISNULL(@PortalUserRole, '''') <> ''''
	BEGIN
		IF @ValidationMessage != ''''
		BEGIN
   			SET @ValidationMessage = @ValidationMessage + '',''
		END
		SET @ValidationMessage = @ValidationMessage + ''The User Role of '' + @PortalUserRole + '' was not found in the Portal User Role. Please add this Role from the System Manager screen and re-attempt the upload''
	END

	IF (@Email IS NULL OR @Email = '''')
	BEGIN
		IF @ValidationMessage != ''''
		BEGIN
   			SET @ValidationMessage = @ValidationMessage + '',''
		END
		SET @ValidationMessage = @ValidationMessage + ''The Portal Username and Contact Email will be identical.  Please provide a valid email to use as the Portal Username and re-attempt the upload.''
	END

	IF ISNUMERIC(@RankStr) = 1
	BEGIN
		SET @Rank = @RankStr
	END
	ELSE
	BEGIN
		SET @ValidationMessage = @ValidationMessage + '',Rank ['' + @RankStr + ''] should be a number''
	END

	IF @ValidationMessage != ''''
	BEGIN
		RAISERROR(@ValidationMessage, 16, 1);
	END

	SELECT @EntityId = intEntityId
		FROM tblEMEntity
			where strEntityNo LIKE ''%'' + ''@entityCustomerId@''

	SET @EntityLocationId = null
	IF ISNULL(@EntityId, 0) > 0 and @LocationName <> ''''
	BEGIN
		SELECT TOP  1 @EntityLocationId = intEntityLocationId FROM tblEMEntityLocation where intEntityId = @EntityId and rtrim(ltrim(lower(@LocationName))) = rtrim(ltrim(lower(strLocationName)))

	END

	IF ISNULL(@EntityId, 0) > 0
	BEGIN

		DECLARE @NewEntityId INT
		INSERT INTO tblEMEntity(
			strName,			strContactNumber,	strEmail,		strSuffix,			strTitle,
			strNickName,		strDepartment,		strNotes,		intEntityRank,		ysnActive,
			strContactMethod,	strEmailDistributionOption
		)

		SELECT
			''@name@'',			'''',				''@email@'',	''@suffix@'',		''@title@'',
			''@nickname@'',		''@dept@'',			''@notes@'',	@Rank,				@ActiveBit,
			@ContactMethod,		@EmailDistributionValid


		SET @NewEntityId = @@IDENTITY

		INSERT INTO tblEMEntityToContact(intEntityId, intEntityContactId, ysnPortalAccess, intEntityLocationId)
		SELECT  @EntityId, @NewEntityId, 0, @EntityLocationId

		if @Phone <> ''''
		BEGIN
			insert into tblEMEntityPhoneNumber(intEntityId, strPhone)
			select @NewEntityId, @Phone
		END

		if @Mobile <> ''''
		BEGIN
			insert into tblEMEntityMobileNumber(intEntityId, strPhone, intCountryId)
			select @NewEntityId, @Mobile, null
		END

		IF @PortalBit = 1
		BEGIN
			DECLARE @ToggleOutput	NVARCHAR(200)

			EXEC uspEMTogglePortalAccess
				@intEntityId				= @EntityId,
				@intEntityContactId			= @NewEntityId,
				@ysnEnablePortalAccess		= 1,
				@message					= @ToggleOutput OUTPUT,
				@intUserRoleId				= @UserRoleId,
				@strPassword				= @PortalPassword

			IF ISNULL(@ToggleOutput, '''') <> ''''
			BEGIN
				SET @ToggleOutput = ''Creating portal access error:'' + @ToggleOutput
				RAISERROR(@ToggleOutput, 16, 1);
			END
		END


	END

'
WHERE intCSVDynamicImportId = 1