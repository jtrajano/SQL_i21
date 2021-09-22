CREATE PROCEDURE [dbo].[uspApiSchemaTransformVendor]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

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
		INSERT INTO tblEMEntity(strEntityNo, strName, strWebsite, strContactNumber, strMobile, strFax, strEmail, strTimezone)
		SELECT strEntityNo, strName, strWebsite, strContactNumber, strMobile, strFax, strEmail, strTimezone
		FROM #tmpApiSchemaVendorTop

		SET @entityId = SCOPE_IDENTITY()

		--ENTITY CONTACT
		INSERT INTO tblEMEntity(strEntityNo, strName, strWebsite, strContactNumber, strMobile, strFax, strEmail, strTimezone)
		SELECT strEntityNo, strContactName, strWebsite, strContactNumber, strMobile, strFax, strEmail, strTimezone
		FROM #tmpApiSchemaVendorTop

		SET @entityContactId = SCOPE_IDENTITY()

		--ENTITY LOCATION
		INSERT INTO tblEMEntityLocation(intEntityId, strLocationName, strAddress, strCity, strState, strZipCode, strCountry, strTimezone, strPricingLevel, ysnDefaultLocation)
		SELECT @entityId, strLocationName, strAddress, strCity, strState, strZipCode, strCountry, strTimezone, strPricingLevel, 1
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
		INSERT INTO tblAPVendor(intEntityId, strVendorId, intGLAccountExpenseId, intVendorType, strTaxNumber, intTermsId, ysnWithholding, dblCreditLimit)
		SELECT @entityId, V.strVendorId, AD.intAccountId, VT.intVendorType, V.strTaxNumber, T.intTermID, 0, 0
		FROM #tmpApiSchemaVendorTop V
		LEFT JOIN vyuGLAccountDetail AD ON AD.strAccountId = V.strExpenseAccountId AND AD.strAccountType = 'Expense'
		LEFT JOIN (
			SELECT 0 intVendorType, 'Company' strVendorType
			UNION ALL
			SELECT 1 intVendorType, 'Person' strVendorType
		) VT ON VT.strVendorType = V.strVendorType
		LEFT JOIN tblSMTerm T ON T.strTerm = V.strTerm

		DELETE FROM #tmpApiSchemaVendor WHERE intKey IN (SELECT intKey FROM #tmpApiSchemaVendorTop)
	END
END