CREATE FUNCTION [dbo].[fnApiSchemaValidateVendorLocation]
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
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, VL.intRowNumber, 'Entity No.', VL.strEntityNo, 'Entity No. is not valid'
	FROM tblApiSchemaVendorLocation VL
	LEFT JOIN tblEMEntity E ON E.strEntityNo = VL.strEntityNo
	OUTER APPLY vyuAPGuidGenerator 
	WHERE VL.guiApiUniqueId = @guiApiUniqueId AND E.intEntityId IS NULL

	--strLocationName
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, intRowNumber, 'Location Name', strLocationName, 'Location Name is required'
	FROM tblApiSchemaVendorLocation
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND strLocationName IS NULL

	--strPricingLevel
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, intRowNumber, 'Pricing Level',  strPricingLevel, 'Pricing Level is not valid'
	FROM tblApiSchemaVendorLocation
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND (NULLIF(strPricingLevel, '') IS NOT NULL AND strPricingLevel NOT IN ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20'))

	--strShipVia
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, VL.intRowNumber, 'Ship Via', VL.strShipVia, 'Ship Via is not valid'
	FROM tblApiSchemaVendorLocation VL
	LEFT JOIN tblSMShipVia SV ON SV.strShipVia = VL.strShipVia
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND (NULLIF(VL.strShipVia, '') IS NOT NULL AND SV.intEntityId IS NULL)

	--strTerm
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, VL.intRowNumber, 'Terms', VL.strTerm, 'Terms is not valid'
	FROM tblApiSchemaVendorLocation VL
	LEFT JOIN tblSMTerms T ON T.strTerm = VL.strTerm
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND (NULLIF(VL.strTerm, '') IS NOT NULL AND T.intTermID IS NULL)

	--strWarehouseName
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, VL.intRowNumber, 'Warehouse', VL.strWarehouseName, 'Warehouse is not valid'
	FROM tblApiSchemaVendorLocation VL
	LEFT JOIN tblSMCompanyLocation CL ON CL.strLocationName = VL.strWarehouseName
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND (NULLIF(VL.strWarehouseName, '') IS NOT NULL AND CL.intCompanyLocationId IS NULL)

	--strFreightTerm
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, VL.intRowNumber, 'Freight Terms', VL.strFreightTerm, 'Freight Terms is not valid'
	FROM tblApiSchemaVendorLocation VL
	LEFT JOIN tblSMFreightTerms FT ON FT.strFreightTerm = VL.strFreightTerm
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND (NULLIF(VL.strFreightTerm, '') IS NOT NULL AND FT.intFreightTermId IS NULL)

	--strTaxCode
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, VL.intRowNumber, 'Tax Code', VL.strTaxCode, 'Tax Code is not valid'
	FROM tblApiSchemaVendorLocation VL
	LEFT JOIN tblSMTaxCode TC ON TC.strTaxCode = VL.strTaxCode
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND (NULLIF(VL.strTaxCode, '') IS NOT NULL AND TC.intTaxCodeId IS NULL)

	--strTaxGroup
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, VL.intRowNumber, 'Tax Group', VL.strTaxGroup, 'Tax Group is not valid'
	FROM tblApiSchemaVendorLocation VL
	LEFT JOIN tblSMTaxGroup TG ON TG.strTaxGroup = VL.strTaxGroup
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND (NULLIF(VL.strTaxGroup, '') IS NOT NULL AND TG.intTaxGroupId IS NULL)

	--strTaxClass
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, VL.intRowNumber, 'Tax Class', VL.strTaxClass, 'Tax Class is not valid'
	FROM tblApiSchemaVendorLocation VL
	LEFT JOIN tblSMTaxClass TC ON TC.strTaxClass = VL.strTaxClass
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND (NULLIF(VL.strTaxClass, '') IS NOT NULL AND TC.intTaxClassId IS NULL)

	--strCheckPayeeName
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, intRowNumber, 'Printed Name', strCheckPayeeName, 'Printed Name is required'
	FROM tblApiSchemaVendorLocation
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND NULLIF(strCheckPayeeName, '') IS NULL

	--strCurrency
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, VL.intRowNumber, 'Currency', VL.strCurrency, 'Currency is not valid'
	FROM tblApiSchemaVendorLocation VL
	LEFT JOIN tblSMCurrency C ON C.strCurrency = VL.strCurrency
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND (NULLIF(VL.strCurrency, '') IS NOT NULL AND C.intCurrencyID IS NULL)

	--strVendorLink
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, VL.intRowNumber, 'Vendor Link', VL.strVendorLink, 'Vendor Link is not valid'
	FROM tblApiSchemaVendorLocation VL
	LEFT JOIN tblAPVendor V ON V.strVendorId = VL.strVendorLink
	OUTER APPLY vyuAPGuidGenerator 
	WHERE VL.guiApiUniqueId = @guiApiUniqueId AND (NULLIF(VL.strVendorLink, '') IS NOT NULL AND V.intEntityId IS NULL)

	--str1099Form
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, intRowNumber, '1099 Form',  str1099Form, '1099 Form is not valid'
	FROM tblApiSchemaVendorLocation
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND (NULLIF(str1099Form, '') IS NOT NULL AND str1099Form NOT IN ('None', '1099-MISC', '1099-INT', '1099-B', '1099-PATR', '1099-DIV', '1099-K', '1099-NEC'))

	--str1099Type
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, VL.intRowNumber, '1099 Type', VL.str1099Type, '1099 Type is not valid'
	FROM tblApiSchemaVendorLocation VL
	LEFT JOIN tblAP1099DIVCategory C ON C.strCategory = VL.str1099Type
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND (NULLIF(VL.str1099Type, '') IS NOT NULL AND C.int1099CategoryId IS NULL)
	
	RETURN
END