CREATE VIEW vyuLGLoadOpenContracts
AS
	SELECT 	CD.intContractDetailId, 
			CD.intContractHeaderId, 
			CD.intContractSeq, 
			CD.intItemId, 					IM.strDescription 			AS strItemDescription,
			CD.dblQuantity												AS dblDetailQuantity,
			CD.intUnitMeasureId, 			UM.strUnitMeasure,
			CD.dblQuantity - IsNull((SELECT SUM (LD.dblQuantity) from tblLGLoad LD Group By LD.intContractDetailId Having CD.intContractDetailId = LD.intContractDetailId), 0) AS dblUnLoadedQuantity,
			
			CH.intPurchaseSale,
			CH.intEntityId,
			CH.intContractNumber,
			CH.dtmContractDate
	FROM tblCTContractDetail 		CD
	JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
	JOIN	tblICItem				IM	ON	IM.intItemId				=	CD.intItemId
	JOIN	tblICUnitMeasure		UM	ON	UM.intUnitMeasureId			=	CD.intUnitMeasureId

	WHERE (CD.dblQuantity - IsNull((select sum (LD.dblQuantity) from tblLGLoad LD Group By LD.intContractDetailId Having CD.intContractDetailId = LD.intContractDetailId), 0)) > 0	
