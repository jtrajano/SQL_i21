﻿CREATE VIEW vyuRKSFuturePSTransaction  

AS  

SELECT TOP 100 PERCENT *
FROM (
	SELECT dblBalanceLot = intTotalLot - dblSelectedLot1
		, dblBalanceLotRoll = intTotalLot - dblSelectedLotRoll
		, dblSelectedLot = 0.0
		, *
	FROM (
		SELECT intSelectedInstrumentTypeId
			, strTransactionNo = strInternalTradeNo
			, dtmTransactionDate
			, intTotalLot = CONVERT(INT, ot.intNoOfContract)
			, dblSelectedLot1 = ISNULL((SELECT SUM (AD.dblMatchQty) FROM tblRKMatchFuturesPSDetail AD
										INNER JOIN tblRKMatchFuturesPSHeader A ON AD.intMatchFuturesPSHeaderId = A.intMatchFuturesPSHeaderId
										WHERE A.strType = 'Realize' GROUP BY AD.intSFutOptTransactionId
										HAVING ot.intFutOptTransactionId = AD.intSFutOptTransactionId), 0)
			, dblSelectedLotRoll = ISNULL((SELECT SUM (AD.dblMatchQty) FROM tblRKMatchFuturesPSDetail AD
										INNER JOIN tblRKMatchFuturesPSHeader A ON AD.intMatchFuturesPSHeaderId = A.intMatchFuturesPSHeaderId
										WHERE A.strType = 'Roll' GROUP BY AD.intSFutOptTransactionId
										HAVING ot.intFutOptTransactionId = AD.intSFutOptTransactionId), 0)
			, strBuySell = CASE WHEN strBuySell ='Buy' Then 'B' else 'S' End COLLATE Latin1_General_CI_AS
			, dblPrice
			, strBook
			, strSubBook
			, ot.intFutureMarketId
			, ot.intBrokerageAccountId
			, ot.intLocationId
			, ot.intFutureMonthId
			, ot.intCommodityId
			, ot.intEntityId
			, intBookId = ISNULL(ot.intBookId, 0)
			, intSubBookId = ISNULL(ot.intSubBookId, 0)
			, intFutOptTransactionId
			, fm.dblContractSize
			--This filter is to get the correct commission based on date
			, dblFutCommission = ISNULL((SELECT TOP 1 (CASE WHEN bc.intFuturesRateType = 2 THEN 0
															ELSE ISNULL(bc.dblFutCommission, 0) / CASE WHEN cur.ysnSubCurrency = 1 THEN cur.intCent ELSE 1 END END) as dblFutCommission
										FROM tblRKBrokerageCommission bc
										LEFT JOIN tblSMCurrency cur on cur.intCurrencyID=bc.intFutCurrencyId
										WHERE bc.intFutureMarketId = ot.intFutureMarketId and bc.intBrokerageAccountId = ot.intBrokerageAccountId
											and ot.dtmTransactionDate between bc.dtmEffectiveDate and ISNULL(bc.dtmEndDate,getdate())),0) * -1 --commision is always negative (RM-1174)
			, dtmFilledDate
			, ot.intFutOptTransactionHeaderId
			, intCurrencyId = c.intCurrencyID
			, c.strCurrency
			, intMainCurrencyId = CASE WHEN c.ysnSubCurrency = 1 THEN c.intMainCurrencyId ELSE c.intCurrencyID END
			, strMainCurrency = CASE WHEN c.ysnSubCurrency = 0 THEN c.strCurrency ELSE MainCurrency.strCurrency END
			, c.intCent
			, c.ysnSubCurrency
			, ot.intBankId
			, ot.intBankAccountId
			, ot.intCurrencyExchangeRateTypeId
			, dtmCreateDateTime = CASE WHEN ISNULL(ot.dtmCreateDateTime, '') = '' THEN ot.dtmTransactionDate ELSE ot.dtmCreateDateTime END
			, ot.strBrokerTradeNo
		FROM tblRKFutOptTransaction ot
		JOIN tblRKFutureMarket fm on fm.intFutureMarketId=ot.intFutureMarketId and ot.intInstrumentTypeId=1 and ot.strStatus='Filled'
		JOIN tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId
		LEFT JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = c.intMainCurrencyId
		LEFT JOIN tblRKBrokerageAccount ba on ot.intBrokerageAccountId=ba.intBrokerageAccountId AND ba.intEntityId = ot.intEntityId  AND ot.intInstrumentTypeId =1
		LEFT JOIN tblCTBook b on b.intBookId=ot.intBookId
		LEFT JOIN tblCTSubBook sb on sb.intSubBookId=ot.intSubBookId and intSelectedInstrumentTypeId=1
	)t
)t1  --where dblBalanceLot > 0  
  
UNION ALL SELECT TOP 100 PERCENT *
FROM (
	SELECT dblBalanceLot = intTotalLot - dblSelectedLot1
		, dblBalanceLotRoll = intTotalLot - dblSelectedLotRoll
		, dblSelectedLot = 0.0
		, *
	FROM (
		SELECT intSelectedInstrumentTypeId
			, strTransactionNo = strInternalTradeNo
			, dtmTransactionDate
			, intTotalLot = CONVERT(INT, ot.dblContractAmount)
			, dblSelectedLot1 = ISNULL((SELECT SUM (AD.dblMatchQty)
										FROM tblRKMatchFuturesPSDetail AD
										inner join tblRKMatchFuturesPSHeader A ON AD.intMatchFuturesPSHeaderId = A.intMatchFuturesPSHeaderId
										where A.strType = 'Realize' GROUP BY AD.intSFutOptTransactionId
										Having ot.intFutOptTransactionId = AD.intSFutOptTransactionId), 0)
			, dblSelectedLotRoll = ISNULL((SELECT SUM (AD.dblMatchQty)
										from tblRKMatchFuturesPSDetail AD
										inner join tblRKMatchFuturesPSHeader A ON AD.intMatchFuturesPSHeaderId = A.intMatchFuturesPSHeaderId
										where A.strType = 'Roll' Group By AD.intSFutOptTransactionId
										Having ot.intFutOptTransactionId = AD.intSFutOptTransactionId), 0)
			, strBuySell = CASE WHEN strBuySell ='Buy' Then 'B' else 'S' End COLLATE Latin1_General_CI_AS
			, dblPrice = ot.dblExchangeRate
			, strBook
			, strSubBook
			, intFutureMarketId = NULL
			, intBrokerageAccountId = NULL
			, intLocationId = NULL
			, intFutureMonthId = NULL
			, intCommodityId
			, intEntityId = NULL
			, intBookId = ISNULL(ot.intBookId, 0)
			, intSubBookId = ISNULL(ot.intSubBookId, 0)
			, intFutOptTransactionId
			, dblContractSize = NULL
			, dblFutCommission = NULL
			, dtmFilledDate = NULL
			, ot.intFutOptTransactionHeaderId
			, intCurrencyId = NULL
			, strCurrency = NULL
			, intMainCurrencyId = NULL
			, strMainCurrency = NULL
			, intCent = NULL
			, ysnSubCurrency = NULL
			, ot.intBankId
			, ot.intBankAccountId
			, ot.intCurrencyExchangeRateTypeId
			, dtmCreateDateTime = CASE WHEN ISNULL(ot.dtmCreateDateTime, '') = '' THEN ot.dtmTransactionDate ELSE ot.dtmCreateDateTime END
			, ot.strBrokerTradeNo
		FROM tblRKFutOptTransaction ot
		LEFT JOIN tblCTBook b on b.intBookId=ot.intBookId
		LEFT JOIN tblCTSubBook sb on sb.intSubBookId=ot.intSubBookId
		LEFT JOIN [dbo].[tblCMBank] AS ban ON ot.[intBankId] = ban.[intBankId]
		LEFT JOIN [dbo].[tblCMBankAccount] AS banAcc ON ot.[intBankAccountId] = banAcc.[intBankAccountId]
		LEFT JOIN [dbo].[tblSMCurrencyExchangeRateType] AS ce ON ot.[intCurrencyExchangeRateTypeId] = ce.[intCurrencyExchangeRateTypeId]
		where intSelectedInstrumentTypeId=2 AND ot.intInstrumentTypeId = 3 and ISNULL(ysnLiquidation,0) = 0
	)t 
)t1   --where  dblBalanceLot > 0
Order by dtmCreateDateTime Asc, dblPrice desc