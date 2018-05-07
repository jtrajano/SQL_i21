
PRINT '---------- START DYNAMIC CSV DEFAULT DATA ----------'
SET NOCOUNT ON

-- Customer Contact Import Begin
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

-- Customer Contact Import End

--Customer Import Begin
SET @NewHeaderId = 2

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCSVDynamicImport WHERE intCSVDynamicImportId = @NewHeaderId)
BEGIN
	INSERT INTO tblSMCSVDynamicImport(intCSVDynamicImportId, strName, strCommand )
	SELECT @NewHeaderId, 'Customer Import','1'
END
--Customer Import End
-- Customer Special Taxing Import Begin
SET @NewHeaderId = 3

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCSVDynamicImport WHERE intCSVDynamicImportId = @NewHeaderId)
BEGIN
	INSERT INTO tblSMCSVDynamicImport(intCSVDynamicImportId, strName, strCommand )
	SELECT @NewHeaderId, 'Customer Special Taxing Import','1'
END



UPDATE tblSMCSVDynamicImport SET
	strName = 'Customer Special Taxing Import',
	strCommand = '
	DECLARE @EntityId 		INT
	DECLARE @EntityNo 		NVARCHAR(100)
	--validation stage
	DECLARE @IsValid 		BIT

	DECLARE @TaxGroup		NVARCHAR(100)
	DECLARE @TaxGroupId		INT
	DECLARE @CusLoc			NVARCHAR(100)
	DECLARE @CusLocId		INT
	DECLARE @VenNo			NVARCHAR(100)
	DECLARE @VenNoId		INT
	DECLARE @ItemCat		NVARCHAR(100)
	DECLARE @ItemNo			NVARCHAR(100)
	DECLARE @ItemCatId		INT
	DECLARE @ItemNoId		INT

	SELECT @CusLoc = ''@cusloc@'',
			@VenNo = ''@venno@'',
			@ItemCat = ''@itemcat@'',
			@ItemNo = ''@itemno@'',
			@TaxGroup = ''@taxgroup@'',
			@EntityNo = ''@entityCustomerId@'',


			@TaxGroupId 	= NULL,
			@CusLocId 		= NULL,
			@VenNoId		= NULL,
			@ItemCatId 		= NULL,
			@ItemNoId		= NULL



	SET @IsValid = 1
	SET @ValidationMessage	= ''''

	SELECT @EntityId = A.intEntityId
		FROM tblEMEntity A
			JOIN (SELECT intEntityId FROM tblEMEntityType WHERE strType = ''Customer'') B
				ON A.intEntityId = B.intEntityId
			where strEntityNo = @EntityNo



	SELECT TOP 1 @VenNoId = A.intEntityId
		FROM tblEMEntity A
			JOIN (SELECT intEntityId FROM tblEMEntityType WHERE strType = ''Vendor'') B
				ON A.intEntityId = B.intEntityId
			where strEntityNo = @VenNo


	SELECT TOP 1 @TaxGroupId = intTaxGroupId FROM tblSMTaxGroup WHERE strTaxGroup = @TaxGroup

	IF ISNULL(@TaxGroupId, 0) <= 0 AND @TaxGroup <> ''''
	BEGIN
		SET @ValidationMessage	= @ValidationMessage + '',Tax Group does not exists''
		SET @IsValid = 0
	END

	IF ISNULL(@VenNoId, 0) <= 0 AND @VenNo <> ''''
	BEGIN
		SET @ValidationMessage	= @ValidationMessage + '',Vendor does not exists''
		SET @IsValid = 0
	END

	select

		@ItemNoId = CASE WHEN @ItemNo <> '''' THEN ITM.intItemId ELSE NULL END,
		--ITM.strItemNo,
		@ItemCatId = CASE WHEN @ItemCat <> '''' THEN CAT.intCategoryId ELSE NULL END--,
		--CAT.strCategoryCode
		from tblICItem ITM
	JOIN ( select intCategoryId, strCategoryCode from tblICCategory) CAT
		on ITM.intCategoryId = CAT.intCategoryId

	WHERE
		( (@ItemCat <> '''' and @ItemNo <> '''' )  and @ItemNo = ITM.strItemNo and @ItemCat = CAT.strCategoryCode)
		OR ( (@ItemCat = '''' and @ItemNo <> '''' )  and @ItemNo = ITM.strItemNo)
		OR ( (@ItemCat <> '''' and @ItemNo = '''' ) and @ItemCat = CAT.strCategoryCode)

	IF (ISNULL(@ItemNoId, 0)) <= 0 AND @ItemNo <> ''''	AND (ISNULL(@ItemCatId, 0)) <= 0 AND @ItemCat <> ''''
	BEGIN
		SET @ValidationMessage	= @ValidationMessage + '',Item and Cateogry does not exists''
		SET @IsValid = 0
	END
	ELSE IF (ISNULL(@ItemNoId, 0)) <= 0 AND @ItemNo <> ''''
	BEGIN
		SET @ValidationMessage	= @ValidationMessage + '',Item does not exists''
		SET @IsValid = 0
	END
	ELSE IF (ISNULL(@ItemCatId, 0)) <= 0 AND @ItemCat <> ''''
	BEGIN
		SET @ValidationMessage	= @ValidationMessage + '',Category does not exists''
		SET @IsValid = 0
	END

	IF ISNULL(@EntityId, 0) > 0 AND @CusLoc <> ''''
	BEGIN
		SELECT @CusLocId = intEntityLocationId FROM tblEMEntityLocation WHERE intEntityId = @EntityId AND strLocationName = @CusLoc
		IF ISNULL(@CusLocId,0) <= 0
		BEGIN
			SET @ValidationMessage	= @ValidationMessage + '',Customer Location does not exists''
			SET @IsValid = 0
		END
	END



	IF ISNULL(@EntityId, 0) > 0
	BEGIN
		IF (@IsValid = 1)
		BEGIN

			INSERT INTO tblARSpecialTax(
					intEntityCustomerId, 	intEntityVendorId, 		intItemId,
					intCategoryId, 			intTaxGroupId, 			intEntityCustomerLocationId)
			SELECT 	@EntityId,				@VenNoId, 				@ItemNoId,
					@ItemCatId, 			@TaxGroupId, 			@CusLocId
		END

	END
	ELSE
	BEGIN
		SET @ValidationMessage = @ValidationMessage + '',Customer (@entityCustomerId@) does not exists.''
	END

'
	 WHERE intCSVDynamicImportId = @NewHeaderId

	 DELETE FROM tblSMCSVDynamicImportParameter WHERE intCSVDynamicImportId = @NewHeaderId


	INSERT INTO tblSMCSVDynamicImportParameter(intCSVDynamicImportId, strColumnName, strDisplayName, ysnRequired)
	SELECT @NewHeaderId, 'entityCustomerId', 'Customer Entity No*', 1
	UNION All
	SELECT @NewHeaderId, 'taxgroup', 'Tax Group*', 1
	Union All
	SELECT @NewHeaderId, 'cusloc', 'Customer Location', 0
	Union All
	SELECT @NewHeaderId, 'venno', 'Vendor No', 0
	Union All
	SELECT @NewHeaderId, 'itemcat', 'Item Category', 0
	Union All
	SELECT @NewHeaderId, 'itemno', 'Item No', 0
-- Customer Special Taxing Import End


--License Tab Begin

SET @NewHeaderId = 4

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCSVDynamicImport WHERE intCSVDynamicImportId = @NewHeaderId)
BEGIN
	INSERT INTO tblSMCSVDynamicImport(intCSVDynamicImportId, strName, strCommand )
	SELECT @NewHeaderId, 'Customer Master License Import','1'
END


UPDATE tblSMCSVDynamicImport SET
	strName = 'Customer Master License Import',
	strCommand = '
	DECLARE @EntityId 		INT
	DECLARE @EntityNo 		NVARCHAR(100)
	--validation stage
	DECLARE @IsValid 		BIT

	SELECT @IsValid = 1,
			@ValidationMessage	= ''''
	DECLARE @LicenseCode 	NVARCHAR(100)
	DECLARE @LicenseCodeId 	INT
	DECLARE @BeginDateS		NVARCHAR(100)
	DECLARE @BeginDate		DATETIME
	DECLARE @EndDateS		NVARCHAR(100)
	DECLARE @EndDate		DATETIME
	DECLARE @Comments		NVARCHAR(100)
	DECLARE @ActiveS		NVARCHAR(100)
	DECLARE @Active			BIT


	SELECT
			@EntityNo = ''@entityCustomerId@'',
			@LicenseCode = ''@liccode@'',
			@BeginDateS = ''@begdate@'',
			@EndDateS = ''@enddate@'',
			@Comments = ''@com@'',
			@ActiveS = LOWER(''@active@''),


			@LicenseCodeId 	= NULL,
			@BeginDate 		= NULL,
			@EndDate		= NULL,
			@Active 		= NULL,
			@EntityId		= NULL




	SELECT @EntityId = A.intEntityId
		FROM tblEMEntity A
			JOIN (SELECT intEntityId FROM tblEMEntityType WHERE strType = ''Customer'') B
				ON A.intEntityId = B.intEntityId
			where strEntityNo = @EntityNo

	IF ISNULL(@LicenseCode, '''') <> ''''
	BEGIN

		SELECT @LicenseCodeId = intLicenseTypeId FROM tblSMLicenseType where strCode = @LicenseCode

		IF ISNULL(@LicenseCodeId, 0) <= 0
		BEGIN
			SET @ValidationMessage	= @ValidationMessage + '',License Code does not exists.''
			SET @IsValid = 0
		END
	END


	IF @BeginDateS <> ''''
	BEGIN

		BEGIN TRY
			SELECT @BeginDate = CAST(@BeginDateS AS DATETIME)
		END TRY
		BEGIN CATCH
			SET @ValidationMessage	= @ValidationMessage + '',Begin Date is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
			SET @IsValid = 0
		END CATCH
	END

	IF @EndDateS <> ''''
	BEGIN

		BEGIN TRY
			SELECT @EndDate = CAST(@EndDateS AS DATETIME)
		END TRY
		BEGIN CATCH
			SET @ValidationMessage	= @ValidationMessage + '',End Date is invalid, please try Month/Day/Year Format e.g. 12/01/2015.''
			SET @IsValid = 0

		END CATCH
	END

	IF @BeginDate IS NOT NULL AND @EndDate IS NOT NULL AND @BeginDate > @EndDate
	BEGIN
		SET @ValidationMessage	= @ValidationMessage + '',Begin Date should not be greater than End Date.''
		SET @IsValid = 0
	END

	IF @ActiveS = ''1'' OR @ActiveS = ''yes'' OR @ActiveS = ''true''
	BEGIN
		SET @Active = 1
	END

	IF ISNULL(@EntityId, 0) > 0
	BEGIN


		IF (@IsValid = 1)
		BEGIN

			INSERT INTO tblARCustomerMasterLicense(
				intEntityCustomerId, 	intLicenseTypeId,
				dtmBeginDate, 			dtmEndDate,
				strComment, 			ysnAcvite)
			SELECT
				@EntityId,				@LicenseCodeId,
				@BeginDate,				@EndDate,
				@Comments,				@Active
		END

	END
	ELSE
	BEGIN
		SET @ValidationMessage = @ValidationMessage + '',Customer (@entityCustomerId@) does not exists.''
	END

'
	 WHERE intCSVDynamicImportId = @NewHeaderId

	 DELETE FROM tblSMCSVDynamicImportParameter WHERE intCSVDynamicImportId = @NewHeaderId


	INSERT INTO tblSMCSVDynamicImportParameter(intCSVDynamicImportId, strColumnName, strDisplayName, ysnRequired)
	SELECT @NewHeaderId, 'entityCustomerId', 'Customer Entity No*', 1
	UNION All
	SELECT @NewHeaderId, 'liccode', 'License Code*', 1
	Union All
	SELECT @NewHeaderId, 'begdate', 'Begin Date', 0
	Union All
	SELECT @NewHeaderId, 'enddate', 'End Date', 0
	Union All
	SELECT @NewHeaderId, 'com', 'Comment', 0
	Union All
	SELECT @NewHeaderId, 'active', 'Active', 0


--License Tab End
--Transport Freight Tab Begin
SET @NewHeaderId = 5

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCSVDynamicImport WHERE intCSVDynamicImportId = @NewHeaderId)
BEGIN
	INSERT INTO tblSMCSVDynamicImport(intCSVDynamicImportId, strName, strCommand )
	SELECT @NewHeaderId, 'Customer Transport Freight Import','1'
END


UPDATE tblSMCSVDynamicImport SET
	strName = 'Customer Transport Freight Import',
	strCommand = '
	DECLARE @EntityId 		INT
	DECLARE @EntityNo 		NVARCHAR(100)
	
	DECLARE @IsValid 		BIT

	SELECT @IsValid = 1,
			@ValidationMessage	= ''''

	DECLARE @CusLoc			NVARCHAR(100)
	DECLARE @CusLocId		INT
	DECLARE @ZipCode 		NVARCHAR(100)
	DECLARE @ItemCat		NVARCHAR(100)
	DECLARE @ItemCatId		INT
	DECLARE @FreightOnly	NVARCHAR(100)
	DECLARE @FreightOnlyB	BIT
	DECLARE @FreightType	NVARCHAR(100)
	DECLARE @ShipVia		NVARCHAR(100)
	DECLARE @ShipViaId		INT
	DECLARE @AmountS		NVARCHAR(100)
	DECLARE @Amount			NUMERIC (18, 6)	
	DECLARE @RateS			NVARCHAR(100)
	DECLARE @Rate			NUMERIC (18, 6)
	DECLARE @MilesS			NVARCHAR(100)
	DECLARE @Miles			NUMERIC (18, 6)
	DECLARE @FreightPrice	NVARCHAR(100)
	DECLARE @FreightPriceB	BIT
	DECLARE @UnitS			NVARCHAR(100)
	DECLARE @Unit			NUMERIC (18, 6)	

	SELECT
			@EntityNo 		= ''@entityCustomerId@'',
			@CusLoc 		= ''@cusloc@'',
			@ZipCode 		= ''@zipcode@'',
			@ItemCat 		= ''@itemcat@'',
			@FreightOnly 	= LOWER(''@freightonly@''),
			@FreightType 	= ''@freighttype@'',
			@ShipVia 		= ''@freightshipvia@'',
			@AmountS		= ''@freightamount@'',
			@RateS			= ''@freightrate@'',
			@MilesS			= ''@freightmiles@'',
			@FreightPrice	= LOWER(''@freightprice@''),
			@UnitS			= ''@freightunit@'',
			
			@CusLocId 		= NULL,
			@ItemCatId		= NULL,
			@FreightOnlyB	= 0,
			@ShipViaId		= NULL,
			@Amount			= 0,
			@Rate			= 0,
			@Miles			= 0,
			@FreightPriceB	= 0,
			@Unit			= 0,
			@EntityId		= NULL

	


	SELECT @EntityId = A.intEntityId
		FROM tblEMEntity A
			JOIN (SELECT intEntityId FROM tblEMEntityType WHERE strType = ''Customer'') B
				ON A.intEntityId = B.intEntityId
			where strEntityNo = @EntityNo


	IF ISNULL(@EntityId, 0) > 0 AND @CusLoc <> ''''
	BEGIN
		SELECT @CusLocId = intEntityLocationId FROM tblEMEntityLocation WHERE intEntityId = @EntityId AND strLocationName = @CusLoc
		IF ISNULL(@CusLocId,0) <= 0
		BEGIN
			SET @ValidationMessage	= @ValidationMessage + '',Customer Location does not exists''
			SET @IsValid = 0
		END
	END

	IF @ShipVia <> '''' 
	BEGIN
		SELECT @ShipViaId = A.intEntityId
		from 
			tblSMShipVia A
				JOIN tblEMEntity B
					on A.[intEntityId] = B.intEntityId
		WHERE A.strShipVia = @ShipVia

		IF ISNULL(@ShipViaId, 0) <= 0
		BEGIN
			SET @ValidationMessage	= @ValidationMessage + '',Ship Via does not exists.''
			SET @IsValid = 0
		END			

	END
		
	IF @AmountS <> ''''
	BEGIN
		IF ISNUMERIC(@AmountS) = 1
			SELECT @Amount = CAST(@AmountS AS NUMERIC(18,6))
		ELSE
		BEGIN
			SET @ValidationMessage	= @ValidationMessage + '',Amount is invalid.''
			SET @IsValid = 0
		END

	END
	
	IF @RateS <> ''''
	BEGIN
		IF ISNUMERIC(@RateS) = 1
			SELECT @Rate = CAST(@RateS AS NUMERIC(18,6))
		ELSE
		BEGIN
			SET @ValidationMessage	= @ValidationMessage + '',Rate is invalid.''
			SET @IsValid = 0
		END

	END
	
	IF @MilesS <> ''''
	BEGIN
		IF ISNUMERIC(@MilesS) = 1
			SELECT @Miles = CAST(@MilesS AS NUMERIC(18,6))
		ELSE
		BEGIN
			SET @ValidationMessage	= @ValidationMessage + '',Miles is invalid.''
			SET @IsValid = 0
		END

	END
	
	IF @UnitS <> ''''
	BEGIN
		IF ISNUMERIC(@UnitS) = 1
			SELECT @Unit = CAST(@UnitS AS NUMERIC(18,6))
		ELSE
		BEGIN
			SET @ValidationMessage	= @ValidationMessage + '',Unit is invalid.''
			SET @IsValid = 0
		END

	END


	

	IF @FreightOnly = ''1'' OR @FreightOnly = ''yes'' OR @FreightOnly = ''true''
	BEGIN
		SET @FreightOnlyB = 1
	END

	IF @FreightPrice = ''1'' OR @FreightPrice = ''yes'' OR @FreightPrice = ''true''
	BEGIN
		SET @FreightPriceB = 1
	END
	


	select		
		@ItemCatId = CASE WHEN @ItemCat <> '''' THEN CAT.intCategoryId ELSE NULL END
		from tblICCategory CAT
	WHERE
		( (@ItemCat <> '''' ) and @ItemCat = CAT.strCategoryCode)

	IF (ISNULL(@ItemCatId, 0)) <= 0 AND @ItemCat <> ''''
	BEGIN
		SET @ValidationMessage	= @ValidationMessage + '',Category does not exists''
		SET @IsValid = 0
	END


	IF ISNULL(@EntityId, 0) > 0
	BEGIN

		IF (@IsValid = 1)
		BEGIN
			IF LOWER(@FreightType) = ''amount''
			BEGIN
				SELECT @ShipViaId = NULL, 	
						@Rate = 0,			@Miles = 0,
						@Unit = 0
			END
			ELSE IF LOWER(@FreightType) = ''miles''
			BEGIN
				SELECT @Amount = 0,
						@Rate = 0,			
						@Unit = 0

			END
			ELSE IF LOWER(@FreightType) = ''rate''
			BEGIN
				SELECT @ShipViaId = NULL, 	@Amount = 0,
						@Miles = 0
			END
			ELSE
			BEGIN
				SELECT @ShipViaId = NULL, 	@Amount = 0,
						@Rate = 0,			@Miles = 0,
						@Unit = 0
			END
			BEGIN TRY
				INSERT INTO tblARCustomerFreightXRef(
					intEntityCustomerId,		intCategoryId,
					ysnFreightOnly,				strFreightType,
					dblFreightAmount,			dblFreightRate,
					dblMinimumUnits,			ysnFreightInPrice,
					dblFreightMiles,			intShipViaId,
					intEntityLocationId,		strZipCode,
					intConcurrencyId	
				)
				SELECT
					@EntityId,					@ItemCatId,
					@FreightOnlyB,				@FreightType,
					@Amount,					@Rate,
					@Unit,						@FreightPriceB,
					@Miles,						@ShipViaId,
					@CusLocId,					@ZipCode,
					0
			END TRY
			BEGIN CATCH
				DECLARE @Err NVARCHAR(MAX)
				SET @Err = Error_Message()
				SELECT @Err
				IF CHARINDEX(''uk_tblarcustomerfreightxref_reference_columns'', LOWER(@Err)) > 0
				BEGIN
					SET @ValidationMessage = ''Duplicate combination of (Location, Zip Code & Category) entry for Customer (@entityCustomerId@).''
				END
				ELSE
				BEGIN
					SET @ValidationMessage = ''Customer (@entityCustomerId@) does not exists.''
				END

				
			END CATCH
				
		END

	END
	ELSE
	BEGIN
		SET @ValidationMessage = @ValidationMessage + '',Customer (@entityCustomerId@) does not exists.''
	END

'
	 WHERE intCSVDynamicImportId = @NewHeaderId

	 DELETE FROM tblSMCSVDynamicImportParameter WHERE intCSVDynamicImportId = @NewHeaderId


	INSERT INTO tblSMCSVDynamicImportParameter(intCSVDynamicImportId, strColumnName, strDisplayName, ysnRequired)
	SELECT @NewHeaderId, 'entityCustomerId', 'Customer Entity No*', 1
	UNION All
	SELECT @NewHeaderId, 'cusloc', 'Customer Location*', 1
	Union All
	SELECT @NewHeaderId, 'zipcode', 'Supplier Zip Code', 0
	Union All
	SELECT @NewHeaderId, 'itemcat', 'Category', 0
	Union All
	SELECT @NewHeaderId, 'freightonly', 'Freight Only', 0
	Union All
	SELECT @NewHeaderId, 'freighttype', 'Freight Type', 0
	Union All
	SELECT @NewHeaderId, 'freightshipvia', 'Fixed Ship Via', 0
	Union All
	SELECT @NewHeaderId, 'freightamount', 'Freight Amount', 0
	Union All
	SELECT @NewHeaderId, 'freightrate', 'Freight Rate', 0
	Union All
	SELECT @NewHeaderId, 'freightmiles', 'Freight Miles', 0
	Union All
	SELECT @NewHeaderId, 'freightprice', 'Freight in Price', 0
	Union All
	SELECT @NewHeaderId, 'freightunit', 'Minimum Units', 0

--Transport Freight Tab End







PRINT '---------- END DYNAMIC CSV DEFAULT DATA ----------'


SET IDENTITY_INSERT tblSMCSVDynamicImport  OFF

GO
SET NOCOUNT OFF


/*
--Test Data for Customer Special Taxing Import
Customer Entity No*,Tax Group*,Customer Location,Vendor No,Item Category,Item No
[failed ] 1005252,1241,124,124,124,124
[failed ] 1005252,1241,Fort Wayne,124,124,124
[failed ] 1005252,OR-Reedsport,Fort Wayne,124,124,124
[failed ] 1005252,OR-Reedsport,Fort Wayne,1005532,GAS,1234
[failed ] 1005252,OR-Reedsport,Fort Wayne,1005532,4213,87G
[failed ] 1005252,OR-Reedsport,Fort Wayne,1005532,GAS12,
[failed ] 1005252,OR-Reedsport,Fort Wayne,1005532,,1287G
[success] 1005252,OR-Reedsport,Fort Wayne,1005532,GAS,
[success] 1005252,OR-Reedsport,Fort Wayne,1005532,,87G
[success] 1005252,OR-Reedsport,Fort Wayne,1005532,GAS,87G


*/

/*
--TEST DATA Customer Master License Import

Customer Entity No*,License Code*,Begin Date,End Date,Comment,Active
[success] 1005252,Haz mat,1/1/2017,,Success,1
[success] 1005252,Haz mat,1/1/2017,3/1/2017,Success,0
[success] 1005252,Haz mat,,,,1
[failed ] 1005252,Haz mate,,,,1
[failed ] 05252,Haz mate,,,,1
[failed ] 1005252,Haz mat,9/1/2017,3/1/2017,Success,0
[failed ] 1005252,Haz mat,9/1/2017,3/1/2017,Success,1

*/