CREATE VIEW vyuRKBrokerageCommission
AS
SELECT
	 BC.intBrokerageCommissionId
	,BC.intBrokerageAccountId
	,BC.intConcurrencyId
	,BC.dtmEffectiveDate
	,BC.dtmEndDate
	,BC.intFuturesRateType
	,CASE WHEN BC.intFuturesRateType = 1 THEN 'Round-turn' ELSE 'Half-turn' END COLLATE Latin1_General_CI_AS AS strFuturesRateType
	,BC.dblFutCommission
	,BC.intFutCurrencyId
	,FutCur.strCurrency AS strFutCurrency
	,BC.intOptionsRateType
	,CASE WHEN BC.intOptionsRateType = 1 THEn 'Half-turn' ELSE '' END COLLATE Latin1_General_CI_AS AS strOptionsRateType
	,BC.dblOptCommission
	,BC.intOptCurrencyId
	,OptCur.strCurrency AS strOptCurrency
	,BC.intFutureMarketId
	,FM.strFutMarketName
	,BC.intCommodityMarketId
	,CMM.strCommodityCode AS strCommodityMarket
	,CMM.intCommodityId
	,BC.strProductType COLLATE Latin1_General_CI_AS AS strProductType
	,dbo.fnRKRKConvertProductTypeKeyToName(isnull(BC.strProductType,'')) COLLATE Latin1_General_CI_AS AS strProductTypeDescription
	,BC.dblMinAmount
	,BC.dblMaxAmount
	,BC.dblPercenatage
	,CAST(ISNULL(FOT.ysnLock,0) AS BIT) AS ysnLock
	,FOT.dtmTransactionDate AS dtmLatestTransactionDate
	,FOT.strInternalTradeNo as strLatestTransaction
	,BC.dblAAFees
	,BC.dblPerFutureContract
FROM tblRKBrokerageCommission BC
JOIN vyuRKCommodityMarketMap CMM ON BC.intCommodityMarketId = CMM.intCommodityMarketId
INNER JOIN tblRKFutureMarket FM ON BC.intFutureMarketId = FM.intFutureMarketId
LEFT JOIN tblSMCurrency FutCur ON BC.intFutCurrencyId = FutCur.intCurrencyID
LEFT JOIN tblSMCurrency OptCur ON BC.intFutCurrencyId = OptCur.intCurrencyID
OUTER APPLY (
 SELECT TOP 1 CASE WHEN ISNULL(FOT.intBrokerageCommissionId,0) = 0  THEN 0 ELSE 1 END AS ysnLock, FOT.dtmTransactionDate, FOT.strInternalTradeNo
 FROM tblRKFutOptTransaction FOT 
 WHERE FOT.intBrokerageCommissionId = BC.intBrokerageCommissionId
 ORDER BY FOT.dtmTransactionDate DESC
) as FOT