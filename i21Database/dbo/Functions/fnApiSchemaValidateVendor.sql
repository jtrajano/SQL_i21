CREATE FUNCTION [dbo].[fnApiSchemaValidateVendor]
(
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
)
RETURNS @returntable TABLE
(
	guiApiImportLogDetailId UNIQUEIDENTIFIER NOT NULL,
	guiApiImportLogId UNIQUEIDENTIFIER NOT NULL,
	strLogLevel NVARCHAR(100) NOT NULL,
	strStatus NVARCHAR(150) NOT NULL,
	strAction NVARCHAR(150) NULL,
	intRowNumber INT NULL,
	strField NVARCHAR(100) NULL,
	strValue NVARCHAR(4000) NULL,
	strMessage NVARCHAR(4000) NULL
)
AS
BEGIN
	--strEntityNo
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, intRowNumber, 'Entity No.', strEntityNo, 'Entity No. is required'
	FROM tblApiSchemaVendor
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND NULLIF(strEntityNo, '') IS NULL

	--strName
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, intRowNumber, 'Entity Name', strName, 'Entity Name is required'
	FROM tblApiSchemaVendor
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND NULLIF(strName, '') IS NULL

	--strContactNumber
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, intRowNumber, 'Entity Contact Number', strContactNumber, 'Entity Contact Number is required'
	FROM tblApiSchemaVendor
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND NULLIF(strContactNumber, '') IS NULL

	--strContactName
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, intRowNumber, 'Entity Name', strContactName, 'Entity Contact is required'
	FROM tblApiSchemaVendor
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND NULLIF(strContactName, '') IS NULL

	--strLocationName
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, intRowNumber, 'Location Name', strLocationName, 'Location Name is required'
	FROM tblApiSchemaVendor
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND NULLIF(strLocationName, '') IS NULL

	--strCountry
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, V.intRowNumber, 'Country', V.strCountry, 'Country is not valid'
	FROM tblApiSchemaVendor V
	LEFT JOIN tblSMCountry C ON C.strCountry = V.strCountry
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND (NULLIF(V.strCountry, '') IS NOT NULL AND C.intCountryID IS NULL)

	--strType
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, intRowNumber, 'Entity Type', strType, 'Entity Type is not valid'
	FROM tblApiSchemaVendor
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND (NULLIF(strType, '') IS NULL OR strType <> 'Vendor')

	--strVendorId
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, intRowNumber, 'Vendor No.', strVendorId, 'Vendor No. is required'
	FROM tblApiSchemaVendor
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND NULLIF(strVendorId, '') IS NULL

	--strExpenseAccountId
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, V.intRowNumber, 'Expense Account', V.strExpenseAccountId, 'Expense Account is not valid'
	FROM tblApiSchemaVendor V
	LEFT JOIN vyuGLAccountDetail AD ON AD.strAccountId = V.strExpenseAccountId AND AD.strAccountCategory NOT IN ('Cash Account', 'AP Account', 'AR Account', 'Inventory', 'Inventory In-Transit', 'Inventory Adjustment') AND AD.ysnActive = 1
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND (NULLIF(V.strExpenseAccountId, '') IS NOT NULL AND AD.intAccountId IS NULL)

	--strVendorType
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, intRowNumber, 'Vendor Type', strVendorType, 'Vendor Type is not valid'
	FROM tblApiSchemaVendor
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND (strVendorType <> 'Company' AND strVendorType <> 'Person')

	--strTerm
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, V.intRowNumber, 'Term', V.strTerm, 'Term is not valid'
	FROM tblApiSchemaVendor V
	LEFT JOIN tblSMTerm T ON T.strTerm = V.strTerm
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND (NULLIF(V.strTerm, '') IS NOT NULL AND T.intTermID IS NULL)
	
	RETURN
END