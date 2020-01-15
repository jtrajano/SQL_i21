CREATE PROCEDURE [dbo].[uspCTLoadPriceContractFixationDetail]
	
	@intPriceFixationId INT
	
AS

BEGIN TRY
	
	DECLARE	@ErrMsg	NVARCHAR(MAX)

	SELECT	FD.*,
			Voucher.strBillId,
			Voucher.ysnPaid,

			PM.strUnitMeasure	AS strPricingUOM,
			strHedgeCurrency = case when FD.ysnHedge = 1 then CY.strCurrency else null end,
			strHedgeUOM = case when FD.ysnHedge = 1 then UM.strUnitMeasure	else null end,
			strHedgeMonth = case when FD.ysnHedge = 1 then REPLACE(MO.strFutureMonth,' ','('+MO.strSymbol+') ') else null end,
			strBroker = case when FD.ysnHedge = 1 then EY.strName else  null end,
			strBrokerAccount = case when FD.ysnHedge = 1 then BA.strAccountNumber else null end,
			TR.ysnFreezed,
			CD.dblRatio,
			dblAppliedQty = CASE
								WHEN	CH.ysnLoad = 1
								THEN	ISNULL(CD.intNoOfLoad,0)	-	ISNULL(CD.dblBalanceLoad,0)
								ELSE	ISNULL(CD.dblQuantity,0)	-	ISNULL(CD.dblBalance,0)												
							END,
			TR.strInternalTradeNo,
			TR.intFutOptTransactionHeaderId

	FROM	tblCTPriceFixationDetail	FD
	JOIN	tblCTPriceFixation			PF	ON	PF.intPriceFixationId			=	FD.intPriceFixationId
											AND	FD.intPriceFixationId			=	@intPriceFixationId
	JOIN	tblICCommodityUnitMeasure	PU	ON	PU.intCommodityUnitMeasureId	=	FD.intPricingUOMId
	JOIN	tblICUnitMeasure			PM	ON	PM.intUnitMeasureId				=	PU.intUnitMeasureId			LEFT
	JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId			=	FD.intFutureMarketId		LEFT
	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=	MA.intCurrencyId			LEFT
	JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId				=	MA.intUnitMeasureId			LEFT
	JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId				=	FD.intHedgeFutureMonthId	LEFT
	JOIN	tblEMEntity					EY	ON	EY.intEntityId					=	FD.intBrokerId				LEFT
	JOIN	tblRKBrokerageAccount		BA	ON	BA.intBrokerageAccountId		=	FD.intBrokerageAccountId	LEFT
	JOIN	tblRKFutOptTransaction		TR	ON	TR.intFutOptTransactionId		=	FD.intFutOptTransactionId	LEFT
	JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId			=	PF.intContractDetailId		LEFT
	JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId			=	CD.intContractHeaderId		OUTER
	APPLY	dbo.fnCTGetVoucherDetail('fixation', FD.intPriceFixationDetailId) Voucher

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH