CREATE PROC uspRKGetAvgHistoricalPrice
	@dtmFromDate datetime = null
	, @dtmToDate datetime = null

AS

DECLARE @MatchedRec AS TABLE (strFutMarketName nvarchar(50)
	, strCommodityCode nvarchar(50) COLLATE Latin1_General_CI_AS
	, strFutureMonth nvarchar(50) COLLATE Latin1_General_CI_AS
	, dblSellMinusBuy DECIMAL(24,10))

DECLARE @RollCostDetail AS TABLE (intFutOptTransactionId int
	, strInternalTradeNo nvarchar(50) COLLATE Latin1_General_CI_AS
	, intFutureMarketId int
	, strFutMarketName nvarchar(50) COLLATE Latin1_General_CI_AS
	, intCommodityId int
	, strCommodityCode nvarchar(50) COLLATE Latin1_General_CI_AS
	, strFutureMonth nvarchar(50) COLLATE Latin1_General_CI_AS
	, strRollMonth nvarchar(50) COLLATE Latin1_General_CI_AS
	, dblContractSize DECIMAL(24,10)
	, ysnSubCurrency bit
	, dblOpenContract int
	, dblContratPrice DECIMAL(24,10)
	, dblSellQty DECIMAL(24,10)
	, dblSellPrice DECIMAL(24,10)
	, dblBuyQty DECIMAL(24,10)
	, dblBuyPrice DECIMAL(24,10)
	, dblBlankRMQty DECIMAL(24,10)
	, dblBlankRMQtyPrice DECIMAL(24,10)
	, dblRMNotEqFMQty DECIMAL(24,10)
	, dblRMNotEqFMQtyPrice DECIMAL(24,10)
	, dblBuyWithOutRollMonthQty DECIMAL(24,10)
	, dblBuyWithOutRollMonthPrice DECIMAL(24,10)
	, intMatchId int)

INSERT INTO @RollCostDetail (intFutOptTransactionId
	, strInternalTradeNo
	, intFutureMarketId
	, strFutMarketName
	, intCommodityId
	, strCommodityCode
	, strFutureMonth
	, strRollMonth
	, dblContractSize
	, ysnSubCurrency
	, dblOpenContract
	, dblContratPrice
	, dblSellQty
	, dblSellPrice
	, dblBuyQty
	, dblBuyPrice
	, dblBlankRMQty
	, dblBlankRMQtyPrice
	, dblRMNotEqFMQty
	, dblRMNotEqFMQtyPrice
	, dblBuyWithOutRollMonthQty
	, dblBuyWithOutRollMonthPrice
	, intMatchId)
SELECT intFutOptTransactionId
	, strInternalTradeNo
	, intFutureMarketId
	, strFutMarketName
	, intCommodityId
	, strCommodityCode
	, strFutureMonth
	, strRollMonth
	, dblContractSize
	, ysnSubCurrency
	, dblOpenContract
	, dblContratPrice
	, dblSellQty
	, dblSellPrice
	, dblBuyQty
	, dblBuyPrice
	, dblBlankRMQty
	, dblBlankRMQtyPrice
	, dblRMNotEqFMQty
	, dblRMNotEqFMQtyPrice
	, dblBuyWithOutRollMonthQty
	, dblBuyWithOutRollMonthPrice
	, ISNULL(intBuyMatchId, intSellMatchId) as intMatchId
FROM (
	SELECT DISTINCT ft.intFutOptTransactionId
		, strInternalTradeNo
		, ft.intFutureMarketId
		, m.strFutMarketName
		, ft.intCommodityId
		, c.strCommodityCode
		, fm.strFutureMonth
		, rfm.strFutureMonth strRollMonth
		, dblContractSize
		, ysnSubCurrency
		, ISNULL((SELECT SUM(dblNoOfContract) FROM vyuRKGetOpenContract fc
				JOIN tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and strBuySell = 'Buy'
				WHERE ft.intFutOptTransactionId = fc.intFutOptTransactionId AND isnull(fc.dblOpenContract,0) > 0),0) dblOpenContract
		, ISNULL((SELECT SUM(dblNoOfContract) FROM vyuRKGetOpenContract fc
				JOIN tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and strBuySell='Buy'
				WHERE ft.intFutOptTransactionId = fc.intFutOptTransactionId  AND isnull(fc.dblOpenContract,0) > 0)*isnull(ft.dblPrice,0),0) dblContratPrice
		, (SELECT SUM(dblMatchQty) dblNoOfContract
			FROM (
				SELECT DISTINCT m.dblMatchQty, fut.dblPrice a
				FROM tblRKFutOptTransaction t
				JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId  and isnull(ft1.intRollingMonthId,0) <> 0
				JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId
				JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intSFutOptTransactionId
				WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId)t) dblSellQty
		, (SELECT SUM(dblPrice) dblPrice
			FROM (
				SELECT DISTINCT fut.dblPrice dblPrice
				FROM tblRKFutOptTransaction t
				JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId  and isnull(ft1.intRollingMonthId,0) <>0
				JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId
				JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intSFutOptTransactionId
				WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId)t) dblSellPrice
		, (SELECT SUM(dblMatchQty) dblNoOfContract
			FROM (
				SELECT DISTINCT m.dblMatchQty, fut.dblPrice a
				FROM tblRKFutOptTransaction t
				JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId   and isnull(ft1.intRollingMonthId,0) <>0
				JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId
				JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intLFutOptTransactionId
				WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId)t) dblBuyQty
		, (SELECT SUM(dblPrice) dblPrice
			FROM (
				SELECT DISTINCT fut.dblPrice dblPrice
				FROM tblRKFutOptTransaction t
				JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId  and isnull(ft1.intRollingMonthId,0) <>0
				JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId
				JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intLFutOptTransactionId
				WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId)t) dblBuyPrice
		, (SELECT distinct top 1 m.intMatchFuturesPSDetailId intMatchFuturesPSDetailId
			FROM tblRKFutOptTransaction t
			JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId  and isnull(ft1.intRollingMonthId,0) <>0
			JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId
			JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intSFutOptTransactionId
			WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId) intSellMatchId
		, (SELECT distinct top 1 m.intMatchFuturesPSDetailId intMatchFuturesPSDetailId
			FROM tblRKFutOptTransaction t
			JOIN tblRKFutOptTransaction ft1 on ft1.intRollingMonthId=t.intRollingMonthId
			JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=ft1.intFutOptTransactionId
			JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intLFutOptTransactionId 
			WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId) intBuyMatchId
		, ISNULL((SELECT SUM(dblOpenContract) FROM vyuRKGetOpenContract fc
				JOIN tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and isnull(foot.intRollingMonthId,0) = 0 AND strBuySell = 'Buy'
				WHERE foot.intFutOptTransactionId = ft.intFutOptTransactionId ),0) dblBlankRMQty
		, ISNULL((SELECT TOP 1 ft.dblPrice FROM vyuRKGetOpenContract fc
				JOIN tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and isnull(foot.intRollingMonthId,0) = 0 and strBuySell='Buy'
				WHERE foot.intFutOptTransactionId =ft.intFutOptTransactionId  ),0) dblBlankRMQtyPrice
		, ISNULL((SELECT SUM(dblOpenContract) from vyuRKGetOpenContract fc
				JOIN tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and foot.intRollingMonthId=foot.intFutureMonthId and strBuySell='Buy'
				WHERE foot.intFutOptTransactionId =ft.intFutOptTransactionId ),0) dblRMNotEqFMQty
		, ISNULL((SELECT SUM(dblOpenContract) from vyuRKGetOpenContract fc
				JOIN tblRKFutOptTransaction foot on foot.intFutOptTransactionId=fc.intFutOptTransactionId and foot.intRollingMonthId=foot.intFutureMonthId and strBuySell='Buy'
				WHERE foot.intFutOptTransactionId =ft.intFutOptTransactionId  )*isnull(ft.dblPrice,0),0) dblRMNotEqFMQtyPrice
		, (SELECT SUM(dblMatchQty) dblNoOfContract
			FROM (
				SELECT distinct m.dblMatchQty, fut.dblPrice a
				FROM tblRKFutOptTransaction t
				JOIN tblRKMatchFuturesPSDetail m on m.intSFutOptTransactionId=t.intFutOptTransactionId
				JOIN tblRKFutOptTransaction fut on fut.intFutOptTransactionId = m.intLFutOptTransactionId
				WHERE fut.intFutOptTransactionId=ft.intFutOptTransactionId and isnull(t.intRollingMonthId,0) = 0)t) dblBuyWithOutRollMonthQty
		, (SELECT SUM(dblMatchPrice) dblNoOfContract
			FROM (
				SELECT DISTINCT m.dblMatchQty * fut.dblPrice dblMatchPrice
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
	WHERE intSelectedInstrumentTypeId in(1,3) AND intInstrumentTypeId = 1
		AND CONVERT(DATETIME,CONVERT(VARCHAR(10),ft.dtmFilledDate,110)) BETWEEN @dtmFromDate and @dtmToDate
) t
ORDER BY strFutureMonth

SELECT strFutMarketName
	, strCommodityCode
	, strRollMonth
	, intMatchId
	, ((SUM(ISNULL(dblSellPrice, 0)) - ISNULL((SELECT SUM(dblBuyPrice) FROM @RollCostDetail WHERE intMatchId = a.intMatchId), 0)) * SUM(dblSellQty)
		* dblContractSize) / CASE WHEN ISNULL(ysnSubCurrency, 0) = 0 THEN 1 ELSE 100 END dblSellMinusBuy
INTO #temp
FROM @RollCostDetail a
GROUP BY strFutMarketName, strCommodityCode, strRollMonth, intMatchId, dblContractSize, ysnSubCurrency
ORDER BY CONVERT(DATETIME,'01 '+strRollMonth) ASC

SELECT strFutMarketName, strCommodityCode, strRollMonth, ISNULL(SUM(dblSellMinusBuy), 0) dblSellMinusBuy FROM #temp
WHERE ISNULL(strRollMonth, '') <> ''
GROUP BY strFutMarketName, strCommodityCode, strRollMonth