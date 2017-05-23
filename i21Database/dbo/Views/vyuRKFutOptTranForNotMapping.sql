CREATE View vyuRKFutOptTranForNotMapping

AS  
SELECT 	ft.intFutOptTransactionId,fom.dblContractSize,strCurrencyExchangeRateType,strBook,strSubBook,fm.dtmFirstNoticeDate,fm.dtmLastTradingDate
,fom.strFutMarketName,strAccountNumber,e.strName,e1.strName as strSalespersonId,
CASE WHEN ft.intInstrumentTypeId = 1 then 'Futures'
	 WHEN ft.intInstrumentTypeId = 2 then 'Options'
	 WHEN ft.intInstrumentTypeId = 3 then 'Currency Contract' end strInstrumentType,
CASE WHEN strBuySell = 'Sell' then -intNoOfContract else intNoOfContract end intGetNoOfContract,
case when strBuySell = 'Sell' then -(fot.dblContractSize * (select sum(intOpenContract) from vyuRKGetOpenContract f where f.intFutOptTransactionId=ft.intFutOptTransactionId) 				
				) else (fot.dblContractSize * (select sum(intOpenContract) from vyuRKGetOpenContract f where f.intFutOptTransactionId=ft.intFutOptTransactionId)) end dblHedgeQty,
strUnitMeasure,strCommodityCode,strLocationName,strCurrency,substring(fm.strFutureMonth,0,4) + '(' +fm.strSymbol+')'+convert(nvarchar,fm.intYear) strFutureMonthYear,
fm.strFutureMonth strFutureMonthYearWOSymbol,
 substring(om.strOptionMonth,0,4) + '(' +fom.strOptSymbol+')'+convert(nvarchar,om.intYear)  strOptionMonthYear,
  		strOptionMonth strOptionMonthYearWOSymbol
		,(SELECT TOP 1 chn.strContractNumber FROM tblCTContractHeader chn where chn.intContractHeaderId = cd.intContractHeaderId)  + ' - ' + CONVERT(varchar,cd.intContractSeq) as strContractSeq,
		ch.strContractNumber strContractNumber
		,frm.strFutureMonth strRollingMonth, ft.intRollingMonthId,
		CASE WHEN ISNULL(intSelectedInstrumentTypeId,1) =1  then 'Exchange Traded' else 'OTC' end as strSelectedInstrumentType,intAssignedLots as intAssignedLots
FROM [tblRKFutOptTransaction] AS ft
LEFT OUTER JOIN [dbo].[vyuRKGetAssignedLots] AS al ON ft.[intFutOptTransactionId] = al.[intFutOptTransactionId]
LEFT OUTER JOIN [dbo].tblEMEntity AS e ON ft.[intEntityId] = e.[intEntityId]
LEFT OUTER JOIN [dbo].tblEMEntity AS e1 ON ft.[intTraderId] = e1.[intEntityId]
LEFT OUTER JOIN [dbo].[tblRKFuturesMonth] AS fm ON ft.[intFutureMonthId] = fm.[intFutureMonthId]
LEFT OUTER JOIN [dbo].[tblRKFuturesMonth] AS frm ON ft.[intRollingMonthId] = frm.[intFutureMonthId]
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
LEFT OUTER JOIN [dbo].[tblSMCurrency] AS bc ON ft.[intCurrencyId] = bc.[intCurrencyID]
LEFT OUTER JOIN [dbo].[tblSMCurrencyExchangeRateType] AS ce ON ft.[intCurrencyExchangeRateTypeId] = ce.[intCurrencyExchangeRateTypeId]
LEFT OUTER JOIN [dbo].[tblRKAssignFuturesToContractSummary] AS cs ON cs.[intFutOptAssignedId] = ft.[intFutOptTransactionId]
LEFT OUTER JOIN [dbo].[tblCTContractHeader] AS ch ON ch.[intContractHeaderId] = cs.[intContractHeaderId]
LEFT OUTER JOIN [dbo].[tblCTContractDetail] AS cd ON cd.[intContractDetailId] = cs.[intContractDetailId]