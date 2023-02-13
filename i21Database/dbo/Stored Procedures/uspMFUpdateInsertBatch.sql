CREATE PROCEDURE uspMFUpdateInsertBatch @MFBatchTableType MFBatchTableType READONLY
	,-- strBatchId is not needed
	@input INT OUTPUT
	,@intputSuccess INT OUTPUT
	,@strBatchId NVARCHAR(50) OUTPUT
	,@ysnCopyBatch BIT = 0
AS
SELECT @input = COUNT(*)
FROM @MFBatchTableType

SET @intputSuccess = 0

DECLARE @tbl TABLE (intId INT)
--DECLARE @guidBatchLogId UNIQUEIDENTIFIER = NEWID()
--DECLARE @dtmCurrent DATETIME = GETDATE()
DECLARE @id INT
DECLARE @intBatchId INT
DECLARE @errorMessage NVARCHAR(300) = ''

INSERT INTO @tbl (intId)
SELECT intId
FROM @MFBatchTableType

WHILE EXISTS (
		SELECT 1
		FROM @tbl
		)
BEGIN
	SELECT TOP 1 @id = intId
	FROM @tbl

	IF EXISTS (
			SELECT 1
			FROM @MFBatchTableType
			WHERE @id = intId
				AND ISNULL(intSales, 0) = 0
			)
		SELECT @errorMessage = 'No of Sales (intSalesId) is missing'
	ELSE IF EXISTS (
			SELECT 1
			FROM @MFBatchTableType
			WHERE @id = intId
				AND ISNULL(intSalesYear, 0) = 0
			)
		SELECT @errorMessage = 'Sales year (intSalesYear) is missing'
	ELSE IF EXISTS (
			SELECT 1
			FROM @MFBatchTableType
			WHERE @id = intId
				AND dtmSalesDate IS NULL
			)
		SELECT @errorMessage = 'Sales date (dtmSalesDate) is missing'
	ELSE IF EXISTS (
			SELECT 1
			FROM @MFBatchTableType
			WHERE @id = intId
				AND RTRIM(LTRIM(strTeaType)) = ''
			)
		SELECT @errorMessage = 'Tea type (strTeaType) is missing'
	ELSE IF EXISTS (
			SELECT 1
			FROM @MFBatchTableType
			WHERE @id = intId
				AND RTRIM(LTRIM(strVendorLotNumber)) = ''
			)
		SELECT @errorMessage = 'Vendor Lot Number (strVendorLotNumber) is missing'
	ELSE IF EXISTS (
			SELECT 1
			FROM @MFBatchTableType
			WHERE @id = intId
				AND ISNULL(intBuyingCenterLocationId, 0) = 0
			)
		SELECT @errorMessage = 'Auction center (intBuyingCenterLocationId) is missing'
	ELSE IF EXISTS (
			SELECT 1
			FROM @MFBatchTableType
			WHERE @id = intId
				AND ISNULL(intLocationId, 0) = 0
			)
		SELECT @errorMessage = 'Location (intLocationId) is missing'

	IF @errorMessage <> ''
	BEGIN
		--INSERT INTO tblMFBatchLog(guidBatchLogId,strResult)
		--SELECT @guidBatchLogId, 'Unique key(s) have no value(s).No action taken.'
		SET @errorMessage = 'Insert/Update batch procedure error: ' + @errorMessage

		RAISERROR (
				@errorMessage
				,16
				,1
				)

		RETURN - 1
	END

	SELECT @strBatchId = A.strBatchId
		,@intBatchId = intBatchId
	FROM @MFBatchTableType B
	LEFT JOIN tblMFBatch A ON A.intSalesYear = B.intSalesYear
		AND A.intSales = B.intSales
		AND A.dtmSalesDate = B.dtmSalesDate
		AND A.strTeaType = B.strTeaType
		AND A.strVendorLotNumber = B.strVendorLotNumber
		AND A.intBuyingCenterLocationId = B.intBuyingCenterLocationId
		AND A.intSubBookId = B.intSubBookId
		AND A.intLocationId = B.intLocationId
	WHERE B.intId = @id

	IF @strBatchId IS NOT NULL
	BEGIN
		UPDATE A
		SET intParentBatchId = T.intParentBatchId
			,intInventoryReceiptId = T.intInventoryReceiptId
			,intSampleId = T.intSampleId
			,intContractDetailId = T.intContractDetailId
			,intItemUOMId = T.intItemUOMId
			,intWeightUOMId = T.intWeightUOMId
			,intStorageLocationId = T.intStorageLocationId
			,intStorageUnitId = T.intStorageUnitId
			,intBrokerId = T.intBrokerId
			,intBrokerWarehouseId = T.intBrokerWarehouseId
			,str3PLStatus = T.str3PLStatus
			,strAirwayBillCode = T.strAirwayBillCode
			,strAWBSampleReceived = T.strAWBSampleReceived
			,strAWBSampleReference = T.strAWBSampleReference
			,dblBasePrice = T.dblBasePrice
			,ysnBoughtAsReserved = T.ysnBoughtAsReserved
			,dblBoughtPrice = T.dblBoughtPrice
			,dblBulkDensity = T.dblBulkDensity
			,strBuyingOrderNumber = T.strBuyingOrderNumber
			,strContainerNumber = T.strContainerNumber
			,intCurrencyId = T.intCurrencyId
			,dtmProductionBatch = T.dtmProductionBatch
			,dtmTeaAvailableFrom = T.dtmTeaAvailableFrom
			,strDustContent = T.strDustContent
			,ysnEUCompliant = T.ysnEUCompliant
			,strTBOEvaluatorCode = T.strTBOEvaluatorCode
			,strEvaluatorRemarks = T.strEvaluatorRemarks
			,dtmExpiration = T.dtmExpiration
			,intFromPortId = T.intFromPortId
			,dblGrossWeight = T.dblGrossWeight
			,dtmInitialBuy = T.dtmInitialBuy
			,dblWeightPerUnit = T.dblWeightPerUnit
			,dblLandedPrice = T.dblLandedPrice
			,strLeafCategory = T.strLeafCategory
			,strLeafManufacturingType = T.strLeafManufacturingType
			,strLeafSize = T.strLeafSize
			,strLeafStyle = T.strLeafStyle
			,dblPackagesBought = T.dblPackagesBought
			,strTeaOrigin = T.strTeaOrigin
			,intOriginalItemId = T.intOriginalItemId
			,dblPackagesPerPallet = T.dblPackagesPerPallet
			,strPlant = T.strPlant
			,dblTotalQuantity = T.dblTotalQuantity
			,strSampleBoxNumber = T.strSampleBoxNumber
			,dblSellingPrice = T.dblSellingPrice
			,dtmStock = T.dtmStock
			,strSubChannel = T.strSubChannel
			,ysnStrategic = T.ysnStrategic
			,strTeaLingoSubCluster = T.strTeaLingoSubCluster
			,dtmSupplierPreInvoiceDate = T.dtmSupplierPreInvoiceDate
			,strSustainability = T.strSustainability
			,strTasterComments = T.strTasterComments
			,dblTeaAppearance = T.dblTeaAppearance
			,strTeaBuyingOffice = T.strTeaBuyingOffice
			,strTeaColour = T.strTeaColour
			,strTeaGardenChopInvoiceNumber = T.strTeaGardenChopInvoiceNumber
			,intGardenMarkId = T.intGardenMarkId
			,strTeaGroup = T.strTeaGroup
			,dblTeaHue = T.dblTeaHue
			,dblTeaIntensity = T.dblTeaIntensity
			,strLeafGrade = T.strLeafGrade
			,dblTeaMoisture = T.dblTeaMoisture
			,dblTeaMouthFeel = T.dblTeaMouthFeel
			,ysnTeaOrganic = T.ysnTeaOrganic
			,dblTeaTaste = T.dblTeaTaste
			,dblTeaVolume = T.dblTeaVolume
			,intTealingoItemId = T.intTealingoItemId
			,dtmWarehouseArrival = T.dtmWarehouseArrival
			,intYearManufacture = T.intYearManufacture
			,strPackageSize = T.strPackageSize
			,intPackageUOMId = T.intPackageUOMId
			,dblTareWeight = T.dblTareWeight
			,strTaster = T.strTaster
			,strFeedStock = T.strFeedStock
			,strFlourideLimit = T.strFlourideLimit
			,strLocalAuctionNumber = T.strLocalAuctionNumber
			,strPOStatus = T.strPOStatus
			,strProductionSite = T.strProductionSite
			,strReserveMU = T.strReserveMU
			,strQualityComments = T.strQualityComments
			,strRareEarth = T.strRareEarth
			,strERPPONumber = T.strERPPONumber
			,strFreightAgent = T.strFreightAgent
			,strSealNumber = T.strSealNumber
			,strContainerType = T.strContainerType
			,strVoyage = T.strVoyage
			,strVessel = T.strVessel
			,intConcurrencyId = intConcurrencyId + 1
			,intMixingUnitLocationId=T.intMixingUnitLocationId
			,dblOriginalTeaTaste		= T.dblOriginalTeaTaste
			,dblOriginalTeaHue			= T.dblOriginalTeaHue
			,dblOriginalTeaIntensity	= T.dblOriginalTeaIntensity	
			,dblOriginalTeaMouthfeel	= T.dblOriginalTeaMouthfeel	
			,dblOriginalTeaAppearance	= T.dblOriginalTeaAppearance
			,dblOriginalTeaVolume		= T.dblOriginalTeaVolume
			,dblOriginalTeaMoisture		= T.dblOriginalTeaMoisture	
			,intMarketZoneId			= T.intMarketZoneId	
			,dblTeaTastePinpoint		= T.dblTeaTastePinpoint
			,dblTeaHuePinpoint			= T.dblTeaHuePinpoint
			,dblTeaIntensityPinpoint	= T.dblTeaIntensityPinpoint	
			,dblTeaMouthFeelPinpoint	= T.dblTeaMouthFeelPinpoint	
			,dblTeaAppearancePinpoint	= T.dblTeaAppearancePinpoint
			,dtmShippingDate			= T.dtmShippingDate	
			,strFines					= T.strFines
		FROM tblMFBatch A
		OUTER APPLY (
			SELECT *
			FROM @MFBatchTableType
			WHERE @id = intId
			) T
		WHERE @strBatchId = A.strBatchId
			AND A.intLocationId = T.intLocationId
			--INSERT INTO tblMFBatchLog(guidBatchLogId,strResult, intBatchId, dtmDate)
			--SELECT @guidBatchLogId, 'Updated ' + @strBatchId, @intBatchId, @dtmCurrent
	END
	ELSE
	BEGIN
		IF @ysnCopyBatch = 0
			EXEC uspSMGetStartingNumber 181
				,@strBatchId OUT

		INSERT INTO tblMFBatch (
			strBatchId
			,intSales
			,intSalesYear
			,dtmSalesDate
			,strTeaType
			,intBrokerId
			,strVendorLotNumber
			,intBuyingCenterLocationId
			,intStorageLocationId
			,intStorageUnitId
			,intBrokerWarehouseId
			,intParentBatchId
			,intInventoryReceiptId
			,intSampleId
			,intItemUOMId
			,intWeightUOMId
			,intContractDetailId
			,str3PLStatus
			,strSupplierReference
			,strAirwayBillCode
			,strAWBSampleReceived
			,strAWBSampleReference
			,dblBasePrice
			,ysnBoughtAsReserved
			,dblBoughtPrice
			,dblBulkDensity
			,strBuyingOrderNumber
			,intSubBookId
			,strContainerNumber
			,intCurrencyId
			,dtmProductionBatch
			,dtmTeaAvailableFrom
			,strDustContent
			,ysnEUCompliant
			,strTBOEvaluatorCode
			,strEvaluatorRemarks
			,dtmExpiration
			,intFromPortId
			,dblGrossWeight
			,dtmInitialBuy
			,dblWeightPerUnit
			,dblLandedPrice
			,strLeafCategory
			,strLeafManufacturingType
			,strLeafSize
			,strLeafStyle
			,dblPackagesBought
			,strTeaOrigin
			,intOriginalItemId
			,dblPackagesPerPallet
			,strPlant
			,dblTotalQuantity
			,strSampleBoxNumber
			,dblSellingPrice
			,dtmStock
			,strSubChannel
			,ysnStrategic
			,strTeaLingoSubCluster
			,dtmSupplierPreInvoiceDate
			,strSustainability
			,strTasterComments
			,dblTeaAppearance
			,strTeaBuyingOffice
			,strTeaColour
			,strTeaGardenChopInvoiceNumber
			,intGardenMarkId
			,strTeaGroup
			,dblTeaHue
			,dblTeaIntensity
			,strLeafGrade
			,dblTeaMoisture
			,dblTeaMouthFeel
			,ysnTeaOrganic
			,dblTeaTaste
			,dblTeaVolume
			,intTealingoItemId
			,dtmWarehouseArrival
			,intYearManufacture
			,strPackageSize
			,intPackageUOMId
			,dblTareWeight
			,strTaster
			,strFeedStock
			,strFlourideLimit
			,strLocalAuctionNumber
			,strPOStatus
			,strProductionSite
			,strReserveMU
			,strQualityComments
			,strRareEarth
			,strERPPONumber
			,strFreightAgent
			,strSealNumber
			,strContainerType
			,strVoyage
			,strVessel
			,intConcurrencyId
			,intLocationId
			,intMixingUnitLocationId
			,dblOriginalTeaTaste
			,dblOriginalTeaHue
			,dblOriginalTeaIntensity
			,dblOriginalTeaMouthfeel
			,dblOriginalTeaAppearance
			,dblOriginalTeaVolume
			,dblOriginalTeaMoisture
			,intMarketZoneId
			,dblTeaTastePinpoint
			,dblTeaHuePinpoint
			,dblTeaIntensityPinpoint
			,dblTeaMouthFeelPinpoint
			,dblTeaAppearancePinpoint
			,dtmShippingDate
			,strFines
			)
		SELECT (
				CASE 
					WHEN @ysnCopyBatch = 0
						THEN @strBatchId
					ELSE strBatchId
					END
				)
			,intSales
			,intSalesYear
			,dtmSalesDate
			,strTeaType
			,intBrokerId
			,strVendorLotNumber
			,intBuyingCenterLocationId
			,intStorageLocationId
			,intStorageUnitId
			,intBrokerWarehouseId
			,intParentBatchId
			,intInventoryReceiptId
			,intSampleId
			,intItemUOMId
			,intWeightUOMId
			,intContractDetailId
			,str3PLStatus
			,strSupplierReference
			,strAirwayBillCode
			,strAWBSampleReceived
			,strAWBSampleReference
			,dblBasePrice
			,ysnBoughtAsReserved
			,dblBoughtPrice
			,dblBulkDensity
			,strBuyingOrderNumber
			,intSubBookId
			,strContainerNumber
			,intCurrencyId
			,dtmProductionBatch
			,dtmTeaAvailableFrom
			,strDustContent
			,ysnEUCompliant
			,strTBOEvaluatorCode
			,strEvaluatorRemarks
			,dtmExpiration
			,intFromPortId
			,dblGrossWeight
			,dtmInitialBuy
			,dblWeightPerUnit
			,dblLandedPrice
			,strLeafCategory
			,strLeafManufacturingType
			,strLeafSize
			,strLeafStyle
			,dblPackagesBought
			,strTeaOrigin
			,intOriginalItemId
			,dblPackagesPerPallet
			,strPlant
			,dblTotalQuantity
			,strSampleBoxNumber
			,dblSellingPrice
			,dtmStock
			,strSubChannel
			,ysnStrategic
			,strTeaLingoSubCluster
			,dtmSupplierPreInvoiceDate
			,strSustainability
			,strTasterComments
			,dblTeaAppearance
			,strTeaBuyingOffice
			,strTeaColour
			,strTeaGardenChopInvoiceNumber
			,intGardenMarkId
			,strTeaGroup
			,dblTeaHue
			,dblTeaIntensity
			,strLeafGrade
			,dblTeaMoisture
			,dblTeaMouthFeel
			,ysnTeaOrganic
			,dblTeaTaste
			,dblTeaVolume
			,intTealingoItemId
			,dtmWarehouseArrival
			,intYearManufacture
			,strPackageSize
			,intPackageUOMId
			,dblTareWeight
			,strTaster
			,strFeedStock
			,strFlourideLimit
			,strLocalAuctionNumber
			,strPOStatus
			,strProductionSite
			,strReserveMU
			,strQualityComments
			,strRareEarth
			,strERPPONumber
			,strFreightAgent
			,strSealNumber
			,strContainerType
			,strVoyage
			,strVessel
			,1
			,intLocationId
			,intMixingUnitLocationId
			,dblOriginalTeaTaste
			,dblOriginalTeaHue
			,dblOriginalTeaIntensity
			,dblOriginalTeaMouthfeel
			,dblOriginalTeaAppearance
			,dblOriginalTeaVolume
			,dblOriginalTeaMoisture
			,intMarketZoneId
			,dblTeaTastePinpoint
			,dblTeaHuePinpoint
			,dblTeaIntensityPinpoint
			,dblTeaMouthFeelPinpoint
			,dblTeaAppearancePinpoint
			,dtmShippingDate
			,strFines
		FROM @MFBatchTableType
		WHERE intId = @id
			--INSERT INTO tblMFBatchLog(guidBatchLogId,strResult, intBatchId, dtmDate)
			--SELECT @guidBatchLogId, 'Inserted ' + @strBatchId, SCOPE_IDENTITY(), @dtmCurrent
	END

	SET @intputSuccess = @intputSuccess + 1

	DELETE
	FROM @tbl
	WHERE @id = intId
END

RETURN 1
