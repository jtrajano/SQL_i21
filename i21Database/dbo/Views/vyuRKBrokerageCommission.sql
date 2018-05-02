CREATE VIEW vyuRKBrokerageCommission
AS
SELECT
	 BC.intBrokerageCommissionId
	,BC.intBrokerageAccountId
	,BC.intConcurrencyId
	,BC.dtmEffectiveDate
	,BC.dtmEndDate
	,BC.intFuturesRateType
	,CASE WHEN BC.intFuturesRateType = 1 THEN 'Round-turn' ELSE 'Half-turn' END AS strFuturesRateType
	,BC.dblFutCommission
	,BC.intFutCurrencyId
	,FutCur.strCurrency AS strFutCurrency
	,BC.intOptionsRateType
	,CASE WHEN BC.intOptionsRateType = 1 THEn 'Round-turn' ELSE '' END AS strOptionsRateType
	,BC.dblOptCommission
	,BC.intOptCurrencyId
	,OptCur.strCurrency AS strOptCurrency
	,BC.intFutureMarketId
	,FM.strFutMarketName
	,BC.intCommodityMarketId
	,CMM.strCommodityCode AS strCommodityMarket
	,CMM.intCommodityId
	,BC.strProductType
	,dbo.fnRKRKConvertProductTypeKeyToName(isnull(BC.strProductType,'')) AS strProductTypeDescription
	,BC.dblMinAmount
	,BC.dblMaxAmount
	,BC.dblPercenatage
	,CAST(ISNULL(FOT.ysnLock,0) AS BIT) AS ysnLock
	,FOT.dtmTransactionDate AS dtmLatestTransactionDate
	,FOT.strInternalTradeNo as strLatestTransaction
FROM tblRKBrokerageCommission BC
INNER JOIN tblRKFutureMarket FM ON BC.intFutureMarketId = FM.intFutureMarketId
LEFT JOIN vyuRKCommodityMarketMap CMM ON BC.intCommodityMarketId = CMM.intCommodityMarketId
LEFT JOIN tblSMCurrency FutCur ON BC.intFutCurrencyId = FutCur.intCurrencyID
LEFT JOIN tblSMCurrency OptCur ON BC.intFutCurrencyId = OptCur.intCurrencyID
OUTER APPLY (
 SELECT TOP 1 CASE WHEN ISNULL(FOT.intBrokerageCommissionId,0) = 0  THEN 0 ELSE 1 END AS ysnLock, FOT.dtmTransactionDate, FOT.strInternalTradeNo
 FROM tblRKFutOptTransaction FOT 
 WHERE FOT.intBrokerageCommissionId = BC.intBrokerageCommissionId
 ORDER BY FOT.dtmTransactionDate DESC
) as FOT