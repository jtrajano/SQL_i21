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
FROM tblRKOptSettlementPriceMarketMap OSP WITH (NOLOCK)
JOIN tblRKOptionsMonth OM WITH (NOLOCK) ON OM.intOptionMonthId = OSP.intOptionMonthId
