﻿CREATE PROCEDURE [dbo].[uspApiSchemaTransformVendorLocation]
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
		LEFT JOIN tblEMEntity E ON E.strEntityNo = VL.strEntityNo
		LEFT JOIN tblSMShipVia SV ON SV.strShipVia = VL.strShipVia
		LEFT JOIN tblSMTerm T ON T.strTerm = VL.strTerm
		LEFT JOIN tblSMCompanyLocation CL ON CL.strLocationName = VL.strWarehouseName
		LEFT JOIN tblSMFreightTerms FT ON FT.strFreightTerm = VL.strFreightTerm
		LEFT JOIN tblSMTaxCode TC ON TC.strTaxCode = VL.strTaxCode
		LEFT JOIN tblSMTaxGroup TG ON TG.strTaxGroup = VL.strTaxGroup
		LEFT JOIN tblSMTaxClass TC2 ON TC2.strTaxClass = VL.strTaxClass
		LEFT JOIN tblSMCurrency C ON C.strCurrency = VL.strCurrency
		LEFT JOIN tblAPVendor V ON V.strVendorId = VL.strVendorLink

		DECLARE @ysnDefaultPayTo AS BIT = 0, @ysnDefaultShipFrom AS BIT = 0

		SELECT @ysnDefaultPayTo = ysnDefaultPayTo   
		,@ysnDefaultShipFrom = ysnDefaultShipFrom     
		FROM #tmpApiSchemaVendorLocationTop  
		
		IF (@ysnDefaultPayTo = 1 OR @ysnDefaultShipFrom = 1)
			BEGIN  
			UPDATE tblAPVendor SET intBillToId = intDefaultPayTo, intShipFromId = intDefaultShipFrom  
			FROM tblAPVendor v INNER JOIN (  
				SELECT el.intEntityId, vl.strEntityNo  
				,CASE WHEN ISNULL(@ysnDefaultPayTo, 0) = 1 THEN el.intEntityLocationId ELSE v.intBillToId END [intDefaultPayTo]  
				,CASE WHEN ISNULL(@ysnDefaultShipFrom, 0) = 1 THEN el.intEntityLocationId ELSE v.intShipFromId END [intDefaultShipFrom]  
				FROM tblEMEntityLocation el  
				INNER JOIN #tmpApiSchemaVendorLocationTop vl ON el.strLocationName = vl.strLocationName  
				INNER JOIN tblAPVendor v ON vl.strEntityNo = v.strVendorId) loc   
			ON v.intEntityId = loc.intEntityId WHERE v.strVendorId = loc.strEntityNo  
		END

		DELETE FROM #tmpApiSchemaVendorLocation WHERE intKey IN (SELECT intKey FROM #tmpApiSchemaVendorLocationTop)
	END
END