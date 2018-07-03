CREATE PROC [dbo].[uspRKRiskPositionInquiry]  
        @intCommodityId INTEGER,  
        @intCompanyLocationId INTEGER,  
        @intFutureMarketId INTEGER,  
        @intFutureMonthId INTEGER,  
        @intUOMId INTEGER,  
        @intDecimal INTEGER,
        @intForecastWeeklyConsumption INTEGER = null,
        @intForecastWeeklyConsumptionUOMId INTEGER = null,
		@intBookId int = NULL, 
		@intSubBookId int = NULL,
		@strPositionBy nvarchar(100) = NULL   
AS  

IF isnull(@intForecastWeeklyConsumptionUOMId, 0) = 0
BEGIN
	SET @intForecastWeeklyConsumption = 1
END

IF isnull(@intForecastWeeklyConsumptionUOMId, 0) = 0
BEGIN
	SET @intForecastWeeklyConsumptionUOMId = @intUOMId
END

DECLARE @strUnitMeasure NVARCHAR(max)
DECLARE @dtmFutureMonthsDate DATETIME
DECLARE @dblContractSize INT
DECLARE @ysnIncludeInventoryHedge BIT
DECLARE @strRiskView NVARCHAR(max)
DECLARE @strFutureMonth NVARCHAR(max)
	,@dblForecastWeeklyConsumption NUMERIC(24, 10)
DECLARE @strParamFutureMonth NVARCHAR(max)

SELECT @dblContractSize = convert(INT, dblContractSize)
FROM tblRKFutureMarket
WHERE intFutureMarketId = @intFutureMarketId

SELECT TOP 1 @dtmFutureMonthsDate = dtmFutureMonthsDate
	,@strParamFutureMonth = strFutureMonth
FROM tblRKFuturesMonth
WHERE intFutureMonthId = @intFutureMonthId

SELECT TOP 1 @strUnitMeasure = strUnitMeasure
FROM tblICUnitMeasure
WHERE intUnitMeasureId = @intUOMId

SELECT @intUOMId = intCommodityUnitMeasureId
FROM tblICCommodityUnitMeasure
WHERE intCommodityId = @intCommodityId AND intUnitMeasureId = @intUOMId

SELECT @ysnIncludeInventoryHedge = ysnIncludeInventoryHedge
FROM tblRKCompanyPreference

SELECT @strRiskView = strRiskView
FROM tblRKCompanyPreference

DECLARE @intForecastWeeklyConsumptionUOMId1 INT

SELECT @intForecastWeeklyConsumptionUOMId1 = intCommodityUnitMeasureId
FROM tblICCommodityUnitMeasure
WHERE intCommodityId = @intCommodityId AND intUnitMeasureId = @intForecastWeeklyConsumptionUOMId

SELECT @dblForecastWeeklyConsumption = isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(@intForecastWeeklyConsumptionUOMId1, @intUOMId, @intForecastWeeklyConsumption), 1)

--    Invoice End
DECLARE @List AS TABLE (
	intRowNumber INT identity(1, 1)
	,Selection NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,PriceStatus NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,strFutureMonth NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,strAccountNumber NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,dblNoOfContract DECIMAL(24, 10)
	,strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,TransactionDate DATETIME
	,TranType NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,CustVendor NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,dblNoOfLot DECIMAL(24, 10)
	,dblQuantity DECIMAL(24, 10)
	,intOrderByHeading INT
	,intOrderBySubHeading INT
	,intContractHeaderId INT
	,intFutOptTransactionHeaderId INT

	)
DECLARE @PricedContractList AS TABLE (
	strFutureMonth NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,strAccountNumber NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,dblNoOfContract DECIMAL(24, 10)
	,strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,TransactionDate DATETIME
	,TranType NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,CustVendor NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,dblNoOfLot DECIMAL(24, 10)
	,dblQuantity DECIMAL(24, 10)
	,intContractHeaderId INT
	,intFutOptTransactionHeaderId INT
	,intPricingTypeId INT
	,strContractType NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,intCommodityId INT
	,intCompanyLocationId INT
	,intFutureMarketId INT
	,dtmFutureMonthsDate DATETIME
	,ysnExpired BIT
	,ysnDeltaHedge BIT
	,intContractStatusId INT
	,dblDeltaPercent DECIMAL(24, 10)
	,intContractDetailId INT
	,intCommodityUnitMeasureId INT
	,dblRatioContractSize DECIMAL(24, 10)
	)

INSERT INTO @PricedContractList
SELECT fm.strFutureMonth
	,strContractType + ' - ' + case when @strPositionBy= 'Product Type' then isnull(ca.strDescription, '') else isnull(cv.strEntityName, '') end AS strAccountNumber
	,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, @intUOMId, CASE WHEN @ysnIncludeInventoryHedge = 0 THEN isnull(dblBalance, 0) ELSE dblDetailQuantity END) AS dblNoOfContract
	,LEFT(strContractType, 1) + ' - ' + strContractNumber + ' - ' + convert(NVARCHAR, intContractSeq) AS strTradeNo
	,dtmStartDate AS TransactionDate
	,strContractType AS TranType
	,strEntityName AS CustVendor
	,dblNoOfLots AS dblNoOfLot
	,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, @intUOMId, CASE WHEN @ysnIncludeInventoryHedge = 0 THEN isnull(dblBalance, 0) ELSE dblDetailQuantity END) AS dblQuantity
	,cv.intContractHeaderId
	,NULL AS intFutOptTransactionHeaderId
	,intPricingTypeId
	,cv.strContractType
	,cv.intCommodityId
	,cv.intCompanyLocationId
	,cv.intFutureMarketId
	,dtmFutureMonthsDate
	,ysnExpired
	,isnull(pl.ysnDeltaHedge, 0) ysnDeltaHedge
	,intContractStatusId
	,dblDeltaPercent,cv.intContractDetailId,um.intCommodityUnitMeasureId
	,dbo.fnCTConvertQuantityToTargetCommodityUOM(um2.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,ffm.dblContractSize) dblRatioContractSize
FROM vyuRKRiskPositionContractDetail cv
JOIN tblRKFutureMarket ffm ON ffm.intFutureMarketId = cv.intFutureMarketId
JOIN tblICCommodityUnitMeasure um2 ON um2.intUnitMeasureId = ffm.intUnitMeasureId and um2.intCommodityId = cv.intCommodityId
JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = cv.intFutureMonthId
JOIN tblICItemUOM u ON cv.intItemUOMId = u.intItemUOMId
JOIN tblICItem ic ON ic.intItemId = cv.intItemId
LEFT JOIN tblICCommodityProductLine pl ON ic.intCommodityId = pl.intCommodityId AND ic.intProductLineId = pl.intCommodityProductLineId
LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = cv.intCommodityId AND um.intUnitMeasureId = cv.intUnitMeasureId
WHERE cv.intCommodityId = @intCommodityId AND cv.intFutureMarketId = @intFutureMarketId AND cv.intContractStatusId NOT IN (2, 3) --AND cv.intPricingTypeId = 1
AND isnull(intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(intBookId,0) else @intBookId end
AND isnull(intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(intSubBookId,0) else @intSubBookId end


SELECT *
INTO #ContractTransaction
FROM (
	SELECT strFutureMonth
		,strAccountNumber
		,case when intPricingTypeId=8 then  dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblNoOfLot*dblRatioContractSize) else dblNoOfContract end dblNoOfContract
		,strTradeNo
		,TransactionDate
		,TranType
		,CustVendor
		,dblNoOfLot
		,case when intPricingTypeId=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblNoOfLot*dblRatioContractSize) else dblQuantity end dblQuantity
		,intContractHeaderId
		,intFutOptTransactionHeaderId
		,intPricingTypeId
		,strContractType
		,intCommodityId
		,intCompanyLocationId
		,intFutureMarketId
		,dtmFutureMonthsDate
		,ysnExpired
	FROM @PricedContractList cv
	WHERE cv.intPricingTypeId = 1 AND ysnDeltaHedge = 0
	
	UNION
	
	--Parcial Priced
	SELECT strFutureMonth
		,strAccountNumber
		,case when intPricingTypeId=8 then  dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblFixedLots*dblRatioContractSize) else dblFixedQty end AS dblNoOfContract
		,strTradeNo
		,TransactionDate
		,TranType
		,CustVendor
		,dblFixedLots dblNoOfLot
		,case when intPricingTypeId=8 then  dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblFixedLots*dblRatioContractSize) else dblFixedQty end dblFixedQty
		,intContractHeaderId
		,intFutOptTransactionHeaderId
		,1 intPricingTypeId
		,strContractType
		,intCommodityId
		,intCompanyLocationId
		,intFutureMarketId
		,dtmFutureMonthsDate
		,ysnExpired		
	FROM (
		SELECT strFutureMonth
			,strAccountNumber
			,0 AS dblNoOfContract
			,strTradeNo
			,TransactionDate
			,TranType
			,CustVendor
			,dblNoOfLot
			,dblQuantity
			,intContractHeaderId
			,intFutOptTransactionHeaderId
			,intPricingTypeId
			,strContractType
			,intCommodityId
			,intCompanyLocationId
			,intFutureMarketId
			,dtmFutureMonthsDate
			,ysnExpired
			,isnull((
					SELECT sum(dblLotsFixed) dblNoOfLots
					FROM tblCTPriceFixation pf
					WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId
					), 0) dblFixedLots
			,isnull((
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, sum(dblQuantity)) dblQuantity
					FROM tblCTPriceFixation pf
					JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
					WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId
					), 0) dblFixedQty,intCommodityUnitMeasureId
					,dblRatioContractSize
		FROM @PricedContractList cv
		WHERE cv.intContractStatusId <> 3 AND intPricingTypeId <> 1 AND isnull(ysnDeltaHedge, 0) =0
		) t
	WHERE isnull(dblNoOfLot, 0) - isnull(dblFixedLots, 0) <> 0
	
	UNION
	
	--Parcial UnPriced
	SELECT strFutureMonth
		,strAccountNumber
		,case when intPricingTypeId=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId,(isnull(dblNoOfLot, 0) - isnull(dblFixedLots, 0)) * dblRatioContractSize) else dblQuantity - dblFixedQty end AS dblNoOfContract
		,strTradeNo
		,TransactionDate
		,TranType
		,CustVendor
		,isnull(dblNoOfLot, 0) - isnull(dblFixedLots, 0) dblNoOfLot
		,case when intPricingTypeId=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId,(isnull(dblNoOfLot, 0) - isnull(dblFixedLots, 0))*dblRatioContractSize) else dblQuantity - dblFixedQty end dblQuantity
		,intContractHeaderId
		,intFutOptTransactionHeaderId
		,2 intPricingTypeId
		,strContractType
		,intCommodityId
		,intCompanyLocationId
		,intFutureMarketId
		,dtmFutureMonthsDate
		,ysnExpired
	FROM (
		SELECT strFutureMonth
			,strAccountNumber
			,0 AS dblNoOfContract
			,strTradeNo
			,TransactionDate
			,strContractType AS TranType
			,CustVendor
			,dblNoOfLot
			,dblQuantity
			,cv.intContractHeaderId
			,NULL AS intFutOptTransactionHeaderId
			,cv.intPricingTypeId
			,cv.strContractType
			,cv.intCommodityId
			,cv.intCompanyLocationId
			,cv.intFutureMarketId
			,dtmFutureMonthsDate
			,ysnExpired
			,isnull((
					SELECT sum(dblLotsFixed) dblNoOfLots
					FROM tblCTPriceFixation pf
					WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId
					), 0) dblFixedLots
			,isnull((
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, sum(pd.dblQuantity)) dblQuantity
					FROM tblCTPriceFixation pf
					JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
					WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId
					), 0) dblFixedQty
			,isnull(dblDeltaPercent,0) dblDeltaPercent,intCommodityUnitMeasureId,dblRatioContractSize
		FROM @PricedContractList cv
		WHERE cv.intContractStatusId <> 3 AND intPricingTypeId <> 1 AND isnull(ysnDeltaHedge, 0) =0
		) t
	WHERE isnull(dblNoOfLot, 0) - isnull(dblFixedLots, 0) <> 0
	) t1
WHERE dblNoOfContract <> 0	


SELECT *
INTO #DeltaPrecent
FROM (
	SELECT strFutureMonth
		,strAccountNumber + '(Delta=' + convert(NVARCHAR, left(dblDeltaPercent, 4)) + '%)' strAccountNumber
		,(case when intPricingTypeId=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId,dblQuantity*dblRatioContractSize) else dblNoOfContract end*dblDeltaPercent)/100 dblNoOfContract
		,strTradeNo
		,TransactionDate
		,TranType
		,CustVendor
		,(dblNoOfLot*dblDeltaPercent)/100 dblNoOfLot
		,(case when intPricingTypeId=8 then dblQuantity*dblRatioContractSize else dblQuantity end*dblDeltaPercent)/100 dblQuantity
		,intContractHeaderId
		,intFutOptTransactionHeaderId
		,intPricingTypeId
		,strContractType
		,intCommodityId
		,intCompanyLocationId
		,intFutureMarketId
		,dtmFutureMonthsDate
		,ysnExpired
	FROM @PricedContractList cv
	WHERE cv.intPricingTypeId = 1 AND ysnDeltaHedge = 1
	
	UNION
	
	--Parcial Priced
	SELECT strFutureMonth
		,strAccountNumber
		,(case when intPricingTypeId=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId,dblFixedLots*dblRatioContractSize) else dblFixedQty end*dblDeltaPercent)/100  AS dblNoOfContract
		,strTradeNo
		,TransactionDate
		,TranType
		,CustVendor
		,(dblFixedLots*dblDeltaPercent)/100 dblNoOfLot
		,(case when intPricingTypeId=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId,dblFixedLots*dblRatioContractSize) else dblFixedQty end*dblDeltaPercent)/100 dblFixedQty
		,intContractHeaderId
		,intFutOptTransactionHeaderId
		,1 intPricingTypeId
		,strContractType
		,intCommodityId
		,intCompanyLocationId
		,intFutureMarketId
		,dtmFutureMonthsDate
		,ysnExpired		
	FROM (
		SELECT strFutureMonth
			,strAccountNumber + '(Delta=' + convert(NVARCHAR, left(dblDeltaPercent, 4)) + '%)' strAccountNumber
			,0 AS dblNoOfContract
			,strTradeNo
			,TransactionDate
			,TranType
			,CustVendor
			,dblNoOfLot
			,dblQuantity
			,intContractHeaderId
			,intFutOptTransactionHeaderId
			,intPricingTypeId
			,strContractType
			,intCommodityId
			,intCompanyLocationId
			,intFutureMarketId
			,dtmFutureMonthsDate
			,ysnExpired
			,isnull((
					SELECT sum(dblLotsFixed) dblNoOfLots
					FROM tblCTPriceFixation pf
					WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId
					), 0) dblFixedLots
			,isnull((
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, sum(dblQuantity)) dblQuantity
					FROM tblCTPriceFixation pf
					JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
					WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId
					), 0) dblFixedQty
			,dblDeltaPercent,intCommodityUnitMeasureId
			,dblRatioContractSize
		FROM @PricedContractList cv
		WHERE cv.intContractStatusId <> 3 AND intPricingTypeId <> 1 AND isnull(ysnDeltaHedge, 0) =1
		) t
	WHERE isnull(dblNoOfLot, 0) - isnull(dblFixedLots, 0) <> 0
	
	UNION
	
	--Parcial UnPriced
	SELECT strFutureMonth
		,strAccountNumber
		,case when intPricingTypeId=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId,(isnull(dblNoOfLot, 0) - isnull(dblFixedLots, 0))*dblRatioContractSize) else dblQuantity - dblFixedQty  end  AS dblNoOfContract
		,strTradeNo
		,TransactionDate
		,TranType
		,CustVendor
		,isnull(dblNoOfLot, 0) - isnull(dblFixedLots, 0) dblNoOfLot
		,case when intPricingTypeId=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId,(isnull(dblNoOfLot, 0) - isnull(dblFixedLots, 0))*dblRatioContractSize) else dblQuantity - dblFixedQty  end dblQuantity
		,intContractHeaderId
		,intFutOptTransactionHeaderId
		,2 intPricingTypeId
		,strContractType
		,intCommodityId
		,intCompanyLocationId
		,intFutureMarketId
		,dtmFutureMonthsDate
		,ysnExpired
	FROM (
		SELECT strFutureMonth
			,strAccountNumber + '(Delta=' + convert(NVARCHAR, left(dblDeltaPercent, 4)) + '%)' strAccountNumber
			,0 AS dblNoOfContract
			,strTradeNo
			,TransactionDate
			,strContractType AS TranType
			,CustVendor
			,(dblNoOfLot*dblDeltaPercent)/100 dblNoOfLot
			,(dblQuantity*dblDeltaPercent)/100 dblQuantity
			,cv.intContractHeaderId
			,NULL AS intFutOptTransactionHeaderId
			,intPricingTypeId
			,cv.strContractType
			,cv.intCommodityId
			,cv.intCompanyLocationId
			,cv.intFutureMarketId
			,dtmFutureMonthsDate
			,ysnExpired
			,isnull((
					SELECT sum(dblLotsFixed) dblNoOfLots
					FROM tblCTPriceFixation pf
					WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId
					), 0) dblFixedLots
			,isnull((
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, sum(pd.dblQuantity)) dblQuantity
					FROM tblCTPriceFixation pf
					JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
					WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId
					), 0) dblFixedQty,intCommodityUnitMeasureId,dblRatioContractSize
		FROM @PricedContractList cv
		WHERE cv.intContractStatusId <> 3 AND intPricingTypeId <> 1 AND isnull(ysnDeltaHedge, 0) = 1
		) t
	WHERE isnull(dblNoOfLot, 0) - isnull(dblFixedLots, 0) <> 0
	) t1
WHERE dblNoOfContract <> 0	

BEGIN
	INSERT INTO @List (
		 Selection
		,PriceStatus
		,strFutureMonth
		,strAccountNumber
		,dblNoOfContract
		,strTradeNo
		,TransactionDate
		,TranType
		,CustVendor
		,dblNoOfLot
		,dblQuantity
		,intContractHeaderId
		,intFutOptTransactionHeaderId
		)
	SELECT Selection
		,PriceStatus
		,strFutureMonth
		,strAccountNumber
		,ROUND(dblNoOfContract, @intDecimal) AS dblNoOfContract
		,strTradeNo
		,TransactionDate
		,TranType
		,CustVendor
		,dblNoOfLot
		,dblQuantity
		,intContractHeaderId
		,intFutOptTransactionHeaderId
	FROM (
		SELECT *
		FROM (
			SELECT DISTINCT 'Physical position / Basis risk' AS Selection
				,'a. Unpriced - (Balance to be Priced)' AS PriceStatus
				,'Previous' AS strFutureMonth
				,strAccountNumber
				,CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (abs(dblNoOfContract)) END AS dblNoOfContract
				,strTradeNo
				,TransactionDate
				,TranType
				,CustVendor
				,CASE WHEN strContractType = 'Purchase' THEN - (abs(dblNoOfLot)) ELSE dblNoOfLot END dblNoOfLot
				,CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (abs(dblQuantity)) END AS dblQuantity
				,intContractHeaderId
				,NULL AS intFutOptTransactionHeaderId
			FROM #ContractTransaction
			WHERE  intPricingTypeId <> 1 AND dtmFutureMonthsDate < @dtmFutureMonthsDate AND intCommodityId = @intCommodityId AND intCompanyLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intCompanyLocationId ELSE @intCompanyLocationId END AND intFutureMarketId = @intFutureMarketId
			
			UNION
			
			SELECT DISTINCT 'Physical position / Basis risk' AS Selection
				,'a. Unpriced - (Balance to be Priced)' AS PriceStatus
				,strFutureMonth
				,strAccountNumber
				,CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (abs(dblNoOfContract)) END AS dblNoOfContract
				,strTradeNo
				,TransactionDate
				,TranType
				,CustVendor
				,CASE WHEN strContractType = 'Purchase' THEN - (abs(dblNoOfLot)) ELSE dblNoOfLot END dblNoOfLot
				,CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (abs(dblQuantity)) END AS dblQuantity
				,intContractHeaderId
				,NULL AS intFutOptTransactionHeaderId
			FROM #ContractTransaction
			WHERE intPricingTypeId <> 1 AND intCommodityId = @intCommodityId AND intCompanyLocationId = CASE WHEN ISNULL(@intCompanyLocationId, 0) = 0 THEN intCompanyLocationId ELSE @intCompanyLocationId END AND intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
			) T1
		
		UNION
		
		SELECT *
		FROM (
			SELECT DISTINCT 'Physical position / Basis risk' AS Selection
				,'b. Priced / Outright - (Outright position)' AS PriceStatus
				,'Previous' AS strFutureMonth
				,strAccountNumber
				,CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (abs(dblNoOfContract)) END AS dblNoOfContract
				,strTradeNo
				,TransactionDate
				,TranType
				,CustVendor
				,CASE WHEN strContractType = 'Purchase' THEN - (abs(dblNoOfLot)) ELSE dblNoOfLot END dblNoOfLot
				,CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (abs(dblQuantity)) END AS dblQuantity
				,intContractHeaderId
				,NULL AS intFutOptTransactionHeaderId
			FROM #ContractTransaction
			WHERE intPricingTypeId = 1 AND dtmFutureMonthsDate < @dtmFutureMonthsDate AND intCommodityId = @intCommodityId AND intCompanyLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intCompanyLocationId ELSE @intCompanyLocationId END AND intFutureMarketId = @intFutureMarketId
			
			UNION
			
			SELECT DISTINCT 'Physical position / Basis risk' AS Selection
				,'b. Priced / Outright - (Outright position)' AS PriceStatus
				,strFutureMonth
				,strAccountNumber
				,CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (abs(dblNoOfContract)) END AS dblNoOfContract
				,strTradeNo
				,TransactionDate
				,TranType
				,CustVendor
				,CASE WHEN strContractType = 'Purchase' THEN - (abs(dblNoOfLot)) ELSE dblNoOfLot END dblNoOfLot
				,CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (abs(dblQuantity)) END AS dblQuantity
				,intContractHeaderId
				,NULL AS intFutOptTransactionHeaderId
			FROM #ContractTransaction
			WHERE intPricingTypeId = 1 AND intCommodityId = @intCommodityId AND intCompanyLocationId = CASE WHEN ISNULL(@intCompanyLocationId, 0) = 0 THEN intCompanyLocationId ELSE @intCompanyLocationId END AND intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
			) T1
		
		UNION
		
		SELECT *
		FROM (
			SELECT DISTINCT 'Specialities & Low grades' AS Selection
				,'a. Unfixed' AS PriceStatus
				,'Previous' strFutureMonth
				,strAccountNumber
				,CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (abs(dblNoOfContract)) END AS dblNoOfContract
				,strTradeNo
				,TransactionDate
				,TranType
				,CustVendor
				,CASE WHEN strContractType = 'Purchase' THEN - (abs(dblNoOfLot)) ELSE dblNoOfLot END AS dblNoOfLot
				,CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (abs(dblQuantity)) END AS dblQuantity
				,intContractHeaderId
				,NULL AS intFutOptTransactionHeaderId
			FROM #DeltaPrecent
			WHERE intPricingTypeId <> 1 AND intCommodityId = @intCommodityId 
				AND intCompanyLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intCompanyLocationId ELSE @intCompanyLocationId END 
				AND intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate < @dtmFutureMonthsDate
			) T1
		UNION
			SELECT *
		FROM (
			SELECT DISTINCT 'Specialities & Low grades' AS Selection
				,'b. fixed' AS PriceStatus
				,'Previous' AS strFutureMonth
				,strAccountNumber
				,CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (abs(dblNoOfContract)) END AS dblNoOfContract
				,strTradeNo
				,TransactionDate
				,TranType
				,CustVendor
				,CASE WHEN strContractType = 'Purchase' THEN - (abs(dblNoOfLot)) ELSE dblNoOfLot END AS dblNoOfLot
				,CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (abs(dblQuantity)) END AS dblQuantity
				,intContractHeaderId
				,NULL AS intFutOptTransactionHeaderId
			FROM #DeltaPrecent
			WHERE intPricingTypeId = 1 AND intCommodityId = @intCommodityId 
			AND intCompanyLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intCompanyLocationId ELSE @intCompanyLocationId END 
			AND intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate < @dtmFutureMonthsDate
			) T1

		UNION

		SELECT *
		FROM (
			SELECT DISTINCT 'Specialities & Low grades' AS Selection
				,'a. Unfixed' AS PriceStatus
				,strFutureMonth
				,strAccountNumber
				,CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (abs(dblNoOfContract)) END AS dblNoOfContract
				,strTradeNo
				,TransactionDate
				,TranType
				,CustVendor
				,CASE WHEN strContractType = 'Purchase' THEN - (abs(dblNoOfLot)) ELSE dblNoOfLot END AS dblNoOfLot
				,CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (abs(dblQuantity)) END AS dblQuantity
				,intContractHeaderId
				,NULL AS intFutOptTransactionHeaderId
			FROM #DeltaPrecent
			WHERE intPricingTypeId <> 1 AND intCommodityId = @intCommodityId 
				AND intCompanyLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intCompanyLocationId ELSE @intCompanyLocationId END 
				AND intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
			) T1
		
		UNION
		
		SELECT *
		FROM (
			SELECT DISTINCT 'Specialities & Low grades' AS Selection
				,'b. fixed' AS PriceStatus
				,strFutureMonth
				,strAccountNumber
				,CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (abs(dblNoOfContract)) END AS dblNoOfContract
				,strTradeNo
				,TransactionDate
				,TranType
				,CustVendor
				,CASE WHEN strContractType = 'Purchase' THEN - (abs(dblNoOfLot)) ELSE dblNoOfLot END AS dblNoOfLot
				,CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (abs(dblQuantity)) END AS dblQuantity
				,intContractHeaderId
				,NULL AS intFutOptTransactionHeaderId
			FROM #DeltaPrecent
			WHERE intPricingTypeId = 1 AND intCommodityId = @intCommodityId AND intCompanyLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intCompanyLocationId ELSE @intCompanyLocationId END AND intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
			) T1
		
		UNION
		
		SELECT Selection
			,PriceStatus
			,strFutureMonth
			,strAccountNumber
			,(dblNoOfContract) AS dblNoOfContract
			,strTradeNo
			,TransactionDate
			,TranType
			,CustVendor
			,dblNoOfLot
			,dblQuantity
			,intContractHeaderId
			,intFutOptTransactionHeaderId
		FROM (
			SELECT DISTINCT 'Terminal position (a. in lots )' AS Selection
				,'Broker Account' AS PriceStatus
				,fm.strFutureMonth
				,e.strName + '-' + strAccountNumber AS strAccountNumber
				,CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract) ELSE - (ft.intNoOfContract) END AS dblNoOfContract
				,ft.strInternalTradeNo AS strTradeNo
				,ft.dtmTransactionDate AS TransactionDate
				,strBuySell AS TranType
				,e.strName AS CustVendor
				,CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract) ELSE - (ft.intNoOfContract) END AS dblNoOfLot
				,CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract * @dblContractSize) ELSE - (ft.intNoOfContract * @dblContractSize) END AS dblQuantity
				,NULL AS intContractHeaderId
				,ft.intFutOptTransactionHeaderId
			FROM tblRKFutOptTransaction ft
			JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
			JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 1
			JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
			WHERE ft.intCommodityId = @intCommodityId AND intLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intLocationId ELSE @intCompanyLocationId END AND intLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intLocationId ELSE @intCompanyLocationId END AND ft.intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
			AND isnull(intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(intBookId,0) else @intBookId end
			AND isnull(intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(intSubBookId,0) else @intSubBookId end
			) t
		
		UNION
		
		SELECT Selection
			,PriceStatus
			,strFutureMonth
			,strAccountNumber
			,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, (dblNoOfContract)) * @dblContractSize AS dblNoOfContract
			,strTradeNo
			,TransactionDate
			,TranType
			,CustVendor
			,dblNoOfLot
			,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblQuantity) dblQuantity
			,intContractHeaderId
			,intFutOptTransactionHeaderId
		FROM (
			SELECT DISTINCT 'Terminal position (b. in ' + @strUnitMeasure + ' )' AS Selection
				,'Broker Account' AS PriceStatus
				,strFutureMonth
				,e.strName + '-' + strAccountNumber AS strAccountNumber
				,CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract) ELSE - (ft.intNoOfContract) END AS dblNoOfContract
				,ft.strInternalTradeNo AS strTradeNo
				,ft.dtmTransactionDate AS TransactionDate
				,strBuySell AS TranType
				,e.strName AS CustVendor
				,CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract) ELSE - (ft.intNoOfContract) END AS dblNoOfLot
				,CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract * @dblContractSize) ELSE - (ft.intNoOfContract * @dblContractSize) END dblQuantity
				,um.intCommodityUnitMeasureId
				,NULL AS intContractHeaderId
				,ft.intFutOptTransactionHeaderId
			FROM tblRKFutOptTransaction ft
			JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
			JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 1
			JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
			JOIN tblRKFutureMarket mar ON mar.intFutureMarketId = ft.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = ft.intCommodityId AND um.intUnitMeasureId = mar.intUnitMeasureId
			WHERE ft.intCommodityId = @intCommodityId AND intLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intLocationId ELSE @intCompanyLocationId END AND ft.intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
			AND isnull(intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(intBookId,0) else @intBookId end
AND isnull(intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(intSubBookId,0) else @intSubBookId end

			) t
		
		UNION
		
		SELECT DISTINCT 'Delta options' AS Selection
			,'Broker Account' AS PriceStatus
			,strFutureMonth
			,e.strName + '-' + strAccountNumber AS strAccountNumber
			,CASE WHEN ft.strBuySell = 'Buy' THEN (
							ft.intNoOfContract - isnull((
									SELECT sum(intMatchQty)
									FROM tblRKOptionsMatchPnS l
									WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId
									), 0)
							) ELSE - (
						ft.intNoOfContract - isnull((
								SELECT sum(intMatchQty)
								FROM tblRKOptionsMatchPnS s
								WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId
								), 0)
						) END * isnull((
					SELECT TOP 1 dblDelta
					FROM tblRKFuturesSettlementPrice sp
					INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
					WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END AND ft.dblStrike = mm.dblStrike
					ORDER BY dtmPriceDate DESC
					), 0) AS dblNoOfContract
			,ft.strInternalTradeNo AS strTradeNo
			,ft.dtmTransactionDate AS TransactionDate
			,strBuySell AS TranType
			,e.strName AS CustVendor
			,CASE WHEN ft.strBuySell = 'Buy' THEN (
							ft.intNoOfContract - isnull((
									SELECT sum(intMatchQty)
									FROM tblRKOptionsMatchPnS l
									WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId
									), 0)
							) ELSE - (
						ft.intNoOfContract - isnull((
								SELECT sum(intMatchQty)
								FROM tblRKOptionsMatchPnS s
								WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId
								), 0)
						) END * isnull((
					SELECT TOP 1 dblDelta
					FROM tblRKFuturesSettlementPrice sp
					INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
					WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END AND ft.dblStrike = mm.dblStrike
					ORDER BY dtmPriceDate DESC
					), 0) AS dblNoOfLot
			,isnull((
					SELECT TOP 1 dblDelta
					FROM tblRKFuturesSettlementPrice sp
					INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
					WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END AND ft.dblStrike = mm.dblStrike
					ORDER BY dtmPriceDate DESC
					), 0) AS dblDelta
			,NULL AS intContractHeaderId
			,ft.intFutOptTransactionHeaderId
		FROM tblRKFutOptTransaction ft
		JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
		JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
		JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
		WHERE intCommodityId = @intCommodityId AND intLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intLocationId ELSE @intCompanyLocationId END AND ft.intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate 
		AND isnull(intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(intBookId,0) else @intBookId end
AND isnull(intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(intSubBookId,0) else @intSubBookId end
		AND intFutOptTransactionId NOT IN (
				SELECT intFutOptTransactionId
				FROM tblRKOptionsPnSExercisedAssigned
				) AND intFutOptTransactionId NOT IN (
				SELECT intFutOptTransactionId
				FROM tblRKOptionsPnSExpired
				)
		) t
	
	UNION
	
	SELECT DISTINCT 'F&O' AS Selection
		,'F&O' AS PriceStatus
		,strFutureMonth
		,'F&O' AS strAccountNumber
		,(dblNoOfContract) AS dblNoOfContract
		,strTradeNo
		,TransactionDate
		,TranType
		,CustVendor
		,dblNoOfLot
		,dblQuantity
		,intContractHeaderId
		,intFutOptTransactionHeaderId
	FROM (
		SELECT Selection
			,PriceStatus
			,strFutureMonth
			,strAccountNumber
			,(dblNoOfContract) AS dblNoOfContract
			,strTradeNo
			,TransactionDate
			,TranType
			,CustVendor
			,dblNoOfLot
			,dblQuantity
			,intContractHeaderId
			,intFutOptTransactionHeaderId
		FROM (
			SELECT DISTINCT 'Terminal position (a. in lots )' AS Selection
				,'Broker Account' AS PriceStatus
				,strFutureMonth
				,e.strName + '-' + strAccountNumber AS strAccountNumber
				,CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract) ELSE - (ft.intNoOfContract) END AS dblNoOfContract
				,ft.strInternalTradeNo AS strTradeNo
				,ft.dtmTransactionDate AS TransactionDate
				,strBuySell AS TranType
				,e.strName AS CustVendor
				,CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract) ELSE - (ft.intNoOfContract) END AS dblNoOfLot
				,CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract * @dblContractSize) ELSE - (ft.intNoOfContract * @dblContractSize) END dblQuantity
				,NULL AS intContractHeaderId
				,ft.intFutOptTransactionHeaderId
			FROM tblRKFutOptTransaction ft
			JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
			JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 1
			JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
			WHERE intCommodityId = @intCommodityId AND intLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intLocationId ELSE @intCompanyLocationId END 
			AND isnull(intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(intBookId,0) else @intBookId end
AND isnull(intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(intSubBookId,0) else @intSubBookId end

			AND ft.intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
			) t
		
		UNION
		
		SELECT DISTINCT 'Delta options' AS Selection
			,'Broker Account' AS PriceStatus
			,strFutureMonth
			,e.strName + '-' + strAccountNumber AS strAccountNumber
			,CASE WHEN ft.strBuySell = 'Buy' THEN (
							ft.intNoOfContract - isnull((
									SELECT sum(intMatchQty)
									FROM tblRKOptionsMatchPnS l
									WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId
									), 0)
							) ELSE - (
						ft.intNoOfContract - isnull((
								SELECT sum(intMatchQty)
								FROM tblRKOptionsMatchPnS s
								WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId
								), 0)
						) END * isnull((
					SELECT TOP 1 dblDelta
					FROM tblRKFuturesSettlementPrice sp
					INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
					WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END AND ft.dblStrike = mm.dblStrike
					ORDER BY dtmPriceDate DESC
					), 0) AS dblNoOfContract
			,ft.strInternalTradeNo AS strTradeNo
			,ft.dtmTransactionDate AS TransactionDate
			,strBuySell AS TranType
			,e.strName AS CustVendor
			,CASE WHEN ft.strBuySell = 'Buy' THEN (
							ft.intNoOfContract - isnull((
									SELECT sum(intMatchQty)
									FROM tblRKOptionsMatchPnS l
									WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId
									), 0)
							) ELSE - (
						ft.intNoOfContract - isnull((
								SELECT sum(intMatchQty)
								FROM tblRKOptionsMatchPnS s
								WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId
								), 0)
						) END * isnull((
					SELECT TOP 1 dblDelta
					FROM tblRKFuturesSettlementPrice sp
					INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
					WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END AND ft.dblStrike = mm.dblStrike
					ORDER BY dtmPriceDate DESC
					), 0) AS dblNoOfLot
			,isnull((
					SELECT TOP 1 dblDelta
					FROM tblRKFuturesSettlementPrice sp
					INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
					WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END AND ft.dblStrike = mm.dblStrike
					ORDER BY dtmPriceDate DESC
					), 0) AS dblDelta
			,NULL AS intContractHeaderId
			,ft.intFutOptTransactionHeaderId
		FROM tblRKFutOptTransaction ft
		JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
		JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
		JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
		WHERE intCommodityId = @intCommodityId AND intLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intLocationId ELSE @intCompanyLocationId END
		AND isnull(intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(intBookId,0) else @intBookId end
		AND isnull(intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(intSubBookId,0) else @intSubBookId end
		 AND ft.intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate AND intFutOptTransactionId NOT IN (
				SELECT intFutOptTransactionId
				FROM tblRKOptionsPnSExercisedAssigned
				) AND intFutOptTransactionId NOT IN (
				SELECT intFutOptTransactionId
				FROM tblRKOptionsPnSExpired
				)
		) t
	
	UNION
	
	SELECT DISTINCT 'Total F&O(b. in ' + @strUnitMeasure + ' )' AS Selection
		,'F&O' AS PriceStatus
		,strFutureMonth
		,'F&O' AS strAccountNumber
		,dblNoOfContract
		,strTradeNo
		,TransactionDate
		,TranType
		,CustVendor
		,dblNoOfLot
		,dblQuantity
		,intContractHeaderId
		,intFutOptTransactionHeaderId
	FROM (
		SELECT strFutureMonth
			,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, (dblNoOfContract)) * @dblContractSize AS dblNoOfContract
			,strTradeNo
			,TransactionDate
			,TranType
			,CustVendor
			,dblNoOfLot
			,dblQuantity
			,intCommodityUnitMeasureId
			,intContractHeaderId
			,intFutOptTransactionHeaderId
		FROM (
			SELECT DISTINCT 'Terminal position (b. in ' + @strUnitMeasure + ' )' AS Selection
				,'Broker Account' AS PriceStatus
				,strFutureMonth
				,e.strName + '-' + strAccountNumber AS strAccountNumber
				,CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract) ELSE - (ft.intNoOfContract) END AS dblNoOfContract
				,ft.strInternalTradeNo AS strTradeNo
				,ft.dtmTransactionDate AS TransactionDate
				,strBuySell AS TranType
				,e.strName AS CustVendor
				,CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract) ELSE - (ft.intNoOfContract) END AS dblNoOfLot
				,CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract * @dblContractSize) ELSE - (ft.intNoOfContract * @dblContractSize) END dblQuantity
				,um.intCommodityUnitMeasureId
				,NULL AS intContractHeaderId
				,ft.intFutOptTransactionHeaderId
			FROM tblRKFutOptTransaction ft
			INNER JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
			INNER JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 1
			INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
			INNER JOIN tblRKFutureMarket mar ON mar.intFutureMarketId = ft.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = ft.intCommodityId AND um.intUnitMeasureId = mar.intUnitMeasureId
			WHERE ft.intCommodityId = @intCommodityId AND intLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intLocationId ELSE @intCompanyLocationId END 
			AND isnull(intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(intBookId,0) else @intBookId end
			AND isnull(intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(intSubBookId,0) else @intSubBookId end
			AND ft.intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
			) t
		
		UNION
		
		SELECT strFutureMonth
			,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId, @intUOMId, (dblNoOfContract)) * dblDelta * dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, @dblContractSize) AS dblNoOfContract
			,strTradeNo
			,TransactionDate
			,TranType
			,CustVendor
			,dblNoOfLot
			,dblQuantity
			,intCommodityUnitMeasureId
			,intContractHeaderId
			,intFutOptTransactionHeaderId
		FROM (
			SELECT DISTINCT 'Delta options' AS Selection
				,'Broker Account' AS PriceStatus
				,strFutureMonth
				,e.strName + '-' + strAccountNumber AS strAccountNumber
				,CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract) ELSE - (ft.intNoOfContract) END AS dblNoOfContract
				,ft.strInternalTradeNo AS strTradeNo
				,ft.dtmTransactionDate AS TransactionDate
				,strBuySell AS TranType
				,e.strName AS CustVendor
				,CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract) ELSE - (ft.intNoOfContract) END AS dblNoOfLot
				,CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract * @dblContractSize) ELSE - (ft.intNoOfContract * @dblContractSize) END dblQuantity
				,um.intCommodityUnitMeasureId
				,(
					SELECT TOP 1 dblDelta
					FROM tblRKFuturesSettlementPrice sp
					INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
					WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END AND ft.dblStrike = mm.dblStrike
					ORDER BY dtmPriceDate DESC
					) AS dblDelta
				,NULL AS intContractHeaderId
				,ft.intFutOptTransactionHeaderId
			FROM tblRKFutOptTransaction ft
			INNER JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
			INNER JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
			INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
			INNER JOIN tblRKFutureMarket mar ON mar.intFutureMarketId = ft.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = ft.intCommodityId AND um.intUnitMeasureId = mar.intUnitMeasureId
			WHERE ft.intCommodityId = @intCommodityId AND intLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intLocationId ELSE @intCompanyLocationId END 
			AND isnull(intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(intBookId,0) else @intBookId end
			AND isnull(intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(intSubBookId,0) else @intSubBookId end
			AND ft.intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
			) t
		) T
		
	---- Taken inventory Qty ----------
	INSERT INTO @List (
		Selection
		,PriceStatus
		,strFutureMonth
		,strAccountNumber
		,dblNoOfContract
		,strTradeNo
		,TransactionDate
		,TranType
		,CustVendor
		,dblNoOfLot
		,dblQuantity
		,intContractHeaderId
		,intFutOptTransactionHeaderId
		)
	SELECT Selection
		,PriceStatus
		,strFutureMonth
		,strAccountNumber
		,sum(dblNoOfContract)
		,strTradeNo
		,TransactionDate
		,TranType
		,CustVendor
		,sum(dblNoOfLot)
		,sum(dblQuantity)
		,intContractHeaderId
		,intFutOptTransactionHeaderId
	FROM (
		SELECT 'Net market risk' AS Selection
			,'Net market risk' AS PriceStatus
			,strFutureMonth
			,'Market Risk' AS strAccountNumber
			,sum(dblNoOfContract) dblNoOfContract
			,strTradeNo
			,TransactionDate
			,TranType
			,CustVendor
			,sum(dblNoOfLot) dblNoOfLot
			,sum(dblQuantity) dblQuantity
			,intContractHeaderId
			,intFutOptTransactionHeaderId
		FROM @List
		WHERE Selection = 'Physical position / Basis risk' AND PriceStatus = 'b. Priced / Outright - (Outright position)' 
		GROUP BY strFutureMonth
			,strTradeNo
			,TransactionDate
			,TranType
			,CustVendor
			,intContractHeaderId
			,intFutOptTransactionHeaderId
		
		UNION
		
		SELECT 'Net market risk' AS Selection
			,'Net market risk' AS PriceStatus
			,strFutureMonth
			,'Market Risk' AS strAccountNumber
			,sum(dblNoOfContract) dblNoOfContract
			,strTradeNo
			,TransactionDate
			,TranType
			,CustVendor
			,sum(dblNoOfLot) dblNoOfLot
			,sum(dblNoOfContract) dblQuantity
			,intContractHeaderId
			,intFutOptTransactionHeaderId
		FROM @List
		WHERE PriceStatus = 'F&O' AND Selection LIKE ('Total F&O%')
		GROUP BY strFutureMonth
			,strAccountNumber
			,strTradeNo
			,TransactionDate
			,TranType
			,CustVendor
			,intContractHeaderId
			,intFutOptTransactionHeaderId
		
		UNION
		
		SELECT 'Net market risk' AS Selection
			,'Net market risk' AS PriceStatus
			,strFutureMonth
			,'Market Risk' AS strAccountNumber
			,sum(dblNoOfContract) dblNoOfContract
			,strTradeNo
			,TransactionDate
			,TranType
			,CustVendor
			,sum(dblNoOfLot) dblNoOfLot
			,sum(dblQuantity) dblQuantity
			,intContractHeaderId
			,intFutOptTransactionHeaderId
		FROM @List
		WHERE PriceStatus = 'b. fixed' AND Selection = ('Specialities & Low grades') 
		GROUP BY strFutureMonth
			,strAccountNumber
			,strTradeNo
			,TransactionDate
			,TranType
			,CustVendor
			,intContractHeaderId
			,intFutOptTransactionHeaderId
		) t
	GROUP BY Selection
		,PriceStatus
		,strAccountNumber
		,strFutureMonth
		,strTradeNo
		,TransactionDate
		,TranType
		,CustVendor
		,intContractHeaderId
		,intFutOptTransactionHeaderId

	--- Switch Position ---------
	INSERT INTO @List (
		Selection
		,PriceStatus
		,strFutureMonth
		,strAccountNumber
		,dblNoOfContract
		,strTradeNo
		,TransactionDate
		,TranType
		,CustVendor
		,dblNoOfLot
		,dblQuantity
		,intContractHeaderId
		,intFutOptTransactionHeaderId
		)
	SELECT Selection
		,PriceStatus
		,strFutureMonth
		,strAccountNumber
		,(dblNoOfContract)
		,strTradeNo
		,TransactionDate
		,TranType
		,CustVendor
		,(dblNoOfLot)
		,(dblQuantity)
		,intContractHeaderId
		,intFutOptTransactionHeaderId
	FROM (
		SELECT 'Switch position' AS Selection
			,'Switch position' AS PriceStatus
			,strFutureMonth
			,'Switch position' AS strAccountNumber
			,(dblNoOfLot) dblNoOfContract
			,strTradeNo
			,TransactionDate
			,TranType
			,CustVendor
			,(dblNoOfLot) dblNoOfLot
			,(dblQuantity) dblQuantity
			,intContractHeaderId
			,intFutOptTransactionHeaderId
		FROM @List
		WHERE Selection = 'Physical position / Basis risk' AND PriceStatus = 'a. Unpriced - (Balance to be Priced)' AND strAccountNumber LIKE '%Purchase%'		

		UNION
		
		SELECT 'Switch position' AS Selection
			,'Switch position' AS PriceStatus
			,strFutureMonth
			,'Switch position' AS strAccountNumber
			,((dblNoOfLot)) dblNoOfContract
			,strTradeNo
			,TransactionDate
			,TranType
			,CustVendor
			,dblNoOfLot dblNoOfLot
			,dblQuantity dblQuantity
			,intContractHeaderId
			,intFutOptTransactionHeaderId
		FROM @List
		WHERE Selection = 'Physical position / Basis risk' AND PriceStatus = 'a. Unpriced - (Balance to be Priced)' AND strAccountNumber LIKE '%Sale%'
		--		UNION
		--		SELECT 'Switch position' AS Selection
		--	,'Switch position' AS PriceStatus
		--	,strFutureMonth
		--	,'Switch position' AS strAccountNumber
		--	,(dblNoOfLot) dblNoOfContract
		--	,strTradeNo
		--	,TransactionDate
		--	,TranType
		--	,CustVendor
		--	,(dblNoOfLot) dblNoOfLot
		--	,(dblQuantity) dblQuantity
		--	,intContractHeaderId
		--	,intFutOptTransactionHeaderId
		--FROM @List
		--	WHERE PriceStatus = 'a. Unfixed' AND Selection = ('Specialities & Low grades') 

		UNION
		
		SELECT 'Switch position' AS Selection
			,'Switch position' AS PriceStatus
			,strFutureMonth
			,'Switch position' AS strAccountNumber
			,dblNoOfLot dblNoOfContract
			,strTradeNo
			,TransactionDate
			,TranType
			,CustVendor
			,dblNoOfLot dblNoOfLot
			,dblQuantity dblQuantity
			,intContractHeaderId
			,intFutOptTransactionHeaderId
		FROM @List
		WHERE PriceStatus = 'F&O' AND Selection = 'F&O'
		) t
END

SELECT TOP 1 @strFutureMonth = strFutureMonth
FROM @List
WHERE strFutureMonth <> 'Previous'
ORDER BY convert(DATETIME, '01 ' + strFutureMonth) ASC

UPDATE @List
SET strFutureMonth = @strFutureMonth
WHERE Selection = 'Switch position' AND strFutureMonth = 'Previous'

UPDATE @List
SET strFutureMonth = @strFutureMonth
WHERE Selection = 'Net market risk' AND strFutureMonth = 'Previous'

IF NOT EXISTS (
		SELECT *
		FROM tblRKFutOptTransaction ft
		JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
		JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
		JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
		WHERE intCommodityId = @intCommodityId AND intLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intLocationId ELSE @intCompanyLocationId END
		AND isnull(intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(intBookId,0) else @intBookId end
		AND isnull(intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(intSubBookId,0) else @intSubBookId end
		 AND ft.intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate AND intFutOptTransactionId NOT IN (
				SELECT intFutOptTransactionId
				FROM tblRKOptionsPnSExercisedAssigned
				) AND intFutOptTransactionId NOT IN (
				SELECT intFutOptTransactionId
				FROM tblRKOptionsPnSExpired
				)
		)
BEGIN
	DELETE
	FROM @List
	WHERE Selection LIKE '%F&O%'
END

UPDATE @List
SET intOrderByHeading = 1
WHERE Selection IN ('Physical position / Differential cover', 'Physical position / Basis risk')

UPDATE @List
SET intOrderByHeading = 2
WHERE Selection = 'Specialities & Low grades'

UPDATE @List
SET intOrderByHeading = 3
WHERE Selection = 'Total speciality delta fixed'

UPDATE @List
SET intOrderByHeading = 4
WHERE Selection = 'Terminal position (a. in lots )'

UPDATE @List
SET intOrderByHeading = 5
WHERE Selection = 'Terminal position (Avg Long Price)'

UPDATE @List
SET intOrderByHeading = 6
WHERE Selection LIKE ('%Terminal position (b.%')

UPDATE @List
SET intOrderByHeading = 7
WHERE Selection = 'Delta options'

UPDATE @List
SET intOrderByHeading = 8
WHERE Selection = 'F&O'

UPDATE @List
SET intOrderByHeading = 9
WHERE Selection LIKE ('%Total F&O(b. in%')

UPDATE @List
SET intOrderByHeading = 10
WHERE Selection IN ('Outright coverage', 'Net market risk')

UPDATE @List
SET intOrderByHeading = 13
WHERE Selection IN ('Switch position', 'Futures required')


 INSERT INTO @List(Selection
		,PriceStatus
		,strFutureMonth
		,strAccountNumber
		,dblNoOfContract
		,strTradeNo
		,TransactionDate
		,TranType
		,CustVendor
		,dblNoOfLot
		,dblQuantity
		,intContractHeaderId
		,intFutOptTransactionHeaderId,intOrderByHeading)
 SELECT DISTINCT 'Physical position / Basis risk',
'a. Unpriced - (Balance to be Priced)',strFutureMonth, NULL,
 NULL, NULL, getdate(), NULL, NULL, NULL, NULL, NULL, NULL,1
FROM @List  WHERE strFutureMonth
 NOT IN (SELECT DISTINCT strFutureMonth FROM @List WHERE Selection = 'Physical position / Basis risk' AND PriceStatus = 'a. Unpriced - (Balance to be Priced)')

select * from ( 
SELECT intRowNumber
	,Selection
	,PriceStatus
	,strFutureMonth
	,cast(CASE WHEN  strFutureMonth ='Previous' THEN '01/01/1900' 
		WHEN  strFutureMonth ='Total' THEN '01/01/9999'
		else CONVERT(DATETIME,'01 '+strFutureMonth) END as datetime)strFutureMonthOrder
	,strAccountNumber
	,CONVERT(DOUBLE PRECISION, ROUND(dblNoOfContract, @intDecimal)) AS dblNoOfContract
	,strTradeNo
	,TransactionDate
	,TranType
	,CustVendor
	,dblNoOfLot
	,dblQuantity
	,intOrderByHeading
	,intContractHeaderId
	,intFutOptTransactionHeaderId
FROM @List
	)t  order by intOrderByHeading,strFutureMonthOrder
