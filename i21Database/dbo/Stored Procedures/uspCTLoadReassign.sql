﻿CREATE	PROCEDURE [dbo].[uspCTLoadReassign]
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
			CAST(PF.intLotsFixed AS NUMERIC(18,6)) dblPricedLot,
			MA.strFutMarketName strMarketName,	
			MO.strFutureMonth AS strMonth,		
			CAST(SY.intHedgedLots AS NUMERIC(18,6)) AS dblHedgeLot,		
			SY.intHedgedLots * MA.dblContractSize AS dblHedgeQty,
			PM.strUnitMeasure AS strPriceUOM,		
			EY.strName AS strEntityName,				
			CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strContractSeq,
			CASE WHEN CD.intContractDetailId = @intDonorId THEN 'Donor' ELSE 'Recipient' END AS strType,
			CASE WHEN CH.intContractTypeId = 1 THEN PA.dblAllocatedQty ELSE SA.dblAllocatedQty END AS dblAllocatedQty,
			
			--Dummy--
			CAST(ROW_NUMBER() OVER (ORDER BY CD.intContractDetailId ASC) AS INT) * -1 AS intReassignDetailId,
			0 AS intReassignId,
			0 AS intConcurrencyId
			---------
			
	FROM	tblCTContractDetail	CD
	JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId	
	JOIn	tblEntity			EY	ON	EY.intEntityId			=	CH.intEntityId				LEFT
	JOIN	tblRKFutureMarket	MA	ON	MA.intFutureMarketId	=	CD.intFutureMarketId		LEFT
	JOIN	tblRKFuturesMonth	MO	ON	MO.intFutureMonthId		=	CD.intFutureMonthId			LEFT
	JOIN	tblICItemUOM		PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId		LEFT
	JOIN	tblICUnitMeasure	PM	ON	PM.intUnitMeasureId		=	PU.intUnitMeasureId			LEFT
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
			)					SA	ON	SA.intSContractDetailId		=	CD.intContractDetailId
	WHERE	CD.intContractDetailId	IN(@intDonorId,@intRecipientId)
	
	--Pricing

	SELECT	PD.intPriceFixationDetailId,
			PD.intFutureMarketId,
			PD.intFutureMonthId,
			PF.intFinalPriceUOMId intPriceUOMId,
			PD.dblFutures AS dblPrice,
			CAST(PD.intNoOfLots AS NUMERIC(18,6)) dblLot,
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

	SELECT	SY.intFutOptTransactionId,
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
END