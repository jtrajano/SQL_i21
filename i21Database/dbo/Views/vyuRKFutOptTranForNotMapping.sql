﻿CREATE VIEW vyuRKFutOptTranForNotMapping

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
						WHEN DE.intInstrumentTypeId = 3 THEN 'Currency Contract' END COLLATE Latin1_General_CI_AS
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
										OR intFutOptTransactionId IN (SELECT intFutOptTransactionId FROM tblRKAssignFuturesToContractSummary WHERE (ISNULL(dblAssignedLotsToSContract,0) <> 0 OR ISNULL(dblAssignedLotsToPContract,0) <>  0)))
									AND intFutOptTransactionId = DE.intFutOptTransactionId), 0) AS BIT)
	, strHedgeType = CASE WHEN PFD.intPriceFixationId IS NOT NULL THEN 'Price Contract'
							WHEN CF.intContractFuturesId IS NOT NULL THEN 'Contract Futures'
							ELSE NULL END COLLATE Latin1_General_CI_AS
	, intHedgeContractId = CASE WHEN PF.intPriceContractId IS NOT NULL THEN PF.intPriceContractId
							WHEN CF.intContractFuturesId IS NOT NULL THEN CFHeader.intContractHeaderId
							ELSE NULL END
	, strHedgeContract = CASE WHEN PF.intPriceContractId IS NOT NULL THEN PriceHeader.strContractNumber + ISNULL('-' + CAST(PriceDetail.intContractSeq AS NVARCHAR(10)), '')
							WHEN CF.intContractFuturesId IS NOT NULL THEN CFHeader.strContractNumber + ISNULL('-' + CAST(CFDetail.intContractSeq AS NVARCHAR(10)), '')
							ELSE NULL END COLLATE Latin1_General_CI_AS
	, dblAvailableContract = ISNULL(DE.dblPContractBalanceLots, 0.00)
	, ysnSlicedTrade = ISNULL(DE.ysnSlicedTrade, CAST(0 AS BIT))
	, DE.intOrigSliceTradeId
	, strOriginalTradeNo = ST.strInternalTradeNo
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
LEFT JOIN tblCTPriceFixationDetail PFD ON PFD.intFutOptTransactionId = DE.intFutOptTransactionId
LEFT JOIN tblCTPriceFixation PF ON PF.intPriceFixationId = PFD.intPriceFixationId
LEFT JOIN tblCTContractDetail PriceDetail ON PriceDetail.intContractDetailId = PF.intContractDetailId
LEFT JOIN tblCTContractHeader PriceHeader ON PriceHeader.intContractHeaderId = PF.intContractHeaderId
LEFT JOIN tblCTContractFutures CF ON CF.intFutOptTransactionId = DE.intFutOptTransactionId
LEFT JOIN tblCTContractDetail CFDetail ON CFDetail.intContractDetailId = CF.intContractDetailId
LEFT JOIN tblCTContractHeader CFHeader ON CFHeader.intContractHeaderId = CFDetail.intContractHeaderId
LEFT JOIN tblRKFutOptTransaction ST ON ST.intFutOptTransactionId = DE.intOrigSliceTradeId
LEFT JOIN (
	SELECT intFutOptTransactionId
		, dblMaxOpenContract = MAX(dblOpenContract)
		, dblSumOpenContract = SUM(dblOpenContract)
	FROM vyuRKGetOpenContract
	GROUP BY intFutOptTransactionId
) GOC ON DE.intFutOptTransactionId = GOC.intFutOptTransactionId