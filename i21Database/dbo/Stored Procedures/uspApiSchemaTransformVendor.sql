CREATE PROCEDURE [dbo].[uspApiSchemaTransformVendor]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

--SET DEFAULT VALUES
UPDATE tblApiSchemaVendor SET strType = 'Vendor' WHERE guiApiUniqueId = @guiApiUniqueId AND strType IS NULL
UPDATE tblApiSchemaVendor SET strVendorType = 'Company' WHERE guiApiUniqueId = @guiApiUniqueId AND strVendorType IS NULL

--VALIDATE
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strLogLevel, strStatus, strAction, intRowNo, strField, strValue, strMessage)
SELECT * FROM dbo.fnApiSchemaValidateVendor(@guiApiUniqueId, @guiLogId)

--TRANSFORM
IF NOT EXISTS(SELECT TOP 1 1 FROM tblApiImportLogDetail WHERE guiApiImportLogId = @guiLogId AND strStatus = 'Failed')
BEGIN
	IF OBJECT_ID('tempdb..#tmpApiSchemaVendor') IS NOT NULL DROP TABLE #tmpApiSchemaVendor
	SELECT * INTO #tmpApiSchemaVendor FROM tblApiSchemaVendor WHERE guiApiUniqueId = @guiApiUniqueId

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpApiSchemaVendor)
	BEGIN
		DECLARE @entityId INT
		DECLARE @entityContactId INT
		DECLARE @entityLocationId INT

		IF OBJECT_ID('tempdb..#tmpApiSchemaVendorTop') IS NOT NULL DROP TABLE #tmpApiSchemaVendorTop
		SELECT TOP 1 * INTO #tmpApiSchemaVendorTop FROM #tmpApiSchemaVendor

		--ENTITY
		INSERT INTO tblEMEntity(strEntityNo, strName, strWebsite, strContactNumber, strFax, strEmail, strTimezone)
		SELECT strEntityNo, strName, strWebsite, '', strFax, strEmail, strTimezone
		FROM #tmpApiSchemaVendorTop

		SET @entityId = SCOPE_IDENTITY()

		--ENTITY CONTACT
		INSERT INTO tblEMEntity(strName, strWebsite, strContactNumber, strFax, strEmail, strTimezone)
		SELECT strContactName, strWebsite, '', strFax, strEmail, strTimezone
		FROM #tmpApiSchemaVendorTop

		SET @entityContactId = SCOPE_IDENTITY()

		--ENTITY PHONE
		INSERT INTO tblEMEntityPhoneNumber(intEntityId, strPhone, intCountryId)
		SELECT @entityContactId, strContactNumber, NULL
		FROM #tmpApiSchemaVendorTop

		--ENTITY MOBILE
		INSERT INTO tblEMEntityMobileNumber(intEntityId, strPhone, intCountryId)
		SELECT @entityContactId, strMobile, NULL
		FROM #tmpApiSchemaVendorTop

		--ENTITY LOCATION
		INSERT INTO tblEMEntityLocation(intEntityId, strLocationName, strCheckPayeeName, strAddress, strCity, strState, strZipCode, strCountry, strTimezone, strPricingLevel, ysnDefaultLocation)
		SELECT @entityId, strLocationName, strName, strAddress, strCity, strState, strZipCode, strCountry, strTimezone, strPricingLevel, 1
		FROM #tmpApiSchemaVendorTop
			
		SET @entityLocationId = SCOPE_IDENTITY()

		--ENTITY CONTACT MAPPING
		INSERT INTO tblEMEntityToContact(intEntityId, intEntityContactId, intEntityLocationId, ysnPortalAccess, ysnDefaultContact)
		SELECT @entityId, @entityContactId, @entityLocationId, 0, 1

		--ENTITY TYPE
		INSERT INTO tblEMEntityType(intEntityId, strType, intConcurrencyId)
		SELECT @entityId, strType, 0
		FROM #tmpApiSchemaVendorTop

		--VENDOR
		INSERT INTO tblAPVendor(intEntityId, strVendorId, intGLAccountExpenseId, intVendorType, strTaxNumber, intTermsId, ysnWithholding, dblCreditLimit, guiApiUniqueId)
		SELECT @entityId, V.strVendorId, AD.intAccountId, VT.intVendorType, V.strTaxNumber, T.intTermID, 0, 0, @guiApiUniqueId
		FROM #tmpApiSchemaVendorTop V
		LEFT JOIN vyuGLAccountDetail AD ON AD.strAccountId = V.strExpenseAccountId AND AD.strAccountType = 'Expense'
		LEFT JOIN (
			SELECT 0 intVendorType, 'Company' strVendorType
			UNION ALL
			SELECT 1 intVendorType, 'Person' strVendorType
		) VT ON VT.strVendorType = V.strVendorType
		LEFT JOIN tblSMTerm T ON T.strTerm = V.strTerm

		--VENDOR TERMS
		INSERT INTO tblAPVendorTerm(intEntityVendorId, intTermId)
		SELECT @entityId, T.intTermID
		FROM #tmpApiSchemaVendorTop V
		LEFT JOIN tblSMTerm T ON T.strTerm = V.strTerm

		DELETE FROM #tmpApiSchemaVendor WHERE intKey IN (SELECT intKey FROM #tmpApiSchemaVendorTop)
	END
END