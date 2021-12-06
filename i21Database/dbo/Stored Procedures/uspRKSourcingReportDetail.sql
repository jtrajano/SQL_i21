CREATE PROCEDURE [dbo].[uspRKSourcingReportDetail]
	@dtmFromDate DATETIME = NULL
	, @dtmToDate DATETIME = NULL
	, @intCommodityId INT = NULL
	, @intUnitMeasureId INT = NULL
	, @strEntityName NVARCHAR(100) = NULL
	, @ysnVendorProducer BIT = NULL
	, @intBookId INT = NULL
	, @intSubBookId INT = NULL
	, @strYear NVARCHAR(10) = NULL
	, @dtmAOPFromDate DATETIME = NULL
	, @dtmAOPToDate DATETIME = NULL
	, @strLocationName NVARCHAR(250)= NULL
	, @intCurrencyId INT = NULL

AS

BEGIN
	IF @dtmAOPToDate = '1900-01-01' SET @dtmAOPToDate = GETDATE()
	IF @strEntityName = '-1' SET @strEntityName = NULL
	IF @strLocationName = '-1' SET @strLocationName = NULL

	DECLARE @ysnUseM2MDate BIT
	
	SELECT TOP 1 @ysnUseM2MDate = ISNULL(ysnUseM2MDate, 0) FROM tblRKCompanyPreference
	
	DECLARE @strCurrency NVARCHAR(100)
		, @strUnitMeasure NVARCHAR(100)

	SELECT @strCurrency = strCurrency FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyId
	SELECT @strUnitMeasure = strUnitMeasure
		, @intUnitMeasureId = c.intUnitMeasureId
	FROM tblICCommodityUnitMeasure c
	JOIN tblICUnitMeasure u ON u.intUnitMeasureId = c.intUnitMeasureId WHERE c.intCommodityUnitMeasureId = @intUnitMeasureId
	
	DECLARE @GetStandardQty AS TABLE(intRowNum INT
		, intContractDetailId INT
		, strEntityName NVARCHAR(MAX)
		, intContractHeaderId INT
		, strContractSeq NVARCHAR(100)
		, dblQty NUMERIC(18, 6)
		, dblReturnQty NUMERIC(18, 6)
		, dblBalanceQty NUMERIC(18, 6)
		, dblNoOfLots NUMERIC(18, 6)
		, dblFuturesPrice NUMERIC(18, 6)
		, dblSettlementPrice NUMERIC(18, 6)
		, dblBasis NUMERIC(18, 6)
		, dblRatio NUMERIC(18, 6)
		, dblPrice NUMERIC(18, 6)
		, dblTotPurchased NUMERIC(18, 6)
		, intCompanyLocationId INT) 

	INSERT INTO @GetStandardQty(intRowNum
		, intContractDetailId
		, strEntityName
		, intContractHeaderId
		, strContractSeq
		, dblQty
		, dblReturnQty
		, dblBalanceQty
		, dblNoOfLots
		, dblFuturesPrice
		, dblSettlementPrice
		, dblBasis
		, dblRatio
		, dblPrice
		, intCompanyLocationId)
	SELECT intRowNum = CAST(ROW_NUMBER() OVER (ORDER BY strEntityName) AS INT)
		, intContractDetailId
		, strEntityName
		, intContractHeaderId
		, strContractSeq
		, dblQty
		, dblReturnQty
		, dblBalanceQty
		, dblNoOfLots
		, dblFuturesPrice
		, dblSettlementPrice
		, dblBasis
		, dblRatio
		, 0.0 dblPrice
		, intCompanyLocationId
	FROM (
		SELECT intContractDetailId
			, strEntityName = strName
			, intContractHeaderId
			, strContractSeq = strContractNumber
			, dblQty = CONVERT(NUMERIC(18, 6), ISNULL(dblQty, 0))
			, dblReturnQty = CONVERT(NUMERIC(18, 6), ISNULL(dblReturn, 0))
			, dblBalanceQty = CONVERT(NUMERIC(18, 6), (ISNULL(dblQty, 0) - ISNULL(dblReturn, 0)))
			, dblNoOfLots = CONVERT(NUMERIC(18, 6), dblNoOfLots)
			, dblFuturesPrice = CONVERT(NUMERIC(18, 6),(CASE WHEN ISNULL(dblFullyPricedFutures, 0) = 0 THEN dblParPricedAvgPrice ELSE dblFullyPricedFutures END))
			, dblSettlementPrice = CONVERT(NUMERIC(18, 6), dblUnPricedSettlementPrice)
			, dblBasis = ISNULL(dblUnPricedBasis, dblBasis)
			, dblRatio
			, intCompanyLocationId
		FROM (
			SELECT e.strName
				, ch.intContractHeaderId
				, strContractNumber = ch.strContractNumber + '-' + CONVERT(NVARCHAR, cd.intContractSeq)
				, intContractDetailId
				, dblQty = cd.dblQuantity
				, dblOriginalQty = cd.dblQuantity
				, cd.dblNoOfLots
				, dblFullyPriced = (SELECT dblCashPrice FROM tblCTContractDetail det WHERE det.intContractDetailId = cd.intContractDetailId AND intPricingTypeId IN (1, 6))
				, dblFullyPricedFutures = (SELECT dblFutures FROM tblCTContractDetail det WHERE det.intContractDetailId = cd.intContractDetailId AND intPricingTypeId IN (1, 6))
				, dblFullyPricedBasis = (SELECT dblConvertedBasis FROM tblCTContractDetail det WHERE det.intContractDetailId = cd.intContractDetailId AND intPricingTypeId IN (1, 6))
				, dblUnPriced = ((SELECT SUM(det.dblQuantity * (det.dblConvertedBasis + (ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId, det.intFutureMonthId, @dtmToDate), 0)))
										/ CASE WHEN ISNULL(mc.ysnSubCurrency, 0) = 1 THEN 100 ELSE 1 END)
									FROM tblCTContractDetail det
									JOIN tblCTContractHeader ch ON det.intContractHeaderId = ch.intContractHeaderId
									JOIN tblICCommodityUnitMeasure cuc ON cuc.intCommodityUnitMeasureId = ch.intCommodityUOMId 
									JOIN tblICItemUOM ic ON det.intPriceItemUOMId = ic.intItemUOMId 
									JOIN tblSMCurrency c ON det.intCurrencyId = c.intCurrencyID
									JOIN tblRKFutureMarket MA ON MA.intFutureMarketId = det.intFutureMarketId
									JOIN tblSMCurrency mc ON MA.intCurrencyId = mc.intCurrencyID
									WHERE det.intContractDetailId = cd.intContractDetailId AND det.intPricingTypeId IN (2)
										AND intContractDetailId NOT IN (SELECT intContractDetailId FROM vyuCTSearchPriceContract)))
				, dblUnPricedBasis = (SELECT SUM(det.dblBasis)
									FROM tblCTContractDetail det
									JOIN tblICItemUOM ic ON det.intPriceItemUOMId = ic.intItemUOMId
									JOIN tblSMCurrency c ON det.intCurrencyId = c.intCurrencyID
									WHERE det.intContractDetailId = cd.intContractDetailId AND det.intPricingTypeId IN (2))
				, dblUnPricedSettlementPrice = ((SELECT ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId, det.intFutureMonthId, @dtmToDate), 0)
														/ CASE WHEN ISNULL(mc.ysnSubCurrency, 0) = 1 THEN 100 ELSE 1 END
												FROM tblCTContractDetail det
												JOIN tblICItemUOM ic ON det.intBasisUOMId = ic.intItemUOMId
												JOIN tblRKFutureMarket MA ON MA.intFutureMarketId = det.intFutureMarketId
												JOIN tblSMCurrency mc ON MA.intCurrencyId = mc.intCurrencyID
												WHERE det.intContractDetailId = cd.intContractDetailId AND det.intPricingTypeId IN (2,8)))
				, dblParPriced = (SELECT DISTINCT ((SUM(detcd.dblFixationPrice * detcd.dblLotsFixed) OVER (PARTITION BY det.intContractDetailId)
												+ (ISNULL(detcd.dblBalanceNoOfLots, 0) * ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId, tcd.intFutureMonthId, @dtmToDate), 0)) / cd.dblNoOfLots)
												+ tcd.dblConvertedBasis) * cd.dblQuantity
								FROM vyuCTSearchPriceContract det
								JOIN vyuCTSearchPriceContractDetail detcd ON det.intPriceFixationId = detcd.intPriceFixationId
								JOIN tblCTContractDetail tcd ON det.intContractDetailId = tcd.intContractDetailId
								JOIN tblCTContractHeader ch ON det.intContractHeaderId = ch.intContractHeaderId
								JOIN tblICCommodityUnitMeasure cuc ON cuc.intCommodityUnitMeasureId = ch.intCommodityUOMId
								JOIN tblICItemUOM ic ON det.intPriceItemUOMId = ic.intItemUOMId
								JOIN tblSMCurrency c ON det.intCurrencyId = c.intCurrencyID
								WHERE detcd.strStatus IN ('Partially Priced') AND det.intContractDetailId = cd.intContractDetailId)
				, dblParPricedBasis = (SELECT DISTINCT tcd.dblConvertedBasis
										FROM vyuCTSearchPriceContract det
										JOIN tblCTContractDetail tcd ON det.intContractDetailId = tcd.intContractDetailId
										JOIN tblCTContractHeader ch ON det.intContractHeaderId = ch.intContractHeaderId
										JOIN tblICCommodityUnitMeasure cuc ON cuc.intCommodityUnitMeasureId = ch.intCommodityUOMId
										JOIN tblSMCurrency c ON det.intCurrencyId = c.intCurrencyID
										WHERE strStatus IN ('Partially Priced') AND det.intContractDetailId = cd.intContractDetailId)
				, dblParPricedAvgPrice = (SELECT DISTINCT (((SUM(detcd.dblFixationPrice * detcd.dblLotsFixed) OVER (PARTITION BY det.intContractDetailId)
														+ (ISNULL(detcd.dblBalanceNoOfLots, 0) * ISNULL(dbo.fnRKGetLatestClosingPrice(det.intFutureMarketId, tcd.intFutureMonthId, @dtmToDate), 0))))/ cd.dblNoOfLots)
										FROM vyuCTSearchPriceContract det
										JOIN vyuCTSearchPriceContractDetail detcd ON det.intPriceFixationId = detcd.intPriceFixationId
										JOIN tblCTContractDetail tcd ON det.intContractDetailId = tcd.intContractDetailId
										JOIN tblCTContractHeader ch ON det.intContractHeaderId = ch.intContractHeaderId
										JOIN tblICCommodityUnitMeasure cuc ON cuc.intCommodityUnitMeasureId = ch.intCommodityUOMId
										JOIN tblICItemUOM ic ON det.intPriceItemUOMId = ic.intItemUOMId
										JOIN tblSMCurrency c ON det.intCurrencyId = c.intCurrencyID
										WHERE detcd.strStatus IN ('Partially Priced') AND det.intContractDetailId = cd.intContractDetailId)
				, dblReturn = (SELECT SUM(dblReturnQty)
								FROM (
									SELECT DISTINCT ri.*
										, dblReturnQty = ri.dblOpenReceive
									FROM tblICInventoryReturned r
									JOIN tblICInventoryReceipt ir ON r.intTransactionId = ir.intInventoryReceiptId
									JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = ir.intInventoryReceiptId
									JOIN tblCTContractDetail cd1 ON cd1.intContractDetailId = ri.intLineNo
									JOIN tblICCommodityUnitMeasure cuc ON cuc.intCommodityId = @intCommodityId AND cuc.intUnitMeasureId = cd1.intUnitMeasureId
									WHERE strReceiptType = 'Inventory Return' AND cd1.intContractDetailId = cd.intContractDetailId
								) t)
				, dblRatio
				, dblBasis
				, cd.intCompanyLocationId
			FROM tblCTContractHeader ch
			JOIN tblCTContractDetail cd ON ch.intContractHeaderId = cd.intContractHeaderId AND cd.intContractStatusId NOT IN (2, 3)
			JOIN tblICCommodityUnitMeasure cuc ON cuc.intCommodityId = @intCommodityId AND cuc.intUnitMeasureId = cd.intUnitMeasureId
			JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cd.intCompanyLocationId
			JOIN tblEMEntity e ON e.intEntityId = CASE WHEN ISNULL(@ysnVendorProducer, 0) = 0 THEN ch.intEntityId
														ELSE CASE WHEN ISNULL(cd.intProducerId, 0) = 0 THEN ch.intEntityId
																	ELSE CASE WHEN ISNULL(cd.ysnClaimsToProducer, 0) = 1 THEN cd.intProducerId
																				ELSE ch.intEntityId END END END
			WHERE ISNULL(CASE WHEN @ysnUseM2MDate = 1 THEN cd.dtmM2MDate ELSE ch.dtmContractDate END, GETDATE()) BETWEEN @dtmFromDate AND @dtmToDate
				AND ch.intCommodityId = @intCommodityId
				AND strName = CASE WHEN ISNULL(@strEntityName, '') = '' THEN strName ELSE @strEntityName END
				AND ISNULL(cd.intBookId, 0) = CASE WHEN ISNULL(@intBookId, 0) = 0 THEN ISNULL(cd.intBookId, 0) ELSE @intBookId END
				AND ISNULL(cd.intSubBookId, 0) = CASE WHEN ISNULL(@intSubBookId, 0) = 0 THEN ISNULL(cd.intSubBookId, 0) ELSE @intSubBookId END
				AND ISNULL(cl.strLocationName, '') = CASE WHEN ISNULL(@strLocationName, '') = '' THEN ISNULL(cl.strLocationName, '') ELSE @strLocationName END
		)t
	)t1
	
	DECLARE @ysnSubCurrency INT
	SELECT @ysnSubCurrency = ysnSubCurrency FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyId

	SELECT b.intItemId
		, b.intStorageLocationId
		, ac.dblCost
		, ic1.intUnitMeasureId
		, b.intCurrencyId
		, a.intCompanyLocationId
	INTO #tempAOP
	FROM tblCTAOP a
		JOIN tblCTAOPDetail  b ON a.intAOPId = b.intAOPId
		JOIN tblCTAOPComponent ac ON ac.intAOPDetailId = b.intAOPDetailId
		JOIN tblICItemUOM ic1 ON b.intPriceUOMId = ic1.intItemUOMId
	WHERE a.dtmFromDate = @dtmAOPFromDate AND dtmToDate = @dtmAOPToDate AND strYear = @strYear
		AND ISNULL(a.intBookId, 0) = CASE WHEN ISNULL(@intBookId, 0) = 0 THEN ISNULL(a.intBookId, 0) ELSE @intBookId END
		AND ISNULL(a.intSubBookId, 0) = CASE WHEN ISNULL(@intSubBookId, 0) = 0 THEN ISNULL(a.intSubBookId, 0) ELSE @intSubBookId END
	
	SELECT intRowNum
		, intContractDetailId
		, strEntityName
		, intContractHeaderId
		, strContractSeq
		, dblQty
		, dblReturnQty
		, dblBalanceQty
		, dblNoOfLots
		, dblFuturesPrice
		, dblSettlementPrice
		, dblBasis
		, dblRatio
		, dblPrice
		, dblBalanceQty * dblPrice dblTotPurchased
		, dblStandardRatio
		, dblStandardQty
		, intItemId
		, dblStandardPrice
		, dblPPVBasis
		, strLocationName
		, dblNewPPVPrice
		, dblStandardValue = (dblBalanceQty * dblStandardPrice)
		, dblPPV = (dblStandardPrice - dblPrice) * dblBalanceQty
		, dblPPVNew = (dblStandardPrice - dblNewPPVPrice) * dblBalanceQty
		, strPricingType
		, strItemNo
		, strProductType
		, strCurrency = @strCurrency
		, strUnitMeasure = @strUnitMeasure
		, strFutureMarket
		, strFutureMonth
	FROM (
		SELECT intRowNum
			, intContractDetailId
			, strEntityName
			, intContractHeaderId
			, strContractSeq
			, dblQty
			, dblReturnQty
			, dblBalanceQty
			, dblNoOfLots
			, dblFuturesPrice
			, dblSettlementPrice
			, dblBasis
			, dblRatio
			, dblPrice = (CASE WHEN ISNULL(dblFuturesPrice, 0) = 0 THEN dblSettlementPrice ELSE dblFuturesPrice END * ISNULL(dblRatio, 1)) + ISNULL(dblBasis, 0)
			, dblStandardRatio
			, dblStandardQty = dblBalanceQty * ISNULL(dblStandardRatio, 1)
			, intItemId
			, dblStandardPrice
			, dblPPVBasis = ISNULL(dblBasis, 0) - ISNULL(dblPPVBasis, 0)
			, dblNewPPVPrice = ((CASE WHEN ISNULL(dblFuturesPrice, 0) = 0 THEN dblSettlementPrice ELSE dblFuturesPrice END 
									* ISNULL(dblRatio, 1)) + ISNULL(dblBasis, 0)) - (dblBasis - ISNULL(dblRate, 0))
			, strLocationName
			, strPricingType
			, strItemNo
			, strProductType
			, strFutureMarket
			, strFutureMonth
		FROM (
			SELECT intRowNum
				, t.intContractDetailId
				, strEntityName
				, t.intContractHeaderId
				, strContractSeq
				, dblQty = dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId, cd.intUnitMeasureId, @intUnitMeasureId, dblQty)
				, dblReturnQty = dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId, cd.intUnitMeasureId, @intUnitMeasureId, dblReturnQty)
				, dblBalanceQty = dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId, cd.intUnitMeasureId, @intUnitMeasureId, dblBalanceQty)
				, t.dblNoOfLots
				, dblFuturesPrice = CONVERT(NUMERIC(18,6), dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId, @intUnitMeasureId, i.intUnitMeasureId
																				, dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId, @intCurrencyId, ISNULL(dblFuturesPrice, 0), NULL, NULL, NULL)))
				, dblSettlementPrice = CONVERT(NUMERIC(18,6), dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId, @intUnitMeasureId, m.intUnitMeasureId
																				, ISNULL(dblSettlementPrice, 0) * ISNULL(dbo.[fnRKGetCurrencyConvertion] (m.intCurrencyId, @intCurrencyId), 1)))
				, dblBasis = CONVERT(NUMERIC(18,6), dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId, @intUnitMeasureId, j.intUnitMeasureId
																				, dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId, @intCurrencyId, ISNULL(t.dblBasis, 0), NULL, intBasisCurrencyId, NULL)))
				, t.dblRatio
				, dblRate = dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId, @intCurrencyId, cost.dblRate, NULL, NULL, NULL)
				, dblPrice = CONVERT(NUMERIC(18,6), dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId, @intUnitMeasureId, m.intUnitMeasureId
																				, dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId, @intCurrencyId, ISNULL(dblPrice, 0), NULL, NULL, NULL)))
				, t.intCompanyLocationId
				, dblStandardRatio = ca.dblRatio
				, ic.intItemId
				, dblStandardPrice = (SELECT SUM(dblQty)
									FROM (
										SELECT dblQty = CONVERT(NUMERIC(18,6), dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId, @intUnitMeasureId, b.intUnitMeasureId
																							, dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId, @intCurrencyId, ISNULL(b.dblCost, 0), b.intCurrencyId, NULL, NULL)))
										FROM #tempAOP b
										WHERE intItemId  = i.intItemId
											AND isnull(b.intStorageLocationId,0) = isnull(cd.intSubLocationId,0)
											AND isnull(b.intCompanyLocationId,0) = isnull(cd.intCompanyLocationId,0)
									) t
								)
				, dblPPVBasis = CONVERT(NUMERIC(18,6), dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId, @intUnitMeasureId, j.intUnitMeasureId
																				, dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId, @intCurrencyId, ISNULL(cost.dblRate, t.dblBasis), NULL, NULL, NULL)))
				, strLocationName
				, strPricingType
				, strItemNo
				, strProductType = ca.strDescription
				, cd.intCurrencyId
				, ysnSubCurrency
				, cd.intUnitMeasureId
				, strFutureMarket = m.strFutMarketName
				, strFutureMonth = fm.strFutureMonth
			FROM @GetStandardQty t
			JOIN tblCTContractDetail cd ON t.intContractDetailId = cd.intContractDetailId
			JOIN tblRKFutureMarket m ON cd.intFutureMarketId = m.intFutureMarketId
			JOIN tblRKFuturesMonth fm ON cd.intFutureMonthId = fm.intFutureMonthId
			JOIN tblICItemUOM i ON cd.intPriceItemUOMId = i.intItemUOMId
			JOIN tblICItemUOM j ON cd.intBasisUOMId = j.intItemUOMId
			JOIN tblCTPricingType pt ON cd.intPricingTypeId = pt.intPricingTypeId
			JOIN tblSMCompanyLocation l ON cd.intCompanyLocationId = l.intCompanyLocationId
			JOIN tblICItem ic ON ic.intItemId = cd.intItemId
			JOIN tblSMCurrency c ON c.intCurrencyID = cd.intCurrencyId
			LEFT JOIN (
				SELECT intContractDetailId
					, dblRate = SUM(dbo.[fnCTConvertQuantityToTargetItemUOM](c1.intItemId, @intUnitMeasureId, i.intUnitMeasureId, ISNULL(dblRate, 0)))
				FROM tblCTContractCost c1
				JOIN tblICItemUOM i ON c1.intItemUOMId = i.intItemUOMId
				WHERE ysnBasis = 1 AND c1.intItemId NOT IN (SELECT ISNULL(intItemId, 0) FROM tblCTComponentMap WHERE ysnExcludeFromPPV = 1)
				GROUP BY intContractDetailId
			) cost ON cost.intContractDetailId = cd.intContractDetailId
			LEFT JOIN tblICCommodityProductLine pl ON ic.intCommodityId = pl.intCommodityId AND ic.intProductLineId = pl.intCommodityProductLineId
			LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
			WHERE cd.intPricingTypeId <> 6
		)t
	)t1
	
	UNION ALL SELECT intRowNum
		, intContractDetailId
		, strEntityName
		, intContractHeaderId
		, strContractSeq
		, dblQty
		, dblReturnQty
		, dblBalanceQty
		, dblNoOfLots = NULL
		, dblFuturesPrice = NULL
		, dblSettlementPrice = NULL
		, dblBasis = NULL
		, dblRatio = NULL
		, dblPrice
		, dblBalanceQty * dblPrice dblTotPurchased
		, dblStandardRatio = NULL
		, dblStandardQty = NULL
		, intItemId
		, dblStandardPrice
		, dblPPVBasis = NULL
		, strLocationName
		, dblNewPPVPrice = NULL
		, (dblBalanceQty * dblStandardPrice) dblStandardValue
		, (dblStandardPrice - dblPrice) * dblBalanceQty dblPPV
		, dblPPVNew = NULL
		, strPricingType
		, strItemNo
		, strProductType
		, strCurrency = @strCurrency
		, strUnitMeasure = @strUnitMeasure
		, strFutureMarket
		, strFutureMonth
	FROM (
		SELECT intRowNum
			, intContractDetailId
			, strEntityName
			, intContractHeaderId
			, strContractSeq
			, dblQty
			, dblReturnQty
			, dblBalanceQty
			, dblPrice
			, intItemId
			, dblStandardPrice
			, strLocationName
			, strPricingType
			, strItemNo
			, strProductType
			, strFutureMarket
			, strFutureMonth
		FROM (
			SELECT intRowNum
				, t.intContractDetailId
				, strEntityName
				, t.intContractHeaderId
				, strContractSeq
				, dblQty = dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId, cd.intUnitMeasureId, @intUnitMeasureId, dblQty)
				, dblReturnQty = dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId, cd.intUnitMeasureId, @intUnitMeasureId, dblReturnQty)
				, dblBalanceQty = dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId, cd.intUnitMeasureId, @intUnitMeasureId, dblBalanceQty)
				, dblPrice = dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId, @intUnitMeasureId, i.intUnitMeasureId, CONVERT(NUMERIC(18,6), dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId, @intCurrencyId, ISNULL(cd.dblCashPrice, 0), NULL, NULL, NULL)))
				, t.intCompanyLocationId
				, ic.intItemId
				, dblStandardPrice = (SELECT SUM(dblQty) 
										FROM (
											SELECT dblQty = CONVERT(NUMERIC(18,6), dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId, @intUnitMeasureId, b.intUnitMeasureId
																							, dbo.[fnRKGetSourcingCurrencyConversion](t.intContractDetailId, @intCurrencyId, ISNULL(b.dblCost, 0), b.intCurrencyId, NULL, NULL)))
											FROM #tempAOP b
											WHERE intItemId  = i.intItemId
												AND isnull(b.intStorageLocationId,0) = isnull(cd.intSubLocationId,0)
												AND isnull(b.intCompanyLocationId,0) = isnull(cd.intCompanyLocationId,0)
										)t
									)
				, strLocationName
				, strPricingType
				, strItemNo
				, ca.strDescription strProductType
				, cd.intCurrencyId
				, ysnSubCurrency
				, cd.intUnitMeasureId
				, strFutureMarket = m.strFutMarketName
				, strFutureMonth = fm.strFutureMonth
			FROM @GetStandardQty t
			JOIN tblCTContractDetail cd ON t.intContractDetailId = cd.intContractDetailId
			LEFT JOIN tblRKFutureMarket m ON cd.intFutureMarketId = m.intFutureMarketId
			LEFT JOIN tblRKFuturesMonth fm ON cd.intFutureMonthId = fm.intFutureMonthId
			LEFT JOIN tblICItemUOM i ON cd.intPriceItemUOMId = i.intItemUOMId
			LEFT JOIN tblCTPricingType pt ON cd.intPricingTypeId = pt.intPricingTypeId
			LEFT JOIN tblSMCompanyLocation l ON cd.intCompanyLocationId = l.intCompanyLocationId
			LEFT JOIN tblICItem ic ON ic.intItemId = cd.intItemId
			LEFT JOIN tblSMCurrency c ON c.intCurrencyID = cd.intCurrencyId
			LEFT JOIN (
				SELECT intContractDetailId
					, dblRate = SUM(dbo.[fnCTConvertQuantityToTargetItemUOM](c1.intItemId, @intUnitMeasureId, i.intUnitMeasureId, ISNULL(dblRate, 0)))
				FROM tblCTContractCost c1
				JOIN tblICItemUOM i ON c1.intItemUOMId = i.intItemUOMId
				WHERE ysnBasis = 1 AND c1.intItemId NOT IN (SELECT ISNULL(intItemId, 0) FROM tblCTComponentMap WHERE ysnExcludeFromPPV = 1)
				GROUP BY intContractDetailId
			) cost ON cost.intContractDetailId = cd.intContractDetailId
			LEFT JOIN tblICCommodityProductLine pl ON ic.intCommodityId = pl.intCommodityId AND ic.intProductLineId = pl.intCommodityProductLineId
			LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
			WHERE cd.intPricingTypeId = 6
		)t
	)t1
END