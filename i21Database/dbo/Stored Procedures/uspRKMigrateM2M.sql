CREATE PROCEDURE [dbo].[uspRKMigrateM2M]

AS

BEGIN
	DECLARE @intM2MInquiryId INT
		, @intM2MHeaderId INT
		, @strRecordName NVARCHAR(50)
		, @ysnByProducer BIT
		, @intCommodityId INT

	SELECT * INTO #tmpOldM2MData FROM tblRKM2MInquiry

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpOldM2MData)
	BEGIN
		SELECT TOP 1 @intM2MInquiryId = intM2MInquiryId
			, @strRecordName = strRecordName
			, @ysnByProducer = ISNULL(ysnByProducer, CAST(0 AS BIT))
			, @intCommodityId = intCommodityId
		FROM #tmpOldM2MData

		IF NOT EXISTS (SELECT TOP 1 1 FROM tblRKM2MHeader WHERE strRecordName = @strRecordName)
		BEGIN
			INSERT INTO tblRKM2MHeader(strRecordName
				, intCommodityId
				, intM2MTypeId
				, intM2MBasisId
				, intFutureSettlementPriceId
				, intPriceUOMId
				, intQtyUOMId
				, intCurrencyId
				, dtmEndDate
				, strRateType
				, intLocationId
				, intMarketZoneId
				, ysnByProducer
				, dtmPostDate
				, dtmReverseDate
				, dtmLastReversalDate
				, ysnPosted
				, dtmCreatedDate
				, dtmUnpostDate
				, strBatchId
				, intCompanyId)
			SELECT strRecordName
				, intCommodityId
				, intM2MTypeId = t.intM2MTypeId
				, intM2MBasisId
				, intFutureSettlementPriceId
				, intPriceUOMId = intPriceItemUOMId
				, intQtyUOMId = intUnitMeasureId
				, intCurrencyId
				, dtmEndDate = dtmTransactionUpTo
				, strRateType
				, intLocationId = intCompanyLocationId
				, intMarketZoneId
				, ysnByProducer
				, dtmPostDate = dtmGLPostDate
				, dtmReverseDate = dtmGLReverseDate
				, dtmLastReversalDate = dtmLastReversalPostDate
				, ysnPosted = ysnPost
				, dtmCreatedDate = dtmCreateDateTime
				, dtmUnpostDate = dtmUnpostedDateTime
				, strBatchId
				, intCompanyId
			FROM #tmpOldM2MData inq
			LEFT JOIN tblRKM2MType t ON t.strType = inq.strPricingType
			WHERE intM2MInquiryId = @intM2MInquiryId

			SET @intM2MHeaderId = SCOPE_IDENTITY()

			INSERT INTO tblRKM2MTransaction(intM2MHeaderId
				, strContractOrInventoryType
				, strContractSeq
				, intEntityId
				, strEntityName
				, intFutureMarketId
				, strFutureMarket
				, intFutureMonthId
				, strFutureMonth
				, dblOpenQty
				, intCommodityId
				, strCommodityCode
				, intItemId
				, strItemNo
				, strOrgin
				, strOriginDest
				, strPosition
				, strPeriod
				, strPeriodTo
				, strStartDate
				, strEndDate
				, strPriOrNotPriOrParPriced
				, intPricingTypeId
				, strPricingType
				, intContractTypeId
				, dblContractBasis
				, dblContractRatio
				, dblFutures
				, dblCash
				, dblContractPrice
				, dblCosts
				, dblAdjustedContractPrice
				, dblMarketBasis
				, dblMarketRatio
				, dblFuturePrice
				, dblContractCash
				, dblMarketPrice
				, dblResult
				, dblResultBasis
				, dblResultRatio
				, dblMarketFuturesResult
				, dblResultCash
				, dblCashPrice
				, intQuantityUOMId
				, intCommodityUnitMeasureId
				, intPriceUOMId
				, intCent
				, intContractHeaderId
				, dtmPlannedAvailabilityDate
				, intContractDetailId
				, dblPricedQty
				, dblUnPricedQty
				, dblPricedAmount
				, intSpreadMonthId
				, strSpreadMonth
				, dblSpreadMonthPrice
				, dblSpread
				, intLocationId
				, strLocationName
				, intMarketZoneId
				, strMarketZoneCode)
			SELECT @intM2MHeaderId
				, t.strContractOrInventoryType
				, t.strContractSeq
				, t.intEntityId
				, strEntityName = e.strName
				, t.intFutureMarketId
				, strFutureMarket = fMar.strFutMarketName
				, t.intFutureMonthId
				, strFutureMonth = fMon.strFutureMonth
				, t.dblOpenQty
				, t.intCommodityId
				, strCommodityCode = c.strCommodityCode
				, t.intItemId
				, strItemNo = i.strItemNo
				, strOrigin = cat.strDescription
				, t.strOriginDest
				, t.strPosition
				, t.strPeriod
				, strPeriodTo = SUBSTRING(CONVERT(NVARCHAR(20),cd.dtmEndDate,106),4,8) COLLATE Latin1_General_CI_AS
				, strStartDate = CONVERT(NVARCHAR(20), cd.dtmStartDate, 106) COLLATE Latin1_General_CI_AS
				, strEndDate = CONVERT(NVARCHAR(20), cd.dtmEndDate, 106) COLLATE Latin1_General_CI_AS
				, t.strPriOrNotPriOrParPriced
				, cd.intPricingTypeId
				, t.strPricingType
				, ch.intContractTypeId
				, t.dblContractBasis
				, t.dblContractRatio
				, t.dblFutures
				, t.dblCash
				, t.dblContractPrice
				, t.dblCosts
				, t.dblAdjustedContractPrice
				, t.dblMarketBasis
				, t.dblMarketRatio
				, t.dblFuturePrice
				, t.dblContractCash
				, t.dblMarketPrice
				, t.dblResult
				, t.dblResultBasis
				, t.dblResultRatio
				, t.dblMarketFuturesResult
				, t.dblResultCash
				, dblCashPrice = t.dblCash
				, intQuantityUOMId = cd.intItemUOMId
				, intCommodityUnitMeasureId = cuom.intCommodityUnitMeasureId
				, intPriceUOMId = cd.intPriceItemUOMId
				, intCent = cur.intCent
				, t.intContractHeaderId
				, t.dtmPlannedAvailabilityDate
				, t.intContractDetailId
				, t.dblPricedQty
				, t.dblUnPricedQty
				, t.dblPricedAmount
				, t.intSpreadMonthId
				, strSpreadMonth = smo.strFutureMonth
				, t.dblSpreadMonthPrice
				, t.dblSpread
				, intLocationId = t.intCompanyLocationId
				, strLocationName = co.strLocationName
				, t.intMarketZoneId
				, strMarketZoneCode = mz.strMarketZoneCode
			FROM tblRKM2MInquiryTransaction t
			LEFT JOIN tblEMEntity e ON t.intEntityId = e.intEntityId
			LEFT JOIN tblRKFutureMarket fMar ON fMar.intFutureMarketId = t.intFutureMarketId
			LEFT JOIN tblRKFuturesMonth fMon ON fMon.intFutureMonthId = t.intFutureMonthId
			LEFT JOIN tblRKFuturesMonth smo ON smo.intFutureMonthId = t.intSpreadMonthId
			LEFT JOIN tblICCommodity c ON c.intCommodityId = t.intCommodityId
			LEFT JOIN tblICItem i ON i.intItemId = t.intItemId
			LEFT JOIN tblICCommodityAttribute cat ON cat.intCommodityAttributeId = i.intOriginId
			LEFT JOIN tblICCommodityUnitMeasure cuom ON cuom.intCommodityId = t.intCommodityId AND cuom.ysnStockUnit = 1
			LEFT JOIN tblARMarketZone mz ON mz.intMarketZoneId = t.intMarketZoneId
			LEFT JOIN tblSMCompanyLocation co ON co.intCompanyLocationId = t.intCompanyLocationId
			LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = t.intContractDetailId
			LEFT JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
			LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = cd.intCurrencyId
			WHERE intM2MInquiryId = @intM2MInquiryId

			INSERT INTO tblRKM2MDifferentialBasis (intM2MHeaderId
				, intCommodityId
				, intItemId
				, strOriginDest
				, intFutureMarketId
				, intFutureMonthId
				, strPeriodTo
				, intLocationId
				, intMarketZoneId
				, intCurrencyId
				, intPricingTypeId
				, strContractInventory
				, intContractTypeId
				, dblCashOrFuture
				, dblBasisOrDiscount
				, dblRatio
				, intUnitMeasureId
				, intM2MBasisDetailId)
			SELECT @intM2MHeaderId
				, intCommodityId
				, intItemId
				, strOriginDest
				, intFutureMarketId
				, intFutureMonthId
				, strPeriodTo
				, intLocationId = intCompanyLocationId
				, intMarketZoneId
				, intCurrencyId
				, intPricingTypeId
				, strContractInventory
				, intContractTypeId
				, dblCashOrFuture
				, dblBasisOrDiscount
				, dblRatio
				, intUnitMeasureId
				, intM2MBasisDetailId
			FROM tblRKM2MInquiryBasisDetail
			WHERE intM2MInquiryId = @intM2MInquiryId

			INSERT INTO tblRKM2MSettlementPrice(intM2MHeaderId
				, intFutureMarketId
				, intFutureMonthId
				, intFutSettlementPriceMonthId
				, dblClosingPrice)
			SELECT @intM2MHeaderId
				, intFutureMarketId
				, intFutureMonthId
				, intFutSettlementPriceMonthId
				, dblClosingPrice
			FROM tblRKM2MInquiryLatestMarketPrice
			WHERE intM2MInquiryId = @intM2MInquiryId

			INSERT INTO tblRKM2MSummary(intM2MHeaderId
				, strSummary
				, intCommodityId
				, strContractOrInventoryType
				, dblQty
				, dblTotal
				, dblFutures
				, dblBasis
				, dblCash)
			SELECT @intM2MHeaderId
				, strSummary
				, intCommodityId
				, strContractOrInventoryType
				, dblQty
				, dblTotal
				, dblFutures
				, dblBasis
				, dblCash
			FROM tblRKM2MInquirySummary
			WHERE intM2MInquiryId = @intM2MInquiryId

			SELECT DISTINCT trans.*
				, strProducer = (CASE WHEN ISNULL(ysnClaimsToProducer, 0) = 1 THEN e.strName ELSE NULL END)
				, intProducerId = (CASE WHEN ISNULL(ysnClaimsToProducer, 0) = 1 THEN ch.intProducerId ELSE NULL END)
			INTO #tmpCPE
			FROM tblRKM2MInquiryTransaction trans
			JOIN tblCTContractDetail ch ON ch.intContractHeaderId = trans.intContractHeaderId
			LEFT JOIN tblEMEntity e ON e.intEntityId = ch.intProducerId
			WHERE trans.intM2MInquiryId = @intM2MInquiryId
	
			DECLARE @tmpCPEDetail TABLE(intM2MHeaderId INT
				, intContractHeaderId INT
				, strContractSeq NVARCHAR(100)
				, strEntityName NVARCHAR(100)
				, intEntityId INT
				, dblMToM NUMERIC(24, 10)
				, dblFixedPurchaseVolume NUMERIC(24, 10)
				, dblUnfixedPurchaseVolume NUMERIC(24, 10)
				, dblTotalValume NUMERIC(24, 10)
				, dblPurchaseOpenQty NUMERIC(24, 10)
				, dblPurchaseContractBasisPrice NUMERIC(24, 10)
				, dblPurchaseFuturesPrice NUMERIC(24, 10)
				, dblPurchaseCashPrice NUMERIC(24, 10)
				, dblFixedPurchaseValue NUMERIC(24, 10)
				, dblUnPurchaseOpenQty NUMERIC(24, 10)
				, dblUnPurchaseContractBasisPrice NUMERIC(24, 10)
				, dblUnPurchaseFuturesPrice NUMERIC(24, 10)
				, dblUnPurchaseCashPrice NUMERIC(24, 10)
				, dblUnfixedPurchaseValue NUMERIC(24, 10)
				, dblTotalCommitedValue NUMERIC(24, 10))

			IF (ISNULL(@ysnByProducer, 0) = 0)
			BEGIN
				INSERT INTO @tmpCPEDetail (intM2MHeaderId
					, intContractHeaderId
					, strContractSeq
					, strEntityName
					, intEntityId
					, dblMToM
					, dblFixedPurchaseVolume
					, dblUnfixedPurchaseVolume
					, dblTotalValume
					, dblPurchaseOpenQty
					, dblPurchaseContractBasisPrice
					, dblPurchaseFuturesPrice
					, dblPurchaseCashPrice
					, dblFixedPurchaseValue
					, dblUnPurchaseOpenQty
					, dblUnPurchaseContractBasisPrice
					, dblUnPurchaseFuturesPrice
					, dblUnPurchaseCashPrice
					, dblUnfixedPurchaseValue
					, dblTotalCommitedValue)
				SELECT intM2MHeaderId = @intM2MHeaderId
					, intContractHeaderId
					, strContractSeq
					, strEntityName
					, intEntityId
					, dblMToM
					, dblFixedPurchaseVolume = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblOpenQty ELSE 0 END)
					, dblUnfixedPurchaseVolume = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblOpenQty ELSE 0 END)
					, dblTotalValume = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblOpenQty ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblOpenQty ELSE 0 END)
					, dblPurchaseOpenQty = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPValueQty ELSE 0 END)
					, dblPurchaseContractBasisPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPContractBasis ELSE 0 END)
					, dblPurchaseFuturesPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPFutures ELSE 0 END)
					, dblPurchaseCashPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPContractBasis ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPFutures ELSE 0 END)
					, dblFixedPurchaseValue = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblQtyPrice ELSE 0 END)
					, dblUnPurchaseOpenQty = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPValueQty ELSE 0 END)
					, dblUnPurchaseContractBasisPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPContractBasis ELSE 0 END)
					, dblUnPurchaseFuturesPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPFutures ELSE 0 END)
					, dblUnPurchaseCashPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPContractBasis ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPFutures ELSE 0 END)
					, dblUnfixedPurchaseValue = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblQtyUnFixedPrice ELSE 0 END)
					, dblTotalCommitedValue = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblQtyPrice ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblQtyUnFixedPrice ELSE 0 END)
				FROM (
					SELECT ch.intContractHeaderId
						, fd.strContractSeq
						, strEntityName = em.strName
						, e.intEntityId
						, fd.dblOpenQty
						, dblMToM = ISNULL(dblResult, 0.00)
						, strPriOrNotPriOrParPriced = (CASE WHEN strPriOrNotPriOrParPriced = 'Partially Priced' THEN 'Unpriced'
															WHEN ISNULL(strPriOrNotPriOrParPriced, '') = '' THEN 'Priced'
															WHEN strPriOrNotPriOrParPriced = 'Fully Priced' THEN 'Priced'
															ELSE strPriOrNotPriOrParPriced END)
						, dblPValueQty = 0.0
						, dblPContractBasis = ISNULL(fd.dblContractBasis, 0)
						, dblPFutures = ISNULL(fd.dblFutures, 0)
						, dblQtyPrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(det.intItemUOMId, 0) = 0 THEN cUOM.intCommodityUnitMeasureId ELSE det.intItemUOMId END
																	, cUOM.intCommodityUnitMeasureId
																	, dbo.fnCTConvertQuantityToTargetCommodityUOM(cUOM.intCommodityUnitMeasureId
																												, ISNULL(det.intPriceItemUOMId, cUOM.intCommodityUnitMeasureId)
																												, fd.dblOpenQty * (ISNULL(fd.dblContractBasis, 0) + ISNULL(fd.dblFutures, 0))))
						, dblUPValueQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(det.intItemUOMId, 0) = 0 THEN cUOM.intCommodityUnitMeasureId ELSE det.intItemUOMId END
																	, cUOM.intCommodityUnitMeasureId
																	, dbo.fnCTConvertQuantityToTargetCommodityUOM(cUOM.intCommodityUnitMeasureId
																												, ISNULL(det.intPriceItemUOMId, cUOM.intCommodityUnitMeasureId)
																												, fd.dblOpenQty))
						, dblUPContractBasis = ISNULL(fd.dblContractBasis, 0)
						, dblUPFutures = ISNULL(fd.dblFuturePrice, 0)
						, dblQtyUnFixedPrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(det.intItemUOMId, 0) = 0 THEN cUOM.intCommodityUnitMeasureId ELSE det.intItemUOMId END
																	, cUOM.intCommodityUnitMeasureId
																	, dbo.fnCTConvertQuantityToTargetCommodityUOM(cUOM.intCommodityUnitMeasureId
																												, ISNULL(det.intPriceItemUOMId, cUOM.intCommodityUnitMeasureId)
																												, fd.dblOpenQty * ((ISNULL(fd.dblContractBasis, 0)) + (ISNULL(fd.dblFuturePrice, 0)))))
					FROM #tmpCPE fd
					JOIN tblCTContractDetail det ON fd.intContractDetailId = det.intContractDetailId
					JOIN tblCTContractHeader ch ON ch.intContractHeaderId = det.intContractHeaderId
					LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = ch.intCommodityId AND cUOM.ysnStockUnit = 1
					JOIN tblICItemUOM ic ON det.intPriceItemUOMId = ic.intItemUOMId
					JOIN tblSMCurrency c ON det.intCurrencyId = c.intCurrencyID
					JOIN tblAPVendor e ON e.intEntityId = fd.intEntityId
					JOIN tblEMEntity em ON em.intEntityId = e.intEntityId
					LEFT JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = @intCommodityId AND cum.intUnitMeasureId = e.intRiskUnitOfMeasureId
					LEFT JOIN tblRKVendorPriceFixationLimit pf ON pf.intVendorPriceFixationLimitId = e.intRiskVendorPriceFixationLimitId
					WHERE strContractOrInventoryType IN ('Contract(P)', 'In-transit(P)', 'Inventory (P)')
				) t
			END
			ELSE
			BEGIN
				INSERT INTO @tmpCPEDetail (intM2MHeaderId
					, intContractHeaderId
					, strContractSeq
					, strEntityName
					, intEntityId
					, dblMToM
					, dblFixedPurchaseVolume
					, dblUnfixedPurchaseVolume
					, dblTotalValume
					, dblPurchaseOpenQty
					, dblPurchaseContractBasisPrice
					, dblPurchaseFuturesPrice
					, dblPurchaseCashPrice
					, dblFixedPurchaseValue
					, dblUnPurchaseOpenQty
					, dblUnPurchaseContractBasisPrice
					, dblUnPurchaseFuturesPrice
					, dblUnPurchaseCashPrice
					, dblUnfixedPurchaseValue
					, dblTotalCommitedValue)
				SELECT intM2MHeaderId = @intM2MHeaderId
					, intContractHeaderId
					, strContractSeq
					, strEntityName
					, intEntityId
					, dblMToM
					, dblFixedPurchaseVolume = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblOpenQty ELSE 0 END)
					, dblUnfixedPurchaseVolume = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblOpenQty ELSE 0 END)
					, dblTotalValume = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblOpenQty ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblOpenQty ELSE 0 END)
					, dblPurchaseOpenQty = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPValueQty ELSE 0 END)
					, dblPurchaseContractBasisPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPContractBasis ELSE 0 END)
					, dblPurchaseFuturesPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPFutures ELSE 0 END)
					, dblPurchaseCashPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPContractBasis ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblPFutures ELSE 0 END)
					, dblFixedPurchaseValue = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblQtyPrice ELSE 0 END)
					, dblUnPurchaseOpenQty = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPValueQty ELSE 0 END)
					, dblUnPurchaseContractBasisPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPContractBasis ELSE 0 END)
					, dblUnPurchaseFuturesPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPFutures ELSE 0 END)
					, dblUnPurchaseCashPrice = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPContractBasis ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblUPFutures ELSE 0 END)
					, dblUnfixedPurchaseValue = (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblQtyUnFixedPrice ELSE 0 END)
					, dblTotalCommitedValue = (CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblQtyPrice ELSE 0 END) + (CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblQtyUnFixedPrice ELSE 0 END)
				FROM(
					SELECT ch.intContractHeaderId
						, fd.strContractSeq
						, strEntityName = ISNULL(strProducer, em.strName)
						, dblMToM = ISNULL(dblResult, 0.00)
						, e.intEntityId
						, fd.dblOpenQty
						, strPriOrNotPriOrParPriced = (CASE WHEN strPriOrNotPriOrParPriced = 'Partially Priced' THEN 'Unpriced'
								WHEN ISNULL(strPriOrNotPriOrParPriced, '') = '' THEN 'Priced'
								WHEN strPriOrNotPriOrParPriced = 'Fully Priced' THEN 'Priced'
								ELSE strPriOrNotPriOrParPriced END)
						, dblPValueQty = 0.0
						, dblPContractBasis = ISNULL(fd.dblContractBasis, 0)
						, dblPFutures = ISNULL(fd.dblFutures, 0)
						, dblQtyPrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(det.intItemUOMId, 0) = 0 THEN cUOM.intCommodityUnitMeasureId ELSE det.intItemUOMId END
																, cUOM.intCommodityUnitMeasureId
																, dbo.fnCTConvertQuantityToTargetCommodityUOM(cUOM.intCommodityUnitMeasureId
																											, ISNULL(det.intPriceItemUOMId, cUOM.intCommodityUnitMeasureId)
																											, fd.dblOpenQty * (ISNULL(fd.dblContractBasis, 0) + ISNULL(fd.dblFutures, 0))))
						, dblUPValueQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(det.intItemUOMId, 0) = 0 THEN cUOM.intCommodityUnitMeasureId ELSE det.intItemUOMId END
																, cUOM.intCommodityUnitMeasureId
																, dbo.fnCTConvertQuantityToTargetCommodityUOM(cUOM.intCommodityUnitMeasureId
																											, ISNULL(det.intPriceItemUOMId, cUOM.intCommodityUnitMeasureId)
																											, fd.dblOpenQty))
						, dblUPContractBasis = ISNULL(fd.dblContractBasis, 0)
						, dblUPFutures = ISNULL(fd.dblFuturePrice, 0)
						, dblQtyUnFixedPrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(det.intItemUOMId, 0) = 0 THEN cUOM.intCommodityUnitMeasureId ELSE det.intItemUOMId END
																, cUOM.intCommodityUnitMeasureId
																, dbo.fnCTConvertQuantityToTargetCommodityUOM(cUOM.intCommodityUnitMeasureId
																											, ISNULL(det.intPriceItemUOMId, cUOM.intCommodityUnitMeasureId)
																											, fd.dblOpenQty * (ISNULL(fd.dblContractBasis, 0) + ISNULL(fd.dblFuturePrice, 0))))
					FROM #tmpCPE fd
					JOIN tblCTContractDetail det ON fd.intContractDetailId = det.intContractDetailId
					JOIN tblCTContractHeader ch ON ch.intContractHeaderId = det.intContractHeaderId
					JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = ch.intCommodityId AND cUOM.ysnStockUnit = 1
					JOIN tblICItemUOM ic ON det.intPriceItemUOMId = ic.intItemUOMId
					JOIN tblSMCurrency c ON det.intCurrencyId = c.intCurrencyID
					LEFT JOIN tblAPVendor e ON e.intEntityId = fd.intProducerId
					LEFT JOIN tblEMEntity em ON em.intEntityId = e.intEntityId
					LEFT JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = @intCommodityId AND cum.intUnitMeasureId = e.intRiskUnitOfMeasureId
					LEFT JOIN tblRKVendorPriceFixationLimit pf ON pf.intVendorPriceFixationLimitId = e.intRiskVendorPriceFixationLimitId
					LEFT JOIN tblAPVendor e1 ON e1.intEntityId = fd.intEntityId
					LEFT JOIN tblICCommodityUnitMeasure cum1 ON cum1.intCommodityId = @intCommodityId AND cum1.intUnitMeasureId = e1.intRiskUnitOfMeasureId
					LEFT JOIN tblRKVendorPriceFixationLimit pf1 ON pf1.intVendorPriceFixationLimitId = e1.intRiskVendorPriceFixationLimitId
					WHERE strContractOrInventoryType IN ('Contract(P)', 'In-transit(P)', 'Inventory (P)')
				) t
			END

			INSERT INTO tblRKM2MCounterPartyExposure(intM2MHeaderId
				, intVendorId
				, intContractHeaderId
				, strContractSeq
				, strEntityName
				, dblMToM
				, dblFixedPurchaseVolume
				, dblUnfixedPurchaseVolume
				, dblPurchaseOpenQty
				, dblPurchaseContractBasisPrice
				, dblPurchaseFuturesPrice
				, dblPurchaseCashPrice
				, dblFixedPurchaseValue
				, dblUnPurchaseOpenQty
				, dblUnPurchaseContractBasisPrice
				, dblUnPurchaseFuturesPrice
				, dblUnPurchaseCashPrice
				, dblUnfixedPurchaseValue)
			SELECT @intM2MHeaderId
				, intEntityId
				, intContractHeaderId
				, strContractSeq
				, strEntityName
				, dblMToM
				, dblFixedPurchaseVolume
				, dblUnfixedPurchaseVolume
				, dblPurchaseOpenQty
				, dblPurchaseContractBasisPrice
				, dblPurchaseFuturesPrice
				, dblPurchaseCashPrice
				, dblFixedPurchaseValue
				, dblUnPurchaseOpenQty
				, dblUnPurchaseContractBasisPrice
				, dblUnPurchaseFuturesPrice
				, dblUnPurchaseCashPrice
				, dblUnfixedPurchaseValue
			FROM @tmpCPEDetail

			DROP TABLE #tmpCPE

			INSERT INTO tblRKM2MPostPreview(dtmDate
			, strBatchId
			, strReversalBatchId
			, intAccountId
			, strAccountId
			, strAccountGroup
			, dblDebit
			, dblCredit
			, dblDebitForeign
			, dblCreditForeign
			, dblDebitUnit
			, dblCreditUnit
			, strDescription
			, strCode
			, strReference
			, intCurrencyId
			, dblExchangeRate
			, dtmDateEntered
			, dtmTransactionDate
			, strJournalLineDescription
			, intJournalLineNo
			, ysnIsUnposted
			, intUserId
			, intEntityId
			, strTransactionId
			, intTransactionId
			, strTransactionType
			, strTransactionForm
			, strModuleName
			, strRateType
			, intM2MHeaderId
			, intSourceLocationId
			, intSourceUOMId
			, dblPrice)
		SELECT dtmDate
			, strBatchId
			, strReversalBatchId
			, intAccountId
			, strAccountId
			, strAccountGroup
			, dblDebit
			, dblCredit
			, dblDebitForeign
			, dblCreditForeign
			, dblDebitUnit
			, dblCreditUnit
			, strDescription
			, strCode
			, strReference
			, intCurrencyId
			, dblExchangeRate
			, dtmDateEntered
			, dtmTransactionDate
			, strJournalLineDescription
			, intJournalLineNo
			, ysnIsUnposted
			, intUserId
			, intEntityId
			, strTransactionId
			, intTransactionId
			, strTransactionType
			, strTransactionForm
			, strModuleName
			, strRateType
			, @intM2MHeaderId
			, intSourceLocationId
			, intSourceUOMId
			, dblPrice
		FROM tblRKM2MPostRecap
		WHERE intM2MInquiryId = @intM2MInquiryId
		END

		DELETE FROM #tmpOldM2MData WHERE intM2MInquiryId = @intM2MInquiryId
	END
END