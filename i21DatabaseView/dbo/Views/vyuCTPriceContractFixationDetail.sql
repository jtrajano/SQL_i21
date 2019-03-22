CREATE VIEW [dbo].[vyuCTPriceContractFixationDetail]

AS

	SELECT	FD.intPriceFixationDetailId,
			FD.intConcurrencyId,
			FD.intPriceFixationId,
			FD.strTradeNo,
			FD.strOrder,
			FD.dtmFixationDate,
			FD.dblQuantity,
			FD.intQtyItemUOMId,
			FD.dblNoOfLots,
			FD.intFutureMarketId,
			FD.intFutureMonthId,
			FD.dblFixationPrice,
			FD.dblFutures,
			FD.dblBasis,
			FD.dblPolRefPrice,
			FD.dblPolPremium,
			FD.dblCashPrice,
			FD.intPricingUOMId,
			FD.ysnHedge,
			FD.ysnAA,
			FD.dblHedgePrice,
			FD.intHedgeFutureMonthId,
			FD.intBrokerId,
			FD.intBrokerageAccountId,
			FD.intFutOptTransactionId,
			FD.dblFinalPrice,
			FD.strNotes,

			PM.strUnitMeasure	AS strPricingUOM,
			CY.strCurrency		AS strHedgeCurrency,
			UM.strUnitMeasure	AS strHedgeUOM,
			REPLACE(MO.strFutureMonth,' ','('+MO.strSymbol+') ') AS strHedgeMonth,
			EY.strName			AS strBroker,
			BA.strAccountNumber AS strBrokerAccount,
			TR.ysnFreezed,
			CD.dblRatio

	FROM	tblCTPriceFixationDetail	FD
	JOIN	tblCTPriceFixation			PF	ON	PF.intPriceFixationId			=	FD.intPriceFixationId
	JOIN	tblICCommodityUnitMeasure	PU	ON	PU.intCommodityUnitMeasureId	=	FD.intPricingUOMId
	JOIN	tblICUnitMeasure			PM	ON	PM.intUnitMeasureId				=	PU.intUnitMeasureId			LEFT
	JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId			=	FD.intFutureMarketId		LEFT
	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=	MA.intCurrencyId			LEFT
	JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId				=	MA.intUnitMeasureId			LEFT
	JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId				=	FD.intHedgeFutureMonthId	LEFT
	JOIN	tblEMEntity					EY	ON	EY.intEntityId					=	FD.intBrokerId				LEFT
	JOIN	tblRKBrokerageAccount		BA	ON	BA.intBrokerageAccountId		=	FD.intBrokerageAccountId	LEFT
	JOIN	tblRKFutOptTransaction		TR	ON	TR.intFutOptTransactionId		=	FD.intFutOptTransactionId	LEFT
	JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId			=	PF.intContractDetailId