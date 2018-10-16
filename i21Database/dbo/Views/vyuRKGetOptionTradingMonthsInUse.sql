CREATE VIEW [dbo].[vyuRKGetOptionTradingMonthsInUse]
AS 
SELECT DISTINCT strMonthName = OPTM.strOptionMonth
	,MARKET.intFutureMarketId
	,MARKET.strFutMarketName
FROM tblRKFutureMarket MARKET
INNER JOIN (
	SELECT intFutureMarketId
		,strOptionMonth
		,strMonthName = LEFT(strOptionMonth,3)
	FROM tblRKOptionsMonth WITH(NOLOCK)
)OPTM ON MARKET.intFutureMarketId = OPTM.intFutureMarketId
WHERE EXISTS(
	SELECT 1
	FROM tblRKFutOptTransactionHeader FOTH WITH(NOLOCK)
	INNER JOIN(
		SELECT intFutOptTransactionHeaderId 
			,intFutureMarketId
			,intOptionMonthId
		FROM tblRKFutOptTransaction WITH(NOLOCK)
	)FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
	INNER JOIN (
		SELECT intOptionMonthId
			,strMonth = strOptionMonth
		FROM tblRKOptionsMonth WITH(NOLOCK)
	)OM ON FOT.intOptionMonthId = OM.intOptionMonthId
	WHERE FOT.intOptionMonthId IS NOT NULL 
		AND FOT.intFutureMarketId = MARKET.intFutureMarketId
		AND OM.strMonth = OPTM.strOptionMonth
)