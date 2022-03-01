CREATE VIEW [dbo].[vyuRKSwitchPositionDerivatives]

AS

SELECT
	intFutOptTransactionId
	,strBrokerName = strName
	,strBrokerageAccount
	,strInternalTradeNo
	,strBuySell
	,strFutureMonth
	,strInstrumentType
	,dblStrike
	,dblContracts = ABS(dblGetNoOfContract)
	,dblHedgeQty
	,strHedgeUOM = strUnitMeasure
	,dblOpenContract = ABS(dblOpenContract)
	,dblPrice
	,intCommodityId
	,intFutureMarketId
	,intFutureMonthId
FROM vyuRKFutOptTransaction
WHERE dblOpenContract <> 0