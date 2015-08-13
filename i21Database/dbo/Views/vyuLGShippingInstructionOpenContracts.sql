CREATE VIEW vyuLGShippingInstructionOpenContracts
AS
	SELECT 	CD.intContractDetailId, 
			CD.intContractHeaderId, 
			CD.intContractSeq, 
			CD.intItemId,
			CD.strItemDescription,
			CD.dblDetailQuantity,
			CD.intUnitMeasureId,
			CD.strItemUOM as strUnitMeasure,
			CD.dblDetailQuantity - IsNull((SELECT SUM (SI.dblQuantity) from tblLGShippingInstructionContractQty SI Group By SI.intContractDetailId Having CD.intContractDetailId = SI.intContractDetailId), 0) AS dblUnShippedQuantity,
			
			CD.intContractTypeId AS intPurchaseSale,
			CD.intEntityId,
			CD.intContractNumber,
			CD.dtmContractDate,
			CD.ysnAllowedToShow
	FROM vyuCTContractDetailView 		CD
	WHERE (CD.dblDetailQuantity - IsNull((select sum (SI.dblQuantity) from tblLGShippingInstructionContractQty SI Group By SI.intContractDetailId Having CD.intContractDetailId = SI.intContractDetailId), 0)) > 0	
