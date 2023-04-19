CREATE VIEW vyuRKFutOptTransaction

AS  

SELECT TOP 100 PERCENT *
	, intRowNum = intFutOptTransactionId --CONVERT(INT,ROW_NUMBER() OVER (ORDER BY intFutOptTransactionId))
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
		, strStatus	= CASE WHEN ft.intSelectedInstrumentTypeId = 2 AND ft.intInstrumentTypeId = 4 -- OTC Forward
							THEN CASE WHEN ISNULL(ft.intBankTransferId, 0) <> 0 THEN 'Posted' 
									WHEN approval.strApprovalStatus = 'Approved' THEN 'Approved and Not Posted'
									ELSE CASE WHEN ISNULL(approval.strApprovalStatus,'') <> '' 
											THEN  approval.strApprovalStatus
											ELSE 'No Need for Approval'
											END
									END
							ELSE ft.strStatus
							END COLLATE Latin1_General_CI_AS
		, strAssignedContracts  = CASE WHEN  ft.intSelectedInstrumentTypeId IN (1) THEN (
									SELECT  STUFF((SELECT ',' + CH.strContractNumber + '-' + CAST(CD.intContractSeq AS NVARCHAR(10))
									FROM tblRKAssignFuturesToContractSummary A
									INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = A.intContractDetailId
									INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
									WHERE ysnIsHedged = 0 AND A.intFutOptTransactionId = ft.intFutOptTransactionId
									FOR XML PATH('')), 1, 1, ''))
								ELSE '' END
		, strHedgedContracts  = CASE WHEN  ft.intSelectedInstrumentTypeId IN (1) THEN 
									(SELECT  STUFF((SELECT ',' + CH.strContractNumber + '-' + CAST(CD.intContractSeq AS NVARCHAR(10))
									FROM tblRKAssignFuturesToContractSummary A
									INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = A.intContractDetailId
									INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
									WHERE ysnIsHedged = 1 AND A.intFutOptTransactionId = ft.intFutOptTransactionId
									FOR XML PATH('')), 1, 1, ''))
								ELSE 
									Contract.strContractNumber + '-' + CAST(ContractDetail.intContractSeq AS NVARCHAR(10))
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
		, strOrderType = (CASE WHEN ft.intOrderTypeId = 2 THEN 'Limit'
							WHEN ft.intOrderTypeId = 3 THEN 'Market'
							ELSE '' END)
		, ft.strCommissionRateType
		, ft.dblBrokerageRate
		, ft.dblCommission
		, ft.ysnCommissionExempt
		, ft.ysnCommissionOverride
		, ft.ysnPosted
		, strCurrencyPair = CPS.strCurrencyPair
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
LEFT JOIN vyuRKCurrencyPairSetup CPS
	ON CPS.intCurrencyPairId = ft.intCurrencyPairId
)t 
--ORDER BY intFutOptTransactionId ASC