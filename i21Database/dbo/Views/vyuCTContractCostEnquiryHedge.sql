CREATE VIEW [dbo].[vyuCTContractCostEnquiryHedge]
	
AS

	SELECT	intAssignFuturesToContractSummaryId,
			intContractDetailId,
			strInternalTradeNo,	
			dtmTransactionDate,	
			strFutMarketName,	
			strFutureMonth,
			dblLots * intProffitLoss dblLots,	
			dblPrice dblPrice,	
			dblLatestPrice,	
			dblContractSize * dblLots * (dblLatestPrice - dblPrice) * intProffitLoss AS dblGrossImpact,
			dblLots * dblCommission dblCommission,
			((dblContractSize * dblLots * (dblLatestPrice - dblPrice ))- (dblLots * dblCommission))  * intProffitLoss AS dblNetImpact
	FROM
	(
			SELECT	SY.intAssignFuturesToContractSummaryId,
					SY.intContractDetailId,
					FT.strInternalTradeNo,
					FT.dtmTransactionDate,
					MA.strFutMarketName,
					MO.strFutureMonth,
					CAST(ISNULL(SY.intHedgedLots,0) AS NUMERIC(18,2))+ISNULL(SY.dblAssignedLots,0) 						AS dblLots,
					FT.dblPrice,
					dbo.fnCTGetLastSettlementPrice(FT.intFutureMarketId,FT.intFutureMonthId)							AS dblLatestPrice,
					dbo.fnCTGetBrokerageCommission(FT.intBrokerageAccountId,FT.intFutureMarketId,FT.dtmTransactionDate) AS dblCommission,
					MA.dblContractSize,
					CASE WHEN FT.strBuySell = 'Sell' THEN -1 ELSE 1 END intProffitLoss
			FROM	tblRKAssignFuturesToContractSummary SY
			JOIN	tblRKFutOptTransaction				FT	ON	FT.intFutOptTransactionId	=	SY.intFutOptTransactionId
			JOIN	tblRKFutureMarket					MA	ON	MA.intFutureMarketId		=	FT.intFutureMarketId
			JOIN	tblRKFuturesMonth					MO	ON	MO.intFutureMonthId			=	FT.intFutureMonthId
	)t

