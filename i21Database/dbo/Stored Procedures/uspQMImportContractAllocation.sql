CREATE PROCEDURE uspQMImportContractAllocation @intImportLogId INT
AS
BEGIN TRY
	DECLARE @strBatchId NVARCHAR(50)

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
	LEFT JOIN tblCTBook BOOK ON BOOK.strBook = IMP.strGroupNumber
	-- Format log message
	OUTER APPLY (
		SELECT strLogMessage = CASE 
				WHEN (CH.intContractHeaderId IS NULL)
					THEN 'CONTRACT NUMBER, '
				ELSE ''
				END + CASE 
				WHEN (CD.intContractDetailId IS NULL)
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
						AND ISNULL(IMP.strGroupNumber, '') <> ''
						)
					THEN 'GROUP NUMBER, '
				ELSE ''
				END
		) MSG
	WHERE IMP.intImportLogId = @intImportLogId
		AND IMP.ysnSuccess = 1
		AND (
			(CH.intContractHeaderId IS NULL)
			OR (CD.intContractDetailId IS NULL)
			OR (
				SAMPLE_STATUS.intSampleStatusId IS NULL
				AND ISNULL(IMP.strSampleStatus, '') <> ''
				)
			OR (
				BOOK.intBookId IS NULL
				AND ISNULL(IMP.strGroupNumber, '') <> ''
				)
			)

	-- End Validation   
	DECLARE @intImportCatalogueId INT
		,@intSampleId INT
		,@intContractHeaderId INT
		,@intContractDetailId INT
		,@intSampleStatusId INT
		,@intBookId INT
		,@dblCashPrice NUMERIC(18, 6)
		,@ysnSampleContractItemMatch BIT
		,@strSampleNumber NVARCHAR(30)
	DECLARE @MFBatchTableType MFBatchTableType
	-- Loop through each valid import detail
	DECLARE @C AS CURSOR;

	SET @C = CURSOR FAST_FORWARD
	FOR

	SELECT intImportCatalogueId = IMP.intImportCatalogueId
		,intSampleId = S.intSampleId
		,intContractHeaderId = CH.intContractHeaderId
		,intContractDetailId = CD.intContractDetailId
		,intSampleStatusId = SAMPLE_STATUS.intSampleStatusId
		,intBookId = BOOK.intBookId
		,dblCashPrice = IMP.dblBoughtPrice
		,ysnSampleContractItemMatch = CASE 
			WHEN CD.intItemId = S.intItemId
				THEN 1
			ELSE 0
			END
		,strSampleNumber = S.strSampleNumber
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
		LEFT JOIN tblCTBook BOOK ON BOOK.strBook = IMP.strGroupNumber
		) ON SY.strSaleYear = IMP.strSaleYear
		AND CL.strLocationName = IMP.strBuyingCenter
		AND S.strSaleNumber = IMP.strSaleNumber
		AND CT.strCatalogueType = IMP.strCatalogueType
		AND E.strName = IMP.strSupplier
		AND S.strRepresentLotNumber = IMP.strLotNumber
	WHERE IMP.intImportLogId = @intImportLogId
		AND IMP.ysnSuccess = 1

	OPEN @C

	FETCH NEXT
	FROM @C
	INTO @intImportCatalogueId
		,@intSampleId
		,@intContractHeaderId
		,@intContractDetailId
		,@intSampleStatusId
		,@intBookId
		,@dblCashPrice
		,@ysnSampleContractItemMatch
		,@strSampleNumber

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- If the contract and sample item does not match, throw an error
		IF @ysnSampleContractItemMatch = 0
		BEGIN
			UPDATE tblQMImportCatalogue
			SET ysnSuccess = 0
				,ysnProcessed = 1
				,strLogResult = 'The item in contract does not match the item in sample ' + @strSampleNumber + '.'
			WHERE intImportCatalogueId = @intImportCatalogueId

			GOTO CONT
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
		FROM tblQMSample S
		WHERE S.intSampleId = @intSampleId

		-- Update Contract Cash Price
		UPDATE CD
		SET intConcurrencyId = CD.intConcurrencyId + 1
			,dblCashPrice = @dblCashPrice
		FROM tblCTContractDetail CD
		INNER JOIN tblQMSample S ON S.intContractDetailId = CD.intContractDetailId
			AND S.intItemId = CD.intItemId
		WHERE CD.intContractHeaderId = @intContractHeaderId
			AND CD.intContractDetailId = @intContractDetailId

		UPDATE tblQMTestResult
		SET intProductTypeId = 8 --Contract Line Item
			,intProductValueId = @intContractDetailId
		WHERE intSampleId = @intSampleId

		UPDATE tblQMImportCatalogue
		SET intSampleId = @intSampleId
		WHERE intImportCatalogueId = @intImportCatalogueId

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
			)
		SELECT strBatchId = S.strBatchNo
			,intSales = CAST(S.strSaleNumber AS INT)
			,intSalesYear = CAST(SY.strSaleYear AS INT)
			,dtmSalesDate = S.dtmSaleDate
			,strTeaType = LEAF_TYPE.strDescription
			,intBrokerId = S.intBrokerId
			,strVendorLotNumber = S.strRepresentLotNumber
			,intBuyingCenterLocationId = S.intCompanyLocationId
			,intStorageLocationId = S.intStorageLocationId
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
			,dblBasePrice = S.dblBasePrice
			,ysnBoughtAsReserved = S.ysnBoughtAsReserve
			,dblBoughtPrice = NULL
			,dblBulkDensity = NULL
			,strBuyingOrderNumber = IMP.strBuyingOrderNumber
			,intSubBookId = S.intSubBookId
			,strContainerNumber = S.strContainerNumber
			,intCurrencyId = S.intCurrencyId
			,dtmProductionBatch = NULL
			,dtmTeaAvailableFrom = NULL
			,strDustContent = NULL
			,ysnEUCompliant = S.ysnEuropeanCompliantFlag
			,strTBOEvaluatorCode = ECTBO.strName
			,strEvaluatorRemarks = S.strComments3
			,dtmExpiration = NULL
			,intFromPortId = NULL
			,dblGrossWeight = S.dblGrossWeight
			,dtmInitialBuy = NULL
			,dblWeightPerUnit = NULL
			,dblLandedPrice = NULL
			,strLeafCategory = LEAF_CATEGORY.strAttribute2
			,strLeafManufacturingType = LEAF_TYPE.strDescription
			,strLeafSize = BRAND.strBrandCode
			,strLeafStyle = STYLE.strName
			,intBookId = S.intBookId
			,dblPackagesBought = NULL
			,intItemUOMId = S.intRepresentingUOMId
			,intWeightUOMId = S.intSampleUOMId
			,strTeaOrigin = S.strCountry
			,intOriginalItemId = NULL
			,dblPackagesPerPallet = NULL
			,strPlant = NULL
			,dblTotalQuantity = S.dblRepresentingQty
			,strSampleBoxNumber = S.strSampleBoxNumber
			,dblSellingPrice = NULL
			,dtmStock = NULL
			,ysnStrategic = NULL
			,strTeaLingoSubCluster = NULL
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
			,strTeaGroup = NULL
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
			,dblTeaMoisture = NULL
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
			,dblTeaVolume = NULL
			,intTealingoItemId = S.intItemId
			,dtmWarehouseArrival = NULL
			,intYearManufacture = NULL
			,strPackageSize = NULL
			,intPackageUOMId = NULL
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
		FROM tblQMSample S
		INNER JOIN tblQMImportCatalogue IMP ON IMP.intSampleId = S.intSampleId
		INNER JOIN tblQMSaleYear SY ON SY.intSaleYearId = S.intSaleYearId
		LEFT JOIN tblICBrand BRAND ON BRAND.intBrandId = S.intBrandId
		LEFT JOIN tblCTValuationGroup STYLE ON STYLE.intValuationGroupId = S.intValuationGroupId
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
		WHERE S.intSampleId = @intSampleId
			AND IMP.intImportLogId = @intImportLogId
			
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
			FROM @MFBatchTableType B
			JOIN tblCTBook Bk ON Bk.intBookId = B.intBookId
			JOIN tblSMCompanyLocation L ON L.strLocationName = Bk.strBook

			EXEC uspMFUpdateInsertBatch @MFBatchTableType
				,@intInput
				,@intInputSuccess
				,NULL
				,1
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
			,@dblCashPrice
			,@ysnSampleContractItemMatch
			,@strSampleNumber
	END

	CLOSE @C

	DEALLOCATE @C

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
