CREATE VIEW [dbo].[vyuCTContractCostEnquiryHedge]
	
AS
	SELECT	*,
			dblGross / intCent AS dblGrossImpact,
			dblNet / intCent AS dblNetImpact,
			dblGross * dblDefaultCurrencyFactor	AS  dblGrossImpactInDefCurrency,
			dblNet * dblDefaultCurrencyFactor		AS  dblNetImpactInDefCurrency
	FROM
	(
		SELECT	intAssignFuturesToContractSummaryId,
				intContractDetailId,
				strInternalTradeNo,	
				dtmTransactionDate,	
				strFutMarketName,	
				strFutureMonth,
				dblLots * intProffitLoss dblLots,	
				dblPrice dblPrice,	
				dblLatestPrice,	
				dblContractSize * dblLots * (dblLatestPrice - dblPrice) * intProffitLoss AS dblGross,
				dblLots * dblCommission / intCent AS dblCommission,
				((dblContractSize * dblLots * (dblLatestPrice - dblPrice ))- (dblLots *  ISNULL(dblCommission,0)))  * intProffitLoss AS dblNet,
				dblDefaultCurrencyFactor,
				intCent
		FROM
		(
				SELECT	SY.intAssignFuturesToContractSummaryId,
						SY.intContractDetailId,
						FT.strInternalTradeNo,
						FT.dtmTransactionDate,
						MA.strFutMarketName,
						MO.strFutureMonth,
						CAST(ISNULL(SY.intHedgedLots,0) AS NUMERIC(18,2))+ISNULL(SY.dblAssignedLots,0) 						AS	dblLots,
						FT.dblPrice,
						dbo.fnCTGetLastSettlementPrice(FT.intFutureMarketId,FT.intFutureMonthId)							AS	dblLatestPrice,
						dbo.fnCTGetBrokerageCommission(FT.intBrokerageAccountId,FT.intFutureMarketId,FT.dtmTransactionDate) AS	dblCommission,
						MA.dblContractSize,
						CASE WHEN FT.strBuySell = 'Sell' THEN -1 ELSE 1 END intProffitLoss,
						dbo.fnCTCalculateAmountBetweenCurrency(FT.intCurrencyId,null,1,1)									AS	dblDefaultCurrencyFactor,
						ISNULL(CY.intCent,1) AS intCent
				FROM	tblRKAssignFuturesToContractSummary SY
				JOIN	tblRKFutOptTransaction				FT	ON	FT.intFutOptTransactionId	=	SY.intFutOptTransactionId
				JOIN	tblRKFutureMarket					MA	ON	MA.intFutureMarketId		=	FT.intFutureMarketId
				JOIN	tblRKFuturesMonth					MO	ON	MO.intFutureMonthId			=	FT.intFutureMonthId
				JOIN	tblSMCurrency						CY	ON	CY.intCurrencyID			=	FT.intCurrencyId
		)t
	)o
