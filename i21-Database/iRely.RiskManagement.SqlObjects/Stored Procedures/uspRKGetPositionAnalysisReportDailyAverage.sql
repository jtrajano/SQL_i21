CREATE PROC uspRKGetPositionAnalysisReportDailyAverage
	@strFilterBy nvarchar(20)= NULL,
	@strCondition nvarchar(20),
	@dtmDateFrom nvarchar(30) = NULL,
	@dtmDateTo nvarchar(30) = NULL,
	@intFutureMarketId int= NULL,
	@intCommodityId int= NULL,
	@intQtyUOMId int = NULL,
	@intCurrencyId int= NULL,
	@intPriceUOMId int = NULL
AS	

DECLARE @queryHeader nvarchar(max),
		@query1 nvarchar(max),
		@query2 nvarchar(max),
		@query3 nvarchar(max),
		@dateFilter nvarchar(max)

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


IF @strFilterBy = 'Transaction Date'
BEGIN

	SET @queryHeader = N'
	--=============================
	-- Filtered By Transaction Date
	--=============================
	SELECT 
	 CONVERT(INT,ROW_NUMBER() OVER(ORDER BY dtmTransactionDate ASC)) AS intRowNum 
	,dtmTransactionDate AS dtmDate
	,intFutureMarketId
	,intCommodityId
	,intCurrencyId
	,SUM(dblOutrightPhysicalDeltaQty)	AS dblOutrightPhysicalDeltaQty
	,SUM(dblOutrightPhysicalQty)		AS dblOutrightPhysicalQty
	,SUM(dblOutrightPhysicalPrice)		AS dblOutrightPhysicalPrice
	,SUM(dblFutureTradeQty)				AS dblFutureTradeQty
	,SUM(dblFutureTradePrice)			AS dblFutureTradePrice
	,SUM(dblPriceFixationDeltaQty)		AS dblPriceFixationDeltaQty
	,SUM(dblPriceFixationQty)			AS dblPriceFixationQty
	,SUM(dblPriceFixationPrice)			AS dblPriceFixationPrice
	,(SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalDeltaQty) + SUM(dblPriceFixationDeltaQty)) AS dblAverageDeltaQty
	,(SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalQty) + SUM(dblPriceFixationQty)) AS dblAverageQty
	,( ((SUM(dblOutrightPhysicalQty) * SUM(dblOutrightPhysicalPrice)) +  (SUM(dblFutureTradeQty) * SUM(dblFutureTradePrice))  +  (SUM(dblPriceFixationQty) * SUM(dblPriceFixationPrice))) / (SUM(dblOutrightPhysicalQty) + SUM(dblFutureTradeQty) + SUM(dblPriceFixationQty)) ) AS dblAveragePrice
	FROM (
	'
	SET @query1 = N'
	--=========================================
	-- Outright Physicals
	--=========================================
	SELECT 
		 CONVERT(date,CH.dtmCreated,101) AS dtmEntryDate
		,CONVERT(date,CH.dtmContractDate,101) AS dtmTransactionDate
		,CD.intFutureMarketId
		,CH.intCommodityId
		,CD.intCurrencyId
		,CASE WHEN ITM.intProductLineId IS NOT NULL THEN 
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,(select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intQtyUOMId IS NULL THEN '0' ELSE CAST(@intQtyUOMId AS NVARCHAR(10)) END  +'), ISNULL(CD.dblQuantity,0)) * (ISNULL(CPL.dblDeltaPercent,0) /100)
		 ELSE
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,(select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intQtyUOMId IS NULL THEN '0' ELSE CAST(@intQtyUOMId AS NVARCHAR(10)) END  +'), ISNULL(CD.dblQuantity,0))
		 END AS dblOutrightPhysicalDeltaQty
		,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,(select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intQtyUOMId IS NULL THEN '0' ELSE CAST(@intQtyUOMId AS NVARCHAR(10)) END  +'), ISNULL(CD.dblQuantity,0))  AS dblOutrightPhysicalQty
		,dbo.fnCTConvertQtyToTargetItemUOM((select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intPriceUOMId IS NULL THEN '0' ELSE CAST(@intPriceUOMId AS NVARCHAR(10)) END  +'),CD.intItemUOMId, ISNULL(CD.dblCashPrice,0)) AS dblOutrightPhysicalPrice
		,0 AS dblFutureTradeDeltaQty
		,0 AS dblFutureTradeQty
		,0 as dblFutureTradePrice
		,0 AS dblPriceFixationDeltaQty
		,0 AS dblPriceFixationQty
		,0 AS dblPriceFixationPrice
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
	INNER JOIN tblICItem ITM ON CD.intItemId = ITM.intItemId
	LEFT JOIN tblICCommodityProductLine CPL ON ITM.intProductLineId = CPL.intCommodityProductLineId
	WHERE 
	CH.intPricingTypeId = 1 --Priced 
	'

	SET @query2 = N'
	--=========================================
	-- Price Fixations
	--=========================================
	UNION ALL 
	SELECT 
		 CONVERT(date,CH.dtmCreated,101) AS dtmEntryDate
		,CONVERT(date,CH.dtmContractDate,101) AS dtmTransactionDate
		,CD.intFutureMarketId
		,CH.intCommodityId
		,CD.intCurrencyId
		,0 dblOutrightPhysicalDeltaQty
		,0  AS dblOutrightPhysicalQty
		,0 AS dblOutrightPhysicalPrice
		,0 AS dblFutureTradeDeltaQty
		,0 AS dblFutureTradeQty
		,0 as dblFutureTradePrice
		,CASE WHEN ITM.intProductLineId IS NOT NULL THEN 
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,(select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intQtyUOMId IS NULL THEN '0' ELSE CAST(@intQtyUOMId AS NVARCHAR(10)) END  +'), ISNULL(PFD.dblQuantity,0))* (ISNULL(CPL.dblDeltaPercent,0) /100)
		 ELSE
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,(select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intQtyUOMId IS NULL THEN '0' ELSE CAST(@intQtyUOMId AS NVARCHAR(10)) END  +'), ISNULL(PFD.dblQuantity,0))
		 END AS dblPriceFixationDeltaQty
		,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,(select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intQtyUOMId IS NULL THEN '0' ELSE CAST(@intQtyUOMId AS NVARCHAR(10)) END  +'), ISNULL(PFD.dblQuantity,0)) AS dblPriceFixationQty
		,dbo.fnCTConvertQtyToTargetItemUOM((select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intPriceUOMId IS NULL THEN '0' ELSE CAST(@intPriceUOMId AS NVARCHAR(10)) END  +'),CD.intItemUOMId, ISNULL(PFD.dblFixationPrice,0)) AS dblPriceFixationPrice
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
	INNER JOIN tblICItem ITM ON CD.intItemId = ITM.intItemId
	LEFT JOIN tblICCommodityProductLine CPL ON ITM.intProductLineId = CPL.intCommodityProductLineId
	INNER JOIN tblCTPriceFixation PF ON CD.intContractDetailId = PF.intContractDetailId
	INNER JOIN tblCTPriceFixationDetail PFD ON PF.intPriceFixationId = PFD.intPriceFixationId
	WHERE 
	PF.intPriceFixationId IS NOT NULL 
	'

	SET @query3 = N'
	--===================
	-- Future Trades
	--===================
	UNION ALL
	SELECT 
		 CONVERT(date,DD.dtmTransactionDate,101) AS dtmEntryDate
		,CONVERT(date,DD.dtmFilledDate,101) AS dtmTransactionDate
		,DD.intFutureMarketId
		,DD.intCommodityId
		,DD.intCurrencyId
		,0 AS dblOutrightPhysicalDeltaQty
		,0 AS dblOutrightPhysicalQty
		,0 AS dblOutrightPhysicalPrice
		,0 AS dblFutureTradeDeltaQty
		,dbo.fnCTConvertQtyToTargetCommodityUOM(DD.intCommodityId,FM.intUnitMeasureId,' + CASE WHEN @intQtyUOMId IS NULL THEN '0' ELSE CAST(@intQtyUOMId AS NVARCHAR(10)) END  +',ISNULL(DD.intNoOfContract,0) * ISNULL(FM.dblContractSize,0) )  AS dblFutureTradeQty
		,dbo.fnCTConvertQtyToTargetCommodityUOM(DD.intCommodityId,' + CASE WHEN @intPriceUOMId IS NULL THEN '0' ELSE CAST(@intPriceUOMId AS NVARCHAR(10)) END  +',FM.intUnitMeasureId,ISNULL(DD.dblPrice,0))  AS dblFutureTradePrice
		,0 AS dblPriceFixationDeltaQty
		,0 AS dblPriceFixationQty
		,0 AS dblPriceFixationPrice
	FROM tblRKFutOptTransactionHeader DH
	INNER JOIN tblRKFutOptTransaction DD ON DH.intFutOptTransactionHeaderId = DD.intFutOptTransactionHeaderId
	INNER JOIN tblRKFutureMarket FM ON DD.intFutureMarketId = FM.intFutureMarketId

	) tbl
	WHERE dtmTransactionDate ' + @dateFilter +
		' AND intFutureMarketId = '+ CASE WHEN @intFutureMarketId IS NULL THEN 'intFutureMarketId' ELSE CAST(@intFutureMarketId AS NVARCHAR(10)) END +'
		AND intCommodityId = '+ CASE WHEN @intCommodityId IS NULL THEN 'intCommodityId' ELSE CAST(@intCommodityId AS NVARCHAR(10)) END +'
		AND intCurrencyId = '+ CASE WHEN @intCurrencyId IS NULL THEN 'intCurrencyId' ELSE CAST(@intCurrencyId AS NVARCHAR(10)) END+'
	GROUP BY 
	 dtmTransactionDate
	,intFutureMarketId
	,intCommodityId
	,intCurrencyId '

	EXEC(@queryHeader + @query1  + @query2 + @query3)
	
END
ELSE
BEGIN
	SET @queryHeader = N'
	--=============================
	-- Filtered By Creation Date
	--=============================
	SELECT 
	  CONVERT(INT,ROW_NUMBER() OVER(ORDER BY dtmEntryDate ASC)) AS intRowNum 
	,dtmEntryDate AS dtmDate
	,intFutureMarketId
	,intCommodityId
	,intCurrencyId
	,SUM(dblOutrightPhysicalDeltaQty)	AS dblOutrightPhysicalDeltaQty
	,SUM(dblOutrightPhysicalQty)		AS dblOutrightPhysicalQty
	,SUM(dblOutrightPhysicalPrice)		AS dblOutrightPhysicalPrice
	,SUM(dblFutureTradeQty)				AS dblFutureTradeQty
	,SUM(dblFutureTradePrice)			AS dblFutureTradePrice
	,SUM(dblPriceFixationDeltaQty)		AS dblPriceFixationDeltaQty
	,SUM(dblPriceFixationQty)			AS dblPriceFixationQty
	,SUM(dblPriceFixationPrice)			AS dblPriceFixationPrice
	,(SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalDeltaQty) + SUM(dblPriceFixationDeltaQty)) AS dblAverageDeltaQty
	,(SUM(dblFutureTradeQty) + SUM(dblOutrightPhysicalQty) + SUM(dblPriceFixationQty)) AS dblAverageQty
	,( ((SUM(dblOutrightPhysicalQty) * SUM(dblOutrightPhysicalPrice)) +  (SUM(dblFutureTradeQty) * SUM(dblFutureTradePrice))  +  (SUM(dblPriceFixationQty) * SUM(dblPriceFixationPrice))) / (SUM(dblOutrightPhysicalQty) + SUM(dblFutureTradeQty) + SUM(dblPriceFixationQty)) ) AS dblAveragePrice

	FROM (
	'
	SET @query1 = N'
	--=========================================
	-- Outright Physicals AND Price Fixations
	--=========================================
	SELECT 
		 CONVERT(date,CH.dtmCreated,101) AS dtmEntryDate
		,CONVERT(date,CH.dtmContractDate,101) AS dtmTransactionDate
		,CD.intFutureMarketId
		,CH.intCommodityId
		,CD.intCurrencyId
		,CASE WHEN ITM.intProductLineId IS NOT NULL THEN 
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,(select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intQtyUOMId IS NULL THEN '0' ELSE CAST(@intQtyUOMId AS NVARCHAR(10)) END  +'), ISNULL(CD.dblQuantity,0)) * (ISNULL(CPL.dblDeltaPercent,0) /100)
		 ELSE
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,(select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intQtyUOMId IS NULL THEN '0' ELSE CAST(@intQtyUOMId AS NVARCHAR(10)) END  +'), ISNULL(CD.dblQuantity,0))
		 END AS dblOutrightPhysicalDeltaQty
		,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,(select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intQtyUOMId IS NULL THEN '0' ELSE CAST(@intQtyUOMId AS NVARCHAR(10)) END  +'), ISNULL(CD.dblQuantity,0))  AS dblOutrightPhysicalQty
		,dbo.fnCTConvertQtyToTargetItemUOM((select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intPriceUOMId IS NULL THEN '0' ELSE CAST(@intPriceUOMId AS NVARCHAR(10)) END  +'),CD.intItemUOMId, ISNULL(CD.dblCashPrice,0)) AS dblOutrightPhysicalPrice
		,0 AS dblFutureTradeDeltaQty
		,0 AS dblFutureTradeQty
		,0 as dblFutureTradePrice
		,0 AS dblPriceFixationDeltaQty
		,0 AS dblPriceFixationQty
		,0 AS dblPriceFixationPrice
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
	INNER JOIN tblICItem ITM ON CD.intItemId = ITM.intItemId
	LEFT JOIN tblICCommodityProductLine CPL ON ITM.intProductLineId = CPL.intCommodityProductLineId
	WHERE 
	CH.intPricingTypeId = 1 --Priced
	'
	SET @query2 = N'
	--=========================================
	-- Price Fixations
	--=========================================
	UNION ALL
	SELECT 
		 CONVERT(date,CH.dtmCreated,101) AS dtmEntryDate
		,CONVERT(date,CH.dtmContractDate,101) AS dtmTransactionDate
		,CD.intFutureMarketId
		,CH.intCommodityId
		,CD.intCurrencyId
		,0 AS dblOutrightPhysicalDeltaQty
		,0 AS dblOutrightPhysicalQty
		,0 AS dblOutrightPhysicalPrice
		,0 AS dblFutureTradeDeltaQty
		,0 AS dblFutureTradeQty
		,0 as dblFutureTradePrice
		,CASE WHEN ITM.intProductLineId IS NOT NULL THEN 
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,(select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intQtyUOMId IS NULL THEN '0' ELSE CAST(@intQtyUOMId AS NVARCHAR(10)) END  +'), ISNULL(PFD.dblQuantity,0))* (ISNULL(CPL.dblDeltaPercent,0) /100)
		 ELSE
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,(select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intQtyUOMId IS NULL THEN '0' ELSE CAST(@intQtyUOMId AS NVARCHAR(10)) END  +'), ISNULL(PFD.dblQuantity,0))
		 END AS dblPriceFixationDeltaQty
		,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,(select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intQtyUOMId IS NULL THEN '0' ELSE CAST(@intQtyUOMId AS NVARCHAR(10)) END  +'), ISNULL(PFD.dblQuantity,0)) AS dblPriceFixationQty
		,dbo.fnCTConvertQtyToTargetItemUOM((select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intPriceUOMId IS NULL THEN '0' ELSE CAST(@intPriceUOMId AS NVARCHAR(10)) END  +'),CD.intItemUOMId, ISNULL(PFD.dblFixationPrice,0)) AS dblPriceFixationPrice
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
	INNER JOIN tblICItem ITM ON CD.intItemId = ITM.intItemId
	LEFT JOIN tblICCommodityProductLine CPL ON ITM.intProductLineId = CPL.intCommodityProductLineId
	INNER JOIN tblCTPriceFixation PF ON CD.intContractDetailId = PF.intContractDetailId
	INNER JOIN tblCTPriceFixationDetail PFD ON PF.intPriceFixationId = PFD.intPriceFixationId
	WHERE 
	PF.intPriceFixationId IS NOT NULL 
	'
	SET @query3 = N'
	--===================
	-- Future Trades
	--===================
	UNION ALL
	SELECT 
		 CONVERT(date,DD.dtmTransactionDate,101) AS dtmEntryDate
		,CONVERT(date,DD.dtmFilledDate,101) AS dtmTransactionDate
		,DD.intFutureMarketId
		,DD.intCommodityId
		,DD.intCurrencyId
		,0 AS dblOutrightPhysicalDeltaQty
		,0 AS dblOutrightPhysicalQty
		,0 AS dblOutrightPhysicalPrice
		,0 AS dblFutureTradeDeltaQty
		,dbo.fnCTConvertQtyToTargetCommodityUOM(DD.intCommodityId,FM.intUnitMeasureId,' + CASE WHEN @intQtyUOMId IS NULL THEN '0' ELSE CAST(@intQtyUOMId AS NVARCHAR(10)) END  +',ISNULL(DD.intNoOfContract,0) * ISNULL(FM.dblContractSize,0) )  AS dblFutureTradeQty
		,dbo.fnCTConvertQtyToTargetCommodityUOM(DD.intCommodityId,' + CASE WHEN @intPriceUOMId IS NULL THEN '0' ELSE CAST(@intPriceUOMId AS NVARCHAR(10)) END  +',FM.intUnitMeasureId,ISNULL(DD.dblPrice,0))  AS dblFutureTradePrice
		,0 AS dblPriceFixationDeltaQty
		,0 AS dblPriceFixationQty
		,0 AS dblPriceFixationPrice
	FROM tblRKFutOptTransactionHeader DH
	INNER JOIN tblRKFutOptTransaction DD ON DH.intFutOptTransactionHeaderId = DD.intFutOptTransactionHeaderId
	INNER JOIN tblRKFutureMarket FM ON DD.intFutureMarketId = FM.intFutureMarketId

	) tbl
	WHERE dtmEntryDate ' + @dateFilter +
		' AND intFutureMarketId = '+ CASE WHEN @intFutureMarketId IS NULL THEN 'intFutureMarketId' ELSE CAST(@intFutureMarketId AS NVARCHAR(10)) END +'
		AND intCommodityId = '+ CASE WHEN @intCommodityId IS NULL THEN 'intCommodityId' ELSE CAST(@intCommodityId AS NVARCHAR(10)) END +'
		AND intCurrencyId = '+ CASE WHEN @intCurrencyId IS NULL THEN 'intCurrencyId' ELSE CAST(@intCurrencyId AS NVARCHAR(10)) END+'
	GROUP BY 
	 dtmEntryDate
	,intFutureMarketId
	,intCommodityId
	,intCurrencyId '

	EXEC(@queryHeader + @query1 + @query2 + @query3)
END


