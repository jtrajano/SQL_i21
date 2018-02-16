CREATE VIEW [dbo].[vyuCTContractCostEnquiryHedge]
	
AS
	SELECT	o.intAssignFuturesToContractSummaryId,
			o.intContractDetailId,
			o.strInternalTradeNo,
			o.dtmTransactionDate,
			o.strFutMarketName,
			o.strFutureMonth,
			o.dblNoOfLots,
			o.dblLots,
			o.dblPrice,
			o.dblLatestPrice,
			o.dblGross,
			o.dblCommission,
			o.dblNet,
			o.dblDefaultCurrencyFactor,
			o.intCent,
			dblGross / intCent AS dblGrossImpact,
			dblNet / intCent AS dblNetImpact,
			dblGross * dblDefaultCurrencyFactor	AS  dblGrossImpactInDefCurrency,
			dblNet * dblDefaultCurrencyFactor		AS  dblNetImpactInDefCurrency,
			CASE WHEN o.dblLots < 0 THEN o.dblLots ELSE 0 END dblNegLots,
			CASE WHEN o.dblLots > 0 THEN o.dblLots ELSE 0 END dblPosLots
	FROM
	(
		SELECT	intAssignFuturesToContractSummaryId,
				intContractDetailId,
				strInternalTradeNo,	
				dtmTransactionDate,	
				strFutMarketName,	
				strFutureMonth,
				dblLots AS dblNoOfLots,
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
						ISNULL(SY.intContractDetailId,CD.intContractDetailId)	AS	intContractDetailId,
						FT.strInternalTradeNo,
						FT.dtmTransactionDate,
						MA.strFutMarketName,
						MO.strFutureMonth,
						CAST(ISNULL(SY.intHedgedLots,0) AS NUMERIC(18, 6))+ISNULL(SY.dblAssignedLots,0) 					AS	dblLots,
						FT.dblPrice,
						dbo.fnCTGetLastSettlementPrice(FT.intFutureMarketId,FT.intFutureMonthId)							AS	dblLatestPrice,
						dbo.fnCTGetBrokerageCommission(FT.intBrokerageAccountId,FT.intFutureMarketId,FT.dtmTransactionDate) AS	dblCommission,
						MA.dblContractSize,
						CASE WHEN FT.strBuySell = 'Sell' THEN -1 ELSE 1 END intProffitLoss,
						dbo.fnCTCalculateAmountBetweenCurrency(FT.intCurrencyId,null,1,1)									AS	dblDefaultCurrencyFactor,
						ISNULL(CY.intCent,1) AS intCent
				FROM	dbo.tblRKAssignFuturesToContractSummary SY
				JOIN	dbo.tblCTContractDetail					CD	ON	CD.intContractHeaderId		=	ISNULL(SY.intContractHeaderId, CD.intContractHeaderId)
																	AND	CD.intContractDetailId		=	ISNULL(SY.intContractDetailId, CD.intContractDetailId)
				JOIN	dbo.tblRKFutOptTransaction				FT	ON	FT.intFutOptTransactionId	=	SY.intFutOptTransactionId
				JOIN	dbo.tblRKFutureMarket					MA	ON	MA.intFutureMarketId		=	FT.intFutureMarketId
				JOIN	dbo.tblRKFuturesMonth					MO	ON	MO.intFutureMonthId			=	FT.intFutureMonthId
				JOIN	dbo.tblSMCurrency						CY	ON	CY.intCurrencyID			=	FT.intCurrencyId		
		)t
	)o
