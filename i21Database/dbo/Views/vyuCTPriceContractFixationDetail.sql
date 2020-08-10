CREATE VIEW [dbo].[vyuCTPriceContractFixationDetail]

AS
	
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
			GROUP BY PFD.intPriceFixationDetailId, BP.ysnPaid
		)

	SELECT	FD.intPriceFixationDetailId,
			FD.intConcurrencyId,
			FD.intPriceFixationId,
			FD.strTradeNo,
			FD.strOrder,
			FD.dtmFixationDate,
			FD.dblQuantity,
			FD.dblQuantityAppliedAndPriced,
			FD.dblLoadAppliedAndPriced,
			FD.dblLoadPriced,
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
			CD.dblRatio,
			FD.dblHedgeNoOfLots AS dblHedgeNoOfLots,
			FD.intDailyAveragePriceDetailId as  intDailyAveragePriceDetailId,
			ysnInvoiced = FDI.ysnInvoiced,
			strInvoiceIds = FDI.strInvoiceIds COLLATE Latin1_General_CI_AS,
			strInvoices = FDI.strInvoices COLLATE Latin1_General_CI_AS,
			ysnBilled = FDV.ysnBilled,
			strBillIds = FDV.strBillIds COLLATE Latin1_General_CI_AS,
			strBills = FDV.strBills COLLATE Latin1_General_CI_AS,
			ysnPaid = CASE WHEN CH.intContractTypeId = 1 THEN ISNULL(PV.ysnPaid,0) ELSE 0 END

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
	JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId			=	PF.intContractDetailId		LEFT
	JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId			=	CD.intContractHeaderId		LEFT 
	JOIN	fixationDetailInvoice		FDI ON	FDI.intPriceFixationDetailId	=	FD.intPriceFixationDetailId	LEFT 
	JOIN	fixationDetailVoucher		FDV ON	FDV.intPriceFixationDetailId	=	FD.intPriceFixationDetailId	LEFT 
	JOIN	paidVouchers				PV	ON	PV.intPriceFixationDetailId		=	FD.intPriceFixationDetailId