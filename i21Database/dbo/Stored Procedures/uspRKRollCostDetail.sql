CREATE PROC uspRKRollCostDetail
	@dtmFromDate datetime = null,
	@dtmToDate datetime = null,
	@strFutureMonth nvarchar(50),
	@strFutMarketName nvarchar(50)
AS


SELECT distinct ft.intFutOptTransactionId,strInternalTradeNo,m.strFutMarketName,c.strCommodityCode,fm.strFutureMonth,dblContractSize,		

isnull((SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
		join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and strBuySell='Buy'
		WHERE ft.intFutOptTransactionId = fc.intFutOptTransactionId  AND isnull(fc.intOpenContract,0) > 0),0) intOpenContract

,isnull(ft.dblPrice,0) as dblBalanceTranPrice

,isnull((SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
		JOIN tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and strBuySell='Buy'
		WHERE ft.intFutOptTransactionId = fc.intFutOptTransactionId  AND isnull(fc.intOpenContract,0) > 0)*isnull(ft.dblPrice,0),0) dblContratPrice

,(SELECT SUM(dblMatchQty) intNoOfContract from (
	SELECT DISTINCT 
		m.dblMatchQty,
		fut.dblPrice a
		FROM tblRKFutOptTransaction t
		JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId  and isnull(ft1.intRollingMonthId,0) <>0
		JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId
		JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intSFutOptTransactionId
	WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId)t) dblSellQty

,(SELECT top 1 SUM(dblPrice) intNoOfContract from (
	SELECT DISTINCT 
		fut.dblPrice 
		FROM tblRKFutOptTransaction t
		JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId  and isnull(ft1.intRollingMonthId,0) <>0
		JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId
		JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intSFutOptTransactionId
	WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId)t) dblSellTranPrice

	,(SELECT SUM(dblPrice) dblPrice from (
			SELECT distinct 
				m.dblMatchQty,
				m.dblMatchQty*fut.dblPrice dblPrice
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
			JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId and t.strBuySell='Buy'  and isnull(ft1.intRollingMonthId,0) <>0
			JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId 
			JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intLFutOptTransactionId
		WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId)t) dblBuyQty

,(SELECT SUM(dblPrice) dblPrice from (
			SELECT distinct 
			fut.dblPrice dblPrice
			FROM tblRKFutOptTransaction t
			JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId and t.strBuySell='Buy'  and isnull(ft1.intRollingMonthId,0) <>0
			JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId  
			JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intLFutOptTransactionId  
			WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId)t) dblBuyTranPrice

	,(SELECT SUM(dblPrice) dblPrice from (
			SELECT distinct 
				m.dblMatchQty,
				m.dblMatchQty*fut.dblPrice dblPrice
			FROM tblRKFutOptTransaction t
			JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId and t.strBuySell='Buy'  and isnull(ft1.intRollingMonthId,0) <>0
			JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId  
			JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intLFutOptTransactionId  
			WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId)t) dblBuyPrice

,isnull((SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
		join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and isnull(foot.intRollingMonthId,0) = 0
		 and strBuySell='Buy'
		WHERE  foot.intFutOptTransactionId =ft.intFutOptTransactionId ),0) intBlankRMQty

,isnull((SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
		join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and isnull(foot.intRollingMonthId,0) = 0
		and strBuySell='Buy'
		WHERE foot.intFutOptTransactionId =ft.intFutOptTransactionId  )*isnull(ft.dblPrice,0),0) dblBlankRMQtyPrice

,isnull((SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
		join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and foot.intRollingMonthId=foot.intFutureMonthId
		 and strBuySell='Buy'
		WHERE  foot.intFutOptTransactionId =ft.intFutOptTransactionId ),0) intRMNotEqFMQty

,isnull((SELECT sum(intOpenContract) from vyuRKGetOpenContract fc 
		join tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and foot.intRollingMonthId=foot.intFutureMonthId
		and strBuySell='Buy'
		WHERE foot.intFutOptTransactionId =ft.intFutOptTransactionId  )*isnull(ft.dblPrice,0),0) dblRMNotEqFMQtyPrice
FROM tblRKFutOptTransaction ft
JOIN tblRKFutureMarket m on ft.intFutureMarketId=m.intFutureMarketId
JOIN tblICCommodity c on ft.intCommodityId=c.intCommodityId
JOIN tblRKFuturesMonth fm on ft.intFutureMonthId=fm.intFutureMonthId  
JOIN tblICCommodityUnitMeasure cuc on  cuc.intCommodityUnitMeasureId=m.intUnitMeasureId 
JOIN tblSMCurrency mc on m.intCurrencyId=mc.intCurrencyID
WHERE intSelectedInstrumentTypeId=1  AND intInstrumentTypeId=1 and strFutureMonth=@strFutureMonth and strFutMarketName=@strFutMarketName
and convert(datetime,CONVERT(VARCHAR(10),ft.dtmFilledDate,110)) BETWEEN @dtmFromDate and @dtmToDate 