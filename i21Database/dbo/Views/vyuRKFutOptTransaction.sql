CREATE View vyuRKFutOptTransaction

AS  
SELECT *,isnull(dblHedgeQty1,0) as dblHedgeQty FROM (
SELECT 	ft.[intFutOptTransactionId] AS [intFutOptTransactionId], 
			ft.[intFutOptTransactionHeaderId] AS [intFutOptTransactionHeaderId], 
			fom.[strFutMarketName] AS [strFutMarketName], 
			ft.[dtmTransactionDate] AS [dtmTransactionDate], 
			fm.[strFutureMonth] AS [strFutureMonthYear], 
			om.[strOptionMonth] AS [strOptionMonthYear], 
			ft.[strOptionType] AS [strOptionType], 
			CASE WHEN (1 = ft.[intInstrumentTypeId]) THEN N'Futures' ELSE N'Options' END AS [strInstrumentType], 
			ft.[dblStrike] AS [dblStrike], 
			ft.[strInternalTradeNo] AS [strInternalTradeNo], 
			e.[strName] AS [strName], 
			acc.[strAccountNumber] AS [strBrokerageAccount], 
			CASE WHEN (N'Sell' = ft.[strBuySell]) THEN  -(ft.[intNoOfContract]) ELSE ft.[intNoOfContract] END AS [intGetNoOfContract], 
			(CASE WHEN (N'Sell' = ft.[strBuySell]) THEN  -(ft.[intNoOfContract]*fot.dblContractSize) ELSE ft.[intNoOfContract]*fot.dblContractSize END) as dblHedgeQty1,
			(SELECT CONVERT(DECIMAL,SUM(intOpenContract)) from vyuRKGetOpenContract goc WHERE goc.intFutOptTransactionId=ft.intFutOptTransactionId) as intOpenContract,
			um.[strUnitMeasure] AS [strUnitMeasure], 
			ft.[strBuySell] AS [strBuySell], 
			ft.[dblPrice] AS [dblPrice], 
			sc.[strCommodityCode] AS [strCommodityCode], 
			cl.[strLocationName] AS [strLocationName], 
			ft.[strStatus] AS [strStatus], 
			sb.[strBook] AS [strBook], 
			ssb.[strSubBook] AS [strSubBook], 
			ft.[dtmFilledDate] AS [dtmFilledDate]					
FROM [tblRKFutOptTransaction] AS ft
LEFT OUTER JOIN [dbo].[tblEntity] AS e ON ft.[intEntityId] = e.[intEntityId]
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
)t
