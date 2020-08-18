CREATE VIEW [dbo].[vyuRKLFuturePSTransaction]

AS

SELECT TOP 100 PERCENT *
FROM (
	SELECT dblTotalLot-dblSelectedLot1 AS dblBalanceLot
		, dblTotalLot-dblSelectedLotRoll AS dblBalanceLotRoll
		, 0.0 as dblSelectedLot
		, *
	FROM (
		SELECT intSelectedInstrumentTypeId
			, strInternalTradeNo AS strTransactionNo
			, dtmTransactionDate as dtmTransactionDate
			, ot.dblNoOfContract as dblTotalLot
			, IsNull((SELECT SUM (AD.dblMatchQty)
					from tblRKMatchFuturesPSDetail AD
					inner join tblRKMatchFuturesPSHeader A ON AD.intMatchFuturesPSHeaderId = A.intMatchFuturesPSHeaderId
					where A.strType = 'Realize'
					Group By AD.intLFutOptTransactionId
					Having ot.intFutOptTransactionId = AD.intLFutOptTransactionId), 0)  As dblSelectedLot1
			, IsNull((SELECT SUM (AD.dblMatchQty)
					from tblRKMatchFuturesPSDetail AD
					inner join tblRKMatchFuturesPSHeader A ON AD.intMatchFuturesPSHeaderId = A.intMatchFuturesPSHeaderId
					where A.strType = 'Roll'
					Group By AD.intLFutOptTransactionId
					Having ot.intFutOptTransactionId = AD.intLFutOptTransactionId), 0)  As dblSelectedLotRoll
			, CASE WHEN strBuySell ='Buy' Then 'B' else 'S' End COLLATE Latin1_General_CI_AS AS strBuySell
			, dblPrice as dblPrice
			, case when isnull(ot.dtmCreateDateTime,'')='' then ot.dtmTransactionDate else ot.dtmCreateDateTime end as dtmCreateDateTime
			, strBook
			, strSubBook
			, ot.intFutureMarketId
			, ot.intBrokerageAccountId
			, ot.intLocationId
			, ot.intFutureMonthId
			, ot.intCommodityId
			, ot.intEntityId
			, ISNULL(ot.intBookId,0) as intBookId
			, ISNULL(ot.intSubBookId,0) as intSubBookId
			, intFutOptTransactionId
			, fm.dblContractSize
			, dblFutCommission = ISNULL((select TOP 1 (case when isnull(bc.intFuturesRateType,2) = 2 then 
														isnull(bc.dblFutCommission,0)* 2 / CASE WHEN cur.ysnSubCurrency = 1 THEN cur.intCent ELSE 1 END
															else  isnull(bc.dblFutCommission,0) / case when cur.ysnSubCurrency = 1 then cur.intCent else 1 end end) as dblFutCommission
										from tblRKBrokerageCommission bc
										LEFT JOIN tblSMCurrency cur on cur.intCurrencyID=bc.intFutCurrencyId
										where bc.intFutureMarketId = ot.intFutureMarketId and bc.intBrokerageAccountId = ot.intBrokerageAccountId
											and cast(getdate() as date) between bc.dtmEffectiveDate and isnull(bc.dtmEndDate,cast(getdate() as date))),0) * -1
			, ot.intBrokerageCommissionId
			, dtmFilledDate
			, ot.intFutOptTransactionHeaderId
			, c.intCurrencyID as intCurrencyId
			, c.strCurrency
			, intMainCurrencyId = CASE WHEN c.ysnSubCurrency = 1 THEN c.intMainCurrencyId ELSE c.intCurrencyID END
			, strMainCurrency = CASE WHEN c.ysnSubCurrency = 0 THEN c.strCurrency ELSE MainCurrency.strCurrency END
			, c.intCent
			, c.ysnSubCurrency
			, ot.intBankId
			, ot.intBankAccountId
			, ot.intCurrencyExchangeRateTypeId
			, ot.strBrokerTradeNo
			, m.strFutureMonth
		FROM tblRKFutOptTransaction ot
		JOIN tblRKFutureMarket fm on fm.intFutureMarketId=ot.intFutureMarketId and ot.intInstrumentTypeId=1 and ot.strStatus='Filled'
		JOIN tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId
		JOIN tblRKFuturesMonth m on m.intFutureMonthId=ot.intFutureMonthId
		LEFT JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = c.intMainCurrencyId
		LEFT JOIN tblRKBrokerageAccount ba on ot.intBrokerageAccountId=ba.intBrokerageAccountId AND ba.intEntityId = ot.intEntityId  
		LEFT JOIN tblCTBook b on b.intBookId=ot.intBookId
		LEFT JOIN tblCTSubBook sb on sb.intSubBookId=ot.intSubBookId 
		where intSelectedInstrumentTypeId in(1,3) and  ot.intInstrumentTypeId = 1
	) t
) t1  --where dblBalanceLot > 0

UNION ALL SELECT TOP 100 PERCENT *
FROM (
	SELECT dblTotalLot-dblSelectedLot1 AS dblBalanceLot
		, dblTotalLot-dblSelectedLotRoll AS dblBalanceLotRoll
		, 0.0 as dblSelectedLot
		, *
	FROM (
		SELECT intSelectedInstrumentTypeId
			, strInternalTradeNo AS strTransactionNo
			, dtmTransactionDate as dtmTransactionDate
			, ot.dblContractAmount as dblTotalLot
			, IsNull((SELECT SUM (AD.dblMatchQty)
					from tblRKMatchFuturesPSDetail AD
					inner join tblRKMatchFuturesPSHeader A ON AD.intMatchFuturesPSHeaderId = A.intMatchFuturesPSHeaderId
					where A.strType = 'Realize'
					GROUP BY AD.intLFutOptTransactionId
					Having ot.intFutOptTransactionId = AD.intLFutOptTransactionId), 0)  As dblSelectedLot1
			, IsNull((SELECT SUM (AD.dblMatchQty)
					from tblRKMatchFuturesPSDetail AD
					inner join tblRKMatchFuturesPSHeader A ON AD.intMatchFuturesPSHeaderId = A.intMatchFuturesPSHeaderId
					where A.strType = 'Roll'
					Group By AD.intLFutOptTransactionId
					Having ot.intFutOptTransactionId = AD.intLFutOptTransactionId), 0) As dblSelectedLotRoll
			, CASE WHEN strBuySell ='Buy' Then 'B' else 'S' End COLLATE Latin1_General_CI_AS AS strBuySell
			, ot.dblExchangeRate as dblPrice
			, case when isnull(ot.dtmCreateDateTime,'')='' then ot.dtmTransactionDate else ot.dtmCreateDateTime end as dtmCreateDateTime
			, strBook
			, strSubBook
			, null intFutureMarketId
			, null intBrokerageAccountId
			, null intLocationId
			, null intFutureMonthId
			, intCommodityId
			, null intEntityId
			, ISNULL(ot.intBookId,0) as intBookId
			, ISNULL(ot.intSubBookId,0) as intSubBookId
			, intFutOptTransactionId
			, null dblContractSize
			, null dblFutCommission
			, null intBrokerageCommissionId
			, null dtmFilledDate
			, ot.intFutOptTransactionHeaderId
			, null as intCurrencyId
			, strCurrency = NULL
			, intMainCurrencyId = NULL
			, strMainCurrency = NULL
			, null as intCent
			, null ysnSubCurrency
			, ot.intBankId
			, ot.intBankAccountId
			, ot.intCurrencyExchangeRateTypeId
			, ot.strBrokerTradeNo
			, strFutureMonth = null
		FROM tblRKFutOptTransaction ot
		LEFT JOIN tblCTBook b on b.intBookId=ot.intBookId
		LEFT JOIN tblCTSubBook sb on sb.intSubBookId=ot.intSubBookId
		LEFT JOIN [dbo].[tblCMBank] AS ban ON ot.[intBankId] = ban.[intBankId]
		LEFT JOIN [dbo].[tblCMBankAccount] AS banAcc ON ot.[intBankAccountId] = banAcc.[intBankAccountId]
		LEFT JOIN [dbo].[tblSMCurrencyExchangeRateType] AS ce ON ot.[intCurrencyExchangeRateTypeId] = ce.[intCurrencyExchangeRateTypeId]
		where intSelectedInstrumentTypeId=2 AND ot.intInstrumentTypeId = 3 and isnull(ysnLiquidation,0) = 0
	) t
) t1
Order by dtmCreateDateTime Asc, dblPrice desc