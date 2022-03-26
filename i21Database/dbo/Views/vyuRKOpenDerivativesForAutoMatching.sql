CREATE VIEW [dbo].[vyuRKOpenDerivativesForAutoMatching]

AS

SELECT TOP 100 PERCENT *
FROM (
	SELECT 
		dblBalanceLot = CASE WHEN intInstrumentTypeId = 1 THEN  CASE WHEN strBuySell = 'Buy' THEN  dblTotalLot - dblFuturesMatchedLotBuy ELSE   dblTotalLot - dblFuturesMatchedLotSell END
							ELSE CASE WHEN strBuySell = 'Buy' THEN  dblTotalLot - dblOptionsMatchedLotBuy ELSE dblTotalLot - dblOptionsMatchedLotSell END 
						END
		, dblTotalLot - dblFuturesMatchedLotBuy AS dblBalanceLotRoll
		, 0.0 as dblSelectedLot
		, *
	FROM (
		SELECT intSelectedInstrumentTypeId
			, ot.intInstrumentTypeId
			, strInternalTradeNo AS strTransactionNo
			, dtmTransactionDate as dtmTransactionDate
			, ot.dblNoOfContract as dblTotalLot
			, IsNull((SELECT SUM (AD.dblMatchQty)
					from tblRKMatchFuturesPSDetail AD
					inner join tblRKMatchFuturesPSHeader A ON AD.intMatchFuturesPSHeaderId = A.intMatchFuturesPSHeaderId
					where A.strType = 'Realize'
					Group By AD.intLFutOptTransactionId
					Having ot.intFutOptTransactionId = AD.intLFutOptTransactionId), 0)  As dblFuturesMatchedLotBuy
			, IsNull((SELECT SUM (AD.dblMatchQty)
					from tblRKMatchFuturesPSDetail AD
					inner join tblRKMatchFuturesPSHeader A ON AD.intMatchFuturesPSHeaderId = A.intMatchFuturesPSHeaderId
					where A.strType = 'Realize'
					Group By AD.intSFutOptTransactionId
					Having ot.intFutOptTransactionId = AD.intSFutOptTransactionId), 0)  As dblFuturesMatchedLotSell
			, IsNull((SELECT SUM (AD.dblMatchQty)
					from tblRKMatchFuturesPSDetail AD
					inner join tblRKMatchFuturesPSHeader A ON AD.intMatchFuturesPSHeaderId = A.intMatchFuturesPSHeaderId
					where A.strType = 'Roll'
					Group By AD.intLFutOptTransactionId
					Having ot.intFutOptTransactionId = AD.intLFutOptTransactionId), 0)  As dblSelectedLotRoll
			, IsNull((SELECT SUM (OM.dblMatchQty)
					from tblRKOptionsMatchPnS OM
					Group By OM.intLFutOptTransactionId
					Having ot.intFutOptTransactionId = OM.intLFutOptTransactionId), 0)  As dblOptionsMatchedLotBuy
			, IsNull((SELECT SUM (OM.dblMatchQty)
					from tblRKOptionsMatchPnS OM
					Group By OM.intSFutOptTransactionId
					Having ot.intFutOptTransactionId = OM.intSFutOptTransactionId), 0)  As dblOptionsMatchedLotSell
			, CASE WHEN strBuySell ='Buy' Then 'B' else 'S' End COLLATE Latin1_General_CI_AS AS strBS
			, strBuySell
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
			, ot.strOptionType
			, ot.dblStrike
		FROM tblRKFutOptTransaction ot
		JOIN tblRKFutureMarket fm on fm.intFutureMarketId=ot.intFutureMarketId  and ot.strStatus='Filled'
		JOIN tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId
		JOIN tblRKFuturesMonth m on m.intFutureMonthId=ot.intFutureMonthId
		LEFT JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = c.intMainCurrencyId
		LEFT JOIN tblRKBrokerageAccount ba on ot.intBrokerageAccountId=ba.intBrokerageAccountId AND ba.intEntityId = ot.intEntityId  
		LEFT JOIN tblCTBook b on b.intBookId=ot.intBookId
		LEFT JOIN tblCTSubBook sb on sb.intSubBookId=ot.intSubBookId 
		where intSelectedInstrumentTypeId in(1,3) and  ot.intInstrumentTypeId IN(1,2)
	) t
) t1  where dblBalanceLot > 0


		