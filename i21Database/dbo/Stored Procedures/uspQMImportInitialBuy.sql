CREATE PROCEDURE uspQMImportInitialBuy
    @intImportLogId INT
AS

BEGIN TRY
	BEGIN TRANSACTION

    -- Validate Foreign Key Fields
    UPDATE IMP
    SET strLogResult = 'Incorrect Field(s): ' + REVERSE(SUBSTRING(REVERSE(MSG.strLogMessage),charindex(',',reverse(MSG.strLogMessage))+1,len(MSG.strLogMessage)))
        ,ysnSuccess = 0
        ,ysnProcessed = 1
    FROM tblQMImportCatalogue IMP
    -- Buyer1 Quantity UOM
    LEFT JOIN tblICUnitMeasure B1QUOM ON B1QUOM.strSymbol = IMP.strB1QtyUOM
    -- Buyer1 Price UOM
    LEFT JOIN tblICUnitMeasure B1PUOM ON B1PUOM.strSymbol = IMP.strB1PriceUOM
    -- Buyer2 Quantity UOM
    LEFT JOIN tblICUnitMeasure B2QUOM ON B2QUOM.strSymbol = IMP.strB2QtyUOM
    -- Buyer2 Price UOM
    LEFT JOIN tblICUnitMeasure B2PUOM ON B2PUOM.strSymbol = IMP.strB2PriceUOM
    -- Buyer3 Quantity UOM
    LEFT JOIN tblICUnitMeasure B3QUOM ON B3QUOM.strSymbol = IMP.strB3QtyUOM
    -- Buyer3 Price UOM
    LEFT JOIN tblICUnitMeasure B3PUOM ON B3PUOM.strSymbol = IMP.strB3PriceUOM
    -- Buyer1 Company Code
    LEFT JOIN tblSMPurchasingGroup COMPANY_CODE ON COMPANY_CODE.strName = IMP.strB1CompanyCode
    -- Buyer1 Group Number
    LEFT JOIN tblCTBook BOOK ON BOOK.strBook = IMP.strB1GroupNumber
    -- Currency
    LEFT JOIN tblSMCurrency CURRENCY ON CURRENCY.strCurrency = IMP.strCurrency
    -- Format log message
    OUTER APPLY (
        SELECT strLogMessage = 
            CASE WHEN (B1QUOM.intUnitMeasureId IS NULL AND ISNULL(IMP.strB1QtyUOM, '') <> '') THEN 'BUYER1 QTY UOM, ' ELSE '' END
            + CASE WHEN (B1PUOM.intUnitMeasureId IS NULL AND ISNULL(IMP.strB1PriceUOM, '') <> '') THEN 'BUYER1 PRICE UOM, ' ELSE '' END
            + CASE WHEN (B2QUOM.intUnitMeasureId IS NULL AND ISNULL(IMP.strB2QtyUOM, '') <> '') THEN 'BUYER2 QTY UOM, ' ELSE '' END
            + CASE WHEN (B2PUOM.intUnitMeasureId IS NULL AND ISNULL(IMP.strB2PriceUOM, '') <> '') THEN 'BUYER2 PRICE UOM, ' ELSE '' END
            + CASE WHEN (B3QUOM.intUnitMeasureId IS NULL AND ISNULL(IMP.strB3QtyUOM, '') <> '') THEN 'BUYER3 QTY UOM, ' ELSE '' END
            + CASE WHEN (B3PUOM.intUnitMeasureId IS NULL AND ISNULL(IMP.strB3PriceUOM, '') <> '') THEN 'BUYER3 PRICE UOM, ' ELSE '' END
            + CASE WHEN (BOOK.intBookId IS NULL AND ISNULL(IMP.strB1GroupNumber, '') <> '') THEN 'BUYER1 COMPANY CODE, ' ELSE '' END
            + CASE WHEN (COMPANY_CODE.intPurchasingGroupId IS NULL AND ISNULL(IMP.strB1CompanyCode, '') <> '') THEN 'BUYER1 GROUP NUMBER, ' ELSE '' END
            + CASE WHEN (CURRENCY.intConcurrencyId IS NULL AND ISNULL(IMP.strCurrency, '') <> '') THEN 'CURRENCY, ' ELSE '' END
    ) MSG
    WHERE IMP.intImportLogId = @intImportLogId
    AND IMP.ysnSuccess = 1
    AND (
        (B1QUOM.intUnitMeasureId IS NULL AND ISNULL(IMP.strB1QtyUOM, '') <> '')
        OR (B1PUOM.intUnitMeasureId IS NULL AND ISNULL(IMP.strB1PriceUOM, '') <> '')
        OR (B2QUOM.intUnitMeasureId IS NULL AND ISNULL(IMP.strB2QtyUOM, '') <> '')
        OR (B2PUOM.intUnitMeasureId IS NULL AND ISNULL(IMP.strB2PriceUOM, '') <> '')
        OR (B3QUOM.intUnitMeasureId IS NULL AND ISNULL(IMP.strB3QtyUOM, '') <> '')
        OR (B3PUOM.intUnitMeasureId IS NULL AND ISNULL(IMP.strB3PriceUOM, '') <> '')
        OR (COMPANY_CODE.intPurchasingGroupId IS NULL AND ISNULL(IMP.strB1CompanyCode, '') <> '')
        OR (BOOK.intBookId IS NULL AND ISNULL(IMP.strB1GroupNumber, '') <> '')
        OR (CURRENCY.intCurrencyID IS NULL AND ISNULL(IMP.strCurrency, '') <> '')
    )
    -- End Validation   

    DECLARE
        @intImportCatalogueId INT
        ,@intSampleId INT
        ,@intOtherBuyerId INT
        ,@intPurchasingGroupId INT
        ,@strPurchasingGroup NVARCHAR(150)
        ,@intBookId INT
        ,@strBook NVARCHAR(100)
        ,@intCurrencyId INT
        ,@strCurrency NVARCHAR(50)
        ,@dblB1QtyBought NUMERIC(18, 6)
        ,@intB1QtyUOMId INT
        ,@dblB1Price NUMERIC(18, 6)
        ,@intB1PriceUOMId INT
        ,@dblB2QtyBought NUMERIC(18, 6)
        ,@intB2QtyUOMId INT
        ,@dblB2Price NUMERIC(18, 6)
        ,@intB2PriceUOMId INT
        ,@dblB3QtyBought NUMERIC(18, 6)
        ,@intB3QtyUOMId INT
        ,@dblB3Price NUMERIC(18, 6)
        ,@intB3PriceUOMId INT

    DECLARE @MFBatchTableType MFBatchTableType

    -- Loop through each valid import detail
    DECLARE @C AS CURSOR;
	SET @C = CURSOR FAST_FORWARD FOR
        SELECT
            intImportCatalogueId = IMP.intImportCatalogueId
            ,intSampleId = S.intSampleId
            ,intOtherBuyerId = SOB.intOtherBuyerId
            ,intPurchasingGroupId = COMPANY_CODE.intPurchasingGroupId
            ,strPurchasingGroup = COMPANY_CODE.strName
            ,intBookId = BOOK.intBookId
            ,strBook = BOOK.strBook
            ,intCurrencyId = CURRENCY.intCurrencyID
            ,strCurrency = CURRENCY.strCurrency
            ,dblB1QtyBought = IMP.dblB1QtyBought
            ,intB1QtyUOMId = B1QUOM.intUnitMeasureId
            ,dblB1Price = IMP.dblB1Price
            ,intB1PriceUOMId = B1PUOM.intUnitMeasureId
            ,dblB2QtyBought = IMP.dblB2QtyBought
            ,intB2QtyUOMId = B2QUOM.intUnitMeasureId
            ,dblB2Price = IMP.dblB2Price
            ,intB2PriceUOMId = B2PUOM.intUnitMeasureId
            ,dblB3QtyBought = IMP.dblB3QtyBought
            ,intB3QtyUOMId = B3QUOM.intUnitMeasureId
            ,dblB3Price = IMP.dblB3Price
            ,intB3PriceUOMId = B3PUOM.intUnitMeasureId
        FROM tblQMSample S
        INNER JOIN tblQMAuction A ON A.intSampleId = S.intSampleId
        INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
        INNER JOIN tblQMCatalogueType CT ON CT.intCatalogueTypeId = A.intCatalogueTypeId
        INNER JOIN (tblEMEntity E INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId)
            ON V.intEntityId = S.intEntityId
        INNER JOIN (
            tblQMImportCatalogue IMP
            -- Sale Year
            INNER JOIN tblQMSaleYear SY ON SY.strSaleYear = IMP.strSaleYear
            -- Buyer1 Quantity UOM
            LEFT JOIN tblICUnitMeasure B1QUOM ON B1QUOM.strSymbol = IMP.strB1QtyUOM
            -- Buyer1 Price UOM
            LEFT JOIN tblICUnitMeasure B1PUOM ON B1PUOM.strSymbol = IMP.strB1PriceUOM
            -- Buyer2 Quantity UOM
            LEFT JOIN tblICUnitMeasure B2QUOM ON B2QUOM.strSymbol = IMP.strB2QtyUOM
            -- Buyer2 Price UOM
            LEFT JOIN tblICUnitMeasure B2PUOM ON B2PUOM.strSymbol = IMP.strB2PriceUOM
            -- Buyer3 Quantity UOM
            LEFT JOIN tblICUnitMeasure B3QUOM ON B3QUOM.strSymbol = IMP.strB3QtyUOM
            -- Buyer3 Price UOM
            LEFT JOIN tblICUnitMeasure B3PUOM ON B3PUOM.strSymbol = IMP.strB3PriceUOM
            -- Buyer1 Company Code
            LEFT JOIN tblSMPurchasingGroup COMPANY_CODE ON COMPANY_CODE.strName = IMP.strB1CompanyCode
            -- Buyer1 Group Number
            LEFT JOIN tblCTBook BOOK ON BOOK.strBook = IMP.strB1GroupNumber
            -- Currency
            LEFT JOIN tblSMCurrency CURRENCY ON CURRENCY.strCurrency = IMP.strCurrency
        ) ON S.strSaleYear = IMP.strSaleYear
            AND CL.strLocationName = IMP.strBuyingCenter
            AND S.strSaleNumber = IMP.strSaleNumber
            AND CT.strCatalogueType = IMP.strCatalogueType
            AND E.strName = IMP.strSupplier
            AND S.strRepresentLotNumber = IMP.strLotNumber
        LEFT JOIN tblQMSampleOtherBuyers SOB ON SOB.intSampleId = S.intSampleId
        WHERE IMP.intImportLogId = @intImportLogId
            AND IMP.ysnSuccess = 1

    OPEN @C 
	FETCH NEXT FROM @C INTO
		@intImportCatalogueId
        ,@intSampleId
        ,@intOtherBuyerId
        ,@intPurchasingGroupId
        ,@strPurchasingGroup
        ,@intBookId
        ,@strBook
        ,@intCurrencyId
        ,@strCurrency
        ,@dblB1QtyBought
        ,@intB1QtyUOMId
        ,@dblB1Price
        ,@intB1PriceUOMId
        ,@dblB2QtyBought
        ,@intB2QtyUOMId
        ,@dblB2Price
        ,@intB2PriceUOMId
        ,@dblB3QtyBought
        ,@intB3QtyUOMId
        ,@dblB3Price
        ,@intB3PriceUOMId
	WHILE @@FETCH_STATUS = 0
	BEGIN

        UPDATE S
        SET
            intConcurrencyId = A.intConcurrencyId + 1
            ,intCurrencyId = @intCurrencyId
            ,strCurrency = @strCurrency
            ,intPurchaseGroupId = @intPurchasingGroupId
            ,strPurchaseGroup = @strPurchasingGroup
            ,intBookId = @intBookId
        FROM tblQMSample S
        INNER JOIN tblQMAuction A ON A.intSampleId = S.intSampleId
        WHERE S.intSampleId = @intSampleId

        UPDATE S
        SET
            intConcurrencyId = A.intConcurrencyId + 1
            ,intCurrencyId = @intCurrencyId
            ,strCurrency = @strCurrency
            ,intPurchaseGroupId = @intPurchasingGroupId
            ,strPurchaseGroup = @strPurchasingGroup
            ,intBookId = @intBookId
        FROM tblQMSample S
        INNER JOIN tblQMAuction A ON A.intSampleId = S.intSampleId
        WHERE S.intSampleId = @intSampleId

        IF @intOtherBuyerId IS NULL
        BEGIN
            INSERT INTO tblQMSampleOtherBuyers (
                intSampleId
                ,dblB1QtyBought
                ,intB1QtyUOMId
                ,dblB1Price
                ,intB1PriceUOMId
                ,dblB2QtyBought
                ,intB2QtyUOMId
                ,dblB2Price
                ,intB2PriceUOMId
                ,dblB3QtyBought
                ,intB3QtyUOMId
                ,dblB3Price
                ,intB3PriceUOMId
            )
            SELECT
                intSampleId = @intSampleId
                ,dblB1QtyBought = @dblB1QtyBought
                ,intB1QtyUOMId = @intB1QtyUOMId
                ,dblB1Price = @dblB1Price
                ,intB1PriceUOMId = @intB1PriceUOMId
                ,dblB2QtyBought = @dblB2QtyBought
                ,intB2QtyUOMId = @intB2QtyUOMId
                ,dblB2Price = @dblB2Price
                ,intB2PriceUOMId = @intB2PriceUOMId
                ,dblB3QtyBought = @dblB3QtyBought
                ,intB3QtyUOMId = @intB3QtyUOMId
                ,dblB3Price = @dblB3Price
                ,intB3PriceUOMId = @intB3PriceUOMId
        END
        ELSE
        BEGIN
            UPDATE SOB
            SET
                dblB1QtyBought = @dblB1QtyBought
                ,intB1QtyUOMId = @intB1QtyUOMId
                ,dblB1Price = @dblB1Price
                ,intB1PriceUOMId = @intB1PriceUOMId
                ,dblB2QtyBought = @dblB2QtyBought
                ,intB2QtyUOMId = @intB2QtyUOMId
                ,dblB2Price = @dblB2Price
                ,intB2PriceUOMId = @intB2PriceUOMId
                ,dblB3QtyBought = @dblB3QtyBought
                ,intB3QtyUOMId = @intB3QtyUOMId
                ,dblB3Price = @dblB3Price
                ,intB3PriceUOMId = @intB3PriceUOMId
                ,intConcurrencyId = SOB.intConcurrencyId + 1
            FROM tblQMSampleOtherBuyers SOB
            WHERE SOB.intSampleId = @intSampleId
        END

        UPDATE tblQMImportCatalogue
        SET intSampleId = @intSampleId
        WHERE intImportCatalogueId = @intImportCatalogueId

        -- Call uspMFUpdateInsertBatch
        DELETE FROM @MFBatchTableType
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
            strBatchId = S.strBatchNo
            ,intSales = CAST(S.strSaleNumber AS INT)
            ,intSalesYear = CAST(S.strSaleYear AS INT)
            ,dtmSalesDate = S.dtmSaleDate
            ,strTeaType = S.strManufacturingLeafType
            ,intBrokerId = S.intForwardingAgentId
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
            ,ysnBoughtPrice = NULL
            ,dblBulkDensity = NULL
            ,strBuyingOrderNumber = IMP.strBuyingOrderNumber
            ,intSubBookId = S.intSubBookId
            ,strContainerNumber = S.strContainerNumber
            ,intCurrencyId = S.intCurrencyId
            ,dtmProductionBatch = NULL
            ,dtmTeaAvailableFrom = NULL
            ,strDustContent = NULL
            ,ysnEUCompliant = S.ysnEuropeanCompliantFlag
            ,strTBOEvaluatorCode = S.strEvaluatorsCodeAtTBO
            ,strEvaluatorRemarks = S.strComments3
            ,dtmExpiration = NULL
            ,intFromPortId = NULL
            ,dblGrossWeight = S.dblGrossWeight
            ,dtmInitialBuy = NULL
            ,dblWeightPerUnit = NULL
            ,dblLandedPrice = NULL
            ,strLeafCategory = S.strLeafCategory
            ,strLeafManufacturingType = S.strManufacturingLeafType
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
            ,dblSellingPrice = S.dblSupplierValuationPrice
            ,dtmStock = NULL
            ,strSubChannel = IMP.strSubChannel
            ,ysnStrategic = NULL
            ,strTeaLingoSubCluster = NULL
            ,dtmSupplierPreInvoiceDate = NULL
            ,strSustainability = S.strProductLine
            ,strTasterComments = S.strComments2
            ,dblTeaAppearance = CASE WHEN ISNULL(APPEARANCE.strPropertyValue, '') = '' THEN NULL ELSE CAST(APPEARANCE.strPropertyValue AS NUMERIC(18,6)) END
            ,strTeaBuyingOffice = IMP.strBuyingCenter
            ,strTeaColour = COLOUR.strDescription
            ,strTeaGardenChopInvoiceNumber = S.strChopNumber
            ,intGardenMarkId = S.intGardenMarkId
            ,strTeaGroup = NULL
            ,dblTeaHue = CASE WHEN ISNULL(HUE.strPropertyValue, '') = '' THEN NULL ELSE CAST(HUE.strPropertyValue AS NUMERIC(18,6)) END
            ,dblTeaIntensity = CASE WHEN ISNULL(INTENSITY.strPropertyValue, '') = '' THEN NULL ELSE CAST(INTENSITY.strPropertyValue AS NUMERIC(18,6)) END
            ,strLeafGrade = S.strGrade
            ,dblTeaMoisture = NULL
            ,dblTeaMouthFeel = CASE WHEN ISNULL(MOUTH_FEEL.strPropertyValue, '') = '' THEN NULL ELSE CAST(MOUTH_FEEL.strPropertyValue AS NUMERIC(18,6)) END
            ,ysnTeaOrganic = S.ysnOrganic
            ,dblTeaTaste = CASE WHEN ISNULL(TASTE.strPropertyValue, '') = '' THEN NULL ELSE CAST(TASTE.strPropertyValue AS NUMERIC(18,6)) END
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
        FROM tblQMSample S
        INNER JOIN tblQMImportCatalogue IMP ON IMP.intSampleId = S.intSampleId
        LEFT JOIN tblICBrand BRAND ON BRAND.intBrandId = S.intBrandId
        LEFT JOIN tblCTValuationGroup STYLE ON STYLE.intValuationGroupId = S.intValuationGroupId
        -- Appearance
        OUTER APPLY (SELECT TR.strPropertyValue FROM tblQMTestResult TR JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND P.strPropertyName = 'Appearance' WHERE TR.intSampleId = S.intSampleId) APPEARANCE
        -- Hue
        OUTER APPLY (SELECT TR.strPropertyValue FROM tblQMTestResult TR JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND P.strPropertyName = 'Hue' WHERE TR.intSampleId = S.intSampleId) HUE
        -- Intensity
        OUTER APPLY (SELECT TR.strPropertyValue FROM tblQMTestResult TR JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND P.strPropertyName = 'Intensity' WHERE TR.intSampleId = S.intSampleId) INTENSITY
        -- Taste
        OUTER APPLY (SELECT TR.strPropertyValue FROM tblQMTestResult TR JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND P.strPropertyName = 'Taste' WHERE TR.intSampleId = S.intSampleId) TASTE
        -- Mouth Feel
        OUTER APPLY (SELECT TR.strPropertyValue FROM tblQMTestResult TR JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND P.strPropertyName = 'Mouth Feel' WHERE TR.intSampleId = S.intSampleId) MOUTH_FEEL
        -- Colour
        LEFT JOIN tblICCommodityAttribute COLOUR ON COLOUR.intCommodityAttributeId = S.intSeasonId
        WHERE S.intSampleId = @intSampleId
        AND IMP.intImportLogId = @intImportLogId

        DECLARE @intInput INT, @intInputSuccess INT

        EXEC uspMFUpdateInsertBatch @MFBatchTableType, @intInput, @intInputSuccess

        FETCH NEXT FROM @C INTO
            @intImportCatalogueId
            ,@intSampleId
            ,@intOtherBuyerId
            ,@intPurchasingGroupId
            ,@strPurchasingGroup
            ,@intBookId
            ,@strBook
            ,@intCurrencyId
            ,@strCurrency
            ,@dblB1QtyBought
            ,@intB1QtyUOMId
            ,@dblB1Price
            ,@intB1PriceUOMId
            ,@dblB2QtyBought
            ,@intB2QtyUOMId
            ,@dblB2Price
            ,@intB2PriceUOMId
            ,@dblB3QtyBought
            ,@intB3QtyUOMId
            ,@dblB3Price
            ,@intB3PriceUOMId
    END
    CLOSE @C
	DEALLOCATE @C

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL

	SET @strErrorMsg = ERROR_MESSAGE()
    ROLLBACK TRANSACTION

	RAISERROR(@strErrorMsg, 11, 1) 
END CATCH