
PRINT '---------- START DYNAMIC CSV DEFAULT DATA ----------'

SET IDENTITY_INSERT tblSMCSVDynamicImport  ON
DECLARE @NewHeaderId INT
SET @NewHeaderId = 1

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCSVDynamicImport WHERE intCSVDynamicImportId = @NewHeaderId)
BEGIN
	INSERT INTO tblSMCSVDynamicImport(intCSVDynamicImportId, strName, strCommand )
	SELECT @NewHeaderId, '1','1'
END

UPDATE tblSMCSVDynamicImport SET
	strName = 'Contact Import',
	strCommand = '	
	DECLARE @EntityId INT
	
		--	phone	
		--mobile		
		--locname	
		--portal
	

	--validation stage
	DECLARE @IsValid BIT 
	--DECLARE @ValidationMessage NVARCHAR(MAX)
	SET @IsValid = 1
	
	DECLARE @ContactMethod	NVARCHAR(100) 	
	DECLARE @ActiveStr		NVARCHAR(100)
	DECLARE @ActiveBit		BIT
	DECLARE @RankStr		NVARCHAR(100)
	DECLARE @Rank			INT	
	DECLARE @PortalStr		NVARCHAR(100)
	DECLARE @PortalBit		BIT

	SET @ValidationMessage	= ''''
	SET @ContactMethod		= ''@contactMethod@''
	SET @ActiveStr			= LOWER(''@active@'')
	SET @ActiveBit			= 0
	SET @RankStr			= ''@rank@''
	SET @Rank				= 1
	SET @PortalStr			= LOWER(''@portal@'')
	SET @PortalBit			= 0
	
	DECLARE @EmailDistribution NVARCHAR(MAX)
	DECLARE @EmailDistributionList NVARCHAR(MAX)
	DECLARE @EmailDistributionValid NVARCHAR(MAX)
	DECLARE @EmailDistributionInvalid NVARCHAR(MAX)

	SET @EmailDistributionList = ''Invoices,Transport Quote,Statements,AP remittance,AR Remittance,Contracts,Sales Order,Credit Memo,Quote Order,Scale,Storage,Cash,Cash Refund,Debit Memo,Customer Prepayment,CF Invoice,Letter,PR Remittance,Dealer CC Notification,Purchase Order,Settlement''


	SET @EmailDistribution = ''@emailDistribution@''

	select @EmailDistributionInvalid = COALESCE(@EmailDistributionInvalid + '','', '''') + RTRIM(LTRIM(a.Item)) 
		from dbo.fnSplitString(@EmailDistribution, '','') a
			left join dbo.fnSplitString(@EmailDistributionList, '','') b
			on a.Item = b.Item
			where b.Item is null


	select @EmailDistributionValid = COALESCE(@EmailDistributionValid + '','', '''') + RTRIM(LTRIM(a.Item)) 
		from dbo.fnSplitString(@EmailDistribution, '','') a
			left join dbo.fnSplitString(@EmailDistributionList, '','') b
			on a.Item = b.Item
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

	IF @PortalStr = ''1'' OR @PortalStr = ''yes'' OR @PortalStr = ''true''
	BEGIN
		SET @PortalBit = 1
	END 

	IF ISNUMERIC(@RankStr) = 1
	BEGIN
		SET @Rank = @RankStr
	END


	SELECT @EntityId = intEntityId 
		FROM tblEMEntity 
			where strEntityNo = ''@entityCustomerId@''
	

	DECLARE @RoleId INT

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

		INSERT INTO tblEMEntityToContact(intEntityId, intEntityContactId, ysnPortalAccess)
		SELECT  @EntityId, @NewEntityId, 0
		

		IF @PortalBit = 1
		BEGIN
			DECLARE @ToggleOutput	NVARCHAR(200)
			DECLARE @UserRoleId		INT
			EXEC uspEMTogglePortalAccess 
				@intEntityId				= @EntityId,
				@intEntityContactId			= @NewEntityId,
				@ysnEnablePortalAccess		= 1,
				@message					= @ToggleOutput OUTPUT,
				@intUserRoleId				= @UserRoleId OUTPUT

			IF ISNULL(@ToggleOutput, '''') <> ''''
			BEGIN
				SET @ToggleOutput = ''Creating portal access error:'' + @ToggleOutput				
				RAISERROR(@ToggleOutput, 16, 1);
			END
		END

		
	END
	
'
	 WHERE intCSVDynamicImportId = @NewHeaderId

	 DELETE FROM tblSMCSVDynamicImportParameter WHERE intCSVDynamicImportId = @NewHeaderId


	INSERT INTO tblSMCSVDynamicImportParameter(intCSVDynamicImportId, strColumnName, strDisplayName, ysnRequired)
	SELECT @NewHeaderId, 'entityCustomerId', 'Customer Entity No*', 1
	Union All
	SELECT @NewHeaderId, 'name', 'Name*', 1
	Union All
	SELECT @NewHeaderId, 'suffix', 'Suffix', 0
	Union All
	SELECT @NewHeaderId, 'title', 'Title', 0
	Union All
	SELECT @NewHeaderId, 'nickname', 'NickName', 0
	Union All
	SELECT @NewHeaderId, 'email', 'Email', 0
	Union All
	SELECT @NewHeaderId, 'phone', 'Phone', 0
	Union All
	SELECT @NewHeaderId, 'mobile', 'Mobile', 0
	Union All
	SELECT @NewHeaderId, 'locname', 'Location Name', 0
	Union All
	SELECT @NewHeaderId, 'contactMethod', 'Contact Method', 0
	Union All
	SELECT @NewHeaderId, 'dept', 'Dept', 0
	Union All
	SELECT @NewHeaderId, 'emailDistribution', 'Email Distribution', 0
	Union All
	SELECT @NewHeaderId, 'notes', 'Notes', 0
	Union All
	SELECT @NewHeaderId, 'active', 'Active', 0
	Union All
	SELECT @NewHeaderId, 'rank', 'Rank', 0
	Union All
	SELECT @NewHeaderId, 'portal', 'Portal Access', 0




PRINT '---------- END DYNAMIC CSV DEFAULT DATA ----------'


SET IDENTITY_INSERT tblSMCSVDynamicImport  OFF

GO