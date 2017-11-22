CREATE VIEW [dbo].[vyuCTSequenceCombo]

AS

	SELECT	CD.intContractDetailId,
			CD.intContractSeq,
			IM.strItemNo,
			CH.strContractNumber + ' - ' +LTRIM(CD.intContractSeq)	AS	strSequenceNumber,	
			CH.strContractNumber,
			CH.intEntityId,
			CH.intCommodityId,
			CH.intContractTypeId,

			CO.strCommodityCode,

			CD.intItemId,
			CD.intCompanyLocationId,
			CD.intContractStatusId,

			CL.strLocationName,
			QM.strUnitMeasure AS strItemUOM,
			ISNULL(CD.dblQuantity,0) - ISNULL(PA.dblAllocatedQty,0) - ISNULL(SA.dblAllocatedQty,0)							AS	dblUnallocatedQty,
			ISNULL(PA.intAllocationUOMId,SA.intAllocationUOMId)																AS	intAllocationUOMId,
			ISNULL(CAST(ISNULL(PF.[dblTotalLots] - ISNULL(PF.[dblLotsFixed],0),CD.dblNoOfLots)	AS NUMERIC(18, 6)),0)		AS	dblUnpricedLots,
			ISNULL(CAST(ISNULL(PF.[dblTotalLots] - ISNULL(PF.intLotsHedged,0),CD.dblNoOfLots)	AS NUMERIC(18, 6)),0)		AS	dblUnhedgedLots

	FROM	tblCTContractDetail		CD	
	JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId	LEFT
	JOIN	tblICItem				IM	ON	IM.intItemId			=	CD.intItemId			LEFT
	JOIN	tblSMCompanyLocation	CL	ON	CL.intCompanyLocationId	=	CD.intCompanyLocationId	LEFT
	JOIN	tblICCommodity			CO	ON	CO.intCommodityId		=	CH.intCommodityId		LEFT
	JOIN	tblICItemUOM			QU	ON	QU.intItemUOMId			=	CD.intItemUOMId			LEFT
	JOIN	tblICUnitMeasure		QM	ON	QM.intUnitMeasureId		=	QU.intUnitMeasureId		LEFT
	JOIN	tblCTPriceFixation		PF	ON	PF.intContractDetailId	=	CD.intContractDetailId	LEFT
	JOIN	(
				SELECT		intPContractDetailId,ISNULL(SUM(dblPAllocatedQty),0)  AS dblAllocatedQty,MIN(intPUnitMeasureId) intAllocationUOMId
				FROM		tblLGAllocationDetail 
				Group By	intPContractDetailId
			)					PA	ON	PA.intPContractDetailId		=	CD.intContractDetailId	LEFT	
	JOIN	(
				SELECT		intSContractDetailId,ISNULL(SUM(dblSAllocatedQty),0)  AS dblAllocatedQty,MIN(intPUnitMeasureId) intAllocationUOMId
				FROM		tblLGAllocationDetail 
				Group By	intSContractDetailId
			)					SA	ON	SA.intSContractDetailId		=	CD.intContractDetailId