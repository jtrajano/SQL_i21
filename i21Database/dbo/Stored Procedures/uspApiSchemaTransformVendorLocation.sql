CREATE PROCEDURE [dbo].[uspApiSchemaTransformVendorLocation]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

--SET DEFAULT VALUES
UPDATE tblApiSchemaVendorLocation
SET dblFarmAcres = ISNULL(dblFarmAcres, 0)
	, ysnActive = ISNULL(ysnActive, 1)
	, dblLongitude = ISNULL(dblLongitude, 0)
	, dblLatitude = ISNULL(dblLatitude, 0)
	, strLocationType = ISNULL(strLocationType, 'Location')
WHERE guiApiUniqueId = @guiApiUniqueId

--VALIDATE
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strLogLevel, strStatus, strAction, intRowNo, strField, strValue, strMessage)
SELECT * FROM dbo.fnApiSchemaValidateVendorLocation(@guiApiUniqueId, @guiLogId)

--TRANSFORM
INSERT INTO tblEMEntityLocation (
	intEntityId,
	strLocationName,
	strAddress,
	strCity,
	strCountry,
	strCounty,
	strState,
	strZipCode,
	strPhone,
	strFax,
	strPricingLevel,
	strNotes,
	strOregonFacilityNumber,
	intShipViaId,
	intTermsId,
	intWarehouseId,
	intFreightTermId,
	intCountyTaxCodeId,
	intTaxGroupId,
	intTaxClassId,
	ysnActive,
	dblLongitude,
	dblLatitude,
	strTimezone,
	strCheckPayeeName,
	intDefaultCurrencyId,
	intVendorLinkId,
	strLocationDescription,
	strLocationType,
	strFarmFieldNumber,
	strFarmFieldDescription,
	strFarmFSANumber,
	strFarmSplitNumber,
	strFarmSplitType,
	dblFarmAcres,
	ysnPrint1099,
	str1099Name,
	str1099Form,
	str1099Type,
	strFederalTaxId,
	dtmW9Signed,
	guiApiUniqueId,
	intRowNumber
)
SELECT E.intEntityId, 
	VL.strLocationName,
	VL.strAddress,
	VL.strCity,
	VL.strCountry,
	VL.strCounty,
	VL.strState,
	VL.strZipCode,
	VL.strPhone,
	VL.strFax,
	VL.strPricingLevel,
	VL.strNotes,
	VL.strOregonFacilityNumber,
	SV.intEntityId,
	T.intTermID,
	CL.intCompanyLocationId,
	FT.intFreightTermId,
	TC.intTaxCodeId,
	TG.intTaxGroupId,
	TC2.intTaxClassId,
	VL.ysnActive,
	VL.dblLongitude,
	VL.dblLatitude,
	VL.strTimezone,
	VL.strCheckPayeeName,
	C.intCurrencyID,
	v.intEntityId,
	VL.strLocationDescription,
	VL.strLocationType,
	VL.strFarmFieldNumber,
	VL.strFarmFieldDescription,
	VL.strFarmFSANumber,
	VL.strFarmSplitNumber,
	VL.strFarmSplitType,
	VL.dblFarmAcres,
	VL.ysnPrint1099,
	VL.str1099Name,
	VL.str1099Form,
	VL.str1099Type,
	VL.strFederalTaxId,
	VL.dtmW9Signed,
	@guiApiUniqueId,
	VL.intRowNumber
FROM tblApiSchemaVendorLocation VL
LEFT JOIN tblEMEntity E ON E.strEntityNo = VL.strEntityNo
LEFT JOIN tblSMShipVia SV ON SV.strShipVia = VL.strShipVia
LEFT JOIN tblSMTerm T ON T.strTerm = VL.strTerm
LEFT JOIN tblSMCompanyLocation CL ON CL.strLocationName = VL.strWarehouseName
LEFT JOIN tblSMFreightTerms FT ON FT.strFreightTerm = VL.strFreightTerm
LEFT JOIN tblSMTaxCode TC ON TC.strTaxCode = VL.strTaxCode
LEFT JOIN tblSMTaxGroup TG ON TG.strTaxGroup = VL.strTaxGroup
LEFT JOIN tblSMTaxClass TC2 ON TC2.strTaxClass = VL.strTaxClass
LEFT JOIN tblSMCurrency C ON C.strCurrency = VL.strCurrency
LEFT JOIN tblAPVendor v ON v.strVendorId = VL.strVendorLink
WHERE VL.guiApiUniqueId = @guiApiUniqueId
	AND NOT EXISTS(SELECT TOP 1 1 FROM tblApiImportLogDetail xd WHERE xd.guiApiImportLogId = @guiLogId AND xd.intRowNo = VL.intRowNumber AND xd.strStatus = 'Failed')
	AND NOT EXISTS(
		SELECT TOP 1 1 
		FROM tblEMEntityLocation xel
		JOIN vyuAPVendor xv ON xv.intEntityId = xel.intEntityId
		WHERE xv.strVendorId = VL.strEntityNo
			AND xel.strLocationName = VL.strLocationName
	)

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Location Name')
    , strValue = vs.strLocationName
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = vs.intRowNumber
    , strMessage = 'The "' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Location Name') + '" ' + ISNULL(vs.strLocationName, '') + ' was imported successfully.'
    , strAction = 'Create'
FROM tblApiSchemaVendorLocation vs
JOIN vyuAPVendor v ON v.strVendorId = vs.strEntityNo
JOIN tblEMEntityLocation el ON el.strLocationName = vs.strLocationName
	AND el.intEntityId = v.intEntityId
WHERE el.guiApiUniqueId = @guiApiUniqueId

UPDATE log
SET log.intTotalRowsImported = r.intCount
FROM tblApiImportLog log
CROSS APPLY (
	SELECT COUNT(*) intCount
	FROM tblEMEntityLocation
	WHERE guiApiUniqueId = log.guiApiUniqueId
) r
WHERE log.guiApiImportLogId = @guiLogId