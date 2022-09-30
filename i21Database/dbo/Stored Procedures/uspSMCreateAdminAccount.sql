CREATE PROCEDURE [dbo].[uspSMCreateAdminAccount]
	@userName NVARCHAR(500),
	@password NVARCHAR(500),
	@name NVARCHAR(100),
	@email NVARCHAR(500),
	@entityId INT OUTPUT
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	BEGIN TRY
		
		
		DECLARE @transCount INT = @@TRANCOUNT
		DECLARE @error NVARCHAR(1000) = NULL
		

		IF @transCount = 0 BEGIN TRANSACTION

		--------------------------------------------------VALIDATION PROCESS--------------------------------------------------
		--check if all values are valid
		IF ISNULL(@userName, '') = ''
		BEGIN
			SET @error =  'Username is invalid.';
			RAISERROR(@error, 16, 1);
		END
		IF ISNULL(@password, '') = ''
		BEGIN
			SET @error =  'Password is invalid.';
			RAISERROR(@error, 16, 1);
			
		END
		IF ISNULL(@name, '') = ''
		BEGIN
			SET @error =  'Name is invalid.';
			RAISERROR(@error, 16, 1);
			
		END
		IF ISNULL(@email, '') = ''
		BEGIN
			SET @error =  'Email is invalid.';
			RAISERROR(@error, 16, 1);
			
		END
		--IF ISNULL(@email, '') NOT LIKE '%_@__%.__%'
		--BEGIN
		--	SET @error =  'Email format is invalid.';
		--	RAISERROR(@error, 16, 1);
			
		--END

		--check if email exists
		IF EXISTS(SELECT 1 FROM tblEMEntity WHERE strEmail = ISNULL(@email, ''))
		BEGIN
			SET @error =  'Email address already in use.';
			RAISERROR(@error, 16, 1);
			
		END

		--check if username exists
		IF EXISTS(SELECT 1 FROM tblSMUserSecurity WHERE strUserName = ISNULL(@userName, ''))
		BEGIN
			SET @error =  'Username already in use.';
			RAISERROR(@error, 16, 1);
			
		END


		------------------------------------------------SP PROCESS ONLY BEHIND THIS LINE------------------------------------------------
		DECLARE @intEntityId INT; 
		DECLARE @intEntityContactId INT;
		DECLARE @intEntityLocationId INT;

		--ENTITY HERE
		INSERT [dbo].[tblEMEntity] ([strName], [strEmail], [strWebsite], [strInternalNotes], [ysnPrint1099], [str1099Name], [str1099Form], [str1099Type], [strFederalTaxId], [strStateTaxId], [dtmW9Signed], [imgPhoto], [strContactNumber], [strTitle], [strDepartment], [strMobile], [strPhone], [strPhone2], [strEmail2], [strFax], [strNotes], [strContactMethod], [strTimezone], [intLanguageId], [strEntityNo], [strContactType], [intDefaultLocationId], [ysnActive], [ysnReceiveEmail], [strEmailDistributionOption], [dtmOriginationDate], [strPhoneBackUp], [intDefaultCountryId], [strDocumentDelivery], [strNickName], [strSuffix], [intEntityClassId], [strExternalERPId], [intEntityRank], [strDateFormat], [strNumberFormat], [intCompanyId], [strFieldDelimiter], [intConcurrencyId])
			VALUES 
			(@name, N'', N'', N'', 0, N'', N'', N'', N'', NULL, NULL, 0x, N'', N'', N'', N'', NULL, N'', N'', NULL, N'', N'', NULL, NULL, NULL, N'', NULL, 0, 0, N'', GETUTCDATE(), NULL, NULL, N'', N'', N'', NULL, N'', 1, N'M/d/yyyy', N'1,234,567.89', NULL, N'Comma', 1)
	
		SET @intEntityId = (SELECT SCOPE_IDENTITY())


		--ITS CONTACT ENTITY
		INSERT [dbo].[tblEMEntity] ( [strName], [strEmail], [strWebsite], [strInternalNotes], [ysnPrint1099], [str1099Name], [str1099Form], [str1099Type], [strFederalTaxId], [strStateTaxId], [dtmW9Signed], [imgPhoto], [strContactNumber], [strTitle], [strDepartment], [strMobile], [strPhone], [strPhone2], [strEmail2], [strFax], [strNotes], [strContactMethod], [strTimezone], [intLanguageId], [strEntityNo], [strContactType], [intDefaultLocationId], [ysnActive], [ysnReceiveEmail], [strEmailDistributionOption], [dtmOriginationDate], [strPhoneBackUp], [intDefaultCountryId], [strDocumentDelivery], [strNickName], [strSuffix], [intEntityClassId], [strExternalERPId], [intEntityRank], [strDateFormat], [strNumberFormat], [intCompanyId], [strFieldDelimiter], [intConcurrencyId])
			VALUES ( @name, @email, N'', N'', 0, N'', N'', N'', N'', NULL, NULL, 0x, N'', N'', N'', N'', N'', N'', N'', NULL, N'', N'', N'', NULL, N'', N'', NULL, 1, 0, N'', NULL, NULL, NULL, N'', N'', N'', NULL, N'', 1, NULL, NULL, NULL, N'Comma', 1)
	
		SET @intEntityContactId = (SELECT SCOPE_IDENTITY())


		--ENTITY LOCATION
		INSERT [dbo].[tblEMEntityLocation] ([intEntityId],[strLocationName], [strAddress], [strCity], [strCountry], [strCounty], [strState], [strZipCode], [strPhone], [strFax], [strPricingLevel], [strNotes], [strOregonFacilityNumber], [intShipViaId], [intTermsId], [intWarehouseId], [ysnDefaultLocation], [intFreightTermId], [intCountyTaxCodeId], [intTaxGroupId], [intTaxClassId], [ysnActive], [dblLongitude], [dblLatitude], [strTimezone], [strCheckPayeeName], [intDefaultCurrencyId], [intVendorLinkId], [strLocationDescription], [strLocationType], [strFarmFieldNumber], [strFarmFieldDescription], [strFarmFSANumber], [strFarmSplitNumber], [strFarmSplitType], [dblFarmAcres], [imgFieldMapFile], [strFieldMapFile], [ysnPrint1099], [str1099Name], [str1099Form], [str1099Type], [strFederalTaxId], [dtmW9Signed], [strOriginLinkCustomer], [intConcurrencyId])
				VALUES (@intEntityId, @name, N'', NULL, NULL, NULL, N'', N'', N'', N'', N'', N'', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, 1, CAST(0.000000 AS Numeric(18, 6)), CAST(0.000000 AS Numeric(18, 6)), N'', N'IRELY ADMIN', NULL, NULL, NULL, N'Location', NULL, NULL, NULL, NULL, NULL, CAST(0.000000 AS Numeric(18, 6)), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'', 1)

		SET @intEntityLocationId = (SELECT SCOPE_IDENTITY())

		--ENTITY TO CONTACT
		INSERT [dbo].[tblEMEntityToContact] ( [intEntityId], [intEntityContactId], [intEntityLocationId], [strUserType], [ysnPortalAccess], [ysnPortalAdmin], [ysnDefaultContact], [intEntityRoleId], [intConcurrencyId]) 
		VALUES ( @intEntityId, @intEntityContactId, @intEntityLocationId, NULL, 0, 0, 1, NULL, 1)


		--ENTITY TYPE
		BEGIN
			INSERT [dbo].[tblEMEntityType] ([intEntityId], [strType], [intConcurrencyId]) VALUES (@intEntityId, N'User', 1)
		END

		--ENTITY CREDENTIAL
		DECLARE @strPassword nvarchar(max) = (select dbo.fnAESEncryptASym(@password))
		BEGIN
			INSERT [dbo].[tblEMEntityCredential] ( [intEntityId], [strUserName], [strPassword], [strApiKey], [strApiSecret], [ysnApiDisabled], [strTFASecretKey], [strTFACurrentCode], [strTFACodeNotifMedium], [ysnTFAEnabled], [ysnNotEncrypted], [strEmail], [ysnEmailConfirmed], [strPhone], [ysnPhoneConfirmed], [strSecurityStamp], [ysnTwoFactorEnabled], [dtmLockoutEndDateUtc], [ysnLockoutEnabled], [intAccessFailedCount], [intGridLayoutConcurrencyId], [intCompanyGridLayoutConcurrencyId], [intConcurrencyId])
				VALUES (@intEntityId, @userName, @strPassword , NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, 1, NULL, 1, @strPassword, 0, NULL, 0, 0, 1, 0, 1)
		END

		--USER ROLE
		declare @intUserRoleId INT;
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMUserRole WHERE strName = 'ADMINISTRATOR')
		BEGIN
			INSERT [dbo].[tblSMUserRole] ( [strName], [strDescription], [strMenu], [strMenuPermission], [strForm], [strRoleType], [ysnAdmin], [intConcurrencyId])
				VALUES ( N'ADMINISTRATOR', N'ADMINISTRATOR - USE FOR IRELY TESTING', N'', N'', NULL, N'Administrator', 1, 1)
		 
				SET @intUserRoleId = (SELECT SCOPE_IDENTITY())
		END
		ELSE
		BEGIN
			SELECT TOP 1 @intUserRoleId = intUserRoleID FROM tblSMUserRole WHERE strName = 'ADMINISTRATOR'
		END

		--LOCATION
		declare @intCompanyLocationId INT;
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCompanyLocation WHERE strLocationNumber = '001' )
		BEGIN
			INSERT [dbo].[tblSMCompanyLocation] ( [strLocationName], [strLocationNumber], [strLocationType])

			values ( N'ADMIN LOCATION', N'001', N'Office')
			set @intCompanyLocationId = (select SCOPE_IDENTITY())
		END
		BEGIN
			SELECT TOP 1 @intCompanyLocationId = intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber = '001'
		END

		--SECURITY
		declare @intSecurityPolicyId int = (select top 1 intSecurityPolicyId from tblSMSecurityPolicy)
		declare @intUserSecurityId int;

		INSERT [dbo].[tblSMUserSecurity] ( [intUserRoleID], [intCompanyLocationId], [intSecurityPolicyId], [strUserName], [strJIRAUserName], [strFullName], [intEntityId], [ysnAdmin])
		VALUES ( @intUserRoleId, @intCompanyLocationId, @intSecurityPolicyId, @userName, N'', @name, @intEntityId, 1)

		insert into tblSMUserSecurityCompanyLocationRolePermission (intEntityUserSecurityId, intEntityId, intUserRoleId, intCompanyLocationId, intConcurrencyId)
			values(@intEntityId,@intEntityId,@intUserRoleId,@intCompanyLocationId,1)

		exec uspSMUpdateUserRoleMenus
				@UserRoleID = @intUserRoleId,
				@BuildUserRole = 1,
				@ForceVisibility = 1

		SET @entityId = @intEntityId

		IF @transCount = 0 COMMIT TRANSACTION


	END TRY
	BEGIN CATCH
		DECLARE @ErrorSeverity INT,
				@ErrorNumber   INT,
				@ErrorMessage nvarchar(4000),
				@ErrorState INT,
				@ErrorLine  INT,
				@ErrorProc nvarchar(200);

		-- Grab error information from SQL functions
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorNumber   = ERROR_NUMBER()
		SET @ErrorMessage  = ERROR_MESSAGE()
		SET @ErrorState    = ERROR_STATE()
		SET @ErrorLine     = ERROR_LINE()

		IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION

		SET @error = @ErrorMessage;
		RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
		
	END CATCH
END