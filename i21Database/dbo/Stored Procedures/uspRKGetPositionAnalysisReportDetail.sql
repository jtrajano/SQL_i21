CREATE PROCEDURE uspRKGetPositionAnalysisReportDetail
	@strFilterBy nvarchar(20)= NULL
	, @strCondition nvarchar(20)
	, @dtmDateFrom nvarchar(30) = NULL
	, @dtmDateTo nvarchar(30) = NULL
	, @intFutureMarketId int= NULL
	, @intCommodityId int= NULL
	, @intQtyUOMId int = NULL
	, @intCurrencyId int= NULL
	, @intPriceUOMId int = NULL

AS

BEGIN
	DECLARE @date NVARCHAR(50)
		, @dateFilter NVARCHAR(MAX)

	SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY dtmTransactionDate ASC)) AS intRowNum
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
		, (CONVERT(VARCHAR(50), CAST(dblOriginalQty AS MONEY), 1) + ' ' + strSymbol) COLLATE Latin1_General_CI_AS as strOriginalQtyUOM
		, CASE WHEN strBuySell = 'Buy' THEN dblQty ELSE dblQty * -1 END AS dblQty
		, CASE WHEN strBuySell = 'Buy' THEN ISNULL(dblDeltaQty,0) ELSE ISNULL(dblDeltaQty,0) * -1 END AS dblDeltaQty
		, dblNoOfLots
		, strPosition
		, strFutureMonth
		, dblPrice
		, ISNULL(dblValue,0) as dblValue
		, intPriceFixationId
	INTO #tmpReportDetail
	FROM (
		--=========================================
		-- Outright Physicals
		--=========================================
		SELECT CD.intFutureMarketId
			, CH.intCommodityId
			, CD.intCurrencyId
			, 'Outright' COLLATE Latin1_General_CI_AS AS strActivity
			, CASE WHEN CH.intContractTypeId = 1 THEN 'Buy' ELSE 'Sell' END COLLATE Latin1_General_CI_AS AS strBuySell
			, CH.strContractNumber AS strTransactionId
			, CH.intContractHeaderId AS intTransactionId
			, CONVERT(date,CH.dtmCreated,101) AS dtmEntryDate
			, CONVERT(date,CH.dtmContractDate,101) AS dtmTransactionDate
			, ITM.strItemNo
			, ITM.intItemId
			, CD.dblQuantity AS dblOriginalQty
			, dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,(select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ISNULL(@intQtyUOMId, 0)), ISNULL(CD.dblQuantity,0)) AS dblQty
			, CD.intItemUOMId
			, UM.strSymbol
			, CASE WHEN ITM.intProductLineId IS NOT NULL THEN ISNULL(CD.dblQuantity,0) * (ISNULL(CPL.dblDeltaPercent,0) /100)
				ELSE ISNULL(CD.dblQuantity,0) END AS dblDeltaQty
			, CD.dblNoOfLots
			, P.strPosition
			, FMo.strFutureMonth
			, dbo.fnCTConvertQtyToTargetItemUOM((select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ISNULL(@intPriceUOMId, 0)),CD.intItemUOMId, ISNULL(CD.dblCashPrice,0)) AS dblPrice
			, CD.dblTotalCost as dblValue
			, PF.intPriceFixationId
		FROM tblCTContractHeader CH
		INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
		INNER JOIN tblICItem ITM ON CD.intItemId = ITM.intItemId
		LEFT JOIN tblICCommodityProductLine CPL ON ITM.intProductLineId = CPL.intCommodityProductLineId
		LEFT JOIN tblCTPriceFixation PF ON CD.intContractDetailId = PF.intContractDetailId
		LEFT JOIN tblCTPosition P ON CH.intPositionId = P.intPositionId
		LEFT JOIN tblRKFuturesMonth FMo ON CD.intFutureMonthId = FMo.intFutureMonthId
		INNER JOIN tblICItemUOM UOM ON CD.intItemUOMId = UOM.intItemUOMId
		INNER JOIN tblICUnitMeasure UM ON UOM.intUnitMeasureId = UM.intUnitMeasureId
		WHERE CH.intPricingTypeId = 1 --Priced
			AND PF.intPriceFixationId IS NULL
			AND CD.intFutureMarketId = ISNULL(@intFutureMarketId, CD.intFutureMarketId)
			AND CH.intCommodityId = ISNULL(@intCommodityId, CH.intCommodityId)
			AND CD.intCurrencyId = ISNULL(@intCurrencyId, CD.intCurrencyId)

		--=========================================
		-- Price Fixations
		--=========================================
		UNION ALL SELECT CD.intFutureMarketId
			, CH.intCommodityId
			, CD.intCurrencyId
			, 'Price Fixing' COLLATE Latin1_General_CI_AS AS strActivity
			, CASE WHEN CH.intContractTypeId = 1 THEN 'Buy' ELSE 'Sell' END COLLATE Latin1_General_CI_AS AS strBuySell
			, CH.strContractNumber AS strTransactionId
			, CH.intContractHeaderId AS intTransactionId
			, CONVERT(date,CH.dtmCreated,101) AS dtmEntryDate
			, CONVERT(date,CH.dtmContractDate,101) AS dtmTransactionDate
			, ITM.strItemNo
			, ITM.intItemId
			, CD.dblQuantity AS dblOriginalQty
			, dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,(select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ISNULL(@intQtyUOMId, 0)), ISNULL(CD.dblQuantity,0)) AS dblQty
			, CD.intItemUOMId
			, UM.strSymbol
			, CASE WHEN ITM.intProductLineId IS NOT NULL THEN ISNULL(PFD.dblQuantity,0) * (ISNULL(CPL.dblDeltaPercent,0) /100)
				ELSE ISNULL(PFD.dblQuantity,0) END AS dblDeltaQty
			, PFD.dblNoOfLots
			, P.strPosition
			, FMo.strFutureMonth
			, dbo.fnCTConvertQtyToTargetItemUOM((select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ISNULL(@intPriceUOMId, 0)),CD.intItemUOMId, ISNULL(PFD.dblFixationPrice,0)) AS dblPrice
			, PFD.dblFixationPrice * PFD.dblQuantity AS dblValue
			, PF.intPriceFixationId
		FROM tblCTContractHeader CH
		INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
		INNER JOIN tblICItem ITM ON CD.intItemId = ITM.intItemId
		LEFT JOIN tblICCommodityProductLine CPL ON ITM.intProductLineId = CPL.intCommodityProductLineId
		LEFT JOIN tblCTPriceFixation PF ON CD.intContractDetailId = PF.intContractDetailId
		LEFT JOIN tblCTPriceFixationDetail PFD ON PF.intPriceFixationId = PFD.intPriceFixationId
		LEFT JOIN tblCTPosition P ON CH.intPositionId = P.intPositionId
		LEFT JOIN tblRKFuturesMonth FMo ON CD.intFutureMonthId = FMo.intFutureMonthId
		INNER JOIN tblICItemUOM UOM ON CD.intItemUOMId = UOM.intItemUOMId
		INNER JOIN tblICUnitMeasure UM ON UOM.intUnitMeasureId = UM.intUnitMeasureId
		WHERE PF.intPriceFixationId IS NOT NULL
			AND CD.intFutureMarketId = ISNULL(@intFutureMarketId, CD.intFutureMarketId)
			AND CH.intCommodityId = ISNULL(@intCommodityId, CH.intCommodityId)
			AND CD.intCurrencyId = ISNULL(@intCurrencyId, CD.intCurrencyId)

		--===================
		-- Future Trades
		--===================
		UNION ALL SELECT DD.intFutureMarketId
			, DD.intCommodityId
			, DD.intCurrencyId
			, 'Futures' COLLATE Latin1_General_CI_AS AS strActivity
			, DD.strBuySell
			, DD.strInternalTradeNo AS strTransactionId
			, DD.intFutOptTransactionHeaderId AS intTransactionId
			, CONVERT(date,DD.dtmTransactionDate,101) AS dtmEntryDate
			, CONVERT(date,DD.dtmFilledDate,101) AS dtmTransactionDate
			, '' COLLATE Latin1_General_CI_AS AS strItemNo
			, 0 AS intItemId
			, ISNULL(DD.dblNoOfContract,0) * ISNULL(FM.dblContractSize,0)  AS dblOriginalQty
			, dbo.fnCTConvertQtyToTargetCommodityUOM(DD.intCommodityId,FM.intUnitMeasureId,ISNULL(@intQtyUOMId, 0),ISNULL(DD.dblNoOfContract,0) * ISNULL(FM.dblContractSize,0) ) AS dblQty
			, null AS intItemUOMId
			, UM.strSymbol
			, ISNULL(DD.dblNoOfContract,0) * ISNULL(FM.dblContractSize,0)  AS dblDeltaQty
			, DD.dblNoOfContract
			, '' COLLATE Latin1_General_CI_AS AS strPosition
			, '' COLLATE Latin1_General_CI_AS AS strFutureMonth
			, dbo.fnCTConvertQtyToTargetCommodityUOM(DD.intCommodityId,ISNULL(@intPriceUOMId, 0),FM.intUnitMeasureId,ISNULL(DD.dblPrice,0)) AS dblPrice 
			, (ISNULL(DD.dblNoOfContract,0) * ISNULL(FM.dblContractSize,0)) * DD.dblPrice AS strValue
			, null AS intPriceFixationId
		FROM tblRKFutOptTransactionHeader DH
		INNER JOIN tblRKFutOptTransaction DD ON DH.intFutOptTransactionHeaderId = DD.intFutOptTransactionHeaderId
		INNER JOIN tblRKFutureMarket FM ON DD.intFutureMarketId = FM.intFutureMarketId
		INNER JOIN tblICUnitMeasure UM ON FM.intUnitMeasureId = UM.intUnitMeasureId
		WHERE  DD.intFutureMarketId = ISNULL(@intFutureMarketId, DD.intFutureMarketId)
		AND DD.intCommodityId = ISNULL(@intCommodityId, DD.intCommodityId)
		AND DD.intCurrencyId = ISNULL(@intCurrencyId, DD.intCurrencyId)
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