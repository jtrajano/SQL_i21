CREATE VIEW [dbo].[vyuCTPriceContractDetailViewBU]

AS

SELECT	
			
			PD.strTradeNo,
			PD.strOrder,
			PD.dtmFixationDate,
			PD.dblQuantity			AS dblDtlQty,
			PD.[dblNoOfLots]		AS dblDtlNoOfLots,
			PD.dblFutures			AS dblDtlFutures,
			PD.dblBasis				AS dblDtlBasis,
			PD.dblCashPrice			AS dblDtlCashPrice,
			dblBalanceNoOfLots,
			PF.dblBasis,
			PF.strBook,
			PF.strCommodityDescription,
			PF.strContractNumber,
			PF.strCurrency,
			PF.strEntityName,
			PF.dtmEndDate,
			PF.strEntityContract,
			PD.dblFinalPrice		AS dblDtlFinalPrice,
			PF.strFutMarketName,
			PF.strFutureMonth,
			PF.ysnLoad,
			PF.strItemDescription,
			PF.strItemNo,
			PF.strItemShortName,
			PF.dblAppliedLoad,
			PF.dblLoadAppliedUnpriced,
			PF.dblLoadPriced,
			PF.dblLoadUnpriced,
			PF.strLocationName,
			PF.dblLotsFixed			AS dblLotsPrice,
			PF.strMainCurrency,
			PF.dblNoOfLots,
			PF.strPriceContractNo,
			PD.intPriceFixationDetailId,
			PF.intPriceFixationId,
			CM.strUnitMeasure		AS strPricingUOM,
			PF.strPricingType,
			PF.strContractType,
			PF.dblAppliedQty,
			PF.dblQuantityAppliedUnpriced,
			PF.dblQuantityPriced,
			PF.dblQuantityUnpriced,
			PD.dblQuantity,
			PF.intContractSeq,
			PF.dtmStartDate,
			PF.strStatus,
			PF.strSubBook,
			PF.strUOM
	FROM	tblCTPriceFixationDetail	PD	WITH (NOLOCK)
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
	LEFT	JOIN	vyuICGetCompactItem ICC ON ICC.intItemId = PF.intItemId

