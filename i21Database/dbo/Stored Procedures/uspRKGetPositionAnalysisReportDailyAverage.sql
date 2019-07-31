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
	DECLARE @queryHeader NVARCHAR(max),
			@query1 NVARCHAR(max),
			@query2 NVARCHAR(max),
			@query3 NVARCHAR(max),
			@dateFilter NVARCHAR(max)

	--Compose the date filter
	IF @strCondition = 'Between' 
	BEGIN
		SET @dateFilter = 'BETWEEN ''' + @dtmDateFrom + ''' AND ''' + @dtmDateTo + ''''
	END
	ELSE IF @strCondition = 'Equal' 
		SET @dateFilter = '= ''' + @dtmDateFrom + ''''
	ELSE IF @strCondition = 'After' 
		SET @dateFilter = '> ''' + @dtmDateFrom + ''''	
	ELSE IF @strCondition = 'Before' 
		SET @dateFilter = '< ''' + @dtmDateFrom + ''''

	SELECT dtmTransactionDate
		, dtmEntryDate
		, intFutureMarketId
		, intCommodityId
		, dblOutrightPhysicalDeltaQty
		, dblOutrightPhysicalQty
		, dblOutrightPhysicalPrice
		, dblFutureTradeQty
		, dblFutureTradePrice
		, dblPriceFixationDeltaQty
		, dblPriceFixationQty
		, dblPriceFixationPrice
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
			, dblOutrightPhysicalDeltaQty = CASE WHEN ITM.intProductLineId IS NOT NULL THEN dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, QtyUOM.intItemUOMId, ISNULL(CD.dblQuantity, 0)) * (ISNULL(CPL.dblDeltaPercent, 0) /100)
												ELSE dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, QtyUOM.intItemUOMId, ISNULL(CD.dblQuantity, 0)) END
			, dblOutrightPhysicalQty = dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, QtyUOM.intItemUOMId, ISNULL(CD.dblQuantity, 0))
			, dblOutrightPhysicalPrice = dbo.fnCTConvertQtyToTargetItemUOM(PriceUOM.intItemUOMId, CD.intItemUOMId, ISNULL(CD.dblCashPrice, 0))
			, dblFutureTradeDeltaQty = 0.00
			, dblFutureTradeQty = 0.00
			, dblFutureTradePrice = 0.00
			, dblPriceFixationDeltaQty = 0.00
			, dblPriceFixationQty = 0.00
			, dblPriceFixationPrice = 0.00
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
			, dblPriceFixationDeltaQty = CASE WHEN ITM.intProductLineId IS NOT NULL THEN dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, QtyUOM.intItemUOMId, ISNULL(PFD.dblQuantity, 0)) * (ISNULL(CPL.dblDeltaPercent, 0) /100)
											ELSE dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, QtyUOM.intItemUOMId, ISNULL(PFD.dblQuantity, 0)) END
			, dblPriceFixationQty = dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, QtyUOM.intItemUOMId, ISNULL(PFD.dblQuantity, 0))
			, dblPriceFixationPrice = dbo.fnCTConvertQtyToTargetItemUOM( PriceUOM.intItemUOMId,CD.intItemUOMId, ISNULL(PFD.dblFixationPrice, 0))
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
			, dblFutureTradeQty = dbo.fnCTConvertQtyToTargetCommodityUOM(DD.intCommodityId, FM.intUnitMeasureId, @intQtyUOMId, ISNULL(DD.dblNoOfContract, 0) * ISNULL(FM.dblContractSize, 0))
			, dblFutureTradePrice = dbo.fnCTConvertQtyToTargetCommodityUOM(DD.intCommodityId, @intPriceUOMId, FM.intUnitMeasureId, ISNULL(DD.dblPrice, 0))
			, dblPriceFixationDeltaQty = 0.00
			, dblPriceFixationQty = 0.00
			, dblPriceFixationPrice = 0.00
		FROM tblRKFutOptTransactionHeader DH
		INNER JOIN tblRKFutOptTransaction DD ON DH.intFutOptTransactionHeaderId = DD.intFutOptTransactionHeaderId
		INNER JOIN tblRKFutureMarket FM ON DD.intFutureMarketId = FM.intFutureMarketId
	) tbl
	WHERE intFutureMarketId = @intFutureMarketId
		AND intCommodityId = @intCommodityId

	IF @strFilterBy = 'Transaction Date'
	BEGIN
		IF @strCondition = 'Between' 
		BEGIN
			SELECT intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmTransactionDate ASC))
				, dtmDate = dtmTransactionDate
				, intFutureMarketId
				, intCommodityId
				, dblOutrightPhysicalDeltaQty = SUM(dblOutrightPhysicalDeltaQty)
				, dblOutrightPhysicalQty = SUM(dblOutrightPhysicalQty)
				, dblOutrightPhysicalPrice = SUM(dblOutrightPhysicalPrice)
				, dblFutureTradeQty = SUM(dblFutureTradeQty)
				, dblFutureTradePrice = SUM(dblFutureTradePrice)
				, dblPriceFixationDeltaQty = SUM(dblPriceFixationDeltaQty)
				, dblPriceFixationQty = SUM(dblPriceFixationQty)
				, dblPriceFixationPrice = SUM(dblPriceFixationPrice)
				, dblAverageDeltaQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalDeltaQty) + SUM(dblPriceFixationDeltaQty)
				, dblAverageQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalQty) + SUM(dblPriceFixationQty)
				, dblAveragePrice = (((SUM(dblOutrightPhysicalQty) * SUM(dblOutrightPhysicalPrice)) + (SUM(dblFutureTradeQty) * SUM(dblFutureTradePrice)) + (SUM(dblPriceFixationQty) * SUM(dblPriceFixationPrice))) / (SUM(dblOutrightPhysicalQty) + SUM(dblFutureTradeQty) + SUM(dblPriceFixationQty)))
			FROM #tmpTransactions tbl
			WHERE dtmTransactionDate BETWEEN @dtmDateFrom AND @dtmDateTo
			GROUP BY dtmTransactionDate
				, intFutureMarketId
				, intCommodityId
		END
		ELSE IF @strCondition = 'Equal' 
		BEGIN
			SELECT intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmTransactionDate ASC))
				, dtmDate = dtmTransactionDate
				, intFutureMarketId
				, intCommodityId
				, dblOutrightPhysicalDeltaQty = SUM(dblOutrightPhysicalDeltaQty)
				, dblOutrightPhysicalQty = SUM(dblOutrightPhysicalQty)
				, dblOutrightPhysicalPrice = SUM(dblOutrightPhysicalPrice)
				, dblFutureTradeQty = SUM(dblFutureTradeQty)
				, dblFutureTradePrice = SUM(dblFutureTradePrice)
				, dblPriceFixationDeltaQty = SUM(dblPriceFixationDeltaQty)
				, dblPriceFixationQty = SUM(dblPriceFixationQty)
				, dblPriceFixationPrice = SUM(dblPriceFixationPrice)
				, dblAverageDeltaQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalDeltaQty) + SUM(dblPriceFixationDeltaQty)
				, dblAverageQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalQty) + SUM(dblPriceFixationQty)
				, dblAveragePrice = (((SUM(dblOutrightPhysicalQty) * SUM(dblOutrightPhysicalPrice)) + (SUM(dblFutureTradeQty) * SUM(dblFutureTradePrice)) + (SUM(dblPriceFixationQty) * SUM(dblPriceFixationPrice))) / (SUM(dblOutrightPhysicalQty) + SUM(dblFutureTradeQty) + SUM(dblPriceFixationQty)))
			FROM #tmpTransactions tbl
			WHERE dtmTransactionDate = @dtmDateFrom
			GROUP BY dtmTransactionDate
				, intFutureMarketId
				, intCommodityId
		END
		ELSE IF @strCondition = 'After' 
		BEGIN
			SELECT intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmTransactionDate ASC))
				, dtmDate = dtmTransactionDate
				, intFutureMarketId
				, intCommodityId
				, dblOutrightPhysicalDeltaQty = SUM(dblOutrightPhysicalDeltaQty)
				, dblOutrightPhysicalQty = SUM(dblOutrightPhysicalQty)
				, dblOutrightPhysicalPrice = SUM(dblOutrightPhysicalPrice)
				, dblFutureTradeQty = SUM(dblFutureTradeQty)
				, dblFutureTradePrice = SUM(dblFutureTradePrice)
				, dblPriceFixationDeltaQty = SUM(dblPriceFixationDeltaQty)
				, dblPriceFixationQty = SUM(dblPriceFixationQty)
				, dblPriceFixationPrice = SUM(dblPriceFixationPrice)
				, dblAverageDeltaQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalDeltaQty) + SUM(dblPriceFixationDeltaQty)
				, dblAverageQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalQty) + SUM(dblPriceFixationQty)
				, dblAveragePrice = (((SUM(dblOutrightPhysicalQty) * SUM(dblOutrightPhysicalPrice)) + (SUM(dblFutureTradeQty) * SUM(dblFutureTradePrice)) + (SUM(dblPriceFixationQty) * SUM(dblPriceFixationPrice))) / (SUM(dblOutrightPhysicalQty) + SUM(dblFutureTradeQty) + SUM(dblPriceFixationQty)))
			FROM #tmpTransactions tbl
			WHERE dtmTransactionDate > @dtmDateFrom
			GROUP BY dtmTransactionDate
				, intFutureMarketId
				, intCommodityId
		END
		ELSE IF @strCondition = 'Before' 
		BEGIN
			SELECT intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmTransactionDate ASC))
				, dtmDate = dtmTransactionDate
				, intFutureMarketId
				, intCommodityId
				, dblOutrightPhysicalDeltaQty = SUM(dblOutrightPhysicalDeltaQty)
				, dblOutrightPhysicalQty = SUM(dblOutrightPhysicalQty)
				, dblOutrightPhysicalPrice = SUM(dblOutrightPhysicalPrice)
				, dblFutureTradeQty = SUM(dblFutureTradeQty)
				, dblFutureTradePrice = SUM(dblFutureTradePrice)
				, dblPriceFixationDeltaQty = SUM(dblPriceFixationDeltaQty)
				, dblPriceFixationQty = SUM(dblPriceFixationQty)
				, dblPriceFixationPrice = SUM(dblPriceFixationPrice)
				, dblAverageDeltaQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalDeltaQty) + SUM(dblPriceFixationDeltaQty)
				, dblAverageQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalQty) + SUM(dblPriceFixationQty)
				, dblAveragePrice = (((SUM(dblOutrightPhysicalQty) * SUM(dblOutrightPhysicalPrice)) + (SUM(dblFutureTradeQty) * SUM(dblFutureTradePrice)) + (SUM(dblPriceFixationQty) * SUM(dblPriceFixationPrice))) / (SUM(dblOutrightPhysicalQty) + SUM(dblFutureTradeQty) + SUM(dblPriceFixationQty)))
			FROM #tmpTransactions tbl
			WHERE dtmTransactionDate < @dtmDateFrom
			GROUP BY dtmTransactionDate
				, intFutureMarketId
				, intCommodityId
		END
	END
	ELSE
	BEGIN
		IF @strCondition = 'Between' 
		BEGIN
			SELECT intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmEntryDate ASC))
				, dtmDate = dtmEntryDate
				, intFutureMarketId
				, intCommodityId
				, dblOutrightPhysicalDeltaQty = SUM(dblOutrightPhysicalDeltaQty)
				, dblOutrightPhysicalQty = SUM(dblOutrightPhysicalQty)
				, dblOutrightPhysicalPrice = SUM(dblOutrightPhysicalPrice)
				, dblFutureTradeQty = SUM(dblFutureTradeQty)
				, dblFutureTradePrice = SUM(dblFutureTradePrice)
				, dblPriceFixationDeltaQty = SUM(dblPriceFixationDeltaQty)
				, dblPriceFixationQty = SUM(dblPriceFixationQty)
				, dblPriceFixationPrice = SUM(dblPriceFixationPrice)
				, dblAverageDeltaQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalDeltaQty) + SUM(dblPriceFixationDeltaQty)
				, dblAverageQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalQty) + SUM(dblPriceFixationQty)
				, dblAveragePrice = (((SUM(dblOutrightPhysicalQty) * SUM(dblOutrightPhysicalPrice)) + (SUM(dblFutureTradeQty) * SUM(dblFutureTradePrice)) + (SUM(dblPriceFixationQty) * SUM(dblPriceFixationPrice))) / (SUM(dblOutrightPhysicalQty) + SUM(dblFutureTradeQty) + SUM(dblPriceFixationQty)))
			FROM #tmpTransactions tbl
			WHERE dtmEntryDate BETWEEN @dtmDateFrom AND @dtmDateTo
			GROUP BY dtmEntryDate
				, intFutureMarketId
				, intCommodityId
		END
		ELSE IF @strCondition = 'Equal' 
		BEGIN
			SELECT intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmEntryDate ASC))
				, dtmDate = dtmEntryDate
				, intFutureMarketId
				, intCommodityId
				, dblOutrightPhysicalDeltaQty = SUM(dblOutrightPhysicalDeltaQty)
				, dblOutrightPhysicalQty = SUM(dblOutrightPhysicalQty)
				, dblOutrightPhysicalPrice = SUM(dblOutrightPhysicalPrice)
				, dblFutureTradeQty = SUM(dblFutureTradeQty)
				, dblFutureTradePrice = SUM(dblFutureTradePrice)
				, dblPriceFixationDeltaQty = SUM(dblPriceFixationDeltaQty)
				, dblPriceFixationQty = SUM(dblPriceFixationQty)
				, dblPriceFixationPrice = SUM(dblPriceFixationPrice)
				, dblAverageDeltaQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalDeltaQty) + SUM(dblPriceFixationDeltaQty)
				, dblAverageQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalQty) + SUM(dblPriceFixationQty)
				, dblAveragePrice = (((SUM(dblOutrightPhysicalQty) * SUM(dblOutrightPhysicalPrice)) + (SUM(dblFutureTradeQty) * SUM(dblFutureTradePrice)) + (SUM(dblPriceFixationQty) * SUM(dblPriceFixationPrice))) / (SUM(dblOutrightPhysicalQty) + SUM(dblFutureTradeQty) + SUM(dblPriceFixationQty)))
			FROM #tmpTransactions tbl
			WHERE dtmEntryDate = @dtmDateFrom
			GROUP BY dtmEntryDate
				, intFutureMarketId
				, intCommodityId
		END
		ELSE IF @strCondition = 'After' 
		BEGIN
			SELECT intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmEntryDate ASC))
				, dtmDate = dtmEntryDate
				, intFutureMarketId
				, intCommodityId
				, dblOutrightPhysicalDeltaQty = SUM(dblOutrightPhysicalDeltaQty)
				, dblOutrightPhysicalQty = SUM(dblOutrightPhysicalQty)
				, dblOutrightPhysicalPrice = SUM(dblOutrightPhysicalPrice)
				, dblFutureTradeQty = SUM(dblFutureTradeQty)
				, dblFutureTradePrice = SUM(dblFutureTradePrice)
				, dblPriceFixationDeltaQty = SUM(dblPriceFixationDeltaQty)
				, dblPriceFixationQty = SUM(dblPriceFixationQty)
				, dblPriceFixationPrice = SUM(dblPriceFixationPrice)
				, dblAverageDeltaQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalDeltaQty) + SUM(dblPriceFixationDeltaQty)
				, dblAverageQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalQty) + SUM(dblPriceFixationQty)
				, dblAveragePrice = (((SUM(dblOutrightPhysicalQty) * SUM(dblOutrightPhysicalPrice)) + (SUM(dblFutureTradeQty) * SUM(dblFutureTradePrice)) + (SUM(dblPriceFixationQty) * SUM(dblPriceFixationPrice))) / (SUM(dblOutrightPhysicalQty) + SUM(dblFutureTradeQty) + SUM(dblPriceFixationQty)))
			FROM #tmpTransactions tbl
			WHERE dtmEntryDate > @dtmDateFrom
			GROUP BY dtmEntryDate
				, intFutureMarketId
				, intCommodityId
		END
		ELSE IF @strCondition = 'Before' 
		BEGIN
			SELECT intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmEntryDate ASC))
				, dtmDate = dtmEntryDate
				, intFutureMarketId
				, intCommodityId
				, dblOutrightPhysicalDeltaQty = SUM(dblOutrightPhysicalDeltaQty)
				, dblOutrightPhysicalQty = SUM(dblOutrightPhysicalQty)
				, dblOutrightPhysicalPrice = SUM(dblOutrightPhysicalPrice)
				, dblFutureTradeQty = SUM(dblFutureTradeQty)
				, dblFutureTradePrice = SUM(dblFutureTradePrice)
				, dblPriceFixationDeltaQty = SUM(dblPriceFixationDeltaQty)
				, dblPriceFixationQty = SUM(dblPriceFixationQty)
				, dblPriceFixationPrice = SUM(dblPriceFixationPrice)
				, dblAverageDeltaQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalDeltaQty) + SUM(dblPriceFixationDeltaQty)
				, dblAverageQty = SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalQty) + SUM(dblPriceFixationQty)
				, dblAveragePrice = (((SUM(dblOutrightPhysicalQty) * SUM(dblOutrightPhysicalPrice)) + (SUM(dblFutureTradeQty) * SUM(dblFutureTradePrice)) + (SUM(dblPriceFixationQty) * SUM(dblPriceFixationPrice))) / (SUM(dblOutrightPhysicalQty) + SUM(dblFutureTradeQty) + SUM(dblPriceFixationQty)))
			FROM #tmpTransactions tbl
			WHERE dtmEntryDate < @dtmDateFrom
			GROUP BY dtmEntryDate
				, intFutureMarketId
				, intCommodityId
		END
	END

	DROP TABLE #tmpTransactions
END