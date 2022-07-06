CREATE PROCEDURE [dbo].[uspApiSchemaTransformTRVendorSupplyPointDetail]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS
BEGIN

	DECLARE @tmpGrossOrNet TABLE (
		strGrossOrNet NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL
	)

	INSERT INTO @tmpGrossOrNet (strGrossOrNet) VALUES ('Gross')
	INSERT INTO @tmpGrossOrNet (strGrossOrNet) VALUES ('Net')

	-- VALIDATE Vendor Entity
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Vendor Entity Number'
		, strValue = SPD.strVendorEntityNo
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = SPD.intRowNumber
		, strMessage = 'Could not find the Vendor Entity Number ''' + SPD.strVendorEntityNo + ''' in i21 Vendors'
	FROM tblApiSchemaTRVendorSupplyPointDetail SPD
	LEFT JOIN tblEMEntity E ON E.strEntityNo = SPD.strVendorEntityNo
	LEFT JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
	WHERE V.intEntityId IS NULL
	AND SPD.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Location Name
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Location Name'
		, strValue = SPD.strLocationName
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = SPD.intRowNumber
		, strMessage = 'Could not find the Location Name ''' + SPD.strLocationName + ''' in i21 Vendor Locations'
	FROM tblApiSchemaTRVendorSupplyPointDetail SPD
	LEFT JOIN tblEMEntity E ON E.strEntityNo = SPD.strVendorEntityNo
	LEFT JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId AND EL.strLocationName = SPD.strLocationName
	WHERE EL.intEntityLocationId IS NULL
	AND SPD.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Gross Or Net
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Gross Or Net'
		, strValue = SPD.strGrossOrNet
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = SPD.intRowNumber
		, strMessage = '''' + SPD.strGrossOrNet + ''' is not a valid value for the field Gross Or Net.'
	FROM tblApiSchemaTRVendorSupplyPointDetail SPD
	LEFT JOIN @tmpGrossOrNet GN ON SPD.strGrossOrNet = GN.strGrossOrNet AND SPD.strGrossOrNet IS NOT NULL
	WHERE GN.strGrossOrNet IS NULL
	AND SPD.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Terminal No
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Terminal No'
		, strValue = SPD.strTerminalNo
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = SPD.intRowNumber
		, strMessage = 'Could not find Terminal No ''' + SPD.strTerminalNo + ''' in i21 Terminal Control Numbers.'
	FROM tblApiSchemaTRVendorSupplyPointDetail SPD
	LEFT JOIN tblTFTerminalControlNumber TCN ON SPD.strTerminalNo = TCN.strTerminalControlNumber AND SPD.strTerminalNo IS NOT NULL
	WHERE TCN.intTerminalControlNumberId IS NULL
	AND SPD.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Supply Point for Rack Prices
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Supply Point for Rack Prices'
		, strValue = SPD.strSupplyPointForRackPrices
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = SPD.intRowNumber
		, strMessage = 'Could not find Supply Point ''' + SPD.strSupplyPointForRackPrices + ''' in i21 Supply Point for Rack Prices.'
	FROM tblApiSchemaTRVendorSupplyPointDetail SPD
	LEFT JOIN vyuTRSupplyPointView SPV ON SPD.strSupplyPointForRackPrices = SPV.strSupplyPoint AND SPD.strSupplyPointForRackPrices IS NOT NULL
	WHERE SPV.intSupplyPointId IS NULL
	AND SPD.guiApiUniqueId = @guiApiUniqueId


	DECLARE @intVendorEntityId INT = NULL
	, @intEntityLocationId INT = NULL
	, @strLocationName NVARCHAR(200) = NULL
	, @strGrossOrNet NVARCHAR(10) = NULL
	, @strFuelDealerId1 NVARCHAR(100) = NULL
	, @strFuelDealerId2 NVARCHAR(100) = NULL
	, @strDefaultOrigin NVARCHAR(100) = NULL
	, @intTerminalControlNumberId INT = NULL
	, @intRackPriceSupplyPointId INT = NULL
	, @ysnMultipleDueDates BIT = NULL
	, @strFreightSalesUnit NVARCHAR(50) = NULL
	, @intRowNumber INT = NULL
	DECLARE DataCursor CURSOR LOCAL FAST_FORWARD	
    FOR 
	SELECT V.intEntityId AS intVendorEntityId
		, EL.intEntityLocationId AS intEntityLocationId
		, EL.strLocationName AS strLocationName
		, SPD.strGrossOrNet
		, SPD.strFuelDealerId1
		, SPD.strFuelDealerId2
		, SPD.strDefaultOrigin
		, TCN.intTerminalControlNumberId
		, SPV.intRackPriceSupplyPointId
		, SPD.ysnMultipleDueDates
		, CASE WHEN SPD.strFreightSalesUnit IS NULL THEN NULL 
			   WHEN SPD.strFreightSalesUnit = 'Net' THEN 'Net' 
			   WHEN SPD.strFreightSalesUnit = 'Gross' THEN 'Gross'
			   ELSE NULL END AS strFreightSalesUnit
		, SPD.intRowNumber
	FROM tblApiSchemaTRVendorSupplyPointDetail SPD
	INNER JOIN tblEMEntity E ON E.strEntityNo = SPD.strVendorEntityNo
	INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
	INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId AND EL.strLocationName = SPD.strLocationName
	INNER JOIN @tmpGrossOrNet GN ON GN.strGrossOrNet = SPD.strGrossOrNet
	LEFT JOIN tblTFTerminalControlNumber TCN ON SPD.strTerminalNo = TCN.strTerminalControlNumber
	LEFT JOIN vyuTRSupplyPointView SPV ON SPD.strSupplyPointForRackPrices = SPV.strSupplyPoint
	WHERE SPD.guiApiUniqueId = @guiApiUniqueId
	AND 1 = CASE WHEN ISNULL(SPD.strTerminalNo, '') = '' THEN 1 
		ELSE CASE WHEN ISNULL(SPD.strTerminalNo, '') != '' AND ISNULL(TCN.intTerminalControlNumberId, 0) != 0 THEN 1 ELSE 0 END END
	AND 1 = CASE WHEN  ISNULL(SPD.strSupplyPointForRackPrices, '') = '' THEN 1 
		ELSE CASE WHEN ISNULL(SPD.strSupplyPointForRackPrices, '') != '' AND ISNULL(SPV.intRackPriceSupplyPointId, 0) != 0 THEN 1 ELSE 0 END END

	OPEN DataCursor
	FETCH NEXT FROM DataCursor INTO
	  @intVendorEntityId 
	, @intEntityLocationId
	, @strLocationName 
	, @strGrossOrNet
	, @strFuelDealerId1
	, @strFuelDealerId2
	, @strDefaultOrigin
	, @intTerminalControlNumberId 
	, @intRackPriceSupplyPointId
	, @ysnMultipleDueDates
	, @strFreightSalesUnit
	, @intRowNumber 

	WHILE @@FETCH_STATUS = 0
    BEGIN
		DECLARE @strImportResultMsg NVARCHAR(50) = NULL
		DECLARE @intSupplyPointId INT = NULL
		SELECT @intSupplyPointId = intSupplyPointId FROM tblTRSupplyPoint WHERE intEntityVendorId = @intVendorEntityId AND intEntityLocationId = @intEntityLocationId

		IF(@intSupplyPointId IS NOT NULL)
		BEGIN
			UPDATE tblTRSupplyPoint SET
				strGrossOrNet = @strGrossOrNet
				, strFuelDealerId1 = @strFuelDealerId1
				, strFuelDealerId2 = @strFuelDealerId2
				, strDefaultOrigin = @strDefaultOrigin
				, intTerminalControlNumberId = @intTerminalControlNumberId
				, intRackPriceSupplyPointId = @intRackPriceSupplyPointId
				, ysnMultipleDueDates = @ysnMultipleDueDates
				, strFreightSalesUnit = @strFreightSalesUnit
				, guiApiUniqueId = @guiApiUniqueId
			WHERE intSupplyPointId = @intSupplyPointId

			SET @strImportResultMsg = 'Record successfully updated.'
		END
		ELSE
		BEGIN
			INSERT INTO tblTRSupplyPoint (
				intEntityVendorId
				, intEntityLocationId
				, strGrossOrNet
				, strFuelDealerId1
				, strFuelDealerId2
				, strDefaultOrigin
				, intTerminalControlNumberId
				, intRackPriceSupplyPointId
				, ysnMultipleDueDates
				, strFreightSalesUnit
				, guiApiUniqueId
				, intConcurrencyId
			)
			VALUES (
				@intVendorEntityId
				, @intEntityLocationId
				, @strGrossOrNet
				, @strFuelDealerId1
				, @strFuelDealerId2
				, @strDefaultOrigin
				, @intTerminalControlNumberId
				, @intRackPriceSupplyPointId
				, @ysnMultipleDueDates
				, @strFreightSalesUnit
				, @guiApiUniqueId
				, 1
			)
			
			UPDATE tblAPVendor SET ysnTransportTerminal = 1 where intEntityId = @intVendorEntityId

			SET @strImportResultMsg = 'Record successfully added.'
		END

		INSERT INTO tblApiImportLogDetail (
				guiApiImportLogDetailId
				, guiApiImportLogId
				, strField
				, strValue
				, strLogLevel
				, strStatus
				, intRowNo
				, strMessage
			)
			SELECT guiApiImportLogDetailId = NEWID()
				, guiApiImportLogId = @guiLogId
				, strField = ''
				, strValue = '' 
				, strLogLevel = 'Success'
				, strStatus = 'Success'
				, intRowNo = @intRowNumber
				, strMessage = @strImportResultMsg


		FETCH NEXT FROM DataCursor INTO
		  @intVendorEntityId 
		, @intEntityLocationId
		, @strLocationName 
		, @strGrossOrNet
		, @strFuelDealerId1
		, @strFuelDealerId2
		, @strDefaultOrigin
		, @intTerminalControlNumberId 
		, @intRackPriceSupplyPointId
		, @ysnMultipleDueDates
		, @strFreightSalesUnit
		, @intRowNumber 
	END
	CLOSE DataCursor
	DEALLOCATE DataCursor

END
