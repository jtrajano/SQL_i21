CREATE	PROCEDURE [dbo].[uspCTLoadReassign]
		@intDonorId		INT,
		@intRecipientId	INT
AS
BEGIN
	--Detail
	SELECT	CH.intEntityId,			
			CD.intContractDetailId,	
			CD.intFutureMarketId,	
			CD.intFutureMonthId,	
			CD.intPriceItemUOMId AS intPriceUOMId,	
			CD.dblQuantity,			
			PD.dblQuantity dblPricedQty,			
			PF.dblLotsFixed AS  dblPricedLot,
			MA.strFutMarketName strMarketName,	
			MO.strFutureMonth AS strMonth,		
			CAST(SY.intHedgedLots AS NUMERIC(18,6)) AS dblHedgeLot,		
			SY.intHedgedLots * MA.dblContractSize AS dblHedgeQty,
			PM.strUnitMeasure AS strPriceUOM,		
			EY.strName AS strEntityName,				
			CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strContractSeq,
			CASE WHEN CD.intContractDetailId = @intDonorId THEN 'Donor' ELSE 'Recipient' END AS strType,
			CASE WHEN CH.intContractTypeId = 1 THEN PA.dblAllocatedQty ELSE SA.dblAllocatedQty END AS dblAllocatedQty,
			CAST(CASE WHEN ISNULL(BL.intCount,0) > 0 THEN 1 ELSE 0 END AS BIT) ysnVoucherExist,
			CAST(CASE WHEN ISNULL(ID.intCount,0) > 0 THEN 1 ELSE 0 END AS BIT) ysnInvoiceExist,
			CD.intItemUOMId intQtyUOMId,
			QM.strUnitMeasure AS strQtyUOM,
			QM.strUnitType,
			--Dummy--
			CAST(ROW_NUMBER() OVER (ORDER BY CD.intContractDetailId ASC) AS INT) * -1 AS intReassignDetailId,
			0 AS intReassignId,
			0 AS intConcurrencyId
			---------
			
	FROM	tblCTContractDetail	CD
	JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId	
	JOIn	tblEMEntity			EY	ON	EY.intEntityId			=	CH.intEntityId				LEFT
	JOIN	tblRKFutureMarket	MA	ON	MA.intFutureMarketId	=	CD.intFutureMarketId		LEFT
	JOIN	tblRKFuturesMonth	MO	ON	MO.intFutureMonthId		=	CD.intFutureMonthId			LEFT
	JOIN	tblICItemUOM		PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId		LEFT
	JOIN	tblICUnitMeasure	PM	ON	PM.intUnitMeasureId		=	PU.intUnitMeasureId			LEFT
	JOIN	tblICItemUOM		QU	ON	QU.intItemUOMId			=	CD.intItemUOMId				LEFT
	JOIN	tblICUnitMeasure	QM	ON	QM.intUnitMeasureId		=	QU.intUnitMeasureId			LEFT
	JOIN	tblCTPriceFixation	PF	ON	PF.intContractDetailId	=	CD.intContractDetailId		LEFT
	JOIN	(
				SELECT		intPriceFixationId,SUM(dblQuantity) dblQuantity 
				FROM		tblCTPriceFixationDetail
				GROUP BY	intPriceFixationId
			)					PD	ON	PD.intPriceFixationId	=	PF.intPriceFixationId		LEFT
	JOIN	(
				SELECT		intContractDetailId,SUM(intHedgedLots)intHedgedLots
				FROM		tblRKAssignFuturesToContractSummary	
				GROUP BY	intContractDetailId
			)					SY	ON	SY.intContractDetailId	=	CD.intContractDetailId		LEFT
	JOIN	(
				SELECT		intPContractDetailId,ISNULL(SUM(dblPAllocatedQty),0)  AS dblAllocatedQty
				FROM		tblLGAllocationDetail 
				Group By	intPContractDetailId
			)					PA	ON	PA.intPContractDetailId		=	CD.intContractDetailId	LEFT	
	JOIN	(
				SELECT		intSContractDetailId,ISNULL(SUM(dblSAllocatedQty),0)  AS dblAllocatedQty
				FROM		tblLGAllocationDetail 
				Group By	intSContractDetailId
			)					SA	ON	SA.intSContractDetailId		=	CD.intContractDetailId	LEFT
	JOIN	(
				SELECT	BD.intContractDetailId,COUNT(*) intCount
				FROM	tblAPBillDetail	BD
				JOIN	tblAPBill		BL	ON BL.intBillId	=	BD.intBillId
				WHERE	BD.intBillId	=	BL.intBillId AND 
						BL.intTransactionType <> 2
				GROUP	BY BD.intContractDetailId
			)					BL	ON	BL.intContractDetailId		=	CD.intContractDetailId	LEFT
	JOIN	(
				SELECT	AD.intContractDetailId,COUNT(*) intCount
				FROM	tblARInvoiceDetail	AD
				GROUP	BY AD.intContractDetailId
			)					ID	ON	ID.intContractDetailId		=	CD.intContractDetailId
	WHERE	CD.intContractDetailId	IN(@intDonorId,@intRecipientId)
	
	--Pricing

	SELECT	PD.intPriceFixationDetailId,
			PD.intFutureMarketId,
			PD.intFutureMonthId,
			PF.intFinalPriceUOMId intPriceUOMId,
			PD.dblFutures AS dblPrice,
			PD.dblNoOfLots AS dblLot,
			NULL AS dblReassign,
			MA.strFutMarketName strMarketName,	
			MO.strFutureMonth AS strMonth,	
			PD.strTradeNo,
			PM.strUnitMeasure strPriceUOM,
			PD.intFutOptTransactionId,

			--Dummy--
			CAST(ROW_NUMBER() OVER (ORDER BY PF.intContractDetailId ASC) AS INT) * -1 AS intReassignPricingId,
			0 AS intReassignId,
			0 AS intConcurrencyId
			---------

	FROM	tblCTPriceFixationDetail	PD
	JOIN	tblCTPriceFixation			PF	ON	PF.intPriceFixationId			=		PD.intPriceFixationId
	JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId			=		PD.intFutureMarketId	LEFT
	JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId				=		PD.intFutureMonthId		LEFT
	JOIN	tblICCommodityUnitMeasure	PU	ON	PU.intCommodityUnitMeasureId	=		PF.intFinalPriceUOMId	LEFT
	JOIN	tblICUnitMeasure			PM	ON	PM.intUnitMeasureId				=		PU.intUnitMeasureId	
	WHERE	PF.intContractDetailId	=	@intDonorId

	--Futures

	SELECT	SY.intAssignFuturesToContractSummaryId,
			SY.intFutOptTransactionId,
			FO.intFutureMarketId,
			FO.intFutureMonthId,
			MA.intUnitMeasureId AS intPriceUOMId,
			FO.dblPrice,
			SY.dblAssignedLots + SY.intHedgedLots dblLot,
			NULL AS dblReassign,
			MA.strFutMarketName strMarketName,	
			MO.strFutureMonth AS strMonth,	
			strInternalTradeNo,
			FO.strBuySell strTradeType,
			UM.strUnitMeasure strPriceUOM,
			PD.intPriceFixationDetailId,
			--Dummy--
			CAST(ROW_NUMBER() OVER (ORDER BY SY.intContractDetailId ASC) AS INT) * -1 AS intReassignFutureId,
			0 AS intReassignId,
			0 AS intConcurrencyId
			---------

	FROM	tblRKAssignFuturesToContractSummary	SY
	JOIN	tblRKFutOptTransaction				FO	ON	FO.intFutOptTransactionId	=	SY.intFutOptTransactionId
	JOIN	tblRKFutureMarket					MA	ON	MA.intFutureMarketId		=	FO.intFutureMarketId	
	JOIN	tblRKFuturesMonth					MO	ON	MO.intFutureMonthId			=	FO.intFutureMonthId			
	JOIN	tblICUnitMeasure					UM	ON	UM.intUnitMeasureId			=	MA.intUnitMeasureId		LEFT
	JOIN	tblCTPriceFixationDetail			PD	ON	PD.intFutOptTransactionId	=	SY.intFutOptTransactionId
	WHERE	SY.intContractDetailId	=	@intDonorId

	--Allocations

	SELECT	AD.intAllocationDetailId,
			intSContractDetailId	AS	intContractDetailId,
			IU.intItemUOMId			AS	intAllocationUOMId,
			IU.intItemUOMId			AS	intReassignUOMId,
			AD.dblSAllocatedQty		AS	dblAllocatedQty,
			AD.dblSAllocatedQty -	ISNULL(PL.dblPickedQty,0)	AS	dblOpenQty,
			NULL					AS	dblReassign,
			CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strContractSeq,
			UM.strUnitMeasure		AS	strReassignUOM,
			UM.strUnitMeasure		AS	strAllocationUOM,
			AD.intSUnitMeasureId	AS	intReassignUnitMeasureId,
			--Dummy--
			CAST(ROW_NUMBER() OVER (ORDER BY AD.intAllocationDetailId ASC) AS INT) * -1 AS intReassignAllocationId,
			0						AS	intReassignId,
			0						AS	intConcurrencyId
			---------

	FROM	tblLGAllocationDetail	AD
	JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId	=	AD.intSContractDetailId
	JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
	JOIN	tblICUnitMeasure		UM	ON	UM.intUnitMeasureId		=	AD.intSUnitMeasureId
	JOIN	tblICItemUOM			IU	ON	IU.intItemId			=	CD.intItemId			AND
											IU.intUnitMeasureId		=	UM.intUnitMeasureId		LEFT
	JOIN	(
				SELECT	AD.intSContractDetailId intContractDetailId,ISNULL(SUM(LD.dblSalePickedQty),0) dblPickedQty 
				FROM	tblLGPickLotDetail		LD
				JOIN	tblLGAllocationDetail	AD	ON	AD.intAllocationDetailId	=	LD.intAllocationDetailId
				GROUP BY AD.intSContractDetailId
			)	PL	ON	PL.intContractDetailId = CD.intContractDetailId
	WHERE	intPContractDetailId =	@intDonorId

	UNION ALL

	SELECT	AD.intAllocationDetailId,
			intPContractDetailId	AS	intContractDetailId,
			IU.intItemUOMId			AS	intAllocationUOMId,
			IU.intItemUOMId			AS	intReassignUOMId,
			AD.dblPAllocatedQty		AS	dblAllocatedQty,
			AD.dblPAllocatedQty	-	ISNULL(PL.dblPickedQty,0)	AS	dblOpenQty,
			NULL					AS	dblReassign,
			CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strContractSeq,
			UM.strUnitMeasure		AS	strReassignUOM,
			UM.strUnitMeasure		AS	strAllocationUOM,
			AD.intPUnitMeasureId	AS	intReassignUnitMeasureId,
			--Dummy--
			CAST(ROW_NUMBER() OVER (ORDER BY AD.intAllocationDetailId ASC) AS INT) * -1 AS intReassignAllocationId,
			0						AS	intReassignId,
			0						AS	intConcurrencyId
			---------

	FROM	tblLGAllocationDetail	AD
	JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId	=	AD.intPContractDetailId
	JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
	JOIN	tblICUnitMeasure		UM	ON	UM.intUnitMeasureId		=	AD.intPUnitMeasureId
	JOIN	tblICItemUOM			IU	ON	IU.intItemId			=	CD.intItemId			AND
											IU.intUnitMeasureId		=	UM.intUnitMeasureId		LEFT
	JOIN	(
				SELECT	AD.intPContractDetailId intContractDetailId,ISNULL(SUM(LD.dblLotPickedQty),0) dblPickedQty 
				FROM	tblLGPickLotDetail		LD
				JOIN	tblLGAllocationDetail	AD	ON	AD.intAllocationDetailId	=	LD.intAllocationDetailId
				GROUP BY AD.intPContractDetailId
			)						PL	ON	PL.intContractDetailId	=	CD.intContractDetailId
	WHERE	intSContractDetailId =	@intDonorId

	--Summary

	SELECT	CD.intContractDetailId,	
			CD.intItemUOMId AS intAllocationUOMId,
			QU.intUnitMeasureId AS intAllocationUnitMeasureId,
			CASE WHEN CH.intContractTypeId = 1 THEN PA.dblAllocatedQty ELSE SA.dblAllocatedQty END AS dblAllocation,			
			PF.dblLotsFixed AS dblPricedLot,
			CAST(SY.dblFuturesLot  AS NUMERIC(18,6)) AS dblFuturesLot,		
			CASE WHEN CD.intContractDetailId = @intDonorId THEN 'Donor' ELSE 'Recipient' END AS strType,
			CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strContractSeq,
			QM.strUnitMeasure AS strAllocationUOM,
			--Dummy--
			CAST(ROW_NUMBER() OVER (ORDER BY CD.intContractDetailId ASC) AS INT) * -1 AS intReassignSummaryId,
			0 AS intReassignId,
			0 AS intConcurrencyId
			---------
			
	FROM	tblCTContractDetail	CD
	JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId	
	JOIN	tblICItemUOM		QU	ON	QU.intItemUOMId			=	CD.intItemUOMId				LEFT
	JOIN	tblICUnitMeasure	QM	ON	QM.intUnitMeasureId		=	QU.intUnitMeasureId			LEFT
	JOIN	tblCTPriceFixation	PF	ON	PF.intContractDetailId	=	CD.intContractDetailId		LEFT
	JOIN	(
				SELECT		intPriceFixationId,SUM(dblQuantity) dblQuantity 
				FROM		tblCTPriceFixationDetail
				GROUP BY	intPriceFixationId
			)					PD	ON	PD.intPriceFixationId	=	PF.intPriceFixationId		LEFT
	JOIN	(
				SELECT		intContractDetailId,SUM(ISNULL(intHedgedLots,0) + ISNULL(dblAssignedLots,0))dblFuturesLot
				FROM		tblRKAssignFuturesToContractSummary	
				GROUP BY	intContractDetailId
			)					SY	ON	SY.intContractDetailId	=	CD.intContractDetailId		LEFT
	JOIN	(
				SELECT		intPContractDetailId,ISNULL(SUM(dblPAllocatedQty),0)  AS dblAllocatedQty
				FROM		tblLGAllocationDetail 
				Group By	intPContractDetailId
			)					PA	ON	PA.intPContractDetailId		=	CD.intContractDetailId	LEFT	
	JOIN	(
				SELECT		intSContractDetailId,ISNULL(SUM(dblSAllocatedQty),0)  AS dblAllocatedQty
				FROM		tblLGAllocationDetail 
				Group By	intSContractDetailId
			)					SA	ON	SA.intSContractDetailId		=	CD.intContractDetailId
	WHERE	CD.intContractDetailId	IN	(@intDonorId,@intRecipientId)
END