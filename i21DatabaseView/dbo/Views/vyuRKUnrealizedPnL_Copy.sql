CREATE VIEW vyuRKUnrealizedPnL_Copy

AS  
 
SELECT TOP 100 PERCENT CONVERT(INT, DENSE_RANK() OVER(ORDER BY CONVERT(DATETIME, '01 ' + strFutureMonth))) RowNum
	, (strFutMarketName+ ' - ' + strFutureMonth + ' - ' + strName) COLLATE Latin1_General_CI_AS MonthOrder
	, *
FROM (
	SELECT *
		, (GrossPnL - dblFutCommission) NetPnL
	FROM (
		SELECT (CONVERT(INT, ISNULL((Long1 - MatchLong), 0) - ISNULL(Sell1 - MatchShort, 0)))*dblContractSize/ case when ysnSubCurrency = 1 then intCent else 1 end  GrossPnL
			, ISNULL(((Long1-MatchLong)*dblPrice),0) LongWaitedPrice
			, ISNULL((Long1-MatchLong),0) as dblLong
			, ISNULL(Sell1-MatchShort,0) as dblShort
			, ISNULL(((Sell1-MatchShort)*dblPrice),0) ShortWaitedPrice
			, convert(int,ISNULL((Long1-MatchLong),0)- ISNULL(Sell1-MatchShort,0)) * -dblFutCommission1 / case when ComSubCurrency = 1 then ComCent else 1 end  AS dblFutCommission
			, convert(int,ISNULL((Long1-MatchLong),0)- ISNULL(Sell1-MatchShort,0)) as  intNet
			, *
		FROM (
			SELECT intFutOptTransactionId
				, fm.strFutMarketName
				, om.strFutureMonth
				, ot.intFutureMonthId
				, ot.intCommodityId
				, ot.intFutureMarketId
				, CONVERT(DATETIME, CONVERT(VARCHAR(10), ot.dtmFilledDate, 110), 110) as dtmTradeDate
				, ot.strInternalTradeNo
				, e.strName
				, acc.strAccountNumber
				, cb.strBook
				, csb.strSubBook
				, sp.strSalespersonId
				, icc.strCommodityCode
				, sl.strLocationName
				, ot.dblNoOfContract as dblOriginalQty
				, Case WHEN ot.strBuySell='Buy' THEN ISNULL(ot.dblNoOfContract,0) ELSE null end Long1
				, Case WHEN ot.strBuySell='Sell' THEN ISNULL(ot.dblNoOfContract,0) ELSE null end Sell1
				, ot.dblNoOfContract as intNet1
				, ot.dblPrice as dblActual
				, null as dblClosing
				, ISNULL(ot.dblPrice,0) dblPrice
				, fm.dblContractSize dblContractSize
				, 0 as intConcurrencyId
				, CASE WHEN bc.intFuturesRateType= 1 then 0 else  ISNULL(bc.dblFutCommission,0) end as dblFutCommission1
				, ISNULL((select sum(dblMatchQty) from tblRKMatchFuturesPSDetail psd WHERE psd.intLFutOptTransactionId=ot.intFutOptTransactionId),0)as MatchLong
				, ISNULL((select sum(dblMatchQty) from tblRKMatchFuturesPSDetail psd WHERE psd.intSFutOptTransactionId=ot.intFutOptTransactionId),0)as MatchShort
				, c.intCurrencyID as intCurrencyId
				, c.intCent
				, c.ysnSubCurrency
				, intFutOptTransactionHeaderId
				, ysnExpired
				, cur.intCent ComCent
				, cur.ysnSubCurrency ComSubCurrency
			FROM tblRKFutOptTransaction ot
			JOIN tblRKFuturesMonth om on om.intFutureMonthId=ot.intFutureMonthId   and ot.strStatus='Filled'
			JOIN tblRKBrokerageAccount acc on acc.intBrokerageAccountId=ot.intBrokerageAccountId
			JOIN tblICCommodity icc on icc.intCommodityId=ot.intCommodityId
			JOIN tblSMCompanyLocation sl on sl.intCompanyLocationId=ot.intLocationId
			JOIN tblARSalesperson sp on sp.intEntityId= ot.intTraderId
			JOIN tblEMEntity e on e.intEntityId=ot.intEntityId
			JOIN tblRKFutureMarket fm on ot.intFutureMarketId=fm.intFutureMarketId
			JOIN tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId
			JOIN tblRKBrokerageCommission bc on bc.intFutureMarketId=ot.intFutureMarketId AND ot.intBrokerageAccountId=bc.intBrokerageAccountId
			JOIN tblSMCurrency cur on cur.intCurrencyID=bc.intFutCurrencyId
			JOIN tblRKBrokerageAccount ba on bc.intBrokerageAccountId=ba.intBrokerageAccountId and ot.intInstrumentTypeId = 1
			LEFT JOIN tblCTBook cb on cb.intBookId= ot.intBookId
			LEFT join tblCTSubBook csb on csb.intSubBookId=ot.intSubBookId
		) t1
	) t1
)t1 ORDER BY RowNum ASC