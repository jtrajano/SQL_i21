﻿CREATE PROCEDURE uspRKGetPositionAnalysisReportDetail
	@strFilterBy NVARCHAR(20) = NULL
	, @strCondition NVARCHAR(20)
	, @dtmDateFrom NVARCHAR(30) = NULL
	, @dtmDateTo NVARCHAR(30) = NULL
	, @intFutureMarketId INT = NULL
	, @intCommodityId INT = NULL
	, @intQtyUOMId INT = NULL
	, @intCurrencyId INT = NULL
	, @intPriceUOMId INT = NULL

AS

BEGIN
	DECLARE @date NVARCHAR(50)
		, @dateFilter NVARCHAR(MAX)

	SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY dtmTransactionDate ASC)) AS intRowNum
		, intFutureMarketId
		, intCommodityId
		, intCurrencyId
		, strActivity
		, strBuySell
		, strTransactionId
		, intTransactionId
		, dtmEntryDate
		, dtmTransactionDate
		, strItemNo
		, strOriginalQtyUOM = (CONVERT(VARCHAR(50), CAST(dblOriginalQty AS MONEY), 1) + ' ' + strSymbol) COLLATE Latin1_General_CI_AS
		, dblQty = CASE WHEN strBuySell = 'Buy' THEN dblQty ELSE dblQty * -1 END
		, dblDeltaQty = CASE WHEN strBuySell = 'Buy' THEN ISNULL(dblDeltaQty,0) ELSE ISNULL(dblDeltaQty,0) * -1 END
		, dblNoOfLots
		, strPosition
		, strFutureMonth
		, dblPrice
		, dblValue = ISNULL(dblValue, 0.00)
		, intPriceFixationId
		, dblFutures
	INTO #tmpReportDetail
	FROM (
		--=========================================
		-- Outright Physicals
		--=========================================
		SELECT CD.intFutureMarketId
			, CH.intCommodityId
			, CD.intCurrencyId
			, strActivity = 'Outright' COLLATE Latin1_General_CI_AS
			, strBuySell = CASE WHEN CH.intContractTypeId = 1 THEN 'Buy' ELSE 'Sell' END COLLATE Latin1_General_CI_AS
			, strTransactionId = CH.strContractNumber
			, intTransactionId = CH.intContractHeaderId
			, dtmEntryDate = CONVERT(DATE, CH.dtmCreated, 101)
			, dtmTransactionDate = CONVERT(DATE, CH.dtmContractDate, 101)
			, ITM.strItemNo
			, ITM.intItemId
			, dblOriginalQty = CD.dblQuantity
			, dblQty = dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, QtyUOM.intItemUOMId, ISNULL(CD.dblQuantity, 0)) * (CASE WHEN CH.intContractTypeId = 1 THEN -1 ELSE 1 END)
			, CD.intItemUOMId
			, UM.strSymbol
			, dblDeltaQty = dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, QtyUOM.intItemUOMId, CASE WHEN ITM.intProductLineId IS NOT NULL THEN ISNULL(CD.dblQuantity, 0) * (ISNULL(CPL.dblDeltaPercent, 0) /100) ELSE ISNULL(CD.dblQuantity, 0) END) * (CASE WHEN CH.intContractTypeId = 1 THEN -1 ELSE 1 END)
			, CD.dblNoOfLots
			, P.strPosition
			, FMo.strFutureMonth
			, dblPrice = dbo.[fnRKGetSourcingCurrencyConversion](CD.intContractDetailId, @intCurrencyId, dbo.fnCTConvertQtyToTargetItemUOM(PriceUOM.intItemUOMId, CD.intItemUOMId, ISNULL(CD.dblCashPrice, 0)), NULL, NULL, NULL)
			, dblValue = dbo.[fnRKGetSourcingCurrencyConversion](CD.intContractDetailId, @intCurrencyId, CD.dblTotalCost * (CASE WHEN CH.intContractTypeId = 1 THEN -1 ELSE 1 END), NULL, NULL, NULL)
			, PF.intPriceFixationId
			, dblFutures = ISNULL(dbo.[fnRKGetSourcingCurrencyConversion](CD.intContractDetailId, @intCurrencyId, dbo.fnCTConvertQtyToTargetCommodityUOM(CH.intCommodityId, ISNULL(@intPriceUOMId, 0), FM.intUnitMeasureId, ISNULL(CD.dblFutures, 0)), NULL, NULL, NULL), 0.00)
		FROM tblCTContractHeader CH
		INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
		INNER JOIN tblICItem ITM ON CD.intItemId = ITM.intItemId
		LEFT JOIN tblICCommodityProductLine CPL ON ITM.intProductLineId = CPL.intCommodityProductLineId
		LEFT JOIN tblCTPriceFixation PF ON CD.intContractDetailId = PF.intContractDetailId
		LEFT JOIN tblCTPosition P ON CH.intPositionId = P.intPositionId
		LEFT JOIN tblRKFuturesMonth FMo ON CD.intFutureMonthId = FMo.intFutureMonthId
		LEFT JOIN tblRKFutureMarket FM ON CD.intFutureMarketId = FM.intFutureMarketId
		INNER JOIN tblICItemUOM UOM ON CD.intItemUOMId = UOM.intItemUOMId
		INNER JOIN tblICUnitMeasure UM ON UOM.intUnitMeasureId = UM.intUnitMeasureId
		LEFT JOIN tblICItemUOM QtyUOM ON QtyUOM.intItemId = ITM.intItemId AND QtyUOM.intUnitMeasureId = ISNULL(@intQtyUOMId, 0)
		LEFT JOIN tblICItemUOM PriceUOM ON PriceUOM.intItemId = ITM.intItemId AND PriceUOM.intUnitMeasureId = ISNULL(@intPriceUOMId, 0)
		WHERE CH.intPricingTypeId = 1 --Priced
			AND PF.intPriceFixationId IS NULL
			AND CD.intFutureMarketId = ISNULL(@intFutureMarketId, CD.intFutureMarketId)
			AND CH.intCommodityId = ISNULL(@intCommodityId, CH.intCommodityId)

		--=========================================
		-- Price Fixations
		--=========================================
		UNION ALL SELECT CD.intFutureMarketId
			, CH.intCommodityId
			, CD.intCurrencyId
			, strActivity = 'Price Fixing' COLLATE Latin1_General_CI_AS
			, strBuySell = CASE WHEN CH.intContractTypeId = 1 THEN 'Buy' ELSE 'Sell' END COLLATE Latin1_General_CI_AS
			, strTransactionId = CH.strContractNumber
			, intTransactionId = CH.intContractHeaderId
			, dtmEntryDate = CONVERT(DATE, CH.dtmCreated, 101)
			, dtmTransactionDate = CONVERT(DATE, CH.dtmContractDate, 101)
			, ITM.strItemNo
			, ITM.intItemId
			, dblOriginalQty = CD.dblQuantity
			, dblQty = dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, QtyUOM.intItemUOMId, (ISNULL(CD.dblQuantity, 0) * (PFD.dblNoOfLots / CD.dblNoOfLots))) * (CASE WHEN CH.intContractTypeId = 1 THEN -1 ELSE 1 END)
			, CD.intItemUOMId
			, UM.strSymbol
			, dblDeltaQty = dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, QtyUOM.intItemUOMId, CASE WHEN ITM.intProductLineId IS NOT NULL THEN ISNULL(PFD.dblQuantity,0) * (ISNULL(CPL.dblDeltaPercent,0) /100) ELSE ISNULL(PFD.dblQuantity,0) END) * (CASE WHEN CH.intContractTypeId = 1 THEN -1 ELSE 1 END)
			, PFD.dblNoOfLots
			, P.strPosition
			, FMo.strFutureMonth
			, dblPrice = dbo.[fnRKGetSourcingCurrencyConversion](CD.intContractDetailId, @intCurrencyId, dbo.fnCTConvertQtyToTargetItemUOM(PriceUOM.intItemUOMId, CD.intItemUOMId, ISNULL(PFD.dblFixationPrice, 0)), NULL, NULL, NULL)
			, dblValue = dbo.[fnRKGetSourcingCurrencyConversion](CD.intContractDetailId, @intCurrencyId, (PFD.dblFixationPrice * PFD.dblQuantity) * (CASE WHEN CH.intContractTypeId = 1 THEN -1 ELSE 1 END), NULL, NULL, NULL)
			, PF.intPriceFixationId
			, dblFutures = ISNULL(dbo.[fnRKGetSourcingCurrencyConversion](CD.intContractDetailId, @intCurrencyId, dbo.fnCTConvertQtyToTargetCommodityUOM(CH.intCommodityId,ISNULL(@intPriceUOMId, 0),FM.intUnitMeasureId,ISNULL(CD.dblFutures,0)), NULL, NULL, NULL), 0.00)
		FROM tblCTContractHeader CH
		INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
		INNER JOIN tblICItem ITM ON CD.intItemId = ITM.intItemId
		LEFT JOIN tblICCommodityProductLine CPL ON ITM.intProductLineId = CPL.intCommodityProductLineId
		LEFT JOIN tblCTPriceFixation PF ON CD.intContractDetailId = PF.intContractDetailId
		LEFT JOIN tblCTPriceFixationDetail PFD ON PF.intPriceFixationId = PFD.intPriceFixationId
		LEFT JOIN tblCTPosition P ON CH.intPositionId = P.intPositionId
		LEFT JOIN tblRKFuturesMonth FMo ON CD.intFutureMonthId = FMo.intFutureMonthId
		LEFT JOIN tblRKFutureMarket FM ON CD.intFutureMarketId = FM.intFutureMarketId
		INNER JOIN tblICItemUOM UOM ON CD.intItemUOMId = UOM.intItemUOMId
		INNER JOIN tblICUnitMeasure UM ON UOM.intUnitMeasureId = UM.intUnitMeasureId
		LEFT JOIN tblICItemUOM QtyUOM ON QtyUOM.intItemId = ITM.intItemId AND QtyUOM.intUnitMeasureId = ISNULL(@intQtyUOMId, 0)
		LEFT JOIN tblICItemUOM PriceUOM ON PriceUOM.intItemId = ITM.intItemId AND PriceUOM.intUnitMeasureId = ISNULL(@intPriceUOMId, 0)
		WHERE PF.intPriceFixationId IS NOT NULL
			AND CD.intFutureMarketId = ISNULL(@intFutureMarketId, CD.intFutureMarketId)
			AND CH.intCommodityId = ISNULL(@intCommodityId, CH.intCommodityId)

		--===================
		-- Future Trades
		--===================
		UNION ALL SELECT DD.intFutureMarketId
			, DD.intCommodityId
			, DD.intCurrencyId
			, strActivity = 'Futures' COLLATE Latin1_General_CI_AS
			, DD.strBuySell
			, strTransactionId = DD.strInternalTradeNo
			, intTransactionId = DD.intFutOptTransactionHeaderId
			, dtmEntryDate = CONVERT(DATE, DD.dtmTransactionDate, 101)
			, dtmTransactionDate = CONVERT(DATE, DD.dtmFilledDate, 101)
			, strItemNo = ''
			, intItemId = 0
			, dblOriginalQty = ISNULL(DD.dblNoOfContract,0) * ISNULL(FM.dblContractSize,0)
			, dblQty = dbo.fnCTConvertQtyToTargetCommodityUOM(DD.intCommodityId,FM.intUnitMeasureId, ISNULL(@intQtyUOMId, 0), ISNULL(DD.dblNoOfContract,0) * ISNULL(FM.dblContractSize,0)) * (CASE WHEN DD.strBuySell = 'Buy' THEN -1 ELSE 1 END)
			, intItemUOMId = NULL
			, UM.strSymbol
			, dblDeltaQty = dbo.fnCTConvertQtyToTargetCommodityUOM(DD.intCommodityId,FM.intUnitMeasureId,ISNULL(@intQtyUOMId, 0),ISNULL(DD.dblNoOfContract,0) * ISNULL(FM.dblContractSize,0)) * (CASE WHEN DD.strBuySell = 'Buy' THEN -1 ELSE 1 END)
			, DD.dblNoOfContract
			, strPosition = '' COLLATE Latin1_General_CI_AS
			, strFutureMonth = FMonth.strFutureMonth
			, dblPrice = dbo.fnRKGetCurrencyConvertion(FM.intCurrencyId, @intCurrencyId) * (dbo.fnCTConvertQtyToTargetCommodityUOM(DD.intCommodityId,ISNULL(@intPriceUOMId, 0),FM.intUnitMeasureId,ISNULL(DD.dblPrice,0)))
			, strValue = dbo.fnRKGetCurrencyConvertion(FM.intCurrencyId, @intCurrencyId) * (((ISNULL(DD.dblNoOfContract,0) * ISNULL(FM.dblContractSize,0)) * DD.dblPrice) * (CASE WHEN DD.strBuySell = 'Buy' THEN -1 ELSE 1 END))
			, intPriceFixationId = NULL
			, dblFutures = ISNULL(dbo.fnRKGetCurrencyConvertion(FM.intCurrencyId, @intCurrencyId) * (dbo.fnCTConvertQtyToTargetCommodityUOM(DD.intCommodityId,ISNULL(@intPriceUOMId, 0),FM.intUnitMeasureId,ISNULL(DD.dblPrice,0))), 0.00)
		FROM tblRKFutOptTransactionHeader DH
		INNER JOIN tblRKFutOptTransaction DD ON DH.intFutOptTransactionHeaderId = DD.intFutOptTransactionHeaderId
		INNER JOIN tblRKFutureMarket FM ON DD.intFutureMarketId = FM.intFutureMarketId
		INNER JOIN tblICUnitMeasure UM ON FM.intUnitMeasureId = UM.intUnitMeasureId
		INNER JOIN tblRKFuturesMonth FMonth ON FMonth.intFutureMonthId = DD.intFutureMonthId
		WHERE  DD.intFutureMarketId = ISNULL(@intFutureMarketId, DD.intFutureMarketId)
		AND DD.intCommodityId = ISNULL(@intCommodityId, DD.intCommodityId)
	) tbl

	IF @strFilterBy = 'Transaction Date'
	BEGIN
		IF @strCondition = 'Between' 
		BEGIN
			SELECT * FROM #tmpReportDetail WHERE dtmTransactionDate BETWEEN @dtmDateFrom AND @dtmDateTo
		END
		ELSE IF @strCondition = 'Equal'
		BEGIN
			SELECT * FROM #tmpReportDetail WHERE dtmTransactionDate = @dtmDateFrom
		END
		ELSE IF @strCondition = 'After'
		BEGIN
			SELECT * FROM #tmpReportDetail WHERE dtmTransactionDate > @dtmDateFrom
		END
		ELSE IF @strCondition = 'Before'
		BEGIN
			SELECT * FROM #tmpReportDetail WHERE dtmTransactionDate < @dtmDateFrom
		END
	END
	ELSE
	BEGIN
		SET @date = 'dtmEntryDate'
		IF @strCondition = 'Between' 
		BEGIN
			SELECT * FROM #tmpReportDetail WHERE dtmEntryDate BETWEEN @dtmDateFrom AND @dtmDateTo
		END
		ELSE IF @strCondition = 'Equal'
		BEGIN
			SELECT * FROM #tmpReportDetail WHERE dtmEntryDate = @dtmDateFrom
		END
		ELSE IF @strCondition = 'After'
		BEGIN
			SELECT * FROM #tmpReportDetail WHERE dtmEntryDate > @dtmDateFrom
		END
		ELSE IF @strCondition = 'Before'
		BEGIN
			SELECT * FROM #tmpReportDetail WHERE dtmEntryDate < @dtmDateFrom
		END
	END

	DROP TABLE #tmpReportDetail
END