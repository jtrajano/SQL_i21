CREATE VIEW [dbo].[vyuCTSearchPriceContractDetail]

AS 


	SELECT	PF.*,

			PD.intPriceFixationDetailId,
			PD.intConcurrencyId,
			PD.strTradeNo,
			PD.strOrder,
			PD.dtmFixationDate,
			PD.dblQuantity			AS dblDtlQty,
			PD.intQtyItemUOMId,
			PD.[dblNoOfLots]		AS dblDtlNoOfLots,
			PD.dblFixationPrice,
			PD.dblFutures			AS dblDtlFutures,
			PD.dblBasis				AS dblDtlBasis,
			PD.dblPolRefPrice,
			PD.dblPolPremium,
			PD.dblCashPrice			AS dblDtlCashPrice,
			PD.intPricingUOMId,
			PD.ysnHedge,
			PD.dblHedgePrice,
			PD.intHedgeFutureMonthId,
			PD.intBrokerId,
			PD.intBrokerageAccountId,
			PD.intFutOptTransactionId,
			PD.dblFinalPrice		AS dblDtlFinalPrice,
			PD.strNotes,

			EY.strName				AS strBroker,
			CM.strUnitMeasure		AS strPricingUOM,
			UM.strUnitMeasure		AS strQuantityUOM,
			BA.strAccountNumber,
			MA.strOptMarketName,
			REPLACE(MO.strFutureMonth,' ','('+MO.strSymbol+') ') AS strPricingMonth,
			REPLACE(HO.strFutureMonth,' ','('+HO.strSymbol+') ') AS strHedgeMonth,
			DP.dtmDate				AS dtmAveragePriceDate
	FROM	tblCTPriceFixationDetail	PD
	JOIN	vyuCTSearchPriceContract	PF	ON	PF.intPriceFixationId			=	PD.intPriceFixationId		LEFT
	JOIN	tblEMEntity					EY	ON	EY.intEntityId					=	PD.intBrokerId				LEFT
	JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	PD.intPricingUOMId			LEFT
	JOIN	tblICUnitMeasure			CM	ON	CM.intUnitMeasureId				=	CU.intUnitMeasureId			LEFT
	JOIN	tblICItemUOM				IU	ON	IU.intItemUOMId					=	PD.intQtyItemUOMId			LEFT
	JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId				=	IU.intUnitMeasureId			LEFT
	JOIN	tblRKBrokerageAccount		BA	ON	BA.intBrokerageAccountId		=	PD.intBrokerageAccountId	LEFT
	JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId			=	PD.intFutureMarketId		LEFT
	JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId				=	PD.intFutureMonthId			LEFT
	JOIN	tblRKFuturesMonth			HO	ON	HO.intFutureMonthId				=	PD.intHedgeFutureMonthId	LEFT
	JOIN	vyuRKGetDailyAveragePriceDetail DP ON DP.intDailyAveragePriceDetailId	=	PD.intDailyAveragePriceDetailId
