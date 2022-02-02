CREATE VIEW vyuRKFutOptTransaction

AS  

SELECT TOP 100 PERCENT *
	, intRowNum = CONVERT(INT,ROW_NUMBER() OVER (ORDER BY intFutOptTransactionId))
	, dblHedgeQty = ISNULL(dblContractSize, 0.00) * dblOpenContract
	, dblContractPrice = ISNULL(dblPrice, 0.00) * dblOpenContract
FROM (
	SELECT ft.intFutOptTransactionId
		, ft.intFutOptTransactionHeaderId
		, fom.strFutMarketName
		, ft.dtmTransactionDate
		, strFutureMonthYear = (LEFT(CONVERT(DATE, '01 ' + fm.strFutureMonth), 7) + ' (' + fm.strFutureMonth + ')') COLLATE Latin1_General_CI_AS
		, ft.intOptionMonthId
		, strOptionMonthYear = om.strOptionMonth
		, ft.strOptionType
		, ft.intInstrumentTypeId
		, strInstrumentType = CASE WHEN (ft.[intInstrumentTypeId] = 1) THEN N'Futures'
								WHEN (ft.[intInstrumentTypeId] = 2) THEN N'Options'
								WHEN (ft.[intInstrumentTypeId] = 3) THEN N'Spot'
								WHEN (ft.[intInstrumentTypeId] = 4) THEN N'Forward'
								WHEN (ft.[intInstrumentTypeId] = 5) THEN N'Swap'END COLLATE Latin1_General_CI_AS
		, ft.dblStrike
		, ft.strInternalTradeNo
		, ft.intEntityId
		, e.strName
		, ft.intBrokerageAccountId
		, ft.intBankAccountId
		, ft.intBankId
		, strBrokerageAccount = acc.strAccountNumber
		, dblGetNoOfContract = CASE WHEN (N'Sell' = ft.[strBuySell]) THEN - (ft.[dblNoOfContract]) ELSE ft.[dblNoOfContract] END
		, fot.dblContractSize
		, dblOpenContract = (CASE WHEN ft.intSelectedInstrumentTypeId = 3 THEN (SELECT CONVERT(DECIMAL(18,6), SUM(goc.dblOpenContract)) from vyuRKGetOpenContract goc WHERE goc.intFutOptTransactionId = ft.intFutOptTransactionId)
								ELSE (SELECT CONVERT(DECIMAL(18,6), SUM(goc.dblOpenContract)) from vyuRKGetOpenContract goc WHERE goc.intFutOptTransactionId = ft.intFutOptTransactionId)
								END)
		, um.strUnitMeasure
		, ft.strBuySell
		, ft.dblPrice
		, sc.strCommodityCode
		, ft.intLocationId
		, cl.strLocationName
		, strStatus	= CASE WHEN ISNULL(approval.strApprovalStatus, '') != '' AND approval.strApprovalStatus != 'Approved' THEN approval.strApprovalStatus
							WHEN ISNULL(ft.strStatus, '') = '' AND approval.strApprovalStatus = 'Approved' 
								THEN CASE WHEN ISNULL(ft.intBankTransferId, 0) <> 0 THEN 'Posted' ELSE 'Approved and Not Posted' END
							ELSE ISNULL(ft.strStatus, 
										CASE WHEN ft.intSelectedInstrumentTypeId = 2 AND ft.intInstrumentTypeId = 4 THEN 'No Need for Approval' 
										ELSE '' END) 
							END
		, ft.intBookId
		, sb.strBook
		, ft.intSubBookId
		, ssb.strSubBook
		, dtmFilledDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), ft.dtmFilledDate, 110), 110)
		, ft.intCommodityId
		, b.strBankName
		, strBankAccountNo
		, ft.intSelectedInstrumentTypeId
		, strSelectedInstrumentType = (CASE WHEN ft.intSelectedInstrumentTypeId = 1 THEN 'Exchange Traded' 
											WHEN ft.intSelectedInstrumentTypeId = 2 THEN 'OTC'
										ELSE 'OTC - Others' END) COLLATE Latin1_General_CI_AS
		, ft.dtmMaturityDate
		, ft.intCurrencyId
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
		, fm.ysnExpired
		, ft.intRollingMonthId
		, strRollingMonth = rm.strFutureMonth
		, ft.strBrokerTradeNo
		, ft.ysnPreCrush
		, fm.strFutureMonth
		, strNotes = ft.strReference
		, ft.intFutureMarketId
		, ft.intFutureMonthId
		, Contract.strContractNumber
		, strSequenceNo = CAST(ContractDetail.intContractSeq AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
		, ft.strRefSwapTradeNo
		, ft.dtmCreateDateTime
		, ft.ysnFreezed
		, ft.intTraderId
		, sp.strName strSalespersonId
		, ft.strReference
		, ysnSlicedTrade = ISNULL(ft.ysnSlicedTrade, CAST(0 AS BIT))
		, ft.intOrigSliceTradeId
		, strOriginalTradeNo = ST.strInternalTradeNo
		, strOrderType = (CASE WHEN ft.intOrderTypeId = 1 THEN 'GTC'
							WHEN ft.intOrderTypeId = 2 THEN 'Limit'
							WHEN ft.intOrderTypeId = 3 THEN 'Market'
							ELSE '' END)
FROM tblRKFutOptTransaction AS ft
LEFT OUTER JOIN tblEMEntity AS e ON ft.[intEntityId] = e.[intEntityId]
LEFT OUTER JOIN tblEMEntity sp ON sp.intEntityId = ft.intTraderId
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
LEFT OUTER JOIN vyuCMBankAccount AS ba ON ft.[intBankAccountId] = ba.[intBankAccountId]
LEFT OUTER JOIN tblSMCurrencyExchangeRateType AS ce ON ft.[intCurrencyExchangeRateTypeId] = ce.[intCurrencyExchangeRateTypeId]
LEFT OUTER JOIN tblCTContractHeader Contract ON Contract.intContractHeaderId = ft.intContractHeaderId
LEFT OUTER JOIN tblCTContractDetail ContractDetail ON ContractDetail.intContractDetailId = ft.intContractDetailId
LEFT JOIN tblRKFutOptTransaction ST ON ST.intFutOptTransactionId = ft.intOrigSliceTradeId
OUTER APPLY (
	SELECT TOP 1 intScreenId FROM tblSMScreen 
	WHERE strModule = 'Risk Management' 
	AND strScreenName = 'Derivative Entry'
) approvalScreen
LEFT JOIN tblSMTransaction approval
	ON ft.intFutOptTransactionId = approval.intRecordId
	AND ft.intInstrumentTypeId = 4						-- OTC Forwards Only
	AND approval.intScreenId = approvalScreen.intScreenId
	AND approval.strApprovalStatus IN ('Waiting for Approval', 'Waiting for Submit', 'Approved')
)t 
ORDER BY intFutOptTransactionId ASC