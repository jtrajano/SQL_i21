CREATE PROC uspRKRollCost
	@dtmFromDate datetime = null,
	@dtmToDate datetime = null
AS

DECLARE @RollCost AS TABLE 
(intRowNumber INT IDENTITY(1,1) PRIMARY KEY, 
strFutMarketName  nvarchar(50),
strCommodityCode  nvarchar(50),
strFutureMonth  nvarchar(50),
intFutureMarketId  int,
intCommodityId int,
dblWtAvgOpenLongPosition  DECIMAL(24,10),
dblSellMinusBuy  DECIMAL(24,10),
dblSumBuy  DECIMAL(24,10),
dblSumQty  DECIMAL(24,10),
ysnSubCurrency bit,
dblContractSize DECIMAL(24,10)
)

INSERT INTO @RollCost
SELECT strFutMarketName,strCommodityCode,strFutureMonth,
	intFutureMarketId,intCommodityId,SUM(isnull(dblContratPrice,0))/ case when isnull(SUM(intOpenContract),0)=0 then 1 else SUM(intOpenContract) end dblWtAvgOpenLongPosition,
	((
	sum(isnull(dblSellPrice,0)*isnull(dblSellQty,0))/case when sum(isnull(dblSellQty,0))=0 then 1 else  sum(isnull(dblSellQty,0)) end
	-
	sum((isnull(dblBuyPrice,0)*isnull(dblBuyQty,0))) /
	case when isnull(sum(isnull(dblBuyQty,0)),0)=0 then 1 
	else sum(isnull(dblBuyQty,0)) end
	) * dblContractSize) / case when isnull(ysnSubCurrency,0)= 0 then 1 else 100 end dblSellMinusBuy,
	
	((sum(isnull(dblBlankRMQtyPrice,0)+isnull(dblRMNotEqFMQtyPrice,0) )
	* dblContractSize))	/ case when isnull(ysnSubCurrency,0)= 0 then 1 else 100 end dblSumBuy,

	sum(isnull(dblBlankRMQty,0)+isnull(dblRMNotEqFMQty,0))  dblSumQty,ysnSubCurrency,dblContractSize

FROM (

SELECT distinct ft.intFutOptTransactionId,strInternalTradeNo,ft.intFutureMarketId,m.strFutMarketName,ft.intCommodityId,c.strCommodityCode,fm.strFutureMonth,dblContractSize,ysnSubCurrency,		

isnull((SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
		join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and strBuySell='Buy'
		WHERE ft.intFutOptTransactionId = fc.intFutOptTransactionId  AND isnull(fc.intOpenContract,0) > 0),0) intOpenContract

,isnull((SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
		join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and strBuySell='Buy'
		WHERE ft.intFutOptTransactionId = fc.intFutOptTransactionId  AND isnull(fc.intOpenContract,0) > 0)*isnull(ft.dblPrice,0),0) dblContratPrice

	,(SELECT sum(dblMatchQty) intNoOfContract from (
		SELECT distinct 
			m.dblMatchQty,
			futM.dblPrice 
			FROM tblRKFutOptTransaction t
			JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId --and  ft1.strBuySell = 'Buy'
			JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId
			JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intSFutOptTransactionId
			JOIN tblRKFutOptTransaction futM on fut.intFutureMonthId=futM.intFutureMonthId and futM.strBuySell = 'Sell' 
		WHERE futM.intFutOptTransactionId=ft.intFutOptTransactionId)t) dblSellQty

	,(SELECT SUM(dblPrice) dblPrice from (
			SELECT distinct 
				m.dblMatchQty,
				m.dblMatchQty*futM.dblPrice dblPrice
				FROM tblRKFutOptTransaction t
			JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId --and ft1.strBuySell = 'Buy'
			JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId
			JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intSFutOptTransactionId
			JOIN tblRKFutOptTransaction futM on fut.intFutureMonthId=futM.intFutureMonthId and futM.strBuySell = 'Sell' 
			WHERE futM.intFutOptTransactionId=ft.intFutOptTransactionId)t) dblSellPrice

	,(SELECT sum(dblMatchQty) intNoOfContract from (
		SELECT distinct 
			m.dblMatchQty,
			fut.dblPrice a
			FROM tblRKFutOptTransaction t
			JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId and t.strBuySell='Buy'  and isnull(ft1.intRollingMonthId,0) <>0
			JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId 
			JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intLFutOptTransactionId
		WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId)t) dblBuyQty

	,(SELECT SUM(dblPrice) dblPrice from (
			SELECT distinct 
				m.dblMatchQty,
				fut.intNoOfContract*fut.dblPrice dblPrice
			FROM tblRKFutOptTransaction t
			JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId and t.strBuySell='Buy'  and isnull(ft1.intRollingMonthId,0) <>0
			JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId  
			JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intLFutOptTransactionId  
			WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId)t) dblBuyPrice

,isnull((SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
		join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and isnull(foot.intRollingMonthId,0) = 0
		 and strBuySell='Buy'
		WHERE  foot.intFutOptTransactionId =ft.intFutOptTransactionId ),0) dblBlankRMQty

,isnull((SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
		join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and isnull(foot.intRollingMonthId,0) = 0
		and strBuySell='Buy'
		WHERE foot.intFutOptTransactionId =ft.intFutOptTransactionId  )*isnull(ft.dblPrice,0),0) dblBlankRMQtyPrice

,isnull((SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
		join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and foot.intRollingMonthId=foot.intFutureMonthId
		 and strBuySell='Buy'
		WHERE  foot.intFutOptTransactionId =ft.intFutOptTransactionId ),0) dblRMNotEqFMQty

,isnull((SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
		join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and foot.intRollingMonthId=foot.intFutureMonthId
		and strBuySell='Buy'
		WHERE foot.intFutOptTransactionId =ft.intFutOptTransactionId  )*isnull(ft.dblPrice,0),0) dblRMNotEqFMQtyPrice
FROM tblRKFutOptTransaction ft
JOIN tblRKFutureMarket m on ft.intFutureMarketId=m.intFutureMarketId
JOIN tblICCommodity c on ft.intCommodityId=c.intCommodityId
JOIN tblRKFuturesMonth fm on ft.intFutureMonthId=fm.intFutureMonthId -- and isnull(ft.intRollingMonthId,ft.intFutureMonthId)=fm.intFutureMonthId 
JOIN tblICCommodityUnitMeasure cuc on  cuc.intCommodityUnitMeasureId=m.intUnitMeasureId 
JOIN tblSMCurrency mc on m.intCurrencyId=mc.intCurrencyID
WHERE intSelectedInstrumentTypeId=1  AND intInstrumentTypeId=1
and convert(datetime,CONVERT(VARCHAR(10),ft.dtmFilledDate,110)) BETWEEN @dtmFromDate and @dtmToDate

)t 
 GROUP BY  strFutMarketName,strCommodityCode,strFutureMonth,intFutureMarketId,intCommodityId,dblContractSize,ysnSubCurrency,ysnSubCurrency
 ORDER BY CONVERT(DATETIME,'01 '+strFutureMonth) ASC 

SELECT *,(isnull(dblSumPrevValue,0)/CASE WHEN isnull(dblSumQty,0)=0 THEN 1 ELSE dblSumQty END /ISNULL(dblContractSize,1))*100 dblWtAvgPosition FROM (
SELECT *,isnull(dblSumBuy,0)+CASE WHEN ISNULL(PreviousValue,0)<0 THEN ABS(ISNULL(PreviousValue,0)) ELSE -ISNULL(PreviousValue,0) end dblSumPrevValue from (
SELECT
prev.dblSellMinusBuy PreviousValue,TT.*  
FROM @RollCost TT
LEFT JOIN @RollCost prev ON prev.intRowNumber = TT.intRowNumber - 1
)t)t1
