CREATE PROCEDURE [dbo].[uspMFUpdateInsertBatch]
(
	@MFBatchTableType	MFBatchTableType READONLY
  , @input				INT OUTPUT
  , @intputSuccess		INT OUTPUT
  , @strBatchId			NVARCHAR(50) OUTPUT
  , @ysnCopyBatch		BIT = 0
)

AS

SELECT @input = COUNT(*) FROM @MFBatchTableType;

SET @intputSuccess = 0

DECLARE @tbl TABLE (intId INT);

DECLARE @id				INT
	  , @intBatchId		INT
	  , @errorMessage	NVARCHAR(300) = ''
	  , @intCountryId INT
	  , @intMarketZoneId INT
	  , @intBuyingCenterLocationId INT

INSERT INTO @tbl (intId)
SELECT intId
FROM @MFBatchTableType

WHILE EXISTS (SELECT 1 FROM @tbl)
	BEGIN
		SELECT TOP 1 @id = intId
		FROM @tbl

		/* Data Validation Starts Here.*/
		IF EXISTS (SELECT 1 FROM @MFBatchTableType WHERE @id = intId AND ISNULL(intSales, 0) = 0)
			BEGIN
				SELECT @errorMessage = 'No of Sales (intSalesId) is missing';
			END
		ELSE IF EXISTS (SELECT 1 FROM @MFBatchTableType WHERE @id = intId AND ISNULL(intSalesYear, 0) = 0)
			BEGIN
				SELECT @errorMessage = 'Sales year (intSalesYear) is missing';
			END
		ELSE IF EXISTS (SELECT 1 FROM @MFBatchTableType WHERE @id = intId AND dtmSalesDate IS NULL)
			BEGIN
				SELECT @errorMessage = 'Sales date (dtmSalesDate) is missing';
			END
		ELSE IF EXISTS (SELECT 1 FROM @MFBatchTableType WHERE @id = intId AND RTRIM(LTRIM(strTeaType)) = '')
			BEGIN
				SELECT @errorMessage = 'Tea type (strTeaType) is missing';
			END
		ELSE IF EXISTS (SELECT 1 FROM @MFBatchTableType WHERE @id = intId AND RTRIM(LTRIM(strVendorLotNumber)) = '')
			BEGIN
				SELECT @errorMessage = 'Vendor Lot Number (strVendorLotNumber) is missing';
			END	
		ELSE IF EXISTS (SELECT 1 FROM @MFBatchTableType WHERE @id = intId AND ISNULL(intBuyingCenterLocationId, 0) = 0)
			BEGIN
				SELECT @errorMessage = 'Auction center (intBuyingCenterLocationId) is missing';
			END
		ELSE IF EXISTS (SELECT 1 FROM @MFBatchTableType WHERE @id = intId AND ISNULL(intLocationId, 0) = 0)
			BEGIN
				SELECT @errorMessage = 'Location (intLocationId) is missing';
			END

		IF @errorMessage <> ''
			BEGIN
				SET @errorMessage = 'Insert/Update batch procedure error: ' + @errorMessage

				RAISERROR (@errorMessage
						 , 16
						 , 1)

				RETURN - 1;
			END

		SELECT @intCountryId = NULL
				,@intMarketZoneId=NULL
				,@intBuyingCenterLocationId =NULL

		SELECT @strBatchId = A.strBatchId
			 , @intBatchId = intBatchId
			 ,@intCountryId = B.intCountryId 
			 ,@intMarketZoneId=B.intMarketZoneId
			 ,@intBuyingCenterLocationId=B.intBuyingCenterLocationId
		FROM @MFBatchTableType B
		LEFT JOIN tblMFBatch A ON A.intSalesYear = B.intSalesYear
			  AND A.intSales = B.intSales
			  AND A.dtmSalesDate = B.dtmSalesDate
			  AND A.strTeaType = B.strTeaType
			  AND A.strVendorLotNumber = B.strVendorLotNumber
			  AND A.intBuyingCenterLocationId = B.intBuyingCenterLocationId
			  AND A.intSubBookId = B.intSubBookId
			  AND A.intLocationId = B.intLocationId
			  AND A.intSupplierId = B.intSupplierId
		WHERE B.intId = @id;

		/* Update Existing Batch if @strBatchId is not empty. */
		IF @strBatchId IS NOT NULL
			BEGIN
				UPDATE A
				SET intParentBatchId				= T.intParentBatchId
				  , intInventoryReceiptId			= T.intInventoryReceiptId
				  , intSampleId						= T.intSampleId
				  , intContractDetailId				= T.intContractDetailId
				  , intItemUOMId					= T.intItemUOMId
				  , intWeightUOMId					= T.intWeightUOMId
				  , intStorageLocationId			= T.intStorageLocationId
				  , intStorageUnitId				= T.intStorageUnitId
				  , intBrokerId						= T.intBrokerId
				  , intBrokerWarehouseId			= T.intBrokerWarehouseId
				  , str3PLStatus					= T.str3PLStatus
				  , strAirwayBillCode				= T.strAirwayBillCode
				  , strAWBSampleReceived			= T.strAWBSampleReceived
				  , strAWBSampleReference			= T.strAWBSampleReference
				  , dblBasePrice					= T.dblBasePrice
				  , ysnBoughtAsReserved				= T.ysnBoughtAsReserved
				  , dblBoughtPrice					= T.dblBoughtPrice
				  , dblBulkDensity					= T.dblBulkDensity
				  , strBuyingOrderNumber			= T.strBuyingOrderNumber
				  , strContainerNumber				= T.strContainerNumber
				  , intCurrencyId					= T.intCurrencyId
				  , dtmProductionBatch				= T.dtmProductionBatch
				  , dtmTeaAvailableFrom				= T.dtmTeaAvailableFrom
				  , strDustContent					= T.strDustContent
				  , ysnEUCompliant					= T.ysnEUCompliant
				  , strTBOEvaluatorCode				= T.strTBOEvaluatorCode
				  , strEvaluatorRemarks				= T.strEvaluatorRemarks
				  , dtmExpiration					= T.dtmExpiration
				  , intFromPortId					= T.intFromPortId
				  , dblGrossWeight					= T.dblGrossWeight
				  , dtmInitialBuy					= T.dtmInitialBuy
				  , dblWeightPerUnit				= T.dblWeightPerUnit
				  , dblLandedPrice					= T.dblLandedPrice
				  , strLeafCategory					= T.strLeafCategory
				  , strLeafManufacturingType		= T.strLeafManufacturingType
				  , strLeafSize						= T.strLeafSize
				  , strLeafStyle					= T.strLeafStyle
				  , dblPackagesBought				= T.dblPackagesBought
				  , strTeaOrigin					= T.strTeaOrigin
				  --, intOriginalItemId				= T.intOriginalItemId
				  , dblPackagesPerPallet			= T.dblPackagesPerPallet
				  , strPlant						= T.strPlant
				  , dblTotalQuantity				= T.dblTotalQuantity
				  , strSampleBoxNumber				= T.strSampleBoxNumber
				  , dblSellingPrice					= T.dblSellingPrice
				  , dtmStock						= T.dtmStock
				  , strSubChannel					= T.strSubChannel
				  , ysnStrategic					= T.ysnStrategic
				  , strTeaLingoSubCluster			= T.strTeaLingoSubCluster
				  , dtmSupplierPreInvoiceDate		= T.dtmSupplierPreInvoiceDate
				  , strSustainability				= T.strSustainability
				  , strTasterComments				= T.strTasterComments
				  , dblTeaAppearance				= T.dblTeaAppearance
				  , strTeaBuyingOffice				= T.strTeaBuyingOffice
				  , strTeaColour					= T.strTeaColour
				  , strTeaGardenChopInvoiceNumber	= T.strTeaGardenChopInvoiceNumber
				  , intGardenMarkId					= T.intGardenMarkId
				  , strTeaGroup						= T.strTeaGroup
				  , dblTeaHue						= T.dblTeaHue
				  , dblTeaIntensity					= T.dblTeaIntensity
				  , strLeafGrade					= T.strLeafGrade
				  , dblTeaMoisture					= T.dblTeaMoisture
				  , dblTeaMouthFeel					= T.dblTeaMouthFeel
				  , ysnTeaOrganic					= T.ysnTeaOrganic
				  , dblTeaTaste						= T.dblTeaTaste
				  , dblTeaVolume					= T.dblTeaVolume
				  , strFines						= T.strFines
				  , intTealingoItemId				= T.intTealingoItemId
				  , dtmWarehouseArrival				= T.dtmWarehouseArrival
				  , intYearManufacture				= T.intYearManufacture
				  , strPackageSize					= T.strPackageSize
				  , intPackageUOMId					= T.intPackageUOMId
				  , dblTareWeight					= T.dblTareWeight
				  , strTaster						= T.strTaster
				  , strFeedStock					= T.strFeedStock
				  , strFlourideLimit				= T.strFlourideLimit
				  , strLocalAuctionNumber			= T.strLocalAuctionNumber
				  , strPOStatus						= T.strPOStatus
				  , strProductionSite				= T.strProductionSite
				  , strReserveMU					= T.strReserveMU
				  , strQualityComments				= T.strQualityComments
				  , strRareEarth					= T.strRareEarth
				  , strERPPONumber					= T.strERPPONumber
				  , strFreightAgent					= T.strFreightAgent
				  , strSealNumber					= T.strSealNumber
				  , strContainerType				= T.strContainerType
				  , strVoyage						= T.strVoyage
				  , strVessel						= T.strVessel
				  , intConcurrencyId				= intConcurrencyId + 1
				  , intMixingUnitLocationId			= T.intMixingUnitLocationId
				  , dblOriginalTeaTaste				= T.dblOriginalTeaTaste
				  , dblOriginalTeaHue				= T.dblOriginalTeaHue
				  , dblOriginalTeaIntensity			= T.dblOriginalTeaIntensity	
				  , dblOriginalTeaMouthfeel			= T.dblOriginalTeaMouthfeel	
				  , dblOriginalTeaAppearance		= T.dblOriginalTeaAppearance
				  , dblOriginalTeaVolume			= T.dblOriginalTeaVolume
				  , dblOriginalTeaMoisture			= T.dblOriginalTeaMoisture	
				  , intMarketZoneId					= T.intMarketZoneId	
				  , dblTeaTastePinpoint				= T.dblTeaTastePinpoint
				  , dblTeaHuePinpoint				= T.dblTeaHuePinpoint
				  , dblTeaIntensityPinpoint			= T.dblTeaIntensityPinpoint	
				  , dblTeaMouthFeelPinpoint			= T.dblTeaMouthFeelPinpoint	
				  , dblTeaAppearancePinpoint		= T.dblTeaAppearancePinpoint
				  , dtmShippingDate					= T.dtmShippingDate	
				FROM tblMFBatch AS A
				OUTER APPLY (SELECT *
							 FROM @MFBatchTableType
							 WHERE @id = intId) AS T
				WHERE @strBatchId = A.strBatchId AND A.intLocationId = T.intLocationId;

			/* End of Update Existing Batch if @strBatchId is not empty. */
			END

		/* Create new Batch if @strBatchId is empty. */
		ELSE
			BEGIN
				/* Set new value of @strBatchId. */
				IF @ysnCopyBatch = 0
					BEGIN
						EXEC dbo.uspMFGeneratePatternId @intCategoryId = 0
							,@intItemId = 0
							,@intManufacturingId = 0
							,@intSubLocationId = 0
							,@intLocationId = @intBuyingCenterLocationId
							,@intOrderTypeId = NULL
							,@intBlendRequirementId = 0
							,@intPatternCode = 181
							,@ysnProposed = 0
							,@intCountryId=@intCountryId
							,@intMarketZoneId=@intMarketZoneId
							,@strPatternString = @strBatchId OUTPUT

						IF @strBatchId IS NULL
						BEGIN
							EXEC uspSMGetStartingNumber 181, @strBatchId OUT;
						END

					END
				/* End of Set new value of @strBatchId. */
				

				INSERT INTO tblMFBatch 
				(
					strBatchId
				  , intSales
				  , intSalesYear
				  , dtmSalesDate
				  , strTeaType
				  , intBrokerId
				  , strVendorLotNumber
				  , intBuyingCenterLocationId
				  , intStorageLocationId
				  , intStorageUnitId
				  , intBrokerWarehouseId
				  , intParentBatchId
				  , intInventoryReceiptId
				  , intSampleId
				  , intItemUOMId
				  , intWeightUOMId
				  , intContractDetailId
				  , str3PLStatus
				  , strSupplierReference
				  , strAirwayBillCode
				  , strAWBSampleReceived
				  , strAWBSampleReference
				  , dblBasePrice
				  , ysnBoughtAsReserved
				  , dblBoughtPrice
				  , dblBulkDensity
				  , strBuyingOrderNumber
				  , intSubBookId
				  , strContainerNumber
				  , intCurrencyId
				  , dtmProductionBatch
				  , dtmTeaAvailableFrom
				  , strDustContent
				  , ysnEUCompliant
				  , strTBOEvaluatorCode
				  , strEvaluatorRemarks
				  , dtmExpiration
				  , intFromPortId
				  , dblGrossWeight
				  , dtmInitialBuy
				  , dblWeightPerUnit
				  , dblLandedPrice
				  , strLeafCategory
				  , strLeafManufacturingType
				  , strLeafSize
				  , strLeafStyle
				  , dblPackagesBought
				  , strTeaOrigin
				  , intOriginalItemId
				  , dblPackagesPerPallet
				  , strPlant
				  , dblTotalQuantity
				  , strSampleBoxNumber
				  , dblSellingPrice
				  , dtmStock
				  , strSubChannel
				  , ysnStrategic
				  , strTeaLingoSubCluster
				  , dtmSupplierPreInvoiceDate
				  , strSustainability
				  , strTasterComments
				  , dblTeaAppearance
				  , strTeaBuyingOffice
				  , strTeaColour
				  , strTeaGardenChopInvoiceNumber
				  , intGardenMarkId
				  , strTeaGroup
				  , dblTeaHue
				  , dblTeaIntensity
				  , strLeafGrade
				  , dblTeaMoisture
				  , dblTeaMouthFeel
				  , ysnTeaOrganic
				  , dblTeaTaste
				  , dblTeaVolume
				  , strFines
				  , intTealingoItemId
				  , dtmWarehouseArrival
				  , intYearManufacture
				  , strPackageSize
				  , intPackageUOMId
				  , dblTareWeight
				  , strTaster
				  , strFeedStock
				  , strFlourideLimit
				  , strLocalAuctionNumber
				  , strPOStatus
				  , strProductionSite
				  , strReserveMU
				  , strQualityComments
				  , strRareEarth
				  , strERPPONumber
				  , strFreightAgent
				  , strSealNumber
				  , strContainerType
				  , strVoyage
				  , strVessel
				  , intConcurrencyId
				  , intLocationId
				  , intMixingUnitLocationId
				  , dblOriginalTeaTaste
				  , dblOriginalTeaHue
				  , dblOriginalTeaIntensity
				  , dblOriginalTeaMouthfeel
				  , dblOriginalTeaAppearance
				  , dblOriginalTeaVolume
				  , dblOriginalTeaMoisture
				  , intMarketZoneId
				  , dblTeaTastePinpoint
				  , dblTeaHuePinpoint
				  , dblTeaIntensityPinpoint
				  , dblTeaMouthFeelPinpoint
				  , dblTeaAppearancePinpoint
				  , dtmShippingDate
				  ,intSupplierId 
				)
				SELECT (CASE WHEN @ysnCopyBatch = 0 THEN @strBatchId
							 ELSE strBatchId
						END)
					 , intSales
					 , intSalesYear
					 , dtmSalesDate
					 , strTeaType
					 , intBrokerId
					 , strVendorLotNumber
					 , intBuyingCenterLocationId
					 , intStorageLocationId
					 , intStorageUnitId
					 , intBrokerWarehouseId
					 , intParentBatchId
					 , intInventoryReceiptId
					 , intSampleId
					 , intItemUOMId
					 , intWeightUOMId
					 , intContractDetailId
					 , str3PLStatus
					 , strSupplierReference
					 , strAirwayBillCode
					 , strAWBSampleReceived
					 , strAWBSampleReference
					 , dblBasePrice
					 , ysnBoughtAsReserved
					 , dblBoughtPrice
					 , dblBulkDensity
					 , strBuyingOrderNumber
					 , intSubBookId
					 , strContainerNumber
					 , intCurrencyId
					 , dtmProductionBatch
					 , dtmTeaAvailableFrom
					 , strDustContent
					 , ysnEUCompliant
					 , strTBOEvaluatorCode
					 , strEvaluatorRemarks
					 , dtmExpiration
					 , intFromPortId
					 , dblGrossWeight
					 , dtmInitialBuy
					 , dblWeightPerUnit
					 , dblLandedPrice
					 , strLeafCategory
					 , strLeafManufacturingType
					 , strLeafSize
					 , strLeafStyle
					 , dblPackagesBought
					 , strTeaOrigin
					 , intOriginalItemId
					 , dblPackagesPerPallet
					 , strPlant
					 , dblTotalQuantity
					 , strSampleBoxNumber
					 , dblSellingPrice
					 , dtmStock
					 , strSubChannel
					 , ysnStrategic
					 , strTeaLingoSubCluster
					 , dtmSupplierPreInvoiceDate
					 , strSustainability
					 , strTasterComments
					 , dblTeaAppearance
					 , strTeaBuyingOffice
					 , strTeaColour
					 , strTeaGardenChopInvoiceNumber
					 , intGardenMarkId
					 , strTeaGroup
					 , dblTeaHue
					 , dblTeaIntensity
					 , strLeafGrade
					 , dblTeaMoisture
					 , dblTeaMouthFeel
					 , ysnTeaOrganic
					 , dblTeaTaste
					 , dblTeaVolume
					 , strFines
					 , intTealingoItemId
					 , dtmWarehouseArrival
					 , intYearManufacture
					 , strPackageSize
					 , intPackageUOMId
					 , dblTareWeight
					 , strTaster
					 , strFeedStock
					 , strFlourideLimit
					 , strLocalAuctionNumber
					 , strPOStatus
					 , strProductionSite
					 , strReserveMU
					 , strQualityComments
					 , strRareEarth
					 , strERPPONumber
					 , strFreightAgent
					 , strSealNumber
					 , strContainerType
					 , strVoyage
					 , strVessel
					 , 1
					 , intLocationId
					 , intMixingUnitLocationId
					 , dblOriginalTeaTaste
					 , dblOriginalTeaHue
					 , dblOriginalTeaIntensity
					 , dblOriginalTeaMouthfeel
					 , dblOriginalTeaAppearance
					 , dblOriginalTeaVolume
					 , dblOriginalTeaMoisture
					 , intMarketZoneId
					 , dblTeaTastePinpoint
					 , dblTeaHuePinpoint
					 , dblTeaIntensityPinpoint
					 , dblTeaMouthFeelPinpoint
					 , dblTeaAppearancePinpoint
					 , dtmShippingDate
					 , intSupplierId 
				FROM @MFBatchTableType
				WHERE intId = @id;

			/* End of Create new Batch if @strBatchId is empty. */
			END

		SET @intputSuccess = @intputSuccess + 1

		DELETE FROM @tbl WHERE @id = intId;
	END

RETURN 1