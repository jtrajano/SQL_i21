CREATE VIEW vyuLGLoadOpenContracts
AS
	SELECT 	CD.intContractDetailId, 
			CD.intContractHeaderId, 
			CD.intContractSeq, 
			CD.intItemId, 					IM.strDescription 			AS strItemDescription,
			CD.dblQuantity												AS dblDetailQuantity,
			CD.intUnitMeasureId, 			UM.strUnitMeasure,
			CD.intCompanyLocationId,
			IsNull(CD.dblBalance, 0) - IsNull(CD.dblScheduleQty, 0)		AS dblUnLoadedQuantity,
			
			CH.intPurchaseSale,
			CH.intEntityId,
			CH.intContractNumber,
			CH.dtmContractDate
	FROM tblCTContractDetail 		CD
	JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
	JOIN	tblICItem				IM	ON	IM.intItemId				=	CD.intItemId
	JOIN	tblICUnitMeasure		UM	ON	UM.intUnitMeasureId			=	CD.intUnitMeasureId

	WHERE (IsNull(CD.dblBalance, 0) - IsNull(CD.dblScheduleQty, 0)) > 0	
