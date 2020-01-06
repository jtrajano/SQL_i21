CREATE VIEW vyuIPGetOptSettlementPriceMarketMap
AS
SELECT OSP.intOptSettlementPriceMonthId
	,OSP.intConcurrencyId
	,OSP.intFutureSettlementPriceId
	,OSP.intOptionMonthId
	,OSP.dblStrike
	,OSP.intTypeId
	,OSP.dblSettle
	,OSP.dblDelta
	,OSP.strComments
	,OSP.intOptSettlementPriceMonthRefId
	,OSP.ysnImported
	,OM.strOptionMonth
FROM tblRKOptSettlementPriceMarketMap OSP
JOIN tblRKOptionsMonth OM ON OM.intOptionMonthId = OSP.intOptionMonthId
