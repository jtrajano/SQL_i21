CREATE VIEW vyuRKFutOptTransaction

AS  

SELECT TOP 100 PERCENT *
	, intRowNum = CONVERT(INT,ROW_NUMBER() OVER (ORDER BY intFutOptTransactionId))
	, dblHedgeQty = ISNULL(dblContractSize, 0) * dblOpenContract
FROM (
	SELECT ft.intFutOptTransactionId
		, ft.intFutOptTransactionHeaderId
		, fom.strFutMarketName
		, ft.dtmTransactionDate
		, strFutureMonthYear = (LEFT(CONVERT(DATE, '01 ' + fm.strFutureMonth), 7) + ' (' + fm.strFutureMonth + ')') COLLATE Latin1_General_CI_AS
		, strOptionMonthYear = om.strOptionMonth
		, ft.strOptionType
		, strInstrumentType = CASE WHEN (ft.[intInstrumentTypeId] = 1) THEN N'Futures'
								WHEN (ft.[intInstrumentTypeId] = 2) THEN N'Options'
								WHEN (ft.[intInstrumentTypeId] = 3) THEN N'Currency Contract' END COLLATE Latin1_General_CI_AS
		, ft.dblStrike
		, ft.strInternalTradeNo
		, e.strName
		, strBrokerageAccount = acc.strAccountNumber
		, dblGetNoOfContract = CASE WHEN (N'Sell' = ft.[strBuySell]) THEN - (ft.[dblNoOfContract]) ELSE ft.[dblNoOfContract] END
		, fot.dblContractSize
		, dblOpenContract = (SELECT CONVERT(DECIMAL, SUM(dblOpenContract)) from vyuRKGetOpenContract goc WHERE goc.intFutOptTransactionId = ft.intFutOptTransactionId)
		, um.strUnitMeasure
		, ft.strBuySell
		, ft.dblPrice
		, sc.strCommodityCode
		, cl.strLocationName
		, ft.strStatus
		, sb.strBook
		, ssb.strSubBook
		, dtmFilledDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), ft.dtmFilledDate, 110), 110)
		, ft.intCommodityId
		, strBankName
		, strBankAccountNo
		, strSelectedInstrumentType = (CASE WHEN intSelectedInstrumentTypeId = 1 THEN 'Exchange Traded' ELSE 'OTC' END) COLLATE Latin1_General_CI_AS
		, ft.dtmMaturityDate
		, strCurrencyExchangeRateType
		, ft.strFromCurrency
		, ft.strToCurrency
		, ft.dblContractAmount
		, ft.dblExchangeRate
		, ft.dblMatchAmount
		, ft.dblAllocatedAmount
		, ft.dblUnAllocatedAmount
		, ft.dblSpotRate
		, ft.ysnLiquidation
		, ft.ysnSwap	
		, strRollingMonth = rm.strFutureMonth
		, ft.strBrokerTradeNo
		, ft.ysnPreCrush
		, fm.strFutureMonth
		, strNotes = ft.strReference
		, ft.intFutureMarketId
		, ft.intFutureMonthId
FROM tblRKFutOptTransaction AS ft
LEFT OUTER JOIN tblEMEntity AS e ON ft.[intEntityId] = e.[intEntityId]
LEFT OUTER JOIN tblRKFuturesMonth AS fm ON ft.[intFutureMonthId] = fm.[intFutureMonthId]
LEFT OUTER JOIN tblRKFuturesMonth AS rm ON ft.[intRollingMonthId] = rm.[intFutureMonthId]
LEFT OUTER JOIN tblRKOptionsMonth AS om ON ft.[intOptionMonthId] = om.[intOptionMonthId]
LEFT OUTER JOIN tblCTBook AS sb ON ft.[intBookId] = sb.[intBookId]
LEFT OUTER JOIN tblCTSubBook AS ssb ON ft.[intSubBookId] = ssb.[intSubBookId]
LEFT OUTER JOIN tblRKFutureMarket AS fom ON ft.[intFutureMarketId] = fom.[intFutureMarketId]
LEFT OUTER JOIN tblRKBrokerageAccount AS acc ON ft.[intBrokerageAccountId] = acc.[intBrokerageAccountId]
LEFT OUTER JOIN tblRKFutureMarket AS [fot] ON ft.[intFutureMarketId] = [fot].[intFutureMarketId]
LEFT OUTER JOIN tblICUnitMeasure AS um ON [fot].[intUnitMeasureId] = um.[intUnitMeasureId]
LEFT OUTER JOIN tblICCommodity AS sc ON ft.[intCommodityId] = sc.[intCommodityId]
LEFT OUTER JOIN tblSMCompanyLocation AS cl ON ft.[intLocationId] = cl.[intCompanyLocationId]
LEFT OUTER JOIN tblCMBank AS b ON ft.[intBankId] = b.[intBankId]
LEFT OUTER JOIN tblCMBankAccount AS ba ON ft.[intBankAccountId] = ba.[intBankAccountId]
LEFT OUTER JOIN tblSMCurrencyExchangeRateType AS ce ON ft.[intCurrencyExchangeRateTypeId] = ce.[intCurrencyExchangeRateTypeId]
)t 
ORDER BY intFutOptTransactionId ASC