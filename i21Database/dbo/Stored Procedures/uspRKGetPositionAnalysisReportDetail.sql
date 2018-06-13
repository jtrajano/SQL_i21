CREATE PROC uspRKGetPositionAnalysisReportDetail
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


DECLARE @outrightQuery AS  NVARCHAR(max) = '',
		@pricingQuery AS  NVARCHAR(max) = '',
		@futuresQuery AS  NVARCHAR(max) = '',
		@date nvarchar(50),
		@dateFilter nvarchar(max)

IF @strFilterBy = 'Transaction Date'
BEGIN
	SET @date = 'dtmTransactionDate'
END
ELSE
	SET @date = 'dtmEntryDate'


--Compose the date filter
IF @strCondition = 'Between' 
BEGIN
	SET @dateFilter = @date + ' BETWEEN ''' + @dtmDateFrom + ''' AND ''' + @dtmDateTo + ''''
END
ELSE IF @strCondition = 'Equal' 
	SET @dateFilter =  @date + ' = ''' + @dtmDateFrom + ''''
ELSE IF @strCondition = 'After' 
	SET @dateFilter =  @date + ' > ''' + @dtmDateFrom + ''''	
ELSE IF @strCondition = 'Before' 
	SET @dateFilter =  @date + ' < ''' + @dtmDateFrom + ''''

SET @outrightQuery = N'
	SELECT 
	 CONVERT(INT,ROW_NUMBER() OVER(ORDER BY dtmTransactionDate ASC)) AS intRowNum 
	,intFutureMarketId
	,intCommodityId
	,intCurrencyId
	,strActivity
	,strBuySell
	,strTransactionId
	,intTransactionId
	,dtmEntryDate
	,dtmTransactionDate
	,strItemNo
	,CONVERT(VARCHAR(50), CAST(dblOriginalQty AS MONEY), 1) + '' '' + strSymbol as strOriginalQtyUOM
	,CASE WHEN strBuySell = ''Buy'' THEN
			dblQty
		 ELSE --Sell
			dblQty * -1
	 END AS dblQty 
	,CASE WHEN strBuySell = ''Buy'' THEN
			ISNULL(dblDeltaQty,0)
		 ELSE --Sell
			ISNULL(dblDeltaQty,0) * -1
	 END AS dblDeltaQty	
	,dblNoOfLots
	,strPosition
	,strFutureMonth
	,dblPrice
	,ISNULL(dblValue,0) as dblValue
	,intPriceFixationId
	
	FROM (

		--=========================================
		-- Outright Physicals
		--=========================================
		SELECT 
			 CD.intFutureMarketId
			,CH.intCommodityId
			,CD.intCurrencyId
			,''Outright'' AS strActivity
			,CASE WHEN CH.intContractTypeId = 1 THEN --Purchase
				''Buy''
				ELSE --Sale
				''Sell''
			 END AS strBuySell
			,CH.strContractNumber AS strTransactionId
			,CH.intContractHeaderId AS intTransactionId
			,CONVERT(date,CH.dtmCreated,101) AS dtmEntryDate
			,CONVERT(date,CH.dtmContractDate,101) AS dtmTransactionDate
			,ITM.strItemNo
			,ITM.intItemId
			,CD.dblQuantity AS dblOriginalQty
			,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,(select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intQtyUOMId IS NULL THEN '0' ELSE CAST(@intQtyUOMId AS NVARCHAR(10)) END  +'), ISNULL(CD.dblQuantity,0)) AS dblQty
			,CD.intItemUOMId
			,UM.strSymbol
			,CASE WHEN ITM.intProductLineId IS NOT NULL THEN 
				ISNULL(CD.dblQuantity,0) * (ISNULL(CPL.dblDeltaPercent,0) /100)
			 ELSE
				ISNULL(CD.dblQuantity,0)	
			 END AS dblDeltaQty
			,CD.dblNoOfLots
			,P.strPosition
			,FMo.strFutureMonth
			,dbo.fnCTConvertQtyToTargetItemUOM((select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intPriceUOMId IS NULL THEN '0' ELSE CAST(@intPriceUOMId AS NVARCHAR(10)) END  +'),CD.intItemUOMId, ISNULL(CD.dblCashPrice,0)) AS dblPrice
			,CD.dblTotalCost as dblValue
			,PF.intPriceFixationId
		FROM tblCTContractHeader CH
		INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
		INNER JOIN tblICItem ITM ON CD.intItemId = ITM.intItemId
		LEFT JOIN tblICCommodityProductLine CPL ON ITM.intProductLineId = CPL.intCommodityProductLineId
		LEFT JOIN tblCTPriceFixation PF ON CD.intContractDetailId = PF.intContractDetailId
		LEFT JOIN tblCTPosition P ON CH.intPositionId = P.intPositionId
		LEFT JOIN tblRKFuturesMonth FMo ON CD.intFutureMonthId = FMo.intFutureMonthId
		INNER JOIN tblICItemUOM UOM ON CD.intItemUOMId = UOM.intItemUOMId
		INNER JOIN tblICUnitMeasure UM ON UOM.intUnitMeasureId = UM.intUnitMeasureId
		WHERE 
		CH.intPricingTypeId = 1 --Priced
		AND PF.intPriceFixationId IS NULL
		AND CD.intFutureMarketId = '+ CASE WHEN @intFutureMarketId IS NULL THEN 'CD.intFutureMarketId' ELSE CAST(@intFutureMarketId AS NVARCHAR(10)) END +'
		AND CH.intCommodityId = '+ CASE WHEN @intCommodityId IS NULL THEN 'CH.intCommodityId' ELSE CAST(@intCommodityId AS NVARCHAR(10)) END +'
		AND CD.intCurrencyId = '+ CASE WHEN @intCurrencyId IS NULL THEN 'CD.intCurrencyId' ELSE CAST(@intCurrencyId AS NVARCHAR(10)) END+'
		'
	SET @pricingQuery = N'
		--=========================================
		-- Price Fixations
		--=========================================
		UNION ALL
		SELECT 
			 CD.intFutureMarketId
			,CH.intCommodityId
			,CD.intCurrencyId
			,''Price Fixing'' AS strActivity
			,CASE WHEN CH.intContractTypeId = 1 THEN --Purchase
				''Buy''
				ELSE --Sale
				''Sell''
			 END AS strBuySell
			,CH.strContractNumber AS strTransactionId
			,CH.intContractHeaderId AS intTransactionId
			,CONVERT(date,CH.dtmCreated,101) AS dtmEntryDate
			,CONVERT(date,CH.dtmContractDate,101) AS dtmTransactionDate
			,ITM.strItemNo
			,ITM.intItemId
			,CD.dblQuantity AS dblOriginalQty
			,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,(select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intQtyUOMId IS NULL THEN '0' ELSE CAST(@intQtyUOMId AS NVARCHAR(10)) END  +'), ISNULL(CD.dblQuantity,0)) AS dblQty
			,CD.intItemUOMId
			,UM.strSymbol
			,CASE WHEN ITM.intProductLineId IS NOT NULL THEN 
				ISNULL(PFD.dblQuantity,0) * (ISNULL(CPL.dblDeltaPercent,0) /100)
				
			 ELSE
				ISNULL(PFD.dblQuantity,0)
			 END AS dblDeltaQty
			,PFD.dblNoOfLots
			,P.strPosition
			,FMo.strFutureMonth
			,dbo.fnCTConvertQtyToTargetItemUOM((select top 1 intItemUOMId from tblICItemUOM where intItemId = ITM.intItemId and intUnitMeasureId = ' + CASE WHEN @intPriceUOMId IS NULL THEN '0' ELSE CAST(@intPriceUOMId AS NVARCHAR(10)) END  +'),CD.intItemUOMId, ISNULL(PFD.dblFixationPrice,0)) AS dblPrice
			,PFD.dblFixationPrice * PFD.dblQuantity AS dblValue
			,PF.intPriceFixationId
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
		WHERE 
		--CH.intPricingTypeId = 1 --Priced
		PF.intPriceFixationId IS NOT NULL
		AND CD.intFutureMarketId = '+ CASE WHEN @intFutureMarketId IS NULL THEN 'CD.intFutureMarketId' ELSE CAST(@intFutureMarketId AS NVARCHAR(10)) END +'
		AND CH.intCommodityId = '+ CASE WHEN @intCommodityId IS NULL THEN 'CH.intCommodityId' ELSE CAST(@intCommodityId AS NVARCHAR(10)) END +'
		AND CD.intCurrencyId = '+ CASE WHEN @intCurrencyId IS NULL THEN 'CD.intCurrencyId' ELSE CAST(@intCurrencyId AS NVARCHAR(10)) END+'
		'
	SET @futuresQuery = N'
		--===================
		-- Future Trades
		--===================
		UNION ALL
		SELECT 
			 DD.intFutureMarketId
			,DD.intCommodityId
			,DD.intCurrencyId
			,''Futures'' AS strActivity
			,DD.strBuySell
			,DD.strInternalTradeNo AS strTransactionId
			,DD.intFutOptTransactionHeaderId AS intTransactionId
			,CONVERT(date,DD.dtmTransactionDate,101) AS dtmEntryDate
			,CONVERT(date,DD.dtmFilledDate,101) AS dtmTransactionDate
			,'''' AS strItemNo
			,0 AS intItemId
			,ISNULL(DD.intNoOfContract,0) * ISNULL(FM.dblContractSize,0)  AS dblOriginalQty
			,dbo.fnCTConvertQtyToTargetCommodityUOM(DD.intCommodityId,FM.intUnitMeasureId,' + CASE WHEN @intQtyUOMId IS NULL THEN '0' ELSE CAST(@intQtyUOMId AS NVARCHAR(10)) END  +',ISNULL(DD.intNoOfContract,0) * ISNULL(FM.dblContractSize,0) ) AS dblQty
			,null AS intItemUOMId
			,UM.strSymbol
			,ISNULL(DD.intNoOfContract,0) * ISNULL(FM.dblContractSize,0)  AS dblDeltaQty
			,DD.intNoOfContract
			,'''' AS strPosition
			,'''' AS strFutureMonth
			,dbo.fnCTConvertQtyToTargetCommodityUOM(DD.intCommodityId,' + CASE WHEN @intPriceUOMId IS NULL THEN '0' ELSE CAST(@intPriceUOMId AS NVARCHAR(10)) END  +',FM.intUnitMeasureId,ISNULL(DD.dblPrice,0)) AS dblPrice 
			,(ISNULL(DD.intNoOfContract,0) * ISNULL(FM.dblContractSize,0)) * DD.dblPrice AS strValue
			,null AS intPriceFixationId
		FROM tblRKFutOptTransactionHeader DH
		INNER JOIN tblRKFutOptTransaction DD ON DH.intFutOptTransactionHeaderId = DD.intFutOptTransactionHeaderId
		INNER JOIN tblRKFutureMarket FM ON DD.intFutureMarketId = FM.intFutureMarketId
		INNER JOIN tblICUnitMeasure UM ON FM.intUnitMeasureId = UM.intUnitMeasureId
		WHERE  DD.intFutureMarketId = '+ CASE WHEN @intFutureMarketId IS NULL THEN 'DD.intFutureMarketId' ELSE CAST(@intFutureMarketId AS NVARCHAR(10)) END +'
		AND DD.intCommodityId = '+ CASE WHEN @intCommodityId IS NULL THEN 'DD.intCommodityId' ELSE CAST(@intCommodityId AS NVARCHAR(10)) END +'
		AND DD.intCurrencyId = '+ CASE WHEN @intCurrencyId IS NULL THEN 'DD.intCurrencyId' ELSE CAST(@intCurrencyId AS NVARCHAR(10)) END+'
	) tbl ' + CASE WHEN @dateFilter IS NOT NULL OR @dateFilter != '' THEN ' WHERE ' + @dateFilter END

	EXEC( @outrightQuery + @pricingQuery + @futuresQuery)
