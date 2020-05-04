﻿CREATE VIEW vyuIPGetFutSettlementPriceMarketMap
AS
SELECT FSP.intFutSettlementPriceMonthId
	,FSP.intConcurrencyId
	,FSP.intFutureSettlementPriceId
	,FSP.intFutureMonthId
	,FSP.dblLastSettle
	,FSP.dblLow
	,FSP.dblHigh
	,FSP.dblOpen
	,FSP.strComments
	,FSP.intFutSettlementPriceMonthRefId
	,FSP.ysnImported
	,FM.strFutureMonth
FROM tblRKFutSettlementPriceMarketMap FSP WITH (NOLOCK)
JOIN tblRKFuturesMonth FM WITH (NOLOCK) ON FM.intFutureMonthId = FSP.intFutureMonthId
