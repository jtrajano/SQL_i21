CREATE PROCEDURE [dbo].[uspCTLoadPriceContractFixationDetail]
	
	@intPriceFixationId INT
	
AS

BEGIN TRY
	
	DECLARE	@ErrMsg	NVARCHAR(MAX);
	
	with fixationDetailInvoice as (
		select
		a.intPriceFixationDetailId
		,ysnInvoiced = (case when count(a.intInvoiceId) > 0 then convert(bit,1) else convert(bit,0) end)
		,strInvoiceIds = 
			STUFF(
					(
						SELECT  ',' +  convert(nvarchar(20),c.intInvoiceId)
						from tblCTPriceFixationDetailAPAR c
						where c.intPriceFixationDetailId = a.intPriceFixationDetailId
						FOR xml path('')
					)
				, 1
				, 1
				, ''
			)
		,strInvoices = 
			STUFF(
					(
						SELECT  ', ' + b.strInvoiceNumber
						FROM tblARInvoice b
						WHERE b.intInvoiceId in (select c.intInvoiceId from tblCTPriceFixationDetailAPAR c where c.intPriceFixationDetailId = a.intPriceFixationDetailId)
						FOR xml path('')
					)
				, 1
				, 1
				, ''
			)
		from tblCTPriceFixationDetailAPAR a
		where a.intInvoiceId is not null group by a.intPriceFixationDetailId			
		),
	fixationDetailVoucher as (
		select
		a.intPriceFixationDetailId
		,ysnBilled = (case when count(a.intBillId) > 0 then convert(bit,1) else convert(bit,0) end)
		,strBillIds = 
			STUFF(
					(
						SELECT  ',' +  convert(nvarchar(20),c.intBillId)
						from tblCTPriceFixationDetailAPAR c
						where c.intPriceFixationDetailId = a.intPriceFixationDetailId
						FOR xml path('')
					)
				, 1
				, 1
				, ''
			)
		,strBills = 
			STUFF(
					(
						SELECT  ', ' + b.strBillId
						FROM tblAPBill b
						WHERE b.intBillId in (select c.intBillId from tblCTPriceFixationDetailAPAR c where c.intPriceFixationDetailId = a.intPriceFixationDetailId)
						FOR xml path('')
					)
				, 1
				, 1
				, ''
			)
		from tblCTPriceFixationDetailAPAR a
		where a.intBillId is not null group by a.intPriceFixationDetailId
		),			
		paidVouchers as (
			SELECT PFD.intPriceFixationDetailId, BP.ysnPaid
			FROM tblCTPriceFixationDetail PFD
			INNER JOIN tblCTPriceFixationDetailAPAR APAR ON PFD.intPriceFixationDetailId = APAR.intPriceFixationDetailId AND APAR.intBillId IS NOT NULL
			INNER JOIN vyuAPBillPayment BP ON APAR.intBillId = BP.intBillId
			WHERE PFD.intPriceFixationId = @intPriceFixationId
			GROUP BY PFD.intPriceFixationDetailId, BP.ysnPaid
		)

	SELECT	FD.*,

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
			TR.intFutOptTransactionHeaderId,
			ysnInvoiced = FDI.ysnInvoiced,
			strInvoiceIds = FDI.strInvoiceIds,
			strInvoices = FDI.strInvoices,
			ysnBilled = FDV.ysnBilled,
			strBillIds = FDV.strBillIds,
			strBills = FDV.strBills,
			strEditErrorMessage = dbo.fnCTGetPricingDetailVoucherInvoice(FD.intPriceFixationDetailId),
			ysnPaid = CAST((CASE WHEN CH.intContractTypeId = 1 THEN ISNULL(PV.ysnPaid,0) ELSE 0 END) AS BIT)

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
	JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId			=	CD.intContractHeaderId		LEFT 
	JOIN	fixationDetailInvoice		FDI ON	FDI.intPriceFixationDetailId	=	FD.intPriceFixationDetailId	LEFT 
	JOIN	fixationDetailVoucher		FDV ON	FDV.intPriceFixationDetailId	=	FD.intPriceFixationDetailId	LEFT 
	JOIN	paidVouchers				PV	ON	PV.intPriceFixationDetailId		=	FD.intPriceFixationDetailId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH