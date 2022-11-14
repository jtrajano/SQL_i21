﻿
Create PROCEDURE [dbo].[uspCTProcessContractDetailImport]
	@intUserId INT,
	@strFileName NVARCHAR(100),
	@guiUniqueId UNIQUEIDENTIFIER
AS

BEGIN


	INSERT INTO tblCTContractDetailImportHeader(intUserId, dtmImportDate, guiUniqueId, strFileName)
	SELECT @intUserId, GETDATE(), @guiUniqueId, @strFileName

	DECLARE @intContractDetailImportHeaderId INT

	SET @intContractDetailImportHeaderId = SCOPE_IDENTITY()

	IF ISNULL(@intContractDetailImportHeaderId, 0) <> 0
	BEGIN
		UPDATE tblCTContractDetailImport
		SET intContractDetailImportHeaderId = @intContractDetailImportHeaderId
		WHERE guiUniqueId = @guiUniqueId

		SELECT intContractDetailImportId
			, ci.intContractDetailImportHeaderId
			, ci.strContractNumber
			, ci.intSequence
			, cs.intContractStatusId
			, ci.strStatus
			, ci.dtmStartDate
			, ci.dtmEndDate
			, ci.dtmM2MDate
			, ci.dtmPlannedAvailability
			, ci.dtmEventStartDate
			, ci.dtmUpdatedAvailability
			, intLocationId = cl.intCompanyLocationId
			, ci.strLocation
			, bk.intBookId
			, ci.strBook
			, sbk.intSubBookId
			, ci.strSubBook
			, ci.strContractItem
			, it.intItemId
			, ci.strItem
			, ci.strItemSpecification
			, pg.intPurchasingGroupId
			, ci.strPurchasingGroup
			, ci.strFarmNo
			, ci.strGrade
			, gm.intGardenMarkId
			, ci.strGarden
			, ci.strVendorLotId
			, ci.dblQuantity
			, intQuantityUOMId = qIuom.intItemUOMId
			, ci.strQuantityUOM
			, ci.dblNetWeight
			, intWeightUOMId = wIuom.intItemUOMId
			, ci.strWeightUOM
			, ci.strPackingDescription
			, ci.dblEstYieldPercent
			, ci.dblUnitPerLayer
			, ci.dblLayerPerPallet
			, ci.intNoOfLots
			, conType.intContainerTypeId
			, ci.strContainerType
			, ci.intNoOfContainers
			, mz.intMarketZoneId
			, ci.strMarketZone
			, ci.strDiscount
			, ci.strDiscountTable
			, ci.strScheduleCode
			, ci.strOption
			, ci.strSplit
			, ci.strFixationBy
			, pt.intPricingTypeId
			, ci.strPricingType
			, fMar.intFutureMarketId
			, ci.strFuturesMarket
			, fMon.intFutureMonthId
			, ci.strFutureMonth
			, ci.dblFutures
			, intBasisUOMId = bIuom.intItemUOMId
			, ci.strBasisUOM
			, intBasisCurrencyId = bCur.intCurrencyID
			, ci.strBasisCurrency
			, ci.dblBasis
			, ci.dblCashPrice
			, intPriceUOMId = pIuom.intItemUOMId
			, ci.strPriceUOM
			, intPriceCurrencyId = pCur.intCurrencyID
			, ci.strPriceCurrency
			, ci.dblTotalCost
			, ci.strERPPONo
			, ci.strERPItemNo
			, ci.strERPBatchNo
			, intInvoiceCurrencyId = iCur.intCurrencyID
			, ci.strInvoiceCurrency
			, ci.dtmFXValidFrom
			, ci.dtmFXValidTo
			, ci.strCurrencyPair
			, ci.dblForexRate
			, ci.dblFXPrice
			, ci.ysnPrice
			, ci.strRateType
			, intFXUOMId = fxIuom.intItemUOMId
			, ci.strFXPriceUOM
			, ci.strRemarks
			, ft.intFreightTermId
			, ci.strFreightTerms
			, intShipViaId = sv.intEntityId
			, ci.strShipVia
			, ci.strFarmInvoiceNo
			, ci.strProducer
			, ci.ysnClaimsToProducer
			, ci.ysnFronting
			, ci.ysnInvoice
			, ci.ysnProvisionalInvoice
			, ci.ysnQuantityFinal
			, ci.ysnBackToBack
			, ci.ysnFinalPnL
			, ci.ysnProvisionalPnL
			, ci.strBuyerSellerName
			, ci.strBillTo
			, ci.strOriginDestination
			, ci.strFOBBasis
			, ci.strRailGrade
			, ci.strRailRemarks
			, ci.strLoadingPointType
			, intLoadintPointId = lp.intCityId
			, ci.strLoadingPoint
			, ci.strDestinationPointType
			, intDestinationPointId = dp.intCityId
			, ci.strDestinationPoint
			, intDestinationCityId = dc.intCityId
			, ci.strDestinationCity
			, ci.strShippingTerms
			, ci.strShippineLine
			, ci.strVessel
			, ci.strShipper
			, intStorageLocationId = sl.intCompanyLocationSubLocationId
			, ci.strStorageLocation
			, ci.strStorageUnit
			, ci.strPrintRemarks
			, ci.guiUniqueId
			, ci.ysnImported
			, ci.strMessage
		INTO #tmpList
		FROM tblCTContractDetailImport ci
		LEFT JOIN tblCTContractHeader ch on ch.strContractNumber = ci.strContractNumber collate database_default
		LEFT JOIN tblCTContractStatus cs ON cs.strContractStatus = ci.strStatus collate database_default
		LEFT JOIN tblSMCompanyLocation cl ON cl.strLocationName = ci.strLocation collate database_default
		LEFT JOIN tblCTBook bk ON bk.strBook = ci.strBook collate database_default
		LEFT JOIN tblCTSubBook sbk ON sbk.strSubBook = ci.strSubBook  collate database_default AND bk.intBookId =sbk.intBookId 
		-- Contract Item
		LEFT JOIN tblICItem it ON it.strItemNo = ci.strItem  collate database_default
		LEFT JOIN tblSMPurchasingGroup pg ON pg.strName = ci.strPurchasingGroup  collate database_default
		-- Farm No
		LEFT JOIN tblICUnitMeasure quom ON upper(quom.strUnitMeasure) = upper(ci.strQuantityUOM)  collate database_default
		LEFT JOIN tblICItemUOM qIuom ON qIuom.intItemId = it.intItemId AND qIuom.intUnitMeasureId = quom.intUnitMeasureId
		LEFT JOIN tblICUnitMeasure wuom ON wuom.strUnitMeasure = ci.strWeightUOM  collate database_default
		LEFT JOIN tblICItemUOM wIuom ON wIuom.intItemId = it.intItemId AND wIuom.intUnitMeasureId = wuom.intUnitMeasureId
		LEFT JOIN tblICUnitMeasure puom ON puom.strUnitMeasure = ci.strPriceUOM  collate database_default
		LEFT JOIN tblICItemUOM pIuom ON pIuom.intItemId = it.intItemId AND pIuom.intUnitMeasureId = puom.intUnitMeasureId
		LEFT JOIN tblLGContainerType conType ON conType.strContainerType = ci.strContainerType  collate database_default
		LEFT JOIN tblARMarketZone mz ON mz.strMarketZoneCode = ci.strMarketZone  collate database_default
		 --ci.strDiscount
			--, ci.strDiscountTable
			--, ci.strScheduleCode
			--, ci.strOption
			--, ci.strSplit
		LEFT JOIN tblCTPricingType pt ON pt.strPricingType = ci.strPricingType  collate database_default
		LEFT JOIN tblRKFutureMarket fMar ON fMar.strFutMarketName = ci.strFuturesMarket  collate database_default
		LEFT JOIN tblRKFuturesMonth fMon ON fMon.strFutureMonth = ci.strFutureMonth collate database_default
		LEFT JOIN tblICUnitMeasure buom ON buom.strUnitMeasure = ci.strBasisUOM collate database_default
		LEFT JOIN tblICItemUOM bIuom ON bIuom.intItemId = it.intItemId AND bIuom.intUnitMeasureId = buom.intUnitMeasureId
		LEFT JOIN tblSMCurrency bCur ON bCur.strCurrency = ci.strBasisCurrency  collate database_default
		LEFT JOIN tblSMCurrency pCur ON pCur.strCurrency = ci.strPriceCurrency  collate database_default
		LEFT JOIN tblSMCurrency iCur ON iCur.strCurrency = ci.strInvoiceCurrency collate database_default

			--, ci.strCurrencyPair
			--, ci.strRateType

		LEFT JOIN tblICUnitMeasure fxuom ON fxuom.strUnitMeasure = ci.strFXPriceUOM  collate database_default
		LEFT JOIN tblICItemUOM fxIuom ON fxIuom.intItemId = it.intItemId AND fxIuom.intUnitMeasureId = fxuom.intUnitMeasureId
		LEFT JOIN tblSMFreightTerms ft ON ft.strFreightTerm = ci.strFreightTerms  collate database_default
		LEFT JOIN tblSMShipVia sv ON sv.strShipVia = ci.strShipVia  collate database_default
			--, ci.strProducer
			--, ci.strBillTo
			--, ci.strOriginDestination
			--, ci.strRailGrade
		LEFT JOIN tblSMCity lp ON lp.strCity = ci.strLoadingPoint  collate database_default
		LEFT JOIN tblSMCity dp ON dp.strCity = ci.strDestinationPoint  collate database_default
		LEFT JOIN tblSMCity dc ON dc.strCity = ci.strDestinationCity  collate database_default
		--ci.strShippineLine
			--, ci.strShipper
		LEFT JOIN tblSMCompanyLocationSubLocation sl ON sl.strSubLocationName = ci.strStorageLocation   collate database_default AND sl.intCompanyLocationId = ch.intCompanyLocationId
		-- Storage Unit

		--Garden
		LEFT JOIN tblQMGardenMark gm on gm.strGardenMark = ci.strGarden collate database_default
		
		where ci.guiUniqueId = @guiUniqueId


		IF EXISTS(SELECT TOP 1 1 FROM #tmpList WHERE ISNULL(intItemId, 0) = 0) 
		BEGIN
		
			INSERT INTO tblCTErrorImportLogs
			SELECT guiUniqueId
				   ,'Invalid Item'
				   ,strContractNumber
				   ,intSequence
				   ,'Fail'
				   ,1
			FROM #tmpList 
			WHERE guiUniqueId = @guiUniqueId AND  ISNULL(intItemId, 0) = 0

			
		END
		
		IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intQuantityUOMId,0) = 0 and isnull(intItemId,0) <> 0)
		BEGIN
		INSERT INTO tblCTErrorImportLogs
			SELECT guiUniqueId
				   ,'Invalid Quantity UOM'
				   ,strContractNumber
				   ,intSequence
				   ,'Fail'
				   ,1
			FROM #tmpList 
			WHERE guiUniqueId = @guiUniqueId AND  ISNULL(intQuantityUOMId, 0) = 0 and isnull(intItemId,0) <> 0
		END

		IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intPriceCurrencyId,0) = 0)
		BEGIN
		INSERT INTO tblCTErrorImportLogs
			SELECT guiUniqueId
				   ,'Invalid Price Currency'
				   ,strContractNumber
				   ,intSequence
				   ,'Fail'
				   ,1
			FROM #tmpList 
			WHERE guiUniqueId = @guiUniqueId AND  ISNULL(intPriceCurrencyId, 0) = 0
		END


		IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intPriceUOMId,0) = 0 and isnull(intItemId,0) <> 0)
		BEGIN
		INSERT INTO tblCTErrorImportLogs
			SELECT guiUniqueId
				   ,'Invalid Price UOM'
				   ,strContractNumber
				   ,intSequence
				   ,'Fail'
				   ,1
			FROM #tmpList 
			WHERE guiUniqueId = @guiUniqueId AND  ISNULL(intPriceUOMId, 0) = 0 and isnull(intItemId,0) <> 0
		END

		
		IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intWeightUOMId,0) = 0 and isnull(intItemId,0) <> 0)
		BEGIN
		INSERT INTO tblCTErrorImportLogs
			SELECT guiUniqueId
				   ,'Invalid Weight UOM'
				   ,strContractNumber
				   ,intSequence
				   ,'Fail'
				   ,1
			FROM #tmpList 
			WHERE guiUniqueId = @guiUniqueId AND  ISNULL(intWeightUOMId, 0) = 0 and isnull(intItemId,0) <> 0
		END

		IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intPricingTypeId,0) = 0)
		BEGIN
		INSERT INTO tblCTErrorImportLogs
			SELECT guiUniqueId
				   ,'Invalid Pricing Type'
				   ,strContractNumber
				   ,intSequence
				   ,'Fail'
				   ,1
			FROM #tmpList 
			WHERE guiUniqueId = @guiUniqueId AND  ISNULL(intPricingTypeId, 0) = 0
		END


		IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intBookId,0) = 0 and strBook <> '')
		BEGIN
		INSERT INTO tblCTErrorImportLogs
			SELECT guiUniqueId
				   ,'Invalid Book'
				   ,strContractNumber
				   ,intSequence
				   ,'Fail'
				   ,1
			FROM #tmpList 
			WHERE guiUniqueId = @guiUniqueId AND isnull(intBookId,0) = 0 and strBook <> ''
		END

		IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intSubBookId,0) = 0 and strSubBook <> '')
		BEGIN
		INSERT INTO tblCTErrorImportLogs
			SELECT guiUniqueId
				   ,'Invalid Sub-Book'
				   ,strContractNumber
				   ,intSequence
				   ,'Fail'
				   ,1
			FROM #tmpList 
			WHERE guiUniqueId = @guiUniqueId AND isnull(intSubBookId,0) = 0 and strSubBook <> ''
		END

		IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intPurchasingGroupId,0) = 0 and strPurchasingGroup <> '')
		BEGIN
		INSERT INTO tblCTErrorImportLogs
			SELECT guiUniqueId
				   ,'Invalid Purchasing Group'
				   ,strContractNumber
				   ,intSequence
				   ,'Fail'
				   ,1
			FROM #tmpList 
			WHERE guiUniqueId = @guiUniqueId AND isnull(intPurchasingGroupId,0) = 0 and strPurchasingGroup <> ''
		END

		IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intGardenMarkId,0) = 0 and strGarden <> '')
		BEGIN
		INSERT INTO tblCTErrorImportLogs
			SELECT guiUniqueId
				   ,'Invalid Garden'
				   ,strContractNumber
				   ,intSequence
				   ,'Fail'
				   ,1
			FROM #tmpList 
			WHERE guiUniqueId = @guiUniqueId AND isnull(intGardenMarkId,0) = 0 and strGarden <> ''
		END


		IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intFreightTermId,0) = 0 and strFreightTerms <> '')
		BEGIN
		INSERT INTO tblCTErrorImportLogs
			SELECT guiUniqueId
				   ,'Invalid Freight Term'
				   ,strContractNumber
				   ,intSequence
				   ,'Fail'
				   ,1
			FROM #tmpList 
			WHERE guiUniqueId = @guiUniqueId AND isnull(intFreightTermId,0) = 0 and strFreightTerms <> ''
		END

		IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intLoadintPointId,0) = 0 and strLoadingPoint <> '')
		BEGIN
		INSERT INTO tblCTErrorImportLogs
			SELECT guiUniqueId
				   ,'Invalid Loading Point'
				   ,strContractNumber
				   ,intSequence
				   ,'Fail'
				   ,1
			FROM #tmpList 
			WHERE guiUniqueId = @guiUniqueId AND isnull(intLoadintPointId,0) = 0 and strLoadingPoint <> ''
		END

		IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intDestinationPointId,0) = 0 and strDestinationPoint <> '')
		BEGIN
		INSERT INTO tblCTErrorImportLogs
			SELECT guiUniqueId
				   ,'Invalid Destination Point'
				   ,strContractNumber
				   ,intSequence
				   ,'Fail'
				   ,1
			FROM #tmpList 
			WHERE guiUniqueId = @guiUniqueId AND isnull(intDestinationPointId,0) = 0 and strDestinationPoint <> ''
		END

		IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intStorageLocationId,0) = 0 and strStorageLocation <> '')
		BEGIN
		INSERT INTO tblCTErrorImportLogs
			SELECT guiUniqueId
				   ,'Invalid Storage Location'
				   ,strContractNumber
				   ,intSequence
				   ,'Fail'
				   ,1
			FROM #tmpList 
			WHERE guiUniqueId = @guiUniqueId AND isnull(intStorageLocationId,0) = 0 and strStorageLocation <> ''
		END


		IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intMarketZoneId,0) = 0 and strMarketZone <> '')
		BEGIN
		INSERT INTO tblCTErrorImportLogs
			SELECT guiUniqueId
				   ,'Invalid Market Zone'
				   ,strContractNumber
				   ,intSequence
				   ,'Fail'
				   ,1
			FROM #tmpList 
			WHERE guiUniqueId = @guiUniqueId AND isnull(intMarketZoneId,0) = 0 and strMarketZone <> ''
		END


		SELECT * FROM #tmpList


		DROP TABLE #tmpList

	END
END
