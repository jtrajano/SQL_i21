CREATE PROCEDURE [dbo].[uspRKM2MVendorExposure]
	@intM2MBasisId INT = NULL
	, @intFutureSettlementPriceId INT = NULL
	, @intQuantityUOMId INT = NULL
	, @intPriceUOMId INT = NULL
	, @intCurrencyUOMId INT = NULL
	, @dtmTransactionDateUpTo DATETIME = NULL
	, @strRateType NVARCHAR(200) = NULL
	, @intCommodityId INT = NULL
	, @intLocationId INT = NULL
	, @intMarketZoneId INT = NULL
	, @ysnVendorProducer BIT = NULL

AS

BEGIN
	DECLARE @tblFinalDetail TABLE (intRowNum INT
		, intConcurrencyId INT
		, intContractHeaderId INT
		, intContractDetailId INT
		, strContractOrInventoryType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strContractSeq NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strEntityName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intEntityId INT
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblOpenQty NUMERIC(24, 10)
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityId INT
		, intItemId INT
		, strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strOrgin NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strPosition NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strPeriod NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strPeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strStartDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strEndDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strPriOrNotPriOrParPriced NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intPricingTypeId INT
		, strPricingType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblContractRatio NUMERIC(24, 10)
		, dblContractBasis NUMERIC(24, 10)
		, dblFutures NUMERIC(24, 10)
		, dblCash NUMERIC(24, 10)
		, dblCosts NUMERIC(24, 10)
		, dblMarketBasis NUMERIC(24, 10)
		, dblMarketRatio NUMERIC(24, 10)
		, dblFuturePrice NUMERIC(24, 10)
		, intContractTypeId INT
		, dblAdjustedContractPrice NUMERIC(24, 10)
		, dblCashPrice NUMERIC(24, 10)
		, dblMarketPrice NUMERIC(24, 10)
		, dblResultBasis NUMERIC(24, 10)
		, dblResultCash NUMERIC(24, 10)
		, dblContractPrice NUMERIC(24, 10)
		, intQuantityUOMId INT
		, intCommodityUnitMeasureId INT
		, intPriceUOMId INT
		, intCent INT
		, dtmPlannedAvailabilityDate DATETIME
		, dblPricedQty NUMERIC(24, 10)
		, dblUnPricedQty NUMERIC(24, 10)
		, dblPricedAmount NUMERIC(24, 10)
		, intMarketZoneId INT
		, intCompanyLocationId INT
		, strMarketZoneCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblResult NUMERIC(24, 10)
		, dblMarketFuturesResult NUMERIC(24, 10)
		, dblResultRatio NUMERIC(24, 10)
		, intSpreadMonthId INT
		, strSpreadMonth NVARCHAR(50)
		, dblSpreadMonthPrice NUMERIC(24, 20)
		, dblSpread NUMERIC(24, 10))
	
	INSERT INTO @tblFinalDetail
	EXEC [uspRKM2MInquiryTransaction] @intM2MBasisId = @intM2MBasisId
		, @intFutureSettlementPriceId = @intFutureSettlementPriceId
		, @intQuantityUOMId = @intQuantityUOMId
		, @intPriceUOMId = @intPriceUOMId
		, @intCurrencyUOMId = @intCurrencyUOMId
		, @dtmTransactionDateUpTo = @dtmTransactionDateUpTo
		, @strRateType = @strRateType
		, @intCommodityId =@intCommodityId
		, @intLocationId = @intLocationId
		, @intMarketZoneId = @intMarketZoneId
	
	SELECT DISTINCT cd.*
		, strProducer = CASE WHEN ISNULL(ysnClaimsToProducer, 0) = 1 THEN e.strName ELSE NULL END
		, intProducerId = CASE WHEN ISNULL(ysnClaimsToProducer, 0) = 1 THEN ch.intProducerId ELSE NULL END
	INTO #temp
	FROM @tblFinalDetail cd
	JOIN tblCTContractDetail ch ON ch.intContractHeaderId = cd.intContractHeaderId
	LEFT JOIN tblEMEntity e ON e.intEntityId = ch.intProducerId
	
	IF (ISNULL(@ysnVendorProducer, 0) = 0)
	BEGIN
		SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strVendorName)) intRowNum
			, strVendorName
			, intEntityId intVendorId
			, strRating
			, dblFixedPurchaseVolume = CONVERT(NUMERIC(16, 2), dblFixedPurchaseVolume)
			, dblUnfixedPurchaseVolume = CONVERT(NUMERIC(16,2),dblUnfixedPurchaseVolume)
			, dblTotalCommittedVolume = CONVERT(NUMERIC(16, 2), dblTotalCommittedVolume)
			, dblFixedPurchaseValue = CONVERT(NUMERIC(16, 2), dblFixedPurchaseValue)
			, dblUnfixedPurchaseValue = CONVERT(NUMERIC(16, 2), dblUnfixedPurchaseValue)
			, dblTotalCommittedValue = CONVERT(NUMERIC(16, 2), dblTotalCommittedValue)
			, dblTotalSpend = CONVERT(NUMERIC(16, 2), dblTotalSpend)
			, dblShareWithSupplier
			, dblMToM
			, dblCompanyExposurePercentage
			, dblPotentialAdditionalVolume = CASE WHEN (ISNULL(dblPotentialAdditionalVolume, 0) - ISNULL(dblTotalCommittedVolume, 0)) < 0 THEN 0
												ELSE (ISNULL(dblPotentialAdditionalVolume, 0) - ISNULL(dblTotalCommittedVolume, 0)) END
			, intConcurrencyId = 0
		FROM (
			SELECT strVendorName
				, intEntityId
				, strRating
				, dblFixedPurchaseVolume
				, dblUnfixedPurchaseVolume
				, dblTotalCommittedVolume
				, dblFixedPurchaseValue
				, dblUnfixedPurchaseValue
				, dblTotalCommittedValue
				, dblTotalSpend = CONVERT(NUMERIC(16, 2), dblTotalSpend)
				, dblShareWithSupplier = CONVERT(NUMERIC(16, 2), dblShareWithSupplier)
				, dblMToM
				, dblCompanyExposurePercentage
				, a = (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend, 0) = 0 THEN 1 ELSE dblTotalSpend END) * dblCompanyExposurePercentage
				, b = (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier, 0) = 0 THEN 1 ELSE dblShareWithSupplier END) * dblSupplierSalesPercentage
				, dblPotentialAdditionalVolume = CASE WHEN CASE WHEN ISNULL(dblTotalSpend, 0) = 0 THEN 1 ELSE dblTotalSpend END > dblCompanyExposurePercentage THEN 0
													WHEN CASE WHEN ISNULL(dblShareWithSupplier, 0) = 0 THEN 1 ELSE dblShareWithSupplier END > dblSupplierSalesPercentage THEN 0
													WHEN (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend, 0) = 0 THEN 1 ELSE dblTotalSpend END) * dblCompanyExposurePercentage
														<= (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier, 0) = 0 THEN 1 ELSE dblShareWithSupplier END) * dblSupplierSalesPercentage
														THEN (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend, 0) = 0 THEN 1 ELSE dblTotalSpend END) * dblCompanyExposurePercentage
													ELSE (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier, 0) = 0 THEN 1 ELSE dblShareWithSupplier END) * dblSupplierSalesPercentage END
			FROM (
				SELECT strVendorName = strEntityName
					, intEntityId
					, strRating = strRiskIndicator
					, dblFixedPurchaseVolume
					, dblUnfixedPurchaseVolume
					, dblTotalCommittedVolume
					, dblFixedPurchaseValue
					, dblUnfixedPurchaseValue
					, dblTotalCommittedValue
					, dblTotalSpend = (ISNULL(dblTotalCommittedValue, 0)/ SUM(CASE WHEN ISNULL(dblTotalCommittedValue, 0) = 0 THEN 1 ELSE dblTotalCommittedValue END) OVER ()) * 100
					, dblShareWithSupplier = (CASE WHEN ISNULL(dblRiskTotalBusinessVolume, 0) = 0 THEN 0 ELSE ISNULL(dblTotalCommittedVolume, 0) / dblRiskTotalBusinessVolume END) * 100
					, dblMToM = dblResult
					, dblCompanyExposurePercentage
					, dblSupplierSalesPercentage
				FROM (
					SELECT strEntityName
						, intEntityId
						, dblFixedPurchaseVolume
						, dblUnfixedPurchaseVolume
						, dblTotalCommittedVolume = dblFixedPurchaseVolume + dblUnfixedPurchaseVolume
						, dblFixedPurchaseValue
						, dblUnfixedPurchaseValue
						, dblTotalCommittedValue = dblFixedPurchaseValue + dblUnfixedPurchaseValue
						, dblResult
						, strRiskIndicator
						, intRiskUnitOfMeasureId
						, dblRiskTotalBusinessVolume
						, dblCompanyExposurePercentage
						, dblSupplierSalesPercentage
					FROM (
						SELECT strEntityName
							, intEntityId
							, dblFixedPurchaseVolume = SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblOpenQty ELSE 0 END)
							, dblUnfixedPurchaseVolume = SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblOpenQty ELSE 0 END)
							, dblFixedPurchaseValue = SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblQtyPrice ELSE 0 END)
							, dblUnfixedPurchaseValue = SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblQtyUnFixedPrice ELSE 0 END)
							, dblResult = SUM(dblResult)
							, strRiskIndicator
							, dblRiskTotalBusinessVolume
							, intRiskUnitOfMeasureId
							, dblCompanyExposurePercentage
							, dblSupplierSalesPercentage
						FROM (
							SELECT strEntityName
								, intEntityId
								, dblOpenQty = SUM(dblOpenQty)
								, dblQtyPrice = SUM(dblQtyPrice)
								, dblQtyUnFixedPrice = SUM(dblQtyUnFixedPrice)
								, strPriOrNotPriOrParPriced
								, dblResult = SUM(dblResult)
								, strRiskIndicator
								, dblRiskTotalBusinessVolume
								, intRiskUnitOfMeasureId
								, dblCompanyExposurePercentage
								, dblSupplierSalesPercentage
							FROM (
								SELECT fd.strEntityName
									, fd.intEntityId
									, fd.dblOpenQty
									, dblQtyPrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN fd.intCommodityUnitMeasureId ELSE intQuantityUOMId END
																				, fd.intCommodityUnitMeasureId
																				, dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId
																															, ISNULL(intPriceUOMId, fd.intCommodityUnitMeasureId)
																															, fd.dblOpenQty * ((ISNULL(fd.dblContractBasis, 0)) + (ISNULL(fd.dblFutures, 0)))))
									, dblQtyUnFixedPrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN fd.intCommodityUnitMeasureId ELSE intQuantityUOMId END
																				, fd.intCommodityUnitMeasureId
																				, dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId
																															, ISNULL(intPriceUOMId, fd.intCommodityUnitMeasureId)
																															, fd.dblOpenQty * ((ISNULL(fd.dblContractBasis, 0)) + (ISNULL(fd.dblFuturePrice, 0)))))
									, strPriOrNotPriOrParPriced = CASE WHEN strPriOrNotPriOrParPriced = 'Partially Priced' THEN 'Unpriced'
																		WHEN ISNULL(strPriOrNotPriOrParPriced, '') = '' THEN 'Priced'
																		WHEN strPriOrNotPriOrParPriced = 'Fully Priced' THEN 'Priced'
																		ELSE strPriOrNotPriOrParPriced END
									, dblResult = ROUND(ISNULL(dblResult, 0), 2)
									, strRiskIndicator
									, dblRiskTotalBusinessVolume = dbo.fnCTConvertQuantityToTargetCommodityUOM(cum.intCommodityUnitMeasureId
																				, CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN fd.intCommodityUnitMeasureId ELSE intQuantityUOMId END
																				, dblRiskTotalBusinessVolume)
									, intRiskUnitOfMeasureId
									, dblCompanyExposurePercentage = ROUND(ISNULL(dblCompanyExposurePercentage, 0), 2)
									, dblSupplierSalesPercentage = ROUND(ISNULL(dblSupplierSalesPercentage, 0), 2)
								FROM #temp fd
								JOIN tblCTContractDetail det ON fd.intContractDetailId = det.intContractDetailId
								JOIN tblICItemUOM ic ON det.intPriceItemUOMId = ic.intItemUOMId
								JOIN tblSMCurrency c ON det.intCurrencyId = c.intCurrencyID
								JOIN tblAPVendor e ON e.intEntityId = fd.intEntityId
								LEFT JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = @intCommodityId AND cum.intUnitMeasureId = e.intRiskUnitOfMeasureId
								LEFT JOIN tblRKVendorPriceFixationLimit pf ON pf.intVendorPriceFixationLimitId = e.intRiskVendorPriceFixationLimitId
								WHERE strContractOrInventoryType IN ('Contract(P)', 'In-transit(P)', 'Inventory (P)')
							) t
							GROUP BY strEntityName
								, strPriOrNotPriOrParPriced
								, strRiskIndicator
								, dblRiskTotalBusinessVolume
								, intRiskUnitOfMeasureId
								, dblCompanyExposurePercentage
								, dblSupplierSalesPercentage
								, intEntityId
						) t1
						GROUP BY strEntityName
							, strRiskIndicator
							, dblRiskTotalBusinessVolume
							, intRiskUnitOfMeasureId
							, dblCompanyExposurePercentage
							, dblSupplierSalesPercentage
							, intEntityId
					)t2
				)t2
			)t3
		)t4
	END
	ELSE
	BEGIN
		SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strVendorName)) intRowNum
			, strVendorName
			, intVendorId = intEntityId
			, strRating
			, dblFixedPurchaseVolume = CONVERT(NUMERIC(16, 2), dblFixedPurchaseVolume)
			, dblUnfixedPurchaseVolume = CONVERT(NUMERIC(16, 2), dblUnfixedPurchaseVolume)
			, dblTotalCommittedVolume = CONVERT(NUMERIC(16, 2), dblTotalCommittedVolume)
			, dblFixedPurchaseValue = CONVERT(NUMERIC(16, 2), dblFixedPurchaseValue)
			, dblUnfixedPurchaseValue = CONVERT(NUMERIC(16, 2), dblUnfixedPurchaseValue)
			, dblTotalCommittedValue = CONVERT(NUMERIC(16, 2), dblTotalCommittedValue)
			, dblTotalSpend = CONVERT(NUMERIC(16, 2), dblTotalSpend)
			, dblShareWithSupplier
			, dblMToM
			, dblCompanyExposurePercentage
			, dblPotentialAdditionalVolume = CASE WHEN (ISNULL(dblPotentialAdditionalVolume, 0) - ISNULL(dblTotalCommittedVolume, 0)) < 0 THEN 0 ELSE (ISNULL(dblPotentialAdditionalVolume, 0) - ISNULL(dblTotalCommittedVolume, 0)) END
			, intConcurrencyId = 0
		FROM (
			SELECT strVendorName
				, intEntityId
				, strRating
				, dblFixedPurchaseVolume
				, dblUnfixedPurchaseVolume
				, dblTotalCommittedVolume
				, dblFixedPurchaseValue
				, dblUnfixedPurchaseValue
				, dblTotalCommittedValue
				, dblTotalSpend = CONVERT(NUMERIC(16, 2), dblTotalSpend)
				, dblShareWithSupplier = CONVERT(NUMERIC(16, 2), dblShareWithSupplier)
				, dblMToM
				, dblCompanyExposurePercentage
				, a = (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend, 0) = 0 THEN 1 ELSE dblTotalSpend END) * dblCompanyExposurePercentage
				, b = (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier, 0) = 0 THEN 1 ELSE dblShareWithSupplier END) *dblSupplierSalesPercentage
				, dblPotentialAdditionalVolume = CASE WHEN CASE WHEN ISNULL(dblTotalSpend,0) = 0 THEN 1 ELSE dblTotalSpend END > dblCompanyExposurePercentage THEN 0
																WHEN CASE WHEN ISNULL(dblShareWithSupplier,0) = 0 THEN 1 ELSE dblShareWithSupplier END > dblSupplierSalesPercentage THEN 0
																WHEN (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend,0) = 0 THEN 1 ELSE dblTotalSpend END) * dblCompanyExposurePercentage
																	<= (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier,0) = 0 THEN 1 ELSE dblShareWithSupplier END) * dblSupplierSalesPercentage
																	THEN (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend,0) = 0 THEN 1 ELSE dblTotalSpend END) * dblCompanyExposurePercentage
																ELSE (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier,0) = 0 THEN 1 ELSE dblShareWithSupplier END) *dblSupplierSalesPercentage END
				, intConcurrencyId = 0
			FROM (
				SELECT strVendorName = strEntityName
					, intEntityId
					, strRating = strRiskIndicator
					, dblFixedPurchaseVolume
					, dblUnfixedPurchaseVolume
					, dblTotalCommittedVolume
					, dblFixedPurchaseValue
					, dblUnfixedPurchaseValue
					, dblTotalCommittedValue
					, dblTotalSpend = (ISNULL(dblTotalCommittedValue, 0)/ SUM(CASE WHEN ISNULL(dblTotalCommittedValue, 0) = 0 THEN 1 ELSE dblTotalCommittedValue END) OVER ()) * 100
					, dblShareWithSupplier = (CASE WHEN ISNULL(dblRiskTotalBusinessVolume, 0) = 0 THEN 0 ELSE ISNULL(dblTotalCommittedVolume, 0) / dblRiskTotalBusinessVolume END) * 100
					, dblMToM = dblResult
					, dblCompanyExposurePercentage
					, dblSupplierSalesPercentage
				FROM (
					SELECT strEntityName
						, intEntityId
						, CONVERT(NUMERIC(16, 2), dblFixedPurchaseVolume) as dblFixedPurchaseVolume
						, CONVERT(NUMERIC(16,2),dblUnfixedPurchaseVolume) as dblUnfixedPurchaseVolume
						, CONVERT(NUMERIC(16,2),(dblFixedPurchaseVolume + dblUnfixedPurchaseVolume)) as dblTotalCommittedVolume
						, CONVERT(NUMERIC(16,2),dblFixedPurchaseValue) dblFixedPurchaseValue
						, CONVERT(NUMERIC(16,2),dblUnfixedPurchaseValue) dblUnfixedPurchaseValue
						, CONVERT(NUMERIC(16,2),(dblFixedPurchaseValue + dblUnfixedPurchaseValue)) as dblTotalCommittedValue
						, CONVERT(NUMERIC(16,2),(dblResult)) as dblResult
						, strRiskIndicator
						, intRiskUnitOfMeasureId
						, dblRiskTotalBusinessVolume
						, dblCompanyExposurePercentage
						, dblSupplierSalesPercentage
					FROM (
						SELECT strEntityName
							, intEntityId
							, dblFixedPurchaseVolume = SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblOpenQty ELSE 0 END)
							, dblUnfixedPurchaseVolume = SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblOpenQty ELSE 0 END)
							, dblFixedPurchaseValue = SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' THEN dblQtyPrice ELSE 0 END)
							, dblUnfixedPurchaseValue = SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' THEN dblQtyUnFixedPrice ELSE 0 END)
							, dblResult = SUM(dblResult)
							, strRiskIndicator
							, dblRiskTotalBusinessVolume
							, intRiskUnitOfMeasureId
							, dblCompanyExposurePercentage
							, dblSupplierSalesPercentage
						FROM (
							SELECT strEntityName
								, intEntityId
								, dblOpenQty = SUM(dblOpenQty)
								, dblQtyPrice = SUM(dblQtyPrice)
								, dblQtyUnFixedPrice = SUM(dblQtyUnFixedPrice)
								, strPriOrNotPriOrParPriced
								, dblResult = SUM(dblResult)
								, strRiskIndicator
								, dblRiskTotalBusinessVolume
								, intRiskUnitOfMeasureId
								, dblCompanyExposurePercentage
								, dblSupplierSalesPercentage
							FROM (
								SELECT strEntityName = ISNULL(strProducer, strEntityName)
									, intEntityId = ISNULL(fd.intEntityId, fd.intProducerId)
									, dblOpenQty
									, dblQtyPrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN fd.intCommodityUnitMeasureId ELSE intQuantityUOMId END
																				, fd.intCommodityUnitMeasureId
																				, dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId
																															, ISNULL(intPriceUOMId, fd.intCommodityUnitMeasureId)
																															, fd.dblOpenQty * ((ISNULL(fd.dblContractBasis, 0)) + (ISNULL(fd.dblFutures, 0)))))
									, dblQtyUnFixedPrice = dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN fd.intCommodityUnitMeasureId ELSE intQuantityUOMId END
																				, fd.intCommodityUnitMeasureId
																				, dbo.fnCTConvertQuantityToTargetCommodityUOM(fd.intCommodityUnitMeasureId
																															, ISNULL(intPriceUOMId, fd.intCommodityUnitMeasureId)
																															, fd.dblOpenQty * ((ISNULL(fd.dblContractBasis, 0)) + (ISNULL(fd.dblFuturePrice, 0)))))
									, strPriOrNotPriOrParPriced = CASE WHEN strPriOrNotPriOrParPriced = 'Partially Priced' THEN 'Unpriced'
																	WHEN ISNULL(strPriOrNotPriOrParPriced, '') = '' THEN 'Priced'
																	WHEN strPriOrNotPriOrParPriced = 'Fully Priced' THEN 'Priced' ELSE strPriOrNotPriOrParPriced END
									, dblResult = ROUND(ISNULL(dblResult, 0), 2)
									, strRiskIndicator = CASE WHEN ISNULL(strProducer, '') = '' THEN pf1.strRiskIndicator ELSE pf.strRiskIndicator END
									, dbo.fnCTConvertQuantityToTargetCommodityUOM(CASE WHEN ISNULL(strProducer, '') = '' THEN cum1.intCommodityUnitMeasureId ELSE cum.intCommodityUnitMeasureId END
																				, CASE WHEN ISNULL(intQuantityUOMId, 0) = 0 THEN fd.intCommodityUnitMeasureId ELSE intQuantityUOMId END
																				, CASE WHEN ISNULL(strProducer, '') = '' THEN e1.dblRiskTotalBusinessVolume ELSE e.dblRiskTotalBusinessVolume END) dblRiskTotalBusinessVolume
									, e.intRiskUnitOfMeasureId
									, dblCompanyExposurePercentage = CASE WHEN ISNULL(strProducer, '') = '' THEN ROUND(ISNULL(pf1.dblCompanyExposurePercentage, 0), 2) ELSE ROUND(ISNULL(pf.dblCompanyExposurePercentage, 0), 2) END
									, dblSupplierSalesPercentage = CASE WHEN ISNULL(strProducer, '') = '' THEN ROUND(ISNULL(pf1.dblSupplierSalesPercentage, 0), 2) ELSE ROUND(ISNULL(pf.dblSupplierSalesPercentage, 0), 2) END
								FROM #temp fd
								JOIN tblCTContractDetail det ON fd.intContractDetailId = det.intContractDetailId
								JOIN tblICItemUOM ic ON det.intPriceItemUOMId = ic.intItemUOMId
								JOIN tblSMCurrency c ON det.intCurrencyId = c.intCurrencyID
								LEFT JOIN tblAPVendor e ON e.intEntityId = fd.intProducerId
								LEFT join tblICCommodityUnitMeasure cum ON cum.intCommodityId = @intCommodityId AND cum.intUnitMeasureId = e.intRiskUnitOfMeasureId
								LEFT JOIN tblRKVendorPriceFixationLimit pf ON pf.intVendorPriceFixationLimitId = e.intRiskVendorPriceFixationLimitId
								LEFT JOIN tblAPVendor e1 ON e1.intEntityId = fd.intEntityId
								LEFT join tblICCommodityUnitMeasure cum1 ON cum1.intCommodityId = @intCommodityId AND cum1.intUnitMeasureId = e1.intRiskUnitOfMeasureId
								LEFT JOIN tblRKVendorPriceFixationLimit pf1 ON pf1.intVendorPriceFixationLimitId = e1.intRiskVendorPriceFixationLimitId
								WHERE strContractOrInventoryType IN ('Contract(P)', 'In-transit(P)', 'Inventory (P)')
							) t
							GROUP BY strEntityName
								, strPriOrNotPriOrParPriced
								, strRiskIndicator
								, dblRiskTotalBusinessVolume
								, intRiskUnitOfMeasureId
								, dblCompanyExposurePercentage
								, dblSupplierSalesPercentage
								, intEntityId
						) t1
						GROUP BY strEntityName
							, strRiskIndicator
							, dblRiskTotalBusinessVolume
							, intRiskUnitOfMeasureId
							, dblCompanyExposurePercentage
							, dblSupplierSalesPercentage
							, intEntityId
					) t2
				) t2
			) t3
		) t4
	END
END