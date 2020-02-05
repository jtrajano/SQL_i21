CREATE VIEW [dbo].[vyuRKGetMatchDerivativesFromSummaryLog]

AS

SELECT strTransactionType
	, intTransactionRecordId
	, strTransactionNumber
	, dtmTransactionDate
	, intFutureMarketId
	, intFutureMonthId
	, intFutOptTransactionId
	, intCommodityId
	, intOrigUOMId
	, intBookId
	, intSubBookId
	, intLocationId
	, dblOrigNoOfLots = SUM(dblOrigNoOfLots)
	, dblContractSize
	, dblOrigQty = SUM(dblOrigQty)
	, dblPrice
	, intEntityId
	, intUserId
	, intMatchNo
	, intMatchDerivativesHeaderId
FROM tblRKSummaryLog sl
CROSS APPLY (
	SELECT [intMatchDerivativesHeaderId]
		, [intMatchDerivativesDetailId]
		, [intMatchNo]
	FROM (
		SELECT strFieldName
			, strValue 
		FROM dbo.fnRKGetMiscFieldTable(sl.strMiscField)
	) t 
	PIVOT(
		MIN(strValue)
		FOR strFieldName IN ([intMatchDerivativesHeaderId]
			, [intMatchDerivativesDetailId]
			, [intMatchNo])
	) AS pivot_table
) pt
WHERE strTransactionType = 'Match Derivatives'
GROUP BY strTransactionType
	, intTransactionRecordId
	, strTransactionNumber
	, dtmTransactionDate
	, intFutureMarketId
	, intFutureMonthId
	, intFutOptTransactionId
	, intCommodityId
	, intOrigUOMId
	, intBookId
	, intSubBookId
	, intLocationId
	, dblContractSize
	, dblPrice
	, intEntityId
	, intUserId
	, intMatchNo
	, intMatchDerivativesHeaderId