CREATE PROCEDURE uspRKGetPositionAnalysisReportDailyAverage
	@strFilterBy NVARCHAR(20) = NULL
	, @strCondition NVARCHAR(20)
	, @dtmDateFrom NVARCHAR(30) = NULL
	, @dtmDateTo NVARCHAR(30) = NULL
	, @intFutureMarketId INT = NULL
	, @intCommodityId INT = NULL
	, @intQtyUOMId INT = NULL
	, @intCurrencyId int= NULL
	, @intPriceUOMId INT = NULL

AS

BEGIN
	SELECT dtmDate = CASE WHEN @strFilterBy = 'Transaction Date' THEN dtmTransactionDate ELSE dtmEntryDate END
		, intFutureMarketId
		, intCommodityId
		, dblOutrightPhysicalDeltaQty = ABS(dblOutrightPhysicalDeltaQty) * CASE WHEN strBuySell = 'Buy' THEN 1 ELSE -1 END
		, dblOutrightPhysicalQty = ABS(dblOutrightPhysicalQty) * CASE WHEN strBuySell = 'Buy' THEN 1 ELSE -1 END
		, dblOutrightPhysicalPrice = ABS(dblOutrightPhysicalQty) * CASE WHEN strBuySell = 'Buy' THEN -1 ELSE 1 END * dblOutrightPhysicalPrice
		, dblFutureTradeQty = ABS(dblFutureTradeQty) * CASE WHEN strBuySell = 'Buy' THEN 1 ELSE -1 END
		, dblFutureTradePrice = ABS(dblFutureTradeQty) * CASE WHEN strBuySell = 'Buy' THEN -1 ELSE 1 END * dblFutureTradePrice
		, dblPriceFixationDeltaQty = ABS(dblPriceFixationDeltaQty) * CASE WHEN strBuySell = 'Buy' THEN 1 ELSE -1 END
		, dblPriceFixationQty = ABS(dblPriceFixationQty) * CASE WHEN strBuySell = 'Buy' THEN 1 ELSE -1 END
		, dblPriceFixationPrice = ABS(dblPriceFixationQty) * CASE WHEN strBuySell = 'Buy' THEN -1 ELSE 1 END * dblPriceFixationPrice
	INTO #tmpTransactions
	FROM (
		--=========================================
		-- Outright Physicals
		--=========================================
		SELECT dtmEntryDate = CONVERT(DATE, CH.dtmCreated, 101)
			, dtmTransactionDate = CONVERT(DATE, CH.dtmContractDate, 101)
			, CD.intFutureMarketId
			, CH.intCommodityId
			, CD.intCurrencyId
			, dblOutrightPhysicalDeltaQty = dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, QtyUOM.intItemUOMId, CASE WHEN ITM.intProductLineId IS NOT NULL THEN ISNULL(CD.dblQuantity, 0) * (ISNULL(CPL.dblDeltaPercent, 0) /100) ELSE ISNULL(CD.dblQuantity, 0) END)
			, dblOutrightPhysicalQty = dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, QtyUOM.intItemUOMId, ISNULL(CD.dblQuantity, 0))
			, dblOutrightPhysicalPrice = ISNULL(dbo.[fnRKConvertUOMCurrency]('ItemUOM', CD.intPriceItemUOMId, PriceUOM.intItemUOMId, 1, CD.intCurrencyId, @intCurrencyId, ISNULL(CD.dblFutures, 0), CD.intContractDetailId), 0.00)
			, dblFutureTradeDeltaQty = 0.00
			, dblFutureTradeQty = 0.00
			, dblFutureTradePrice = 0.00
			, dblPriceFixationDeltaQty = 0.00
			, dblPriceFixationQty = 0.00
			, dblPriceFixationPrice = 0.00
			, strBuySell = CASE WHEN CH.intContractTypeId = 1 THEN 'Buy' ELSE 'Sell' END COLLATE Latin1_General_CI_AS
		FROM tblCTContractHeader CH
		INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
		INNER JOIN tblICItem ITM ON CD.intItemId = ITM.intItemId
		LEFT JOIN tblICCommodityProductLine CPL ON ITM.intProductLineId = CPL.intCommodityProductLineId
		LEFT JOIN tblICItemUOM QtyUOM ON QtyUOM.intItemId = ITM.intItemId AND QtyUOM.intUnitMeasureId = @intQtyUOMId
		LEFT JOIN tblICItemUOM PriceUOM ON PriceUOM.intItemId = ITM.intItemId AND PriceUOM.intUnitMeasureId = @intPriceUOMId
		WHERE CH.intPricingTypeId = 1 --Priced 

		--=========================================
		-- Price Fixations
		--=========================================
		UNION ALL SELECT dtmEntryDate = CONVERT(DATE, CH.dtmCreated, 101)
			, dtmTransactionDate = CONVERT(DATE, CH.dtmContractDate, 101)
			, CD.intFutureMarketId
			, CH.intCommodityId
			, CD.intCurrencyId
			, dblOutrightPhysicalDeltaQty = 0.00
			, dblOutrightPhysicalQty = 0.00
			, dblOutrightPhysicalPrice = 0.00
			, dblFutureTradeDeltaQty = 0.00
			, dblFutureTradeQty = 0.00
			, dblFutureTradePrice = 0.00
			, dblPriceFixationDeltaQty = dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, QtyUOM.intItemUOMId, CASE WHEN ITM.intProductLineId IS NOT NULL THEN ISNULL(PFD.dblQuantity,0) * (ISNULL(CPL.dblDeltaPercent,0) /100) ELSE ISNULL(PFD.dblQuantity,0) END)
			, dblPriceFixationQty = dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, QtyUOM.intItemUOMId, ISNULL(PFD.dblQuantity,0))
			, dblPriceFixationPrice = ISNULL(dbo.[fnRKConvertUOMCurrency]('ItemUOM', CD.intPriceItemUOMId, PriceUOM.intItemUOMId, 1, CD.intCurrencyId, @intCurrencyId, ISNULL(PFD.dblFixationPrice, 0), CD.intContractDetailId), 0.00)
			, strBuySell = CASE WHEN CH.intContractTypeId = 1 THEN 'Buy' ELSE 'Sell' END COLLATE Latin1_General_CI_AS
		FROM tblCTContractHeader CH
		INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
		INNER JOIN tblICItem ITM ON CD.intItemId = ITM.intItemId
		LEFT JOIN tblICCommodityProductLine CPL ON ITM.intProductLineId = CPL.intCommodityProductLineId
		INNER JOIN tblCTPriceFixation PF ON CD.intContractDetailId = PF.intContractDetailId
		INNER JOIN tblCTPriceFixationDetail PFD ON PF.intPriceFixationId = PFD.intPriceFixationId
		LEFT JOIN tblICItemUOM QtyUOM ON QtyUOM.intItemId = ITM.intItemId AND QtyUOM.intUnitMeasureId = @intQtyUOMId
		LEFT JOIN tblICItemUOM PriceUOM ON PriceUOM.intItemId = ITM.intItemId AND PriceUOM.intUnitMeasureId = @intPriceUOMId
		WHERE PF.intPriceFixationId IS NOT NULL 

		--===================
		-- Future Trades
		--===================
		UNION ALL SELECT dtmEntryDate = CONVERT(DATE, DD.dtmTransactionDate, 101)
			, dtmTransactionDate = CONVERT(DATE, DD.dtmFilledDate, 101)
			, DD.intFutureMarketId
			, DD.intCommodityId
			, DD.intCurrencyId
			, dblOutrightPhysicalDeltaQty = 0.00
			, dblOutrightPhysicalQty = 0.00
			, dblOutrightPhysicalPrice = 0.00
			, dblFutureTradeDeltaQty = 0.00
			, dblFutureTradeQty = dbo.fnCTConvertQtyToTargetCommodityUOM(DD.intCommodityId, FM.intUnitMeasureId, ISNULL(@intQtyUOMId, 0), ISNULL(DD.dblNoOfContract,0) * ISNULL(FM.dblContractSize,0))
			, dblFutureTradePrice = ISNULL(dbo.[fnRKConvertUOMCurrency]('CommodityUOM', MarketUOM.intCommodityUnitMeasureId, PriceUOM.intCommodityUnitMeasureId, 1, FM.intCurrencyId, @intCurrencyId, ISNULL(DD.dblPrice, 0), NULL), 0.00)
			, dblPriceFixationDeltaQty = 0.00
			, dblPriceFixationQty = 0.00
			, dblPriceFixationPrice = 0.00
			, DD.strBuySell
		FROM tblRKFutOptTransactionHeader DH
		INNER JOIN tblRKFutOptTransaction DD ON DH.intFutOptTransactionHeaderId = DD.intFutOptTransactionHeaderId
		INNER JOIN tblRKFutureMarket FM ON DD.intFutureMarketId = FM.intFutureMarketId
		LEFT JOIN tblICCommodityUnitMeasure MarketUOM ON MarketUOM.intCommodityId = DD.intCommodityId AND MarketUOM.intUnitMeasureId = FM.intUnitMeasureId
		LEFT JOIN tblICCommodityUnitMeasure PriceUOM ON PriceUOM.intCommodityId = DD.intCommodityId AND PriceUOM.intUnitMeasureId = ISNULL(@intPriceUOMId, 0)
	) tbl
	WHERE intFutureMarketId = @intFutureMarketId
		AND intCommodityId = @intCommodityId
	
	IF @strCondition = 'Between' 
	BEGIN
		SELECT intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmDate ASC))
			, dtmDate
			, intFutureMarketId
			, intCommodityId
			, dblOutrightPhysicalDeltaQty = SUM(dblOutrightPhysicalDeltaQty)
			, dblOutrightPhysicalQty = SUM(dblOutrightPhysicalQty)
			, dblOutrightPhysicalPrice = CASE WHEN SUM(dblOutrightPhysicalQty) != 0 THEN SUM(dblOutrightPhysicalPrice) / SUM(dblOutrightPhysicalQty) ELSE 0 END
			, dblFutureTradeQty = SUM(dblFutureTradeQty)
			, dblFutureTradePrice = CASE WHEN SUM(dblFutureTradeQty) != 0 THEN SUM(dblFutureTradePrice) / SUM(dblFutureTradeQty) ELSE 0 END
			, dblPriceFixationDeltaQty = SUM(dblPriceFixationDeltaQty)
			, dblPriceFixationQty = SUM(dblPriceFixationQty)
			, dblPriceFixationPrice = CASE WHEN SUM(dblPriceFixationQty) != 0 THEN SUM(dblPriceFixationPrice) / SUM(dblPriceFixationQty) ELSE 0 END 
			, dblAverageDeltaQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalDeltaQty) + SUM(dblPriceFixationDeltaQty)
			, dblAverageQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalQty) + SUM(dblPriceFixationQty)
			, dblAveragePrice = ((SUM(dblOutrightPhysicalQty) * (CASE WHEN SUM(dblOutrightPhysicalQty) != 0 THEN SUM(dblOutrightPhysicalPrice) / SUM(dblOutrightPhysicalQty) ELSE 0 END))
								+ (SUM(dblFutureTradeQty) * (CASE WHEN SUM(dblFutureTradeQty) != 0 THEN SUM(dblFutureTradePrice) / SUM(dblFutureTradeQty) ELSE 0 END))
								+ (SUM(dblPriceFixationQty) * (CASE WHEN SUM(dblPriceFixationQty) != 0 THEN SUM(dblPriceFixationPrice) / SUM(dblPriceFixationQty) ELSE 0 END)))
								/ (SUM(dblOutrightPhysicalQty) + SUM(dblFutureTradeQty) + SUM(dblPriceFixationQty))
		FROM #tmpTransactions tbl
		WHERE dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
		GROUP BY dtmDate
			, intFutureMarketId
			, intCommodityId
	END
	ELSE IF @strCondition = 'Equal' 
	BEGIN
		SELECT intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmDate ASC))
			, dtmDate
			, intFutureMarketId
			, intCommodityId
			, dblOutrightPhysicalDeltaQty = SUM(dblOutrightPhysicalDeltaQty)
			, dblOutrightPhysicalQty = SUM(dblOutrightPhysicalQty)
			, dblOutrightPhysicalPrice = CASE WHEN SUM(dblOutrightPhysicalQty) != 0 THEN SUM(dblOutrightPhysicalPrice) / SUM(dblOutrightPhysicalQty) ELSE 0 END
			, dblFutureTradeQty = SUM(dblFutureTradeQty)
			, dblFutureTradePrice = CASE WHEN SUM(dblFutureTradeQty) != 0 THEN SUM(dblFutureTradePrice) / SUM(dblFutureTradeQty) ELSE 0 END
			, dblPriceFixationDeltaQty = SUM(dblPriceFixationDeltaQty)
			, dblPriceFixationQty = SUM(dblPriceFixationQty)
			, dblPriceFixationPrice = CASE WHEN SUM(dblPriceFixationQty) != 0 THEN SUM(dblPriceFixationPrice) / SUM(dblPriceFixationQty) ELSE 0 END 
			, dblAverageDeltaQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalDeltaQty) + SUM(dblPriceFixationDeltaQty)
			, dblAverageQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalQty) + SUM(dblPriceFixationQty)
			, dblAveragePrice = ((SUM(dblOutrightPhysicalQty) * (CASE WHEN SUM(dblOutrightPhysicalQty) != 0 THEN SUM(dblOutrightPhysicalPrice) / SUM(dblOutrightPhysicalQty) ELSE 0 END))
								+ (SUM(dblFutureTradeQty) * (CASE WHEN SUM(dblFutureTradeQty) != 0 THEN SUM(dblFutureTradePrice) / SUM(dblFutureTradeQty) ELSE 0 END))
								+ (SUM(dblPriceFixationQty) * (CASE WHEN SUM(dblPriceFixationQty) != 0 THEN SUM(dblPriceFixationPrice) / SUM(dblPriceFixationQty) ELSE 0 END)))
								/ (SUM(dblOutrightPhysicalQty) + SUM(dblFutureTradeQty) + SUM(dblPriceFixationQty))
		FROM #tmpTransactions tbl
		WHERE dtmDate = @dtmDateFrom
		GROUP BY dtmDate
			, intFutureMarketId
			, intCommodityId
	END
	ELSE IF @strCondition = 'After' 
	BEGIN
		SELECT intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmDate ASC))
			, dtmDate
			, intFutureMarketId
			, intCommodityId
			, dblOutrightPhysicalDeltaQty = SUM(dblOutrightPhysicalDeltaQty)
			, dblOutrightPhysicalQty = SUM(dblOutrightPhysicalQty)
			, dblOutrightPhysicalPrice = CASE WHEN SUM(dblOutrightPhysicalQty) != 0 THEN SUM(dblOutrightPhysicalPrice) / SUM(dblOutrightPhysicalQty) ELSE 0 END
			, dblFutureTradeQty = SUM(dblFutureTradeQty)
			, dblFutureTradePrice = CASE WHEN SUM(dblFutureTradeQty) != 0 THEN SUM(dblFutureTradePrice) / SUM(dblFutureTradeQty) ELSE 0 END
			, dblPriceFixationDeltaQty = SUM(dblPriceFixationDeltaQty)
			, dblPriceFixationQty = SUM(dblPriceFixationQty)
			, dblPriceFixationPrice = CASE WHEN SUM(dblPriceFixationQty) != 0 THEN SUM(dblPriceFixationPrice) / SUM(dblPriceFixationQty) ELSE 0 END 
			, dblAverageDeltaQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalDeltaQty) + SUM(dblPriceFixationDeltaQty)
			, dblAverageQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalQty) + SUM(dblPriceFixationQty)
			, dblAveragePrice = ((SUM(dblOutrightPhysicalQty) * (CASE WHEN SUM(dblOutrightPhysicalQty) != 0 THEN SUM(dblOutrightPhysicalPrice) / SUM(dblOutrightPhysicalQty) ELSE 0 END))
								+ (SUM(dblFutureTradeQty) * (CASE WHEN SUM(dblFutureTradeQty) != 0 THEN SUM(dblFutureTradePrice) / SUM(dblFutureTradeQty) ELSE 0 END))
								+ (SUM(dblPriceFixationQty) * (CASE WHEN SUM(dblPriceFixationQty) != 0 THEN SUM(dblPriceFixationPrice) / SUM(dblPriceFixationQty) ELSE 0 END)))
								/ (SUM(dblOutrightPhysicalQty) + SUM(dblFutureTradeQty) + SUM(dblPriceFixationQty))
		FROM #tmpTransactions tbl
		WHERE dtmDate > @dtmDateFrom
		GROUP BY dtmDate
			, intFutureMarketId
			, intCommodityId
	END
	ELSE IF @strCondition = 'Before' 
	BEGIN
		SELECT intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmDate ASC))
			, dtmDate
			, intFutureMarketId
			, intCommodityId
			, dblOutrightPhysicalDeltaQty = SUM(dblOutrightPhysicalDeltaQty)
			, dblOutrightPhysicalQty = SUM(dblOutrightPhysicalQty)
			, dblOutrightPhysicalPrice = CASE WHEN SUM(dblOutrightPhysicalQty) != 0 THEN SUM(dblOutrightPhysicalPrice) / SUM(dblOutrightPhysicalQty) ELSE 0 END
			, dblFutureTradeQty = SUM(dblFutureTradeQty)
			, dblFutureTradePrice = CASE WHEN SUM(dblFutureTradeQty) != 0 THEN SUM(dblFutureTradePrice) / SUM(dblFutureTradeQty) ELSE 0 END
			, dblPriceFixationDeltaQty = SUM(dblPriceFixationDeltaQty)
			, dblPriceFixationQty = SUM(dblPriceFixationQty)
			, dblPriceFixationPrice = CASE WHEN SUM(dblPriceFixationQty) != 0 THEN SUM(dblPriceFixationPrice) / SUM(dblPriceFixationQty) ELSE 0 END 
			, dblAverageDeltaQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalDeltaQty) + SUM(dblPriceFixationDeltaQty)
			, dblAverageQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalQty) + SUM(dblPriceFixationQty)
			, dblAveragePrice = ((SUM(dblOutrightPhysicalQty) * (CASE WHEN SUM(dblOutrightPhysicalQty) != 0 THEN SUM(dblOutrightPhysicalPrice) / SUM(dblOutrightPhysicalQty) ELSE 0 END))
								+ (SUM(dblFutureTradeQty) * (CASE WHEN SUM(dblFutureTradeQty) != 0 THEN SUM(dblFutureTradePrice) / SUM(dblFutureTradeQty) ELSE 0 END))
								+ (SUM(dblPriceFixationQty) * (CASE WHEN SUM(dblPriceFixationQty) != 0 THEN SUM(dblPriceFixationPrice) / SUM(dblPriceFixationQty) ELSE 0 END)))
								/ (SUM(dblOutrightPhysicalQty) + SUM(dblFutureTradeQty) + SUM(dblPriceFixationQty))
		FROM #tmpTransactions tbl
		WHERE dtmDate < @dtmDateFrom
		GROUP BY dtmDate
			, intFutureMarketId
			, intCommodityId
	END

	DROP TABLE #tmpTransactions
END