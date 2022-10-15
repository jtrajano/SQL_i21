CREATE PROCEDURE uspMFUpdateInsertBatch
	@MFBatchTableType MFBatchTableType READONLY,
    @strBatchId NVARCHAR(50) OUT
AS

SELECT TOP 1 @strBatchId = strBatchId FROM tblMFBatch A
JOIN @MFBatchTableType B
ON 
A.intSalesYear = B.intSalesYear
AND A.intSales = B.intSales
AND A.dtmSalesDate = B.dtmSalesDate
AND A.strTeaType = B.strTeaType
AND A.intBrokerId = B.intBrokerId
AND A.strVendorLotNumber = B.strVendorLotNumber
AND A.intBuyingCenterLocationId =B.intBuyingCenterLocationId

IF @strBatchId IS NOT NULL
BEGIN
	UPDATE A
	SET 
	intParentBatchId				 = T.intParentBatchId,
	intInventoryReceiptId			 = T.intInventoryReceiptId,
	intSampleId						 = T.intSampleId,
	intContractDetailId				 = T.intContractDetailId,
	str3PLStatus					 = T.str3PLStatus,
	strAirwayBillCode				 = T.strAirwayBillCode,
	strAWBSampleReceived			 = T.strAWBSampleReceived,
	strAWBSampleReference			 = T.strAWBSampleReference,
	dblBasePrice					 = T.dblBasePrice,
	ysnBoughtAsReserved				 = T.ysnBoughtAsReserved,
	ysnBoughtPrice					 = T.ysnBoughtPrice,
	intBrokerWarehouseId			 = T.intBrokerWarehouseId,
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
	--intBookId						 = T.intBookId,
	dblPackagesBought				 = T.dblPackagesBought,
	strTeaOrigin					 = T.strTeaOrigin,
	intOriginalItemId				 = T.intOriginalItemId,
	dblPackagesPerPallet			 = T.dblPackagesPerPallet,
	strPlant						 = T.strPlant,
	dblTotalQuantity				 = T.dblTotalQuantity,
	strSampleBoxNumber				 = T.strSampleBoxNumber,
	dblSellingPrice					 = T.dblSellingPrice,
	dtmStock						 = T.dtmStock,
	strStorageLocation				 = T.strStorageLocation,
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
	strTinNumber					 = T.strTinNumber,
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
	strRareEarth					 = T.strRareEarth
	FROM tblMFBatch A
	OUTER APPLY(
		SELECT * FROM @MFBatchTableType
	)T
	WHERE @strBatchId=strBatchId
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
		,intParentBatchId
		,intInventoryReceiptId
		,intSampleId
		,intContractDetailId
		,str3PLStatus
		,strSupplierReference
		,strAirwayBillCode
		,strAWBSampleReceived
		,strAWBSampleReference
		,dblBasePrice
		,ysnBoughtAsReserved
		,ysnBoughtPrice
		,intBrokerWarehouseId
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
		-- ,intBookId
		,dblPackagesBought
		,strTeaOrigin
		,intOriginalItemId
		,dblPackagesPerPallet
		,strPlant
		,dblTotalQuantity
		,strSampleBoxNumber
		,dblSellingPrice
		,dtmStock
		,strStorageLocation
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
		,strTinNumber
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
		,strRareEarth)

	 SELECT 
		@strBatchId
		,intSales
		,intSalesYear
		,dtmSalesDate
		,strTeaType
		,intBrokerId
		,strVendorLotNumber
		,intBuyingCenterLocationId
		,intParentBatchId
		,intInventoryReceiptId
		,intSampleId
		,intContractDetailId
		,str3PLStatus
		,strSupplierReference
		,strAirwayBillCode
		,strAWBSampleReceived
		,strAWBSampleReference
		,dblBasePrice
		,ysnBoughtAsReserved
		,ysnBoughtPrice
		,intBrokerWarehouseId
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
		-- ,intBookId
		,dblPackagesBought
		,strTeaOrigin
		,intOriginalItemId
		,dblPackagesPerPallet
		,strPlant
		,dblTotalQuantity
		,strSampleBoxNumber
		,dblSellingPrice
		,dtmStock
		,strStorageLocation
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
		,strTinNumber
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
	FROM @MFBatchTableType
END