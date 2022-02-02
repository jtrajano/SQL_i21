CREATE VIEW vyuRKFutOptTranForNotMapping

AS  

SELECT DE.intFutOptTransactionId
	, FMarket.dblContractSize
	, strCurrencyExchangeRateType
	, strBook
	, strSubBook
	, FMonth.dtmFirstNoticeDate
	, FMonth.dtmLastTradingDate
	, FMarket.strFutMarketName
	, FMarket.ysnOptions
	, strAccountNumber
	, e.strName
	, strSalespersonId = Trader.strName
	, strInstrumentType = CASE WHEN DE.intInstrumentTypeId = 1 THEN 'Futures'
						WHEN DE.intInstrumentTypeId = 2 THEN 'Options'
						WHEN DE.intInstrumentTypeId = 3 THEN 'Spot'						
						WHEN DE.intInstrumentTypeId = 4 THEN 'Forward'						
						WHEN DE.intInstrumentTypeId = 5 THEN 'Swap' END COLLATE Latin1_General_CI_AS
	, dblGetNoOfContract = CASE WHEN DE.strBuySell = 'Sell' THEN - DE.dblNoOfContract ELSE DE.dblNoOfContract END
	, dblHedgeQty = CASE WHEN DE.strBuySell = 'Sell' THEN - (FMarket.dblContractSize * GOC.dblSumOpenContract)
						ELSE (FMarket.dblContractSize * GOC.dblSumOpenContract) END
	, strUnitMeasure
	, strCommodityCode
	, strLocationName
	, Curr.strCurrency
	, strFutureMonthYear = (SUBSTRING(FMonth.strFutureMonth, 0, 4) + '(' + FMonth.strSymbol + ')' + CONVERT(NVARCHAR, FMonth.intYear)) COLLATE Latin1_General_CI_AS
	, strFutureMonthYearWOSymbol = FMonth.strFutureMonth
	, strOptionMonthYear = (SUBSTRING(OMonth.strOptionMonth, 0, 4) + '(' + OMonth.strOptMonthSymbol + ')' + CONVERT(NVARCHAR, OMonth.intYear)) COLLATE Latin1_General_CI_AS
	, strOptionMonthYearWOSymbol = strOptionMonth
	, strContractSeq = (ch.strContractNumber + ' - ' + CAST(cd.intContractSeq AS NVARCHAR(10))) COLLATE Latin1_General_CI_AS
	, strContractNumber = ch.strContractNumber
	, strRollingMonth = RMonth.strFutureMonth
	, DE.intRollingMonthId
	, strSelectedInstrumentType = CASE WHEN ISNULL(DE.intSelectedInstrumentTypeId,1) =1  THEN 'Exchange Traded'
										WHEN DE.intSelectedInstrumentTypeId = 2 THEN 'OTC'
										ELSE 'OTC - Others' END COLLATE Latin1_General_CI_AS
	, dblAssignedLots = AD.dblAssignedLots
	, Bank.strBankName
	, BankAcct.strBankAccountNo
	, dblUsedContract = ISNULL(DE.dblNoOfContract - GOC.dblMaxOpenContract, 0.00)
	, ysnLocked = CAST(ISNULL((SELECT TOP 1 1 FROM tblRKFutOptTransaction 
								WHERE (intFutOptTransactionId IN (SELECT intLFutOptTransactionId FROM tblRKMatchFuturesPSDetail)
										OR intFutOptTransactionId IN (SELECT intSFutOptTransactionId FROM tblRKMatchFuturesPSDetail)
										OR intFutOptTransactionId IN (SELECT intLFutOptTransactionId FROM tblRKOptionsMatchPnS)
										OR intFutOptTransactionId IN (SELECT intSFutOptTransactionId FROM tblRKOptionsMatchPnS)
										OR intFutOptTransactionId IN (SELECT intFutOptTransactionId FROM tblRKAssignFuturesToContractSummary WHERE (ISNULL(dblAssignedLotsToSContract,0) <> 0 OR ISNULL(dblAssignedLotsToPContract,0) <>  0))
										OR intFutOptTransactionId IN (SELECT DISTINCT intOrigSliceTradeId FROM tblRKFutOptTransaction WHERE intOrigSliceTradeId is not null))
									AND intFutOptTransactionId = DE.intFutOptTransactionId), 0) AS BIT)
	, dblAvailableContract = ISNULL(DE.dblPContractBalanceLots, 0.00)
	, ysnSlicedTrade = ISNULL(DE.ysnSlicedTrade, CAST(0 AS BIT))
	, DE.intOrigSliceTradeId
	, strOriginalTradeNo = ST.strInternalTradeNo
	, strHedgeType = 'Contract Futures' COLLATE Latin1_General_CI_AS
	, intHedgeContractId = hedgecontractheader.intContractHeaderId 
	, strHedgeContract = hedgecontractheader.strContractNumber + ISNULL('-' + CAST(hedgecontractdetail.intContractSeq AS NVARCHAR(10)), '') COLLATE Latin1_General_CI_AS
	, strBuyBankName = BuyBank.strBankName COLLATE Latin1_General_CI_AS
	, strBuyBankAccountNo = BuyBankAcct.strBankAccountNo COLLATE Latin1_General_CI_AS
	, strBankTransferNo = BT.strTransactionId COLLATE Latin1_General_CI_AS
	, dtmBankTransferDate = BT.dtmDate	
	, ysnBankTransferPosted = CASE WHEN ISNULL(DE.intBankTransferId, 0) <> 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	, strApprovalStatus = CASE WHEN ISNULL(approval.strApprovalStatus, '') != '' AND approval.strApprovalStatus != 'Approved' THEN approval.strApprovalStatus
							WHEN ISNULL(DE.strStatus, '') = '' AND approval.strApprovalStatus = 'Approved' 
								THEN CASE WHEN ISNULL(DE.intBankTransferId, 0) <> 0 THEN 'Posted' ELSE 'Approved and not Posted' END
							ELSE ISNULL(DE.strStatus, 
										CASE WHEN DE.intSelectedInstrumentTypeId = 2 AND DE.intInstrumentTypeId = 4 THEN 'No Need for Approval' 
										ELSE '' END) 
							END COLLATE Latin1_General_CI_AS
	, strOrderType = (CASE WHEN DE.intOrderTypeId = 1 THEN 'GTC'
							WHEN DE.intOrderTypeId = 2 THEN 'Limit'
							WHEN DE.intOrderTypeId = 3 THEN 'Market'
							ELSE '' END) COLLATE Latin1_General_CI_AS
	, strDerivativeContractNumber = CASE WHEN ISNULL(contractH.intContractHeaderId, 0) <> 0 THEN contractH.strContractNumber + ' - ' + CAST(contractD.intContractSeq AS NVARCHAR(50)) ELSE NULL END COLLATE Latin1_General_CI_AS 
FROM tblRKFutOptTransaction DE
LEFT JOIN tblEMEntity AS e ON DE.intEntityId = e.intEntityId
LEFT JOIN tblEMEntity AS Trader ON DE.intTraderId = Trader.intEntityId
LEFT JOIN tblRKFuturesMonth AS FMonth ON DE.intFutureMonthId = FMonth.intFutureMonthId
LEFT JOIN tblRKFuturesMonth AS RMonth ON DE.intRollingMonthId = RMonth.intFutureMonthId
LEFT JOIN tblRKOptionsMonth AS OMonth ON DE.intOptionMonthId = OMonth.intOptionMonthId
LEFT JOIN tblCTBook AS book ON DE.intBookId = book.intBookId
LEFT JOIN tblCTSubBook AS subBook ON DE.intSubBookId = subBook.intSubBookId
LEFT JOIN tblRKBrokerageAccount AS BA ON DE.intBrokerageAccountId = BA.intBrokerageAccountId
LEFT JOIN tblRKFutureMarket AS FMarket ON DE.intFutureMarketId = FMarket.intFutureMarketId
LEFT JOIN tblICUnitMeasure AS UOM ON FMarket.intUnitMeasureId = UOM.intUnitMeasureId
LEFT JOIN tblICCommodity AS Com ON DE.intCommodityId = Com.intCommodityId
LEFT JOIN tblSMCompanyLocation AS Loc ON DE.intLocationId = Loc.intCompanyLocationId
LEFT JOIN tblCMBank AS Bank ON DE.intBankId = Bank.intBankId
LEFT JOIN vyuCMBankAccount AS BankAcct ON DE.intBankAccountId = BankAcct.intBankAccountId
LEFT JOIN tblSMCurrency AS Curr ON DE.intCurrencyId = Curr.intCurrencyID
LEFT JOIN tblSMCurrencyExchangeRateType AS CurEx ON DE.intCurrencyExchangeRateTypeId = CurEx.intCurrencyExchangeRateTypeId
LEFT JOIN tblRKAssignFuturesToContractSummary AS AD ON AD.intFutOptAssignedId = DE.intFutOptTransactionId
LEFT JOIN tblCTContractHeader AS ch ON ch.intContractHeaderId = AD.intContractHeaderId
LEFT JOIN tblCTContractDetail AS cd ON cd.intContractDetailId = AD.intContractDetailId
LEFT JOIN tblCMBank AS BuyBank ON DE.intBuyBankId = BuyBank.intBankId
LEFT JOIN vyuCMBankAccount AS BuyBankAcct ON DE.intBuyBankAccountId = BuyBankAcct.intBankAccountId
LEFT JOIN tblCMBankTransfer BT ON BT.intTransactionId = DE.intBankTransferId
LEFT JOIN tblRKFutOptTransaction ST ON ST.intFutOptTransactionId = DE.intOrigSliceTradeId
LEFT JOIN (
	SELECT intFutOptTransactionId
		, dblMaxOpenContract = MAX(dblOpenContract)
		, dblSumOpenContract = SUM(dblOpenContract)
	FROM vyuRKGetOpenContract
	GROUP BY intFutOptTransactionId
) GOC ON DE.intFutOptTransactionId = GOC.intFutOptTransactionId
OUTER APPLY (
	SELECT TOP 1 ftcs.intContractDetailId
	FROM tblRKAssignFuturesToContractSummary ftcs
	WHERE ftcs.intFutOptTransactionId = DE.intFutOptTransactionId
) hedgecontract
LEFT JOIN tblCTContractDetail hedgecontractdetail
	ON hedgecontract.intContractDetailId = hedgecontractdetail.intContractDetailId
LEFT JOIN tblCTContractHeader hedgecontractheader
	ON hedgecontractdetail.intContractHeaderId = hedgecontractheader.intContractHeaderId
OUTER APPLY (
	SELECT TOP 1 intScreenId FROM tblSMScreen 
	WHERE strModule = 'Risk Management' 
	AND strScreenName = 'Derivative Entry'
) approvalScreen
LEFT JOIN tblSMTransaction approval
	ON DE.intFutOptTransactionId = approval.intRecordId
	AND DE.intInstrumentTypeId = 4						-- OTC Forwards Only
	AND approval.intScreenId = approvalScreen.intScreenId
	AND approval.strApprovalStatus IN ('Waiting for Approval', 'Waiting for Submit', 'Approved')
LEFT JOIN tblCTContractHeader contractH
	ON contractH.intContractHeaderId = DE.intContractHeaderId
LEFT JOIN tblCTContractDetail contractD
	ON contractD.intContractDetailId = DE.intContractDetailId