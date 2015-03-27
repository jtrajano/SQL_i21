CREATE VIEW vyuLGShippingInstructionOpenContracts
AS
	SELECT 	CD.intContractDetailId, 
			CD.intContractHeaderId, 
			CD.intContractSeq, 
			CD.intItemId, 					IM.strDescription 			AS strItemDescription,
			CD.dblQuantity												AS dblDetailQuantity,
			CD.intUnitMeasureId, 			UM.strUnitMeasure,
			CD.dblQuantity - IsNull((SELECT SUM (SI.dblQuantity) from tblLGShippingInstructionContractQty SI Group By SI.intContractDetailId Having CD.intContractDetailId = SI.intContractDetailId), 0) AS dblUnShippedQuantity,
			
			CH.intPurchaseSale,
			CH.intEntityId,
			CH.intContractNumber,
			CH.dtmContractDate
	FROM tblCTContractDetail 		CD
	JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
	JOIN	tblICItem				IM	ON	IM.intItemId				=	CD.intItemId
	JOIN	tblICUnitMeasure		UM	ON	UM.intUnitMeasureId			=	CD.intUnitMeasureId

	WHERE (CD.dblQuantity - IsNull((select sum (SI.dblQuantity) from tblLGShippingInstructionContractQty SI Group By SI.intContractDetailId Having CD.intContractDetailId = SI.intContractDetailId), 0)) > 0	
