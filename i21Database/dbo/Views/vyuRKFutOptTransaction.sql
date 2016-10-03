CREATE View vyuRKFutOptTransaction

AS  

SELECT top 100 percent *,convert(int,ROW_NUMBER() OVER (ORDER BY intFutOptTransactionId)) AS intRowNum,isnull(dblContractSize,0)*intOpenContract as dblHedgeQty FROM (
SELECT 	ft.[intFutOptTransactionId] AS [intFutOptTransactionId], 
			ft.[intFutOptTransactionHeaderId] AS [intFutOptTransactionHeaderId], 
			fom.[strFutMarketName] AS [strFutMarketName], 
			ft.[dtmTransactionDate] AS [dtmTransactionDate], 
			fm.[strFutureMonth] AS [strFutureMonthYear], 
			om.[strOptionMonth] AS [strOptionMonthYear], 
			ft.[strOptionType] AS [strOptionType], 
			CASE WHEN (ft.[intInstrumentTypeId]=1) THEN N'Futures'
				 WHEN (ft.[intInstrumentTypeId]=2) THEN N'Options'
				 WHEN (ft.[intInstrumentTypeId]=3) THEN N'Currency Contract' END AS [strInstrumentType], 
			ft.[dblStrike] AS [dblStrike], 
			ft.[strInternalTradeNo] AS [strInternalTradeNo], 
			e.[strName] AS [strName], 
			acc.[strAccountNumber] AS [strBrokerageAccount], 
			CASE WHEN (N'Sell' = ft.[strBuySell]) THEN  -(ft.[intNoOfContract]) ELSE ft.[intNoOfContract] END AS [intGetNoOfContract], 
			fot.dblContractSize as dblContractSize,
			(SELECT CONVERT(DECIMAL,SUM(intOpenContract)) from vyuRKGetOpenContract goc WHERE goc.intFutOptTransactionId=ft.intFutOptTransactionId) as intOpenContract,
			um.[strUnitMeasure] AS [strUnitMeasure], 
			ft.[strBuySell] AS [strBuySell], 
			ft.[dblPrice] AS [dblPrice], 
			sc.[strCommodityCode] AS [strCommodityCode], 
			cl.[strLocationName] AS [strLocationName], 
			ft.[strStatus] AS [strStatus], 
			sb.[strBook] AS [strBook], 
			ssb.[strSubBook] AS [strSubBook], 
			ft.[dtmFilledDate] AS [dtmFilledDate],
			ft.intCommodityId
			,strBankName
			,strBankAccountNo
			,case when intSelectedInstrumentTypeId=1 then 'Exchange Traded' else 'OTC' end strSelectedInstrumentType
			,ft.[dtmMaturityDate]
			,strCurrencyExchangeRateType
			,ft.strFromCurrency
			,ft.strToCurrency
			,ft.dblContractAmount
			,ft.dblExchangeRate
			,ft.dblMatchAmount
			,ft.dblAllocatedAmount
			,ft.dblUnAllocatedAmount
			,ft.dblSpotRate
			,ft.ysnLiquidation
			,ft.ysnSwap					
FROM [tblRKFutOptTransaction] AS ft
LEFT OUTER JOIN [dbo].tblEMEntity AS e ON ft.[intEntityId] = e.[intEntityId]
LEFT OUTER JOIN [dbo].[tblRKFuturesMonth] AS fm ON ft.[intFutureMonthId] = fm.[intFutureMonthId]
LEFT OUTER JOIN [dbo].[tblRKOptionsMonth] AS om ON ft.[intOptionMonthId] = om.[intOptionMonthId]
LEFT OUTER JOIN [dbo].[tblCTBook] AS sb ON ft.[intBookId] = sb.[intBookId]
LEFT OUTER JOIN [dbo].[tblCTSubBook] AS ssb ON ft.[intSubBookId] = ssb.[intSubBookId]
LEFT OUTER JOIN [dbo].[tblRKFutureMarket] AS fom ON ft.[intFutureMarketId] = fom.[intFutureMarketId]
LEFT OUTER JOIN [dbo].[tblRKBrokerageAccount] AS acc ON ft.[intBrokerageAccountId] = acc.[intBrokerageAccountId]
LEFT OUTER JOIN [dbo].[tblRKFutureMarket] AS [fot] ON ft.[intFutureMarketId] = [fot].[intFutureMarketId]
LEFT OUTER JOIN [dbo].[tblICUnitMeasure] AS um ON [fot].[intUnitMeasureId] = um.[intUnitMeasureId]
LEFT OUTER JOIN [dbo].[tblICCommodity] AS sc ON ft.[intCommodityId] = sc.[intCommodityId]
LEFT OUTER JOIN [dbo].[tblSMCompanyLocation] AS cl ON ft.[intLocationId] = cl.[intCompanyLocationId]
LEFT OUTER JOIN [dbo].[tblCMBank] AS b ON ft.[intBankId] = b.[intBankId]
LEFT OUTER JOIN [dbo].[tblCMBankAccount] AS ba ON ft.[intBankAccountId] = ba.[intBankAccountId]
LEFT OUTER JOIN [dbo].[tblSMCurrencyExchangeRateType] AS ce ON ft.[intCurrencyExchangeRateTypeId] = ce.[intCurrencyExchangeRateTypeId]
)t order by convert(int,REPLACE(REPLACE(REPLACE(strInternalTradeNo,'-S' ,''),'O-' ,''),'-H','')) ASC