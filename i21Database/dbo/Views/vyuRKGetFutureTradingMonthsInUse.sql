CREATE VIEW [dbo].[vyuRKGetFutureTradingMonthsInUse]
AS 
SELECT DISTINCT strMonthName = FUTM.strFutureMonth
	,MARKET.intFutureMarketId
	,MARKET.strFutMarketName
FROM tblRKFutureMarket MARKET WITH(NOLOCK)
INNER JOIN (
	SELECT intFutureMarketId
		,strFutureMonth
		,strMonthName = LEFT(strFutureMonth,3)
	FROM tblRKFuturesMonth WITH(NOLOCK)
)FUTM ON MARKET.intFutureMarketId = FUTM.intFutureMarketId
WHERE EXISTS(
	SELECT 1
	FROM tblCTContractDetail CD WITH (NOLOCK)
	INNER JOIN (
		SELECT intFutureMonthId
			,strMonth = strFutureMonth
		FROM tblRKFuturesMonth WITH (NOLOCK)
	)FM ON CD.intFutureMonthId = FM.intFutureMonthId
	WHERE CD.intFutureMonthId IS NOT NULL 
		AND CD.intFutureMarketId = MARKET.intFutureMarketId
		AND FM.strMonth = FUTM.strFutureMonth
)
OR EXISTS(
	SELECT 1
	FROM tblRKFuturesSettlementPrice SP WITH(NOLOCK)
	INNER JOIN(
		SELECT intFutureSettlementPriceId
			, intFutureMonthId
		FROM tblRKFutSettlementPriceMarketMap WITH(NOLOCK)
	) SPM ON SP.intFutureSettlementPriceId = SPM.intFutureSettlementPriceId
	INNER JOIN (
		SELECT intFutureMonthId
			,strMonth = strFutureMonth
		FROM tblRKFuturesMonth WITH(NOLOCK)
	)FM ON SPM.intFutureMonthId = FM.intFutureMonthId
	WHERE SPM.intFutureMonthId IS NOT NULL 
		AND SP.intFutureMarketId = MARKET.intFutureMarketId
		AND FM.strMonth = FUTM.strFutureMonth
)
OR EXISTS(
	SELECT 1
	FROM tblRKFutOptTransactionHeader FOTH WITH(NOLOCK)
	INNER JOIN(
		SELECT intFutOptTransactionHeaderId 
			,intFutureMarketId
			,intFutureMonthId
		FROM tblRKFutOptTransaction WITH(NOLOCK)
	)FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
	INNER JOIN (
		SELECT intFutureMonthId
			,strMonth = strFutureMonth
		FROM tblRKFuturesMonth WITH(NOLOCK)
	)FM ON FOT.intFutureMonthId = FM.intFutureMonthId
	WHERE FOT.intFutureMonthId IS NOT NULL 
		AND FOT.intFutureMarketId = MARKET.intFutureMarketId
		AND FM.strMonth = FUTM.strFutureMonth
)
OR EXISTS(
	SELECT 1
	FROM tblRKM2MInquiryTransaction MM WITH(NOLOCK)
	INNER JOIN (
		SELECT intFutureMonthId
			,strMonth = strFutureMonth
		FROM tblRKFuturesMonth WITH(NOLOCK)
	)FM ON MM.intFutureMonthId = FM.intFutureMonthId
	WHERE MM.intFutureMonthId IS NOT NULL 
		AND MM.intFutureMarketId = MARKET.intFutureMarketId
		AND FM.strMonth = FUTM.strFutureMonth
)