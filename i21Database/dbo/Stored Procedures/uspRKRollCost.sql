﻿CREATE PROC uspRKRollCost
	@dtmFromDate datetime = null,
	@dtmToDate datetime = null
AS

DECLARE @RollCost AS TABLE 
(intRowNumber INT IDENTITY(1,1) PRIMARY KEY, 
strFutMarketName  nvarchar(50),
strCommodityCode  nvarchar(50),
strFutureMonth  nvarchar(50),
strFutureMonthOrder  nvarchar(50),
intFutureMarketId  int,
intCommodityId int,
dblWtAvgOpenLongPosition  DECIMAL(24,10),
dblSumBuy  DECIMAL(24,10),
dblSumQty  DECIMAL(24,10),
dblSumAvgLong  DECIMAL(24,10),
ysnSubCurrency bit,
dblContractSize DECIMAL(24,10),
dblAvgLongPrice DECIMAL(24,10),
dblAvgLongQty DECIMAL(24,10),
dblSumBuyForHistorical DECIMAL(24,10),
dblNoOfContractAvg DECIMAL(24,10),
intBookId int,
strBook  nvarchar(100),
intSubBookId int,
strSubBook  nvarchar(100),
intEntityId int,
strBroker  nvarchar(100),
intBrokerageAccountId int,
strBrokerAccountNo  nvarchar(50)
)

DECLARE @RollCostDetail AS TABLE 
(intFutOptTransactionId int,
strInternalTradeNo nvarchar(50),
intFutureMarketId  int,
strFutMarketName  nvarchar(50),
intCommodityId int,
strCommodityCode  nvarchar(50),
strFutureMonth  nvarchar(50),
strFutureMonthOrder  nvarchar(50),
strRollMonth nvarchar(50),
dblContractSize DECIMAL(24,10),
ysnSubCurrency bit,
dblOpenContract int, 
dblContratPrice DECIMAL(24,10),
dblSellQty  DECIMAL(24,10),
dblSellPrice  DECIMAL(24,10),
dblBuyQty  DECIMAL(24,10),
dblBuyPrice  DECIMAL(24,10),
dblBlankRMQty  DECIMAL(24,10),
dblBlankRMQtyPrice  DECIMAL(24,10),
dblRMNotEqFMQty  DECIMAL(24,10),
dblRMNotEqFMQtyPrice  DECIMAL(24,10),
dblBuyWithOutRollMonthQty DECIMAL(24,10),
dblBuyWithOutRollMonthPrice DECIMAL(24,10),
intMatchId int,
dblNoOfContract DECIMAL(24,10),
dblNoOfContractPrice DECIMAL(24,10),
intBookId int,
strBook  nvarchar(100),
intSubBookId int,
strSubBook  nvarchar(100),
intEntityId int,
strBroker  nvarchar(100),
intBrokerageAccountId int,
strBrokerAccountNo  nvarchar(50)
)

DECLARE @MatchedRec AS TABLE 
(
strFutMarketName  nvarchar(50),
strCommodityCode  nvarchar(50),
strFutureMonth  nvarchar(50),
dblSellMinusBuy DECIMAL(24,10) 
)


INSERT INTO @MatchedRec (strFutMarketName,strCommodityCode,strFutureMonth,dblSellMinusBuy)
EXEC uspRKGetAvgHistoricalPrice @dtmFromDate=@dtmFromDate,@dtmToDate=@dtmToDate

INSERT INTO @RollCostDetail (
	intFutOptTransactionId 
	,strInternalTradeNo
	,intFutureMarketId  
	,strFutMarketName 
	,intCommodityId 
	,strCommodityCode 
	,strFutureMonth 
	,strFutureMonthOrder
	,strRollMonth
	,dblContractSize 
	,ysnSubCurrency 
	,dblOpenContract 
	,dblContratPrice 
	,dblSellQty  
	,dblSellPrice  
	,dblBuyQty  
	,dblBuyPrice  
	,dblBlankRMQty  
	,dblBlankRMQtyPrice  
	,dblRMNotEqFMQty  
	,dblRMNotEqFMQtyPrice
	,dblBuyWithOutRollMonthQty
	,dblBuyWithOutRollMonthPrice
	,intMatchId
	,dblNoOfContract
	,dblNoOfContractPrice 
	,intBookId
	,strBook
	,intSubBookId
	,strSubBook
	,intEntityId
	,strBroker
	,intBrokerageAccountId
	,strBrokerAccountNo
)
SELECT 
	intFutOptTransactionId 
	,strInternalTradeNo
	,intFutureMarketId  
	,strFutMarketName 
	,intCommodityId 
	,strCommodityCode 
	,strFutureMonth 
	,strFutureMonthOrder
	,strRollMonth
	,dblContractSize 
	,ysnSubCurrency 
	,dblOpenContract 
	,dblContratPrice 
	,dblSellQty  
	,dblSellPrice  
	,dblBuyQty  
	,dblBuyPrice  
	,dblBlankRMQty  
	,dblBlankRMQtyPrice  
	,dblRMNotEqFMQty  
	,dblRMNotEqFMQtyPrice
	,dblBuyWithOutRollMonthQty
	,dblBuyWithOutRollMonthPrice
	,isnull(intBuyMatchId,intSellMatchId) as intMatchId
	,dblNoOfContract
	,dblNoOfContractPrice 
	,intBookId
	,strBook
	,intSubBookId
	,strSubBook
	,intEntityId
	,strBroker
	,intBrokerageAccountId
	,strBrokerAccountNo
FROM (
	SELECT DISTINCT 
		ft.intFutOptTransactionId
		,strInternalTradeNo
		,ft.intFutureMarketId
		,m.strFutMarketName
		,ft.intCommodityId
		,c.strCommodityCode
		,strFutureMonth = SUBSTRING(fm.strFutureMonth,0,4) + '(' + fm.strSymbol + ') ' + CONVERT(NVARCHAR(5),fm.intYear) 
		,strFutureMonthOrder = fm.strFutureMonth
		,strRollMonth = SUBSTRING(rfm.strFutureMonth,0,4) + '(' + rfm.strSymbol + ') ' + CONVERT(NVARCHAR(5),rfm.intYear) 
		,dblContractSize
		,ysnSubCurrency
		,isnull((SELECT sum(dblOpenContract) from vyuRKGetOpenContract fc 
				join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and strBuySell='Buy'
				WHERE ft.intFutOptTransactionId = fc.intFutOptTransactionId  AND isnull(fc.dblOpenContract,0) > 0),0) dblOpenContract
		,isnull((SELECT sum(dblOpenContract) from vyuRKGetOpenContract fc 
				join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and strBuySell='Buy'
				WHERE ft.intFutOptTransactionId = fc.intFutOptTransactionId  AND isnull(fc.dblOpenContract,0) > 0)*isnull(ft.dblPrice,0),0) dblContratPrice
		,(SELECT SUM(dblMatchQty) dblNoOfContract from (
			SELECT DISTINCT 
				m.dblMatchQty,
				fut.dblPrice a
				FROM tblRKFutOptTransaction t
				JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId  and isnull(ft1.intRollingMonthId,0) <> 0
				JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId
				JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intSFutOptTransactionId 
			WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId)t) dblSellQty
		,(SELECT SUM(dblPrice) dblPrice from (
					SELECT distinct 
						fut.dblPrice dblPrice
						FROM tblRKFutOptTransaction t
					JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId  and isnull(ft1.intRollingMonthId,0) <>0
					JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId
					JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intSFutOptTransactionId
					WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId)t) dblSellPrice
			,(SELECT sum(dblMatchQty) dblNoOfContract from (
				SELECT distinct 
					m.dblMatchQty,
					fut.dblPrice a
					FROM tblRKFutOptTransaction t
					JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId   and isnull(ft1.intRollingMonthId,0) <>0
					JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId 
					JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intLFutOptTransactionId
				WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId)t) dblBuyQty
			,(SELECT SUM(dblPrice) dblPrice from (
					SELECT distinct 					
						fut.dblPrice dblPrice
					FROM tblRKFutOptTransaction t
					JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId  and isnull(ft1.intRollingMonthId,0) <>0
					JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId  
					JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intLFutOptTransactionId  
					WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId)t) dblBuyPrice
			,(SELECT distinct top 1
				m.intMatchFuturesPSDetailId intMatchFuturesPSDetailId
				FROM tblRKFutOptTransaction t
				JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId  and isnull(ft1.intRollingMonthId,0) <>0
				JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId
				JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intSFutOptTransactionId
				WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId) intSellMatchId
			,(SELECT distinct top 1					
						m.intMatchFuturesPSDetailId intMatchFuturesPSDetailId
					FROM tblRKFutOptTransaction t
					JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId  and isnull(ft1.intRollingMonthId,0) <>0
					JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId  
					JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intLFutOptTransactionId  
					WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId) intBuyMatchId
		,isnull((SELECT sum(dblNoOfContract) from tblRKFutOptTransaction foot  where strBuySell='Buy'
				and  foot.intFutOptTransactionId =ft.intFutOptTransactionId ),0) dblNoOfContract
		,isnull((SELECT sum(dblNoOfContract*dblPrice) from tblRKFutOptTransaction foot  where strBuySell='Buy'
				and  foot.intFutOptTransactionId =ft.intFutOptTransactionId ),0) dblNoOfContractPrice
		,isnull((SELECT sum(dblOpenContract) from vyuRKGetOpenContract fc 
				join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and isnull(foot.intRollingMonthId,0) = 0
				 and strBuySell='Buy'
				WHERE  foot.intFutOptTransactionId =ft.intFutOptTransactionId ),0) dblBlankRMQty
		,isnull((SELECT sum(dblOpenContract) from vyuRKGetOpenContract fc 
				join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and isnull(foot.intRollingMonthId,0) = 0
				and strBuySell='Buy'
				WHERE foot.intFutOptTransactionId =ft.intFutOptTransactionId  )*isnull(ft.dblPrice,0),0) dblBlankRMQtyPrice
		,isnull((SELECT sum(dblOpenContract) from vyuRKGetOpenContract fc 
				join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and foot.intRollingMonthId=foot.intFutureMonthId
				 and strBuySell='Buy'
				WHERE  foot.intFutOptTransactionId =ft.intFutOptTransactionId ),0) dblRMNotEqFMQty
		,isnull((SELECT sum(dblOpenContract) from vyuRKGetOpenContract fc 
				join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and foot.intRollingMonthId=foot.intFutureMonthId
				and strBuySell='Buy'
				WHERE foot.intFutOptTransactionId =ft.intFutOptTransactionId  )*isnull(ft.dblPrice,0),0) dblRMNotEqFMQtyPrice
		,(SELECT sum(dblMatchQty) dblNoOfContract from (
				SELECT distinct 
					m.dblMatchQty,
					fut.dblPrice a
					FROM tblRKFutOptTransaction t					
					JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=t.intFutOptTransactionId 
					JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intLFutOptTransactionId
				WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId and isnull(t.intRollingMonthId,0) = 0)t) dblBuyWithOutRollMonthQty
			,(SELECT sum(dblMatchPrice) dblNoOfContract from (
				SELECT distinct 
					m.dblMatchQty* fut.dblPrice dblMatchPrice
					FROM tblRKFutOptTransaction t					
					JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=t.intFutOptTransactionId 
					JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intLFutOptTransactionId
				WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId and isnull(t.intRollingMonthId,0) = 0)t) dblBuyWithOutRollMonthPrice
			,ft.intBookId
			,B.strBook
			,ft.intSubBookId
			,SB.strSubBook
			,ft.intEntityId
			,E.strName as strBroker
			,ft.intBrokerageAccountId
			,BA.strAccountNumber as strBrokerAccountNo
		FROM tblRKFutOptTransaction ft
			JOIN tblRKFutureMarket m on ft.intFutureMarketId=m.intFutureMarketId
			JOIN tblICCommodity c on ft.intCommodityId=c.intCommodityId
			JOIN tblRKFuturesMonth fm on ft.intFutureMonthId=fm.intFutureMonthId 
			JOIN tblICCommodityUnitMeasure cuc on  cuc.intCommodityUnitMeasureId=m.intUnitMeasureId 
			JOIN tblSMCurrency mc on m.intCurrencyId=mc.intCurrencyID
			JOIN tblRKBrokerageAccount BA on ft.intBrokerageAccountId = BA.intBrokerageAccountId
			LEFT JOIN tblEMEntity E on ft.intEntityId = E.intEntityId
			LEFT JOIN tblCTBook B on ft.intBookId = B.intBookId
			LEFT JOIN tblCTSubBook SB on ft.intSubBookId = SB.intSubBookId
			LEFT JOIN tblRKFuturesMonth rfm on rfm.intFutureMonthId=ft.intRollingMonthId
		WHERE intSelectedInstrumentTypeId=1  AND ft.intInstrumentTypeId=1
			and convert(datetime,CONVERT(VARCHAR(10),ft.dtmFilledDate,110)) BETWEEN @dtmFromDate and @dtmToDate	
)t
ORDER BY strFutureMonthOrder

INSERT INTO @RollCost (
	strFutMarketName
	,strCommodityCode
	,strFutureMonth
	,strFutureMonthOrder
	,dblWtAvgOpenLongPosition
	,dblSumBuy
	,dblSumQty
	,ysnSubCurrency
	,dblContractSize
	,dblAvgLongQty
	,dblSumBuyForHistorical
	,dblNoOfContractAvg
	,intBookId
	,strBook
	,intSubBookId
	,strSubBook
	,intEntityId
	,strBroker
	,intBrokerageAccountId
	,strBrokerAccountNo
)
SELECT 
	strFutMarketName
	,strCommodityCode
	,strFutureMonth
	,strFutureMonthOrder
	,SUM(isnull(dblContratPrice,0))/ case when isnull(SUM(dblOpenContract),0)=0 then 1 else SUM(dblOpenContract) end dblWtAvgOpenLongPosition
	,((sum(isnull(dblBuyWithOutRollMonthPrice,0)+isnull(dblContratPrice,0))/
		case when sum(isnull(dblOpenContract,0)+isnull(dblBuyWithOutRollMonthQty,0))=0 THEN 1 ELSE 
		sum(isnull(dblOpenContract,0)+isnull(dblBuyWithOutRollMonthQty,0)) end	
		*sum(isnull(dblOpenContract,0)+isnull(dblBuyWithOutRollMonthQty,0)) 
		* dblContractSize))	/ case when isnull(ysnSubCurrency,0)= 0 then 1 else 100 end dblSumBuy
	,sum(isnull(dblBlankRMQty,0)+isnull(dblRMNotEqFMQty,0)) dblSumQtyAfterCalculate
	,ysnSubCurrency
	,dblContractSize
	,sum(isnull(dblOpenContract,0)+isnull(dblBuyWithOutRollMonthQty,0)) dblAvgLongQty
	,((sum(isnull(dblBuyWithOutRollMonthPrice,0)+isnull(dblContratPrice,0))/
		case when sum(isnull(dblOpenContract,0)+isnull(dblBuyWithOutRollMonthQty,0))=0 THEN 1 ELSE 
		sum(isnull(dblOpenContract,0)+isnull(dblBuyWithOutRollMonthQty,0)) end	
		)) dblSumBuyForHistorical
	,sum(isnull(dblNoOfContractPrice,0))/case when isnull(sum(dblNoOfContract),0)=0 then 1 else sum(dblNoOfContract) end dblNoOfContractAvg
	,intBookId
	,strBook
	,intSubBookId
	,strSubBook
	,intEntityId
	,strBroker
	,intBrokerageAccountId
	,strBrokerAccountNo
FROM @RollCostDetail 
GROUP BY strFutMarketName,strCommodityCode,ysnSubCurrency,dblContractSize,strFutureMonth,strFutureMonthOrder,intBookId
	,strBook
	,intSubBookId
	,strSubBook
	,intEntityId
	,strBroker
	,intBrokerageAccountId
	,strBrokerAccountNo


SELECT 
	*
	,(SELECT dblSellMinusBuy from @MatchedRec s where s.strFutureMonth=t.strFutureMonth and s.strFutMarketName=t.strFutMarketName) dblSellMinusBuy 
INTO #temp 
FROM  @RollCost t
  

SELECT 
	*
	,isnull(dblWtAvgPosition,0)-isnull(dblSumAvgLong,0) dblRollCost 
FROM (
	select 
	* 
	,isnull(dblWtAvgPosition1,dblNoOfContractAvg) dblWtAvgPosition
	from(
		SELECT 
			intRowNumber
			,strFutMarketName
			,strCommodityCode
			,strFutureMonth
			,strFutureMonthOrder
			,dblWtAvgOpenLongPosition
			,dblSumBuy
			,dblSellMinusBuy
			,dblSumBuy+ case when isnull(dblSellMinusBuy,0) < 0 then  abs(dblSellMinusBuy) else -dblSellMinusBuy end dblAdjustedSpent
			,((dblSumBuy+ case when isnull(dblSellMinusBuy,0) < 0 then  abs(dblSellMinusBuy) else -dblSellMinusBuy end)/case when isnull(dblSumQty,0) = 0 then 1 else dblSumQty end/dblContractSize)*case when isnull(ysnSubCurrency,0)= 0 then 1 else 100 end dblWtAvgPosition1
			,dblSumBuyForHistorical dblSumAvgLong
			,dblSumQty
			,ysnSubCurrency
			,dblContractSize
			,dblAvgLongQty
			,dblNoOfContractAvg  
			,intBookId
			,strBook
			,intSubBookId
			,strSubBook
			,intEntityId
			,strBroker
			,intBrokerageAccountId
			,strBrokerAccountNo
		FROM #temp
	)t
)t1
ORDER BY strFutMarketName, CONVERT(DATETIME,'01 '+strFutureMonthOrder) ASC 