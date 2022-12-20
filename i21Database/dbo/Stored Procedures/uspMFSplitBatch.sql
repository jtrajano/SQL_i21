CREATE PROCEDURE uspMFSplitBatch
	@MFBatchSplitTable MFBatchSplitTableType READONLY
AS	
DECLARE @intBatchId INT
DECLARE @tbl TABLE (intBatchId int)

INSERT INTO @tbl
SELECT intBatchId FROM @MFBatchSplitTable

WHILE EXISTS (SELECT 1 FROM  @tbl)
BEGIN
	SELECT TOP 1 @intBatchId = intBatchId FROM @tbl
	IF EXISTS(SELECT 1 FROM @MFBatchSplitTable WHERE ysnSplit = 1 AND @intBatchId = intBatchId)
	BEGIN
		DECLARE @strBatchId NVARCHAR(50)
		EXEC uspSMGetStartingNumber 181 , @strBatchId OUT
		INSERT INTO [dbo].[tblMFBatch]
				([strBatchId]
				,intLocationId
				,[intSales]
				,[intSalesYear]
				,[dtmSalesDate]
				,[strTeaType]
				,[intBrokerId]
				,[strVendorLotNumber]
				,[intBuyingCenterLocationId]
				,[intParentBatchId]
				,[intStorageLocationId]
				,[intStorageUnitId]
				,[intInventoryReceiptId]
				,[intBrokerWarehouseId]
				,[intSampleId]
				,[intItemUOMId]
				,[intWeightUOMId]
				,[intContractDetailId]
				,[str3PLStatus]
				,[strSupplierReference]
				,[strAirwayBillCode]
				,[strAWBSampleReceived]
				,[strAWBSampleReference]
				,[dblBasePrice]
				,[ysnBoughtAsReserved]
				,[dblBoughtPrice]
				,[dblBulkDensity]
				,[strBuyingOrderNumber]
				,[intSubBookId]
				,[strContainerNumber]
				,[intCurrencyId]
				,[dtmProductionBatch]
				,[dtmTeaAvailableFrom]
				,[strDustContent]
				,[ysnEUCompliant]
				,[strTBOEvaluatorCode]
				,[strEvaluatorRemarks]
				,[dtmExpiration]
				,[intFromPortId]
				,[dblGrossWeight]
				,[dtmInitialBuy]
				,[dblWeightPerUnit]
				,[dblLandedPrice]
				,[strLeafCategory]
				,[strLeafManufacturingType]
				,[strLeafSize]
				,[strLeafStyle]
				,[intMixingUnitLocationId]
				,[dblPackagesBought]
				,[strTeaOrigin]
				,[intOriginalItemId]
				,[dblPackagesPerPallet]
				,[strPlant]
				,[dblTotalQuantity]
				,[strSampleBoxNumber]
				,[dblSellingPrice]
				,[dtmStock]
				,[strSubChannel]
				,[ysnStrategic]
				,[strTeaLingoSubCluster]
				,[dtmSupplierPreInvoiceDate]
				,[strSustainability]
				,[strTasterComments]
				,[dblTeaAppearance]
				,[strTeaBuyingOffice]
				,[strTeaColour]
				,[strTeaGardenChopInvoiceNumber]
				,[intGardenMarkId]
				,[strTeaGroup]
				,[dblTeaHue]
				,[dblTeaIntensity]
				,[strLeafGrade]
				,[dblTeaMoisture]
				,[dblTeaMouthFeel]
				,[ysnTeaOrganic]
				,[dblTeaTaste]
				,[dblTeaVolume]
				,[intTealingoItemId]
				,[dtmWarehouseArrival]
				,[intYearManufacture]
				,[strPackageSize]
				,[intPackageUOMId] 
				,[dblTareWeight]
				,[strTaster]
				,[strFeedStock]
				,[strFlourideLimit]
				,[strLocalAuctionNumber]
				,[strPOStatus]
				,[strProductionSite]
				,[strReserveMU]
				,[strQualityComments]
				,[strRareEarth]
				,[strFreightAgent]
				,[strSealNumber]
				,[strContainerType]
				,[strVoyage]
				,[strVessel]
				,[intConcurrencyId]
				,[intReasonCodeId]
				,[dtmSplit]
				,[strNotes])
		SELECT TOP 1
				 [strBatchId] = @strBatchId
				,intLocationId = B.intLocationId
				,[intSales]
				,[intSalesYear]
				,[dtmSalesDate]
				,[strTeaType]
				,[intBrokerId]
				,[strVendorLotNumber]
				,[intBuyingCenterLocationId]
				,[intParentBatchId] = B.intBatchId
				,[intStorageLocationId] = B.intSplitStorageLocationId
				,[intStorageUnitId] = B.intSplitStorageUnitId
				,[intInventoryReceiptId]
				,[intBrokerWarehouseId]
				,[intSampleId]
				,[intItemUOMId]
				,[intWeightUOMId]
				,[intContractDetailId]
				,[str3PLStatus]
				,[strSupplierReference]
				,[strAirwayBillCode]
				,[strAWBSampleReceived]
				,[strAWBSampleReference]
				,[dblBasePrice]
				,[ysnBoughtAsReserved]
				,[dblBoughtPrice]
				,[dblBulkDensity]
				,[strBuyingOrderNumber]
				,[intSubBookId]
				,[strContainerNumber]
				,[intCurrencyId]
				,[dtmProductionBatch]
				,[dtmTeaAvailableFrom]
				,[strDustContent]
				,[ysnEUCompliant]
				,[strTBOEvaluatorCode]
				,[strEvaluatorRemarks]
				,[dtmExpiration]
				,[intFromPortId]
				,[dblGrossWeight]
				,[dtmInitialBuy]
				,[dblWeightPerUnit]= B.dblSplitWeightPerUnit
				,[dblLandedPrice]
				,[strLeafCategory]
				,[strLeafManufacturingType]
				,[strLeafSize]
				,[strLeafStyle]
				,[intMixingUnitLocationId]
				,[dblPackagesBought]--= B.dblSplitPackages
				,[strTeaOrigin]
				,[intOriginalItemId]
				,[dblPackagesPerPallet]
				,[strPlant]
				,[dblTotalQuantity] = B.dblSplitPackages
				,[strSampleBoxNumber]
				,[dblSellingPrice]
				,[dtmStock]
				,[strSubChannel]
				,[ysnStrategic]
				,[strTeaLingoSubCluster]
				,[dtmSupplierPreInvoiceDate]
				,[strSustainability]
				,[strTasterComments]
				,[dblTeaAppearance]
				,[strTeaBuyingOffice]
				,[strTeaColour]
				,[strTeaGardenChopInvoiceNumber]
				,[intGardenMarkId]
				,[strTeaGroup]
				,[dblTeaHue]
				,[dblTeaIntensity]
				,[strLeafGrade]
				,[dblTeaMoisture]
				,[dblTeaMouthFeel]
				,[ysnTeaOrganic]
				,[dblTeaTaste]
				,[dblTeaVolume]
				,[intTealingoItemId]
				,[dtmWarehouseArrival]
				,[intYearManufacture]
				,[strPackageSize]
				,[intPackageUOMId]
				,[dblTareWeight]
				,[strTaster]
				,[strFeedStock]
				,[strFlourideLimit]
				,[strLocalAuctionNumber]
				,[strPOStatus]
				,[strProductionSite]
				,[strReserveMU]
				,[strQualityComments]
				,[strRareEarth]
				,[strFreightAgent]
				,[strSealNumber]
				,[strContainerType]
				,[strVoyage]
				,[strVessel]
				,[intConcurrencyId] =1
				,[intReasonCodeId] = B.intSplitReasonCodeId
				,[dtmSplit] = B.dtmSplit
				,[strNotes] = B.strSplitNotes
				FROM tblMFBatch A JOIN @MFBatchSplitTable B ON
				A.intBatchId = B.intBatchId
				WHERE @intBatchId = B.intBatchId

		UPDATE A 
		SET dblTotalQuantity = dblTotalQuantity-B.dblSplitPackages
		--,dblPackagesBought = (dblTotalQuantity-B.dblSplitQuantity)/ dblWeightPerUnit
		FROM tblMFBatch A JOIN @MFBatchSplitTable B ON A.intBatchId = B.intBatchId
		WHERE B.intBatchId =@intBatchId
	END
	ELSE
	BEGIN
		UPDATE A 
		SET dblTotalQuantity = A.dblTotalQuantity + C.dblTotalQuantity
		--dblPackagesBought = (A.dblTotalQuantity+C.dblTotalQuantity)/ dblWeightPerUnit
		FROM tblMFBatch A JOIN @MFBatchSplitTable B ON A.intBatchId = B.intParentBatchId
		outer apply(
			SELECT dblTotalQuantity FROM tblMFBatch WHERE intBatchId =B.intBatchId 
		)C
		where B.intBatchId =@intBatchId

		UPDATE A 
		SET dblTotalQuantity = 0,
		dblPackagesBought = 0
		FROM tblMFBatch A JOIN @MFBatchSplitTable B ON A.intBatchId = B.intBatchId
		where B.intBatchId =@intBatchId
	END
	DELETE FROM @tbl WHERE intBatchId = @intBatchId
END