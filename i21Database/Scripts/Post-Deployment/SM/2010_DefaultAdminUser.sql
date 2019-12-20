PRINT 'START ADD DEFAULT IRELYADMIN USER'

declare @intEntityId INT; 
declare @intEntityContactId INT;
DECLARE @intEntityLocationId INT;

/***************************************************************************************************************************************************************************/
--ENTITY HERE
begin transaction
begin try

IF NOT EXISTS(SELECT TOP 1 1 FROM tblEMEntity WHERE strName = 'IRELY ADMIN')
AND (SELECT COUNT(*) FROM tblSMBuildNumber) = 1

	BEGIN
		INSERT [dbo].[tblEMEntity] ([strName], [strEmail], [strWebsite], [strInternalNotes], [ysnPrint1099], [str1099Name], [str1099Form], [str1099Type], [strFederalTaxId], [strStateTaxId], [dtmW9Signed], [imgPhoto], [strContactNumber], [strTitle], [strDepartment], [strMobile], [strPhone], [strPhone2], [strEmail2], [strFax], [strNotes], [strContactMethod], [strTimezone], [intLanguageId], [strEntityNo], [strContactType], [intDefaultLocationId], [ysnActive], [ysnReceiveEmail], [strEmailDistributionOption], [dtmOriginationDate], [strPhoneBackUp], [intDefaultCountryId], [strDocumentDelivery], [strNickName], [strSuffix], [intEntityClassId], [strExternalERPId], [intEntityRank], [strDateFormat], [strNumberFormat], [intCompanyId], [strFieldDelimiter], [intConcurrencyId])
		 VALUES 
		 (N'IRELY ADMIN', N'', N'', N'', 0, N'', N'', N'', N'', NULL, NULL, 0x, N'', N'', N'', N'', NULL, N'', N'', NULL, N'', N'', NULL, NULL, NULL, N'', NULL, 0, 0, N'', GETUTCDATE(), NULL, NULL, N'', N'', N'', NULL, N'', 1, N'M/d/yyyy', N'1,234,567.89', NULL, N'Comma', 1)
	
	SET @intEntityId = (SELECT SCOPE_IDENTITY())



--ITS CONTACT ENTITY

		INSERT [dbo].[tblEMEntity] ( [strName], [strEmail], [strWebsite], [strInternalNotes], [ysnPrint1099], [str1099Name], [str1099Form], [str1099Type], [strFederalTaxId], [strStateTaxId], [dtmW9Signed], [imgPhoto], [strContactNumber], [strTitle], [strDepartment], [strMobile], [strPhone], [strPhone2], [strEmail2], [strFax], [strNotes], [strContactMethod], [strTimezone], [intLanguageId], [strEntityNo], [strContactType], [intDefaultLocationId], [ysnActive], [ysnReceiveEmail], [strEmailDistributionOption], [dtmOriginationDate], [strPhoneBackUp], [intDefaultCountryId], [strDocumentDelivery], [strNickName], [strSuffix], [intEntityClassId], [strExternalERPId], [intEntityRank], [strDateFormat], [strNumberFormat], [intCompanyId], [strFieldDelimiter], [intConcurrencyId])
		 VALUES ( N'IRELY ADMIN', N'irelyadmin@irely.com', N'', N'', 0, N'', N'', N'', N'', NULL, NULL, 0x, N'', N'', N'', N'', N'', N'', N'', NULL, N'', N'', N'', NULL, N'', N'', NULL, 1, 0, N'', NULL, NULL, NULL, N'', N'', N'', NULL, N'', 1, NULL, NULL, NULL, N'Comma', 1)
	
	SET @intEntityContactId = (SELECT SCOPE_IDENTITY())




/***************************************************************************************************************************************************************************/

--ENTITY LOCATION
 
IF NOT EXISTS (SELECT TOP 1 1 FROM tblEMEntityLocation WHERE strLocationName = 'IRELY ADMIN') 
	AND EXISTS (SELECT TOP 1 1 FROM tblEMEntity WHERE intEntityId = @intEntityId)
INSERT [dbo].[tblEMEntityLocation] ([intEntityId],[strLocationName], [strAddress], [strCity], [strCountry], [strCounty], [strState], [strZipCode], [strPhone], [strFax], [strPricingLevel], [strNotes], [strOregonFacilityNumber], [intShipViaId], [intTermsId], [intWarehouseId], [ysnDefaultLocation], [intFreightTermId], [intCountyTaxCodeId], [intTaxGroupId], [intTaxClassId], [ysnActive], [dblLongitude], [dblLatitude], [strTimezone], [strCheckPayeeName], [intDefaultCurrencyId], [intVendorLinkId], [strLocationDescription], [strLocationType], [strFarmFieldNumber], [strFarmFieldDescription], [strFarmFSANumber], [strFarmSplitNumber], [strFarmSplitType], [dblFarmAcres], [imgFieldMapFile], [strFieldMapFile], [ysnPrint1099], [str1099Name], [str1099Form], [str1099Type], [strFederalTaxId], [dtmW9Signed], [strOriginLinkCustomer], [intConcurrencyId])
 VALUES (@intEntityId, N'IRELY ADMIN', N'', NULL, NULL, NULL, N'', N'', N'', N'', N'', N'', NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, 1, CAST(0.000000 AS Numeric(18, 6)), CAST(0.000000 AS Numeric(18, 6)), N'', N'IRELY ADMIN', NULL, NULL, NULL, N'Location', NULL, NULL, NULL, NULL, NULL, CAST(0.000000 AS Numeric(18, 6)), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'', 1)

 SET @intEntityLocationId = (SELECT SCOPE_IDENTITY())
/***************************************************************************************************************************************************************/

--ENTITY TO CONTACT



INSERT [dbo].[tblEMEntityToContact] ( [intEntityId], [intEntityContactId], [intEntityLocationId], [strUserType], [ysnPortalAccess], [ysnPortalAdmin], [ysnDefaultContact], [intEntityRoleId], [intConcurrencyId]) 
VALUES ( @intEntityId, @intEntityContactId, @intEntityLocationId, NULL, 0, 0, 1, NULL, 1)


/***************************************************************************************************************************************************************/
--ENTITY TYPE


	BEGIN
		INSERT [dbo].[tblEMEntityType] ([intEntityId], [strType], [intConcurrencyId]) VALUES (@intEntityId, N'User', 1)
	END


/*****************************************************************************************************************************************************************/

--ENTITY CREDENTIAL
DECLARE @strPassword nvarchar(max) = (select dbo.fnAESEncryptASym('i21By2015'))


	BEGIN
		INSERT [dbo].[tblEMEntityCredential] ( [intEntityId], [strUserName], [strPassword], [strApiKey], [strApiSecret], [ysnApiDisabled], [strTFASecretKey], [strTFACurrentCode], [strTFACodeNotifMedium], [ysnTFAEnabled], [ysnNotEncrypted], [strEmail], [ysnEmailConfirmed], [strPhone], [ysnPhoneConfirmed], [strSecurityStamp], [ysnTwoFactorEnabled], [dtmLockoutEndDateUtc], [ysnLockoutEnabled], [intAccessFailedCount], [intGridLayoutConcurrencyId], [intCompanyGridLayoutConcurrencyId], [intConcurrencyId])
		 VALUES (@intEntityId, N'irelyadmin',@strPassword , NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, 1, NULL, 1, @strPassword, 0, NULL, 0, 0, 1, 0, 1)
	END

/******************************************************************************************************************************************************************/
--USER ROLE

declare @intUserRoleId INT;

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMUserRole WHERE strName = 'IRELYADMIN')
	BEGIN
		INSERT [dbo].[tblSMUserRole] ( [strName], [strDescription], [strMenu], [strMenuPermission], [strForm], [strRoleType], [ysnAdmin], [intConcurrencyId])
		 VALUES ( N'IRELYADMIN', N'IRELYADMIN - USE FOR IRELY TESTING', N'', N'', NULL, N'Administrator', 1, 1)
		 
		 SET @intUserRoleId= (SELECT SCOPE_IDENTITY())
	END



/**********************************************************************************************************************************************************************/
--LOCATION
declare @intCompanyLocationId INT;
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCompanyLocation WHERE strLocationName = 'ADMIN LOCATION' )
	BEGIN
		INSERT [dbo].[tblSMCompanyLocation] ( [strLocationName], [strLocationNumber], [strLocationType])

		values ( N'ADMIN LOCATION', N'001', N'Office')
		set @intCompanyLocationId = (select SCOPE_IDENTITY())

	END

/***************************************************************************************************************************************************************************/


--SECURITY

declare @intSecurityPolicyId int = (select top 1 intSecurityPolicyId from tblSMSecurityPolicy)
declare @intUserSecurityId int;

	INSERT [dbo].[tblSMUserSecurity] ( [intUserRoleID], [intCompanyLocationId], [intSecurityPolicyId], [strUserName], [strJIRAUserName], [strFullName], [intEntityId])
	VALUES ( @intUserRoleId, @intCompanyLocationId, @intSecurityPolicyId, N'irelyadmin', N'', N'IRELY ADMIN',@intEntityId)



	insert into tblSMUserSecurityCompanyLocationRolePermission (intEntityUserSecurityId, intEntityId, intUserRoleId, intCompanyLocationId, intConcurrencyId)
		values(@intEntityId,@intEntityId,@intUserRoleId,@intCompanyLocationId,1)

	exec uspSMUpdateUserRoleMenus
			@UserRoleID = @intUserRoleId,
			@BuildUserRole = 1,
			@ForceVisibility = 1


END
end try
begin catch
rollback transaction
end catch
commit transaction

PRINT 'END ADD DEFAULT IRELYADMIN USER'