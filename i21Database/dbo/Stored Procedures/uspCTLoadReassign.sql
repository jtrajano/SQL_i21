CREATE	PROCEDURE [dbo].[uspCTLoadReassign]
		@intDonorId		INT,
		@intRecipientId	INT
AS
BEGIN

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
	JOIn	tblRKFutureMarket	MA	ON	MA.intFutureMarketId	=	CD.intFutureMarketId		LEFT
	JOIn	tblRKFuturesMonth	MO	ON	MO.intFutureMonthId		=	CD.intFutureMonthId			LEFT
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
	
END