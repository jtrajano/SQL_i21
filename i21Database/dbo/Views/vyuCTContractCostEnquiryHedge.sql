CREATE VIEW [dbo].[vyuCTContractCostEnquiryHedge]
	
AS

	SELECT	intAssignFuturesToContractSummaryId,
			intContractDetailId,
			strInternalTradeNo,	
			dtmTransactionDate,	
			strFutMarketName,	
			strFutureMonth,
			dblLots,	
			dblPrice,	
			dblLatestPrice,	
			dblLatestPrice - dblPrice AS dblGrossImpact,
			dblCommission,
			dblLatestPrice - dblPrice - dblCommission AS dblNetImpact
	FROM
	(
			SELECT	SY.intAssignFuturesToContractSummaryId,
					SY.intContractDetailId,
					FT.strInternalTradeNo,
					FT.dtmTransactionDate,
					MA.strFutMarketName,
					MO.strFutureMonth,
					CAST(ISNULL(SY.intHedgedLots,SY.dblAssignedLots) AS NUMERIC(18,2))									AS dblLots,
					FT.dblPrice,
					dbo.fnCTGetLastSettlementPrice(FT.intFutureMarketId,FT.intFutureMonthId)							AS dblLatestPrice,
					dbo.fnCTGetBrokerageCommission(FT.intBrokerageAccountId,FT.intFutureMarketId,FT.dtmTransactionDate) AS dblCommission
			FROM	tblRKAssignFuturesToContractSummary SY
			JOIN	tblRKFutOptTransaction				FT	ON	FT.intFutOptTransactionId	=	SY.intFutOptTransactionId
			JOIN	tblRKFutureMarket					MA	ON	MA.intFutureMarketId		=	FT.intFutureMarketId
			JOIN	tblRKFuturesMonth					MO	ON	MO.intFutureMonthId			=	FT.intFutureMonthId
	)t

