CREATE PROCEDURE [dbo].[uspApiSchemaTransformVendorLocation]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

--SET DEFAULT VALUES
UPDATE tblApiSchemaVendorLocation SET ysnActive = 1 WHERE guiApiUniqueId = @guiApiUniqueId AND ysnActive IS NULL
UPDATE tblApiSchemaVendorLocation SET dblLongitude = 0 WHERE guiApiUniqueId = @guiApiUniqueId AND dblLongitude IS NULL
UPDATE tblApiSchemaVendorLocation SET dblLatitude = 0 WHERE guiApiUniqueId = @guiApiUniqueId AND dblLatitude IS NULL
UPDATE tblApiSchemaVendorLocation SET strLocationType = 'Location' WHERE guiApiUniqueId = @guiApiUniqueId AND strLocationType IS NULL
UPDATE tblApiSchemaVendorLocation SET dblFarmAcres = 0 WHERE guiApiUniqueId = @guiApiUniqueId AND dblFarmAcres IS NULL

--VALIDATE
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strLogLevel, strStatus, strAction, intRowNo, strField, strValue, strMessage)
SELECT * FROM dbo.fnApiSchemaValidateVendorLocation(@guiApiUniqueId, @guiLogId)

--TRANSFORM
IF NOT EXISTS(SELECT TOP 1 1 FROM tblApiImportLogDetail WHERE guiApiImportLogId = @guiLogId AND strStatus = 'Failed')
BEGIN
	IF OBJECT_ID('tempdb..#tmpApiSchemaVendorLocation') IS NOT NULL DROP TABLE #tmpApiSchemaVendorLocation
	SELECT * INTO #tmpApiSchemaVendorLocation FROM tblApiSchemaVendorLocation WHERE guiApiUniqueId = @guiApiUniqueId

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpApiSchemaVendorLocation)
	BEGIN
		IF OBJECT_ID('tempdb..#tmpApiSchemaVendorLocationTop') IS NOT NULL DROP TABLE #tmpApiSchemaVendorLocationTop
		SELECT TOP 1 * INTO #tmpApiSchemaVendorLocationTop FROM #tmpApiSchemaVendorLocation

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
			guiApiUniqueId
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
			   V.intEntityId,
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
			   @guiApiUniqueId
		FROM #tmpApiSchemaVendorLocationTop VL
		INNER JOIN tblEMEntity E ON E.strEntityNo = VL.strEntityNo
		INNER JOIN tblSMShipVia SV ON SV.strShipVia = VL.strShipVia
		INNER JOIN tblSMTerms T ON T.strTerm = VL.strTerm
		INNER JOIN tblSMCompanyLocation CL ON CL.strLocationName = VL.strWarehouseName
		INNER JOIN tblSMFreightTerms FT ON FT.strFreightTerm = VL.strFreightTerm
		INNER JOIN tblSMTaxCode TC ON TC.strTaxCode = VL.strTaxCode
		INNER JOIN tblSMTaxGroup TG ON TG.strTaxGroup = VL.strTaxGroup
		INNER JOIN tblSMTaxClass TC2 ON TC2.strTaxClass = VL.strTaxClass
		INNER JOIN tblSMCurrency C ON C.strCurrency = VL.strCurrency
		INNER JOIN tblAPVendor V ON V.strVendorId = VL.strVendorLink

		DELETE FROM #tmpApiSchemaVendorLocation WHERE intKey IN (SELECT intKey FROM #tmpApiSchemaVendorLocationTop)
	END
END