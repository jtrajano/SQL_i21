CREATE FUNCTION [dbo].[fnApiSchemaValidateVendorPricing]
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
	--strVendorId
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, VP.intRowNumber, 'Vendor No.', VP.strVendorId, 'Vendor No. is not valid'
	FROM tblApiSchemaVendorPricing VP
	LEFT JOIN tblAPVendor V ON V.strVendorId = VP.strVendorId
	OUTER APPLY vyuAPGuidGenerator 
	WHERE VP.guiApiUniqueId = @guiApiUniqueId AND V.intEntityId IS NULL

	--strLocationName
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, VP.intRowNumber, 'Location Name', VP.strLocationName, 'Location Name is not valid'
	FROM tblApiSchemaVendorPricing VP
	INNER JOIN tblAPVendor V ON V.strVendorId = VP.strVendorId
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = V.intEntityId AND EL.strLocationName = VP.strLocationName
	OUTER APPLY vyuAPGuidGenerator 
	WHERE VP.guiApiUniqueId = @guiApiUniqueId AND EL.intEntityLocationId IS NULL

	--strItemNo
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, VP.intRowNumber, 'Item No.', VP.strItemNo, 'Item No. is not valid'
	FROM tblApiSchemaVendorPricing VP
	LEFT JOIN tblICItem I ON I.strItemNo = VP.strItemNo
	OUTER APPLY vyuAPGuidGenerator 
	WHERE VP.guiApiUniqueId = @guiApiUniqueId AND I.intItemId IS NULL

	--strUnitMeasure
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, VP.intRowNumber, 'Item UOM', VP.strUnitMeasure, 'Item UOM is not valid'
	FROM tblApiSchemaVendorPricing VP
	INNER JOIN tblICItem I ON I.strItemNo = VP.strItemNo
	LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = VP.strUnitMeasure
	LEFT JOIN tblICItemUOM IU ON IU.intItemId = I.intItemId AND IU.intUnitMeasureId = UM.intUnitMeasureId
	OUTER APPLY vyuAPGuidGenerator 
	WHERE VP.guiApiUniqueId = @guiApiUniqueId AND IU.intItemUOMId IS NULL

	--dblPrice
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, intRowNumber, 'Price', dblPrice, 'Price is required'
	FROM tblApiSchemaVendorPricing
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND dblPrice IS NULL

	--strCurrency
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, VP.intRowNumber, 'Currency', VP.strCurrency, 'Currency is not valid'
	FROM tblApiSchemaVendorPricing VP
	LEFT JOIN tblSMCurrency C ON C.strCurrency = VP.strCurrency
	OUTER APPLY vyuAPGuidGenerator 
	WHERE VP.guiApiUniqueId = @guiApiUniqueId AND C.intCurrencyID IS NULL

	--dtmBeginDate
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, intRowNumber, 'Begin Date', dtmBeginDate, 'Begin Date is required'
	FROM tblApiSchemaVendorPricing
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND dtmBeginDate IS NULL

	--dtmEndDate
	INSERT @returntable
	SELECT strNewId, @guiLogId, 'Error', 'Failed', NULL, intRowNumber, 'End Date', dtmEndDate, 'End Date is required'
	FROM tblApiSchemaVendorPricing
	OUTER APPLY vyuAPGuidGenerator 
	WHERE guiApiUniqueId = @guiApiUniqueId AND dtmEndDate IS NULL
	
	RETURN
END