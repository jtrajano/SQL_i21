CREATE PROCEDURE uspMFUpdateInsertBatch
	@MFBatchTableType MFBatchTableType READONLY, -- strBatchId is not needed
	@input INT OUTPUT,
	@intputSuccess INT OUTPUT
AS

SELECT @input = COUNT(*) FROM @MFBatchTableType
SET @intputSuccess = 0
DECLARE @tbl TABLE ( intId int) 
--DECLARE @guidBatchLogId UNIQUEIDENTIFIER = NEWID()
--DECLARE @dtmCurrent DATETIME = GETDATE()
DECLARE @id INT 
DECLARE @strBatchId NVARCHAR(40), @intBatchId INT


INSERT INTO @tbl(intId)
SELECT intId FROM @MFBatchTableType

_begin:
WHILE EXISTS (SELECT 1 FROM @tbl)
BEGIN

	SELECT TOP 1  @id = intId FROM @tbl

	IF EXISTS( SELECT 1 FROM  @MFBatchTableType 
	WHERE @id = intId AND(
	ISNULL(intSales,0) = 0 OR
	ISNULL(intSalesYear,0) = 0 OR
	dtmSalesDate IS NULL OR
	RTRIM(LTRIM(strTeaType)) = '' OR
	ISNULL(intBrokerId,0) = 0 OR
	RTRIM(LTRIM(strVendorLotNumber)) = '' OR
	ISNULL(intBuyingCenterLocationId,0) = 0 )
	)
	BEGIN
		--INSERT INTO tblMFBatchLog(guidBatchLogId,strResult)
		--SELECT @guidBatchLogId, 'Unique key(s) have no value(s).No action taken.'
		DELETE FROM @tbl WHERE intId = @id
		goto _begin
	END


	SELECT @strBatchId = A.strBatchId ,
	@intBatchId = intBatchId
	FROM @MFBatchTableType B 
	LEFT JOIN tblMFBatch A
	ON 
	A.intSalesYear = B.intSalesYear
	AND A.intSales = B.intSales
	AND A.dtmSalesDate = B.dtmSalesDate
	AND A.strTeaType = B.strTeaType
	AND A.intBrokerId = B.intBrokerId
	AND A.strVendorLotNumber = B.strVendorLotNumber
	AND A.intBuyingCenterLocationId =B.intBuyingCenterLocationId
	WHERE B.intId = @id

	IF @strBatchId IS NOT NULL
	BEGIN
		UPDATE A
		SET 
		intParentBatchId				 = T.intParentBatchId,
		intInventoryReceiptId			 = T.intInventoryReceiptId,
		intSampleId						 = T.intSampleId,
		intContractDetailId				 = T.intContractDetailId,
		intItemUOMId					 = T.intItemUOMId,
		intWeightUOMId					 = T.intWeightUOMId,				
		intStorageLocationId			 = T.intStorageLocationId,
		intStorageUnitId				 = T.intStorageUnitId,  
		str3PLStatus					 = T.str3PLStatus,
		strAirwayBillCode				 = T.strAirwayBillCode,
		strAWBSampleReceived			 = T.strAWBSampleReceived,
		strAWBSampleReference			 = T.strAWBSampleReference,
		dblBasePrice					 = T.dblBasePrice,
		ysnBoughtAsReserved				 = T.ysnBoughtAsReserved,
		ysnBoughtPrice					 = T.ysnBoughtPrice,
		dblBulkDensity					 = T.dblBulkDensity,
		strBuyingOrderNumber			 = T.strBuyingOrderNumber,
		intSubBookId					 = T.intSubBookId,
		strContainerNumber				 = T.strContainerNumber,
		intCurrencyId					 = T.intCurrencyId,
		dtmProductionBatch				 = T.dtmProductionBatch,
		dtmTeaAvailableFrom				 = T.dtmTeaAvailableFrom,
		strDustContent					 = T.strDustContent,
		ysnEUCompliant					 = T.ysnEUCompliant,
		strTBOEvaluatorCode				 = T.strTBOEvaluatorCode,
		strEvaluatorRemarks				 = T.strEvaluatorRemarks,
		dtmExpiration					 = T.dtmExpiration,
		intFromPortId					 = T.intFromPortId,
		dblGrossWeight					 = T.dblGrossWeight,
		dtmInitialBuy					 = T.dtmInitialBuy,
		dblWeightPerUnit				 = T.dblWeightPerUnit,
		dblLandedPrice					 = T.dblLandedPrice,
		strLeafCategory					 = T.strLeafCategory,
		strLeafManufacturingType		 = T.strLeafManufacturingType,
		strLeafSize						 = T.strLeafSize,
		strLeafStyle					 = T.strLeafStyle,
		dblPackagesBought				 = T.dblPackagesBought,
		strTeaOrigin					 = T.strTeaOrigin,
		intOriginalItemId				 = T.intOriginalItemId,
		dblPackagesPerPallet			 = T.dblPackagesPerPallet,
		strPlant						 = T.strPlant,
		dblTotalQuantity				 = T.dblTotalQuantity,
		strSampleBoxNumber				 = T.strSampleBoxNumber,
		dblSellingPrice					 = T.dblSellingPrice,
		dtmStock						 = T.dtmStock,
		strSubChannel					 = T.strSubChannel,
		ysnStrategic					 = T.ysnStrategic,
		strTeaLingoSubCluster			 = T.strTeaLingoSubCluster,
		dtmSupplierPreInvoiceDate		 = T.dtmSupplierPreInvoiceDate,
		strSustainability				 = T.strSustainability,
		strTasterComments				 = T.strTasterComments,
		dblTeaAppearance				 = T.dblTeaAppearance,
		strTeaBuyingOffice				 = T.strTeaBuyingOffice,
		strTeaColour					 = T.strTeaColour,
		strTeaGardenChopInvoiceNumber	 = T.strTeaGardenChopInvoiceNumber,
		intGardenMarkId					 = T.intGardenMarkId,
		strTeaGroup						 = T.strTeaGroup,
		dblTeaHue						 = T.dblTeaHue,
		dblTeaIntensity					 = T.dblTeaIntensity,
		strLeafGrade					 = T.strLeafGrade,
		dblTeaMoisture					 = T.dblTeaMoisture,
		dblTeaMouthFeel					 = T.dblTeaMouthFeel,
		ysnTeaOrganic					 = T.ysnTeaOrganic,
		dblTeaTaste						 = T.dblTeaTaste,
		dblTeaVolume					 = T.dblTeaVolume,
		intTealingoItemId				 = T.intTealingoItemId,
		dtmWarehouseArrival				 = T.dtmWarehouseArrival,
		intYearManufacture				 = T.intYearManufacture,
		strPackageSize					 = T.strPackageSize,
		intPackageUOMId					 = T.intPackageUOMId,
		dblTareWeight					 = T.dblTareWeight,
		strTaster						 = T.strTaster,
		strFeedStock					 = T.strFeedStock,
		strFlourideLimit				 = T.strFlourideLimit,
		strLocalAuctionNumber			 = T.strLocalAuctionNumber,
		strPOStatus						 = T.strPOStatus,
		strProductionSite				 = T.strProductionSite,
		strReserveMU					 = T.strReserveMU,
		strQualityComments				 = T.strQualityComments,
		strRareEarth					 = T.strRareEarth,
		strFreightAgent					 = T.strFreightAgent, 
		strSealNumber					 = T.strSealNumber,
		strContainerType				 = T.strContainerType,
		strVoyage					 	 = T.strVoyage,
		strVessel					 	 = T.strVessel
		FROM tblMFBatch A
		OUTER APPLY(
			SELECT * FROM @MFBatchTableType WHERE @id = intId
		)T
		WHERE @strBatchId=A.strBatchId

		--INSERT INTO tblMFBatchLog(guidBatchLogId,strResult, intBatchId, dtmDate)
		--SELECT @guidBatchLogId, 'Updated ' + @strBatchId, @intBatchId, @dtmCurrent
	END
	ELSE
	BEGIN

		EXEC uspSMGetStartingNumber 181 , @strBatchId OUT

		INSERT INTO tblMFBatch(
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
			,ysnBoughtPrice
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
			,strFreightAgent
			,strSealNumber
			,strContainerType
			,strVoyage
			,strVessel
			)

		SELECT 
			@strBatchId
			,intSales
			,intSalesYear
			,dtmSalesDate
			,strTeaType
			,intBrokerId
			,strVendorLotNumber
			,intBuyingCenterLocationId
			,intStorageLocationId
			,intStorageUnitId
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
			,ysnBoughtPrice
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
			,strFreightAgent
			,strSealNumber
			,strContainerType
			,strVoyage
			,strVessel
		FROM @MFBatchTableType WHERE intId = @id


		--INSERT INTO tblMFBatchLog(guidBatchLogId,strResult, intBatchId, dtmDate)
		--SELECT @guidBatchLogId, 'Inserted ' + @strBatchId, SCOPE_IDENTITY(), @dtmCurrent
	END

	SET @intputSuccess = @intputSuccess + 1
	DELETE FROM  @tbl WHERE @id = intId

END