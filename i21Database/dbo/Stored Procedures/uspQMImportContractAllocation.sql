CREATE PROCEDURE uspQMImportContractAllocation
(
	@intImportLogId INT
) 
AS
BEGIN TRY
	DECLARE @strBatchId			NVARCHAR(50)
		  , @intEntityUserId	INT
		  , @strPlantCode		NVARCHAR(50)

	DECLARE @strTxnIdentifier NVARCHAR(36)
			,@intRowCount INT
			,@intRow INT = 0
			,@ysnLastRow BIT
			,@dblAllocatedQty numeric(18,6)
			,@dblContractQuantity  numeric(18,6)
			,@dblContractPrice numeric(18,6)
	DECLARE @intToDeleteBatchLocationId INT
	DECLARE
		@ysnSuccess BIT
		,@strErrorMessage NVARCHAR(MAX)
		,@strReferenceNo NVARCHAR(50)

	SET @strTxnIdentifier = convert(nvarchar(36),NEWID())

	SELECT @intEntityUserId = intEntityId
	FROM tblQMImportLog
	WHERE intImportLogId = @intImportLogId

	BEGIN TRANSACTION

	-- Validate Foreign Key Fields
	UPDATE IMP
	SET strLogResult = 'Incorrect Field(s): ' + REVERSE(SUBSTRING(REVERSE(MSG.strLogMessage), charindex(',', reverse(MSG.strLogMessage)) + 1, len(MSG.strLogMessage)))
		,ysnSuccess = 0
		,ysnProcessed = 1
	FROM tblQMImportCatalogue IMP
	-- Contract Number
	LEFT JOIN tblCTContractHeader CH ON CH.strContractNumber = IMP.strContractNumber
	-- Contract Sequence
	LEFT JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
		AND CD.intContractSeq = IMP.intContractItem
	-- Sample Status
	LEFT JOIN tblQMSampleStatus SAMPLE_STATUS ON SAMPLE_STATUS.strStatus = IMP.strSampleStatus
	-- Group Number
	LEFT JOIN tblCTBook BOOK ON (BOOK.strBook = IMP.strGroupNumber OR BOOK.strBookDescription = IMP.strGroupNumber)
	-- Strategy
	LEFT JOIN tblCTSubBook STRATEGY ON IMP.strStrategy IS NOT NULL AND STRATEGY.strSubBook = IMP.strStrategy AND STRATEGY.intBookId = BOOK.intBookId
	-- Currency
	LEFT JOIN tblSMCurrency CUR ON CUR.strCurrency = IMP.strCurrency
	-- Format log message
	OUTER APPLY (
		SELECT strLogMessage = CASE 
				WHEN (CH.intContractHeaderId IS NULL)
				AND ISNULL(IMP.strContractNumber, '') <> ''
					THEN 'CONTRACT NUMBER, '
				ELSE ''
				END + CASE 
				WHEN (CD.intContractDetailId IS NULL)
				AND ISNULL(IMP.intContractItem, 0) >0
					THEN 'CONTRACT ITEM, '
				ELSE ''
				END + CASE 
				WHEN (
						SAMPLE_STATUS.intSampleStatusId IS NULL
						AND ISNULL(IMP.strSampleStatus, '') <> ''
						)
					THEN 'SAMPLE STATUS, '
				ELSE ''
				END + CASE 
				WHEN (
						BOOK.intBookId IS NULL
				--		AND ISNULL(IMP.strGroupNumber, '') <> ''
						)
					THEN 'GROUP NUMBER, '
				ELSE ''
				END + CASE 
				WHEN (
						STRATEGY.intSubBookId IS NULL
						AND ISNULL(IMP.strStrategy, '') <> ''
						)
					THEN 'STRATEGY, '
				ELSE ''
				END + CASE 
				WHEN (
						CUR.intCurrencyID IS NULL
						--AND ISNULL(IMP.strCurrency, '') <> ''
						)
					THEN 'CURRENCY, '
				ELSE ''
				END+ CASE 
				WHEN (
						CD.intBookId<>BOOK.intBookId
				--		AND ISNULL(IMP.strGroupNumber, '') <> ''
						)
					THEN 'MIXING UNIT, '
				ELSE ''
				END 
		) MSG
	WHERE IMP.intImportLogId = @intImportLogId
		AND IMP.ysnSuccess = 1
		AND (
			(CH.intContractHeaderId IS NULL AND ISNULL(IMP.strContractNumber, '') <> '')
			OR (CD.intContractDetailId IS NULL AND ISNULL(IMP.intContractItem, 0) >0)
			OR (
				SAMPLE_STATUS.intSampleStatusId IS NULL
				AND ISNULL(IMP.strSampleStatus, '') <> ''
				)
			OR (
				BOOK.intBookId IS NULL
			--	AND ISNULL(IMP.strGroupNumber, '') <> ''
				)
			OR (
				STRATEGY.intSubBookId IS NULL
				AND ISNULL(IMP.strStrategy, '') <> ''
				)
			OR (
				CUR.intCurrencyID IS NULL
				--AND ISNULL(IMP.strCurrency, '') <> ''
				)
			OR CD.intBookId<>BOOK.intBookId
			)

	EXECUTE uspQMImportValidationTastingScore @intImportLogId;

	-- End Validation   
	DECLARE @intImportCatalogueId INT
		,@intSampleId INT
		,@intContractHeaderId INT
		,@intContractDetailId INT
		,@intSampleStatusId INT
		,@intBookId INT
		,@intSubBookId INT
		,@dblCashPrice NUMERIC(18, 6)
		,@ysnSampleContractItemMatch BIT
		,@strSampleNumber NVARCHAR(30)
		,@intCurrencyID INT
	DECLARE @MFBatchTableType MFBatchTableType

	IF OBJECT_ID('tempdb..#tmpQMContractLineAllocation') IS NOT NULL
        DROP TABLE #tmpQMContractLineAllocation

	SELECT intImportCatalogueId = IMP.intImportCatalogueId
		,intSampleId = S.intSampleId
		,intContractHeaderId = CH.intContractHeaderId
		,intContractDetailId = CD.intContractDetailId
		,intSampleStatusId = SAMPLE_STATUS.intSampleStatusId
		,intBookId = BOOK.intBookId
		,intSubBookId = STRATEGY.intSubBookId
		,dblCashPrice = IMP.dblBoughtPrice
		,ysnSampleContractItemMatch = CASE 
			WHEN CD.intItemId = S.intItemId
				THEN 1
			ELSE 0
			END
		,strSampleNumber = S.strSampleNumber
		,intCurrencyID = CUR.intCurrencyID
		,strPlantCode=CL.strOregonFacilityNumber
	INTO #tmpQMContractLineAllocation
	FROM tblQMSample S
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
	INNER JOIN tblQMCatalogueType CT ON CT.intCatalogueTypeId = S.intCatalogueTypeId
	INNER JOIN (
		tblEMEntity E INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
		) ON V.intEntityId = S.intEntityId
	INNER JOIN tblQMSaleYear SY ON SY.intSaleYearId = S.intSaleYearId
	INNER JOIN (
		tblQMImportCatalogue IMP
		-- Contract Number
		LEFT JOIN tblCTContractHeader CH ON CH.strContractNumber = IMP.strContractNumber
		-- Contract Sequence
		LEFT JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
			AND CD.intContractSeq = IMP.intContractItem
		-- Sample Status
		LEFT JOIN tblQMSampleStatus SAMPLE_STATUS ON SAMPLE_STATUS.strStatus = IMP.strSampleStatus
		-- Group Number
		LEFT JOIN tblCTBook BOOK ON (BOOK.strBook = IMP.strGroupNumber OR BOOK.strBookDescription = IMP.strGroupNumber)
		-- Strategy
		LEFT JOIN tblCTSubBook STRATEGY ON IMP.strStrategy IS NOT NULL AND STRATEGY.strSubBook = IMP.strStrategy AND STRATEGY.intBookId = BOOK.intBookId
		-- Currency
		LEFT JOIN tblSMCurrency CUR ON IMP.strCurrency IS NOT NULL AND CUR.strCurrency = IMP.strCurrency
		) ON SY.strSaleYear = IMP.strSaleYear
		AND CL.strLocationName = IMP.strBuyingCenter
		AND S.strSaleNumber = IMP.strSaleNumber
		AND CT.strCatalogueType = IMP.strCatalogueType
		AND E.strName = IMP.strSupplier
		AND S.strRepresentLotNumber = IMP.strLotNumber
	WHERE IMP.intImportLogId = @intImportLogId
		AND IMP.ysnSuccess = 1

	SELECT @intRowCount = COUNT(1)
	FROM #tmpQMContractLineAllocation

	-- Loop through each valid import detail
	DECLARE @C AS CURSOR;

	SET @C = CURSOR FAST_FORWARD
	FOR
	SELECT * FROM #tmpQMContractLineAllocation

	OPEN @C

	FETCH NEXT
	FROM @C
	INTO @intImportCatalogueId
		,@intSampleId
		,@intContractHeaderId
		,@intContractDetailId
		,@intSampleStatusId
		,@intBookId
		,@intSubBookId
		,@dblCashPrice
		,@ysnSampleContractItemMatch
		,@strSampleNumber
		,@intCurrencyID
		,@strPlantCode

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @intRow = @intRow + 1
		-- If the contract and sample item does not match, throw an error
		IF @ysnSampleContractItemMatch = 0 AND @intContractDetailId IS NOT NULL
		BEGIN
			UPDATE tblQMImportCatalogue
			SET ysnSuccess = 0
				,ysnProcessed = 1
				,strLogResult = 'The item in contract does not match the item in sample ' + @strSampleNumber + '.'
			WHERE intImportCatalogueId = @intImportCatalogueId

			GOTO CONT
		END

		EXEC uspQMGenerateSampleCatalogueImportAuditLog
			@intSampleId  = @intSampleId
			,@intUserEntityId = @intEntityUserId
			,@strRemarks = 'Updated from Contract Line Allocation Import'
			,@ysnCreate = 0
			,@ysnBeforeUpdate = 1

		--IF EXISTS(
		--	SELECT 1 FROM tblCTContractDetail CD
		--	WHERE CD.intContractDetailId = @intContractDetailId
		--	AND (Select dblUnitQty from tblICItemUOM where intItemUOMId = CD.intItemUOMId) != (select strNoOfPackagesUOM from tblQMImportCatalogue WHERE intImportCatalogueId = @intImportCatalogueId)
		--)
		--BEGIN
		--	UPDATE IC
		--	SET ysnSuccess = 0, ysnProcessed = 1
		--		,strLogResult = 'Allocated Qty UOM does not match the item in contract'
		--	FROM tblQMImportCatalogue IC
		--	WHERE IC.intImportCatalogueId = @intImportCatalogueId
		--	GOTO CONT
		--END

		IF @intContractDetailId IS NOT NULL
		BEGIN
			SELECT @dblAllocatedQty=0
			SELECT @dblContractQuantity=0
			SELECT @dblContractPrice=0

			SELECT @dblAllocatedQty=SUM(dblRepresentingQty) 
			FROM tblQMSample S
			WHERE intContractDetailId = @intContractDetailId
				OR intSampleId = @intSampleId

			SELECT @dblContractQuantity=dblQuantity
					,@strReferenceNo=strReferenceNo  
					,@dblContractPrice=dblCashPrice
			FROM tblCTContractDetail 
			WHERE intContractDetailId = @intContractDetailId
				
			IF @dblAllocatedQty>@dblContractQuantity
			BEGIN
				UPDATE IC
				SET ysnSuccess = 0, ysnProcessed = 1
					,strLogResult = 'Allocated Qty cannot be greater than Contracted Qty'
				FROM tblQMImportCatalogue IC
				WHERE IC.intImportCatalogueId = @intImportCatalogueId
				GOTO CONT
			END
			IF @dblCashPrice>@dblContractPrice
			BEGIN
				UPDATE IC
				SET ysnSuccess = 0, ysnProcessed = 1
					,strLogResult = 'Cash Price is different between catalogue and contract sequence.'
				FROM tblQMImportCatalogue IC
				WHERE IC.intImportCatalogueId = @intImportCatalogueId
				GOTO CONT
			END
		END
		-- Update Sample
		UPDATE S
		SET intConcurrencyId = S.intConcurrencyId + 1
			,intProductTypeId = 8 --Contract Line Item
			,intProductValueId = @intContractDetailId
			,intContractHeaderId = @intContractHeaderId
			,intContractDetailId = @intContractDetailId
			,intSampleStatusId = @intSampleStatusId
			,intBookId = @intBookId
			,intSubBookId = @intSubBookId
			,intCurrencyId = @intCurrencyID
			,strBuyingOrderNo =@strReferenceNo
		FROM tblQMSample S
		WHERE S.intSampleId = @intSampleId

		SELECT @ysnLastRow = CASE WHEN @intRow = @intRowCount THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END

		---- Update Contract Cash Price
		--IF ISNULL(@dblCashPrice, 0) <> 0 AND @intContractDetailId IS NOT NULL
		--	EXEC uspCTUpdateSequencePrice
		--		@intContractDetailId = @intContractDetailId
		--		,@dblNewPrice = @dblCashPrice
		--		,@intUserId = @intEntityUserId
		--		,@strScreen = 'Contract Line Allocation Import'
		--		,@ysnLastRecord = @ysnLastRow
		--		,@strTxnIdentifier = @strTxnIdentifier

		IF @intContractDetailId IS NOT NULL
		BEGIN
			UPDATE tblQMTestResult
			SET intProductTypeId = 8 --Contract Line Item
				,intProductValueId = @intContractDetailId
			WHERE intSampleId = @intSampleId
		END

		UPDATE tblQMImportCatalogue
		SET intSampleId = @intSampleId
		WHERE intImportCatalogueId = @intImportCatalogueId

		SELECT
			@strBatchId = B.strBatchId
			,@intToDeleteBatchLocationId = B.intBuyingCenterLocationId
		FROM tblQMSample S
		INNER JOIN tblMFBatch B ON B.intSampleId = S.intSampleId
		WHERE S.intSampleId = @intSampleId

		IF @strBatchId IS NOT NULL AND @intContractDetailId IS NULL
		BEGIN
			-- Delete batch for both TBO and MU
			EXEC uspMFDeleteBatch
				@strBatchId = @strBatchId
				,@intLocationId = @intToDeleteBatchLocationId
				,@ysnSuccess = @ysnSuccess OUTPUT
				,@strErrorMessage = @strErrorMessage OUTPUT

			IF @ysnSuccess = 0
				UPDATE tblQMImportCatalogue
				SET ysnProcessed = 1, ysnSuccess = 0, strLogResult = @strErrorMessage
				WHERE intImportCatalogueId = @intImportCatalogueId

				GOTO CONT
		END

		-- Call uspMFUpdateInsertBatch
		DELETE
		FROM @MFBatchTableType

		INSERT INTO @MFBatchTableType (
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
			,intBookId
			,dblPackagesBought
			,intItemUOMId
			,intWeightUOMId
			,strTeaOrigin
			,intOriginalItemId
			,dblPackagesPerPallet
			,strPlant
			,dblTotalQuantity
			,strSampleBoxNumber
			,dblSellingPrice
			,dtmStock
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
			,strFines
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
			,intLocationId
			,intMixingUnitLocationId
			,intMarketZoneId
			,dtmShippingDate 
			,intCountryId
			,intSupplierId
			)
		SELECT strBatchId = S.strBatchNo
			,intSales = CAST(S.strSaleNumber AS INT)
			,intSalesYear = CAST(SY.strSaleYear AS INT)
			,dtmSalesDate = S.dtmSaleDate
			,strTeaType = CT.strCatalogueType
			,intBrokerId = S.intBrokerId
			,strVendorLotNumber = S.strRepresentLotNumber
			,intBuyingCenterLocationId = S.intCompanyLocationId
			,intStorageLocationId = CD.intSubLocationId
			,intStorageUnitId = NULL
			,intBrokerWarehouseId = NULL
			,intParentBatchId = NULL
			,intInventoryReceiptId = S.intInventoryReceiptId
			,intSampleId = S.intSampleId
			,intContractDetailId = S.intContractDetailId
			,str3PLStatus = S.str3PLStatus
			,strSupplierReference = S.strAdditionalSupplierReference
			,strAirwayBillCode = S.strCourierRef
			,strAWBSampleReceived = CAST(S.intAWBSampleReceived AS NVARCHAR(50))
			,strAWBSampleReference = S.strAWBSampleReference
			,dblBasePrice = CD.dblCashPrice
			,ysnBoughtAsReserved = S.ysnBoughtAsReserve
			,dblBoughtPrice = CD.dblCashPrice 
			,dblBulkDensity = NULL
			,strBuyingOrderNumber = CD.strReference 
			,intSubBookId = S.intSubBookId
			,strContainerNumber = S.strContainerNumber
			,intCurrencyId = S.intCurrencyId
			,dtmProductionBatch = S.dtmManufacturingDate
			,dtmTeaAvailableFrom = NULL
			,strDustContent = NULL
			,ysnEUCompliant = S.ysnEuropeanCompliantFlag
			,strTBOEvaluatorCode = ECTBO.strName
			,strEvaluatorRemarks = S.strComments3
			,dtmExpiration = NULL
			,intFromPortId = CD.intLoadingPortId
			,dblGrossWeight = S.dblSampleQty +IsNULL(S.dblTareWeight,0) 
			,dtmInitialBuy = NULL
			,dblWeightPerUnit = dbo.fnCalculateQtyBetweenUOM(QIUOM.intItemUOMId, WIUOM.intItemUOMId, 1)
			,dblLandedPrice = NULL
			,strLeafCategory = LEAF_CATEGORY.strAttribute2
			,strLeafManufacturingType = LEAF_TYPE.strDescription
			,strLeafSize = BRAND.strBrandCode
			,strLeafStyle = STYLE.strName
			,intBookId = S.intBookId
			,dblPackagesBought = S.dblRepresentingQty
			,intItemUOMId = S.intSampleUOMId
			,intWeightUOMId = S.intSampleUOMId
			,strTeaOrigin = S.strCountry
			,intOriginalItemId = S.intItemId
			,dblPackagesPerPallet = IsNULL(I.intUnitPerLayer *I.intLayerPerPallet,20)
			,strPlant = @strPlantCode
			,dblTotalQuantity = S.dblSampleQty 
			,strSampleBoxNumber = S.strSampleBoxNumber
			,dblSellingPrice = NULL
			,dtmStock = CD.dtmUpdatedAvailabilityDate 
			,ysnStrategic = NULL
			,strTeaLingoSubCluster = REGION.strDescription
			,dtmSupplierPreInvoiceDate = NULL
			,strSustainability = SUSTAINABILITY.strDescription
			,strTasterComments = S.strComments2
			,dblTeaAppearance = CASE 
				WHEN ISNULL(APPEARANCE.strPropertyValue, '') = ''
					THEN NULL
				ELSE CAST(APPEARANCE.strPropertyValue AS NUMERIC(18, 6))
				END
			,strTeaBuyingOffice = IMP.strBuyingCenter
			,strTeaColour = COLOUR.strDescription
			,strTeaGardenChopInvoiceNumber = S.strChopNumber
			,intGardenMarkId = S.intGardenMarkId
			,strTeaGroup = ISNULL(BRAND.strBrandCode, '') + ISNULL(REGION.strDescription, '') + ISNULL(STYLE.strName, '')
			,dblTeaHue = CASE 
				WHEN ISNULL(HUE.strPropertyValue, '') = ''
					THEN NULL
				ELSE CAST(HUE.strPropertyValue AS NUMERIC(18, 6))
				END
			,dblTeaIntensity = CASE 
				WHEN ISNULL(INTENSITY.strPropertyValue, '') = ''
					THEN NULL
				ELSE CAST(INTENSITY.strPropertyValue AS NUMERIC(18, 6))
				END
			,strLeafGrade = GRADE.strDescription
			,dblTeaMoisture = CASE 
				WHEN ISNULL(MOISTURE.strPropertyValue, '') = ''
					THEN NULL
				ELSE CAST(MOISTURE.strPropertyValue AS NUMERIC(18, 6))
				END
			,dblTeaMouthFeel = CASE 
				WHEN ISNULL(MOUTH_FEEL.strPropertyValue, '') = ''
					THEN NULL
				ELSE CAST(MOUTH_FEEL.strPropertyValue AS NUMERIC(18, 6))
				END
			,ysnTeaOrganic = S.ysnOrganic
			,dblTeaTaste = CASE 
				WHEN ISNULL(TASTE.strPropertyValue, '') = ''
					THEN NULL
				ELSE CAST(TASTE.strPropertyValue AS NUMERIC(18, 6))
				END
			,dblTeaVolume = CASE 
				WHEN ISNULL(VOLUME.strPropertyValue, '') = ''
					THEN NULL
				ELSE CAST(VOLUME.strPropertyValue AS NUMERIC(18, 6))
				END
			,strFines = CASE WHEN ISNULL(FINES.strPropertyValue, '') = '' THEN NULL ELSE FINES.strPropertyValue END
			,intTealingoItemId = S.intItemId
			,dtmWarehouseArrival = NULL
			,intYearManufacture =  Datepart(YYYY,S.dtmManufacturingDate)
			,strPackageSize = NULL
			,intPackageUOMId = S.intRepresentingUOMId
			,dblTareWeight = S.dblTareWeight
			,strTaster = IMP.strTaster
			,strFeedStock = NULL
			,strFlourideLimit = NULL
			,strLocalAuctionNumber = NULL
			,strPOStatus = NULL
			,strProductionSite = NULL
			,strReserveMU = NULL
			,strQualityComments = NULL
			,strRareEarth = NULL
			,strFreightAgent = NULL
			,strSealNumber = NULL
			,strContainerType = NULL
			,strVoyage = NULL
			,strVessel = NULL
			,intLocationId = S.intCompanyLocationId
			,intMixingUnitLocationId=MU.intCompanyLocationId
			,intMarketZoneId = S.intMarketZoneId
			,dtmShippingDate=CD.dtmEtaPol
			,intCountryId=ORIGIN.intCountryID
			,intSupplierId=S.intEntityId
		FROM tblQMSample S
		INNER JOIN tblQMImportCatalogue IMP ON IMP.intSampleId = S.intSampleId
		INNER JOIN tblQMSaleYear SY ON SY.intSaleYearId = S.intSaleYearId
		INNER JOIN tblQMCatalogueType CT ON CT.intCatalogueTypeId = S.intCatalogueTypeId
		INNER JOIN tblICItem I ON I.intItemId = S.intItemId
		LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = S.intContractHeaderId
		LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId  = S.intContractDetailId
		LEFT JOIN tblICCommodityAttribute REGION ON REGION.intCommodityAttributeId = I.intRegionId
		LEFT JOIN tblICCommodityAttribute ORIGIN ON ORIGIN.intCommodityAttributeId = S.intCountryID
		LEFT JOIN tblICBrand BRAND ON BRAND.intBrandId = S.intBrandId
		LEFT JOIN tblCTValuationGroup STYLE ON STYLE.intValuationGroupId = S.intValuationGroupId
		Left JOIN tblCTBook B on B.intBookId =S.intBookId 
		Left JOIN tblSMCompanyLocation MU on MU.strLocationName =B.strBook 
		-- Appearance
		OUTER APPLY (
			SELECT TR.strPropertyValue
			FROM tblQMTestResult TR
			JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
				AND P.strPropertyName = 'Appearance'
			WHERE TR.intSampleId = S.intSampleId
			) APPEARANCE
		-- Hue
		OUTER APPLY (
			SELECT TR.strPropertyValue
			FROM tblQMTestResult TR
			JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
				AND P.strPropertyName = 'Hue'
			WHERE TR.intSampleId = S.intSampleId
			) HUE
		-- Intensity
		OUTER APPLY (
			SELECT TR.strPropertyValue
			FROM tblQMTestResult TR
			JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
				AND P.strPropertyName = 'Intensity'
			WHERE TR.intSampleId = S.intSampleId
			) INTENSITY
		-- Taste
		OUTER APPLY (
			SELECT TR.strPropertyValue
			FROM tblQMTestResult TR
			JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
				AND P.strPropertyName = 'Taste'
			WHERE TR.intSampleId = S.intSampleId
			) TASTE
		-- Mouth Feel
		OUTER APPLY (
			SELECT TR.strPropertyValue
			FROM tblQMTestResult TR
			JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
				AND P.strPropertyName = 'Mouth Feel'
			WHERE TR.intSampleId = S.intSampleId
			) MOUTH_FEEL
		-- Moisture
		OUTER APPLY (
			SELECT TR.strPropertyValue
			FROM tblQMTestResult TR
			JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
				AND P.strPropertyName = 'Moisture'
			WHERE TR.intSampleId = S.intSampleId
			) MOISTURE
		--Volume
		OUTER APPLY (
			SELECT TR.strPropertyValue
				,TR.dblPinpointValue
			FROM tblQMTestResult TR
			JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
				AND P.strPropertyName = 'Volume'
			WHERE TR.intSampleId = S.intSampleId
			) VOLUME
		--Fines
		OUTER APPLY (
			SELECT TR.strPropertyValue
				,TR.dblPinpointValue
			FROM tblQMTestResult TR
			JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
				AND P.strPropertyName = 'Fines'
			WHERE TR.intSampleId = S.intSampleId
			) FINES
		-- Colour
		LEFT JOIN tblICCommodityAttribute COLOUR ON COLOUR.intCommodityAttributeId = S.intSeasonId
		-- Manufacturing Leaf Type
		LEFT JOIN tblICCommodityAttribute LEAF_TYPE ON LEAF_TYPE.intCommodityAttributeId = S.intManufacturingLeafTypeId
		-- Evaluator's Code at TBO
		LEFT JOIN tblEMEntity ECTBO ON ECTBO.intEntityId = S.intEvaluatorsCodeAtTBOId
		-- Leaf Category
		LEFT JOIN tblICCommodityAttribute2 LEAF_CATEGORY ON LEAF_CATEGORY.intCommodityAttributeId2 = S.intLeafCategoryId
		-- Sustainability / Rainforest
		LEFT JOIN tblICCommodityProductLine SUSTAINABILITY ON SUSTAINABILITY.intCommodityProductLineId = S.intProductLineId
		-- Grade
		LEFT JOIN tblICCommodityAttribute GRADE ON GRADE.intCommodityAttributeId = S.intGradeId
		-- Weight Item UOM
		LEFT JOIN tblICItemUOM WIUOM ON WIUOM.intItemId = S.intItemId AND WIUOM.intUnitMeasureId = S.intSampleUOMId
		-- Qty Item UOM
		LEFT JOIN tblICItemUOM QIUOM ON QIUOM.intItemId = S.intItemId AND QIUOM.intUnitMeasureId = S.intRepresentingUOMId
		WHERE S.intSampleId = @intSampleId
			AND IMP.intImportLogId = @intImportLogId
			AND S.intContractDetailId IS NOT NULL
			
		DECLARE @intInput INT
			,@intInputSuccess INT

		IF EXISTS (
				SELECT *
				FROM @MFBatchTableType
				)
		BEGIN
			EXEC uspMFUpdateInsertBatch @MFBatchTableType
				,@intInput
				,@intInputSuccess
				,@strBatchId OUTPUT
				,0

			UPDATE B
			SET B.intLocationId = L.intCompanyLocationId
				,strBatchId = @strBatchId
				,intSampleId=NULL
				,dblOriginalTeaTaste = dblTeaTaste
				,dblOriginalTeaHue = dblTeaHue
				,dblOriginalTeaIntensity = dblTeaIntensity
				,dblOriginalTeaMouthfeel = dblTeaMouthFeel
				,dblOriginalTeaAppearance = dblTeaAppearance
				,strPlant=L.strVendorRefNoPrefix
			FROM @MFBatchTableType B
			JOIN tblCTBook Bk ON Bk.intBookId = B.intBookId
			JOIN tblSMCompanyLocation L ON L.strLocationName = Bk.strBook

			EXEC uspMFUpdateInsertBatch @MFBatchTableType
				,@intInput
				,@intInputSuccess
				,NULL
				,1

			UPDATE tblQMSample
			SET strBatchNo = @strBatchId
			WHERE intSampleId = @intSampleId
		END

		CONT:

		FETCH NEXT
		FROM @C
		INTO @intImportCatalogueId
			,@intSampleId
			,@intContractHeaderId
			,@intContractDetailId
			,@intSampleStatusId
			,@intBookId
			,@intSubBookId
			,@dblCashPrice
			,@ysnSampleContractItemMatch
			,@strSampleNumber
			,@intCurrencyID
			,@strPlantCode
	END

	CLOSE @C

	DEALLOCATE @C

	EXEC uspQMGenerateSampleCatalogueImportAuditLog
		@intUserEntityId = @intEntityUserId
		,@strRemarks = 'Updated from Contract Line Allocation Import'
		,@ysnCreate = 0
		,@ysnBeforeUpdate = 0

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL

	SET @strErrorMsg = ERROR_MESSAGE()

	ROLLBACK TRANSACTION

	RAISERROR (
			@strErrorMsg
			,11
			,1
			)
END CATCH
