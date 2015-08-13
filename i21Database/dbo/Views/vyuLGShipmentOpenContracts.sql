CREATE VIEW vyuLGShipmentOpenContracts
AS
	SELECT 	CD.intContractDetailId, 
			CD.intContractHeaderId, 
			CD.intContractSeq, 
			CD.intItemId, 					
			CD.strItemDescription,
			CD.dblDetailQuantity,
			CD.intUnitMeasureId,
			CD.strItemUOM as strUnitMeasure,
			CD.dblDetailQuantity - IsNull((SELECT SUM (S.dblQuantity) from tblLGShipmentContractQty S Group By S.intContractDetailId Having CD.intContractDetailId = S.intContractDetailId), 0) AS dblUnShippedQuantity,
			
			CD.intContractTypeId as intPurchaseSale,
			CD.intEntityId,
			CD.intContractNumber,
			CD.dtmContractDate,
			CD.intCompanyLocationId,
			CD.intCommodityId,
			CD.intPositionId,
			CD.intItemUOMId,
			CD.ysnAllowedToShow
	FROM 	vyuCTContractDetailView 		CD
	WHERE (CD.dblDetailQuantity - IsNull((SELECT SUM (S.dblQuantity) from tblLGShipmentContractQty S Group By S.intContractDetailId Having CD.intContractDetailId = S.intContractDetailId), 0)) > 0 AND 
			CD.intContractTypeId = 1
