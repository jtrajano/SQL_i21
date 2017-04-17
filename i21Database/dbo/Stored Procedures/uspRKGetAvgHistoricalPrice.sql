CREATE PROC uspRKGetAvgHistoricalPrice
	@dtmFromDate datetime = null,
	@dtmToDate datetime = null
AS

DECLARE @MatchedRec AS TABLE 
(
strFutMarketName  nvarchar(50),
strCommodityCode  nvarchar(50),
strFutureMonth  nvarchar(50),
dblSellMinusBuy DECIMAL(24,10) 
)

DECLARE @RollCostDetail AS TABLE 
(intFutOptTransactionId int,
strInternalTradeNo nvarchar(50),
intFutureMarketId  int,
strFutMarketName  nvarchar(50),
intCommodityId int,
strCommodityCode  nvarchar(50),
strFutureMonth  nvarchar(50),
strRollMonth nvarchar(50),
dblContractSize DECIMAL(24,10),
ysnSubCurrency bit,
intOpenContract int, 
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
intMatchId int
)


INSERT INTO @RollCostDetail (intFutOptTransactionId ,strInternalTradeNo,intFutureMarketId  ,strFutMarketName ,intCommodityId ,strCommodityCode ,
strFutureMonth ,strRollMonth,dblContractSize ,ysnSubCurrency ,intOpenContract , dblContratPrice ,dblSellQty  ,dblSellPrice  ,dblBuyQty  ,dblBuyPrice  ,dblBlankRMQty  ,dblBlankRMQtyPrice  ,
dblRMNotEqFMQty  ,dblRMNotEqFMQtyPrice,dblBuyWithOutRollMonthQty,dblBuyWithOutRollMonthPrice, intMatchId )
select intFutOptTransactionId ,strInternalTradeNo,intFutureMarketId  ,strFutMarketName ,intCommodityId ,strCommodityCode ,
strFutureMonth ,strRollMonth,dblContractSize ,ysnSubCurrency ,intOpenContract , dblContratPrice ,dblSellQty  ,dblSellPrice  ,dblBuyQty ,dblBuyPrice,dblBlankRMQty  ,dblBlankRMQtyPrice  ,
dblRMNotEqFMQty  ,dblRMNotEqFMQtyPrice,dblBuyWithOutRollMonthQty,dblBuyWithOutRollMonthPrice, isnull(intBuyMatchId,intSellMatchId) as intMatchId from (

SELECT distinct ft.intFutOptTransactionId,strInternalTradeNo,ft.intFutureMarketId,m.strFutMarketName,ft.intCommodityId,c.strCommodityCode,
				fm.strFutureMonth,rfm.strFutureMonth  strRollMonth,dblContractSize,ysnSubCurrency,		
		isnull((SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
				join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and strBuySell='Buy'
				WHERE ft.intFutOptTransactionId = fc.intFutOptTransactionId  AND isnull(fc.intOpenContract,0) > 0),0) intOpenContract

		,isnull((SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
				join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and strBuySell='Buy'
				WHERE ft.intFutOptTransactionId = fc.intFutOptTransactionId  AND isnull(fc.intOpenContract,0) > 0)*isnull(ft.dblPrice,0),0) dblContratPrice

			,(SELECT SUM(dblMatchQty) intNoOfContract from (
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

			,(SELECT sum(dblMatchQty) intNoOfContract from (
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

			,	(SELECT distinct top 1
			m.intMatchFuturesPSDetailId intMatchFuturesPSDetailId
			FROM tblRKFutOptTransaction t
			JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId  and isnull(ft1.intRollingMonthId,0) <>0
			JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId
			JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intSFutOptTransactionId
			WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId) intSellMatchId

		,(SELECT distinct top 1					
				m.intMatchFuturesPSDetailId intMatchFuturesPSDetailId
			FROM tblRKFutOptTransaction t
			JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId  --and isnull(ft1.intRollingMonthId,0) <>0
			JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId  
			JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intLFutOptTransactionId  
			WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId) intBuyMatchId

		,isnull((SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
				join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and isnull(foot.intRollingMonthId,0) = 0
				 and strBuySell='Buy'
				WHERE  foot.intFutOptTransactionId =ft.intFutOptTransactionId ),0) dblBlankRMQty
				
		,isnull((SELECT top 1 ft.dblPrice from vyuRKGetOpenContract fc 
				join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and isnull(foot.intRollingMonthId,0) = 0
				and strBuySell='Buy'
				WHERE foot.intFutOptTransactionId =ft.intFutOptTransactionId  ),0) dblBlankRMQtyPrice

		,isnull((SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
				join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and foot.intRollingMonthId=foot.intFutureMonthId
				 and strBuySell='Buy'
				WHERE  foot.intFutOptTransactionId =ft.intFutOptTransactionId ),0) dblRMNotEqFMQty

		,isnull((SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
				join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and foot.intRollingMonthId=foot.intFutureMonthId
				and strBuySell='Buy'
				WHERE foot.intFutOptTransactionId =ft.intFutOptTransactionId  )*isnull(ft.dblPrice,0),0) dblRMNotEqFMQtyPrice

			,(SELECT sum(dblMatchQty) intNoOfContract from (
				SELECT distinct 
					m.dblMatchQty,
					fut.dblPrice a
					FROM tblRKFutOptTransaction t					
					JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=t.intFutOptTransactionId 
					JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intLFutOptTransactionId
				WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId and isnull(t.intRollingMonthId,0) = 0)t) dblBuyWithOutRollMonthQty

			,(SELECT sum(dblMatchPrice) intNoOfContract from (
				SELECT distinct 
					m.dblMatchQty* fut.dblPrice dblMatchPrice
					FROM tblRKFutOptTransaction t					
					JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=t.intFutOptTransactionId 
					JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intLFutOptTransactionId
				WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId and isnull(t.intRollingMonthId,0) = 0)t) dblBuyWithOutRollMonthPrice
						
		FROM tblRKFutOptTransaction ft
		JOIN tblRKFutureMarket m on ft.intFutureMarketId=m.intFutureMarketId
		JOIN tblICCommodity c on ft.intCommodityId=c.intCommodityId
		JOIN tblRKFuturesMonth fm on ft.intFutureMonthId=fm.intFutureMonthId 
		JOIN tblICCommodityUnitMeasure cuc on  cuc.intCommodityUnitMeasureId=m.intUnitMeasureId 
		JOIN tblSMCurrency mc on m.intCurrencyId=mc.intCurrencyID
		LEFT JOIN tblRKFuturesMonth rfm on rfm.intFutureMonthId=ft.intRollingMonthId
		
		WHERE intSelectedInstrumentTypeId=1  AND intInstrumentTypeId=1
		and convert(datetime,CONVERT(VARCHAR(10),ft.dtmFilledDate,110)) BETWEEN @dtmFromDate and @dtmToDate)t
		order by strFutureMonth


SELECT strFutMarketName,strCommodityCode,strRollMonth,intMatchId,
	((sum(isnull(dblSellPrice,0)) - isnull((select sum(dblBuyPrice) from @RollCostDetail where intMatchId=a.intMatchId),0)) *sum(dblSellQty)
	* dblContractSize) / case when isnull(ysnSubCurrency,0)= 0 then 1 else 100 end dblSellMinusBuy
into #temp	
FROM @RollCostDetail a
 GROUP BY  strFutMarketName,strCommodityCode,strRollMonth,intMatchId,dblContractSize,ysnSubCurrency
 
 ORDER BY CONVERT(DATETIME,'01 '+strRollMonth) ASC 


 select  strFutMarketName,strCommodityCode,strRollMonth,isnull(sum(dblSellMinusBuy),0) dblSellMinusBuy from #temp 
 where isnull(strRollMonth,'')<>'' 
 group by strFutMarketName,strCommodityCode,strRollMonth 