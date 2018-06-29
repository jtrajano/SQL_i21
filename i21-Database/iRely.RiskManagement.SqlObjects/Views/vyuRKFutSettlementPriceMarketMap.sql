CREATE VIEW vyuRKFutSettlementPriceMarketMap
AS
SELECT
	 SPMM.intFutSettlementPriceMonthId
	,SPMM.intFutureSettlementPriceId
	,SPMM.intFutureMonthId
	,SPMM.dblLastSettle
	,SPMM.dblLow
	,SPMM.dblHigh
	,SPMM.dblOpen
	,SPMM.strComments
	,SPMM.intConcurrencyId
	,FM.strFutureMonth AS strFutureMonthYear
	,FM.strFutureMonth AS strFutureMonthYearWOSymbol
	,CAST(CASE WHEN ILMP.intFutSettlementPriceMonthId IS NULL THEN 0 ELSE 1 END AS bit) AS ysnUsed
	,M2M.strRecordName as strM2MBatch
	,M2M.dtmTransactionUpTo as dtmM2MDate
FROM tblRKFutSettlementPriceMarketMap SPMM
INNER JOIN tblRKFuturesMonth FM ON SPMM.intFutureMonthId = FM.intFutureMonthId
LEFT JOIN tblRKM2MInquiryLatestMarketPrice ILMP ON SPMM.intFutSettlementPriceMonthId = ILMP.intFutSettlementPriceMonthId
LEFT JOIN tblRKM2MInquiry M2M ON ILMP.intM2MInquiryId = M2M.intM2MInquiryId





