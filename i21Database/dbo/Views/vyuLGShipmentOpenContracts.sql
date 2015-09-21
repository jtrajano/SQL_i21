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
			CD.strContractNumber,
			CD.dtmContractDate,
			CD.intCompanyLocationId,
			CD.intCommodityId,
			CD.intPositionId,
			CD.intItemUOMId,
			CD.ysnAllowedToShow,
			CD.intLoadingPortId,
			CD.intDestinationPortId,
			CD.intDestinationCityId,
			LoadingPort.strCity as strOriginPort,
			DestPort.strCity as strDestinationPort,
			DestCity.strCity as strDestinationCity,
			CD.strPackingDescription,
			CD.intShippingLineId as intShippingLineEntityId,
			CD.intNumberOfContainers,
			CD.intContainerTypeId,
			CD.strVessel

	FROM 	vyuCTContractDetailView 		CD
	LEFT JOIN tblSMCity LoadingPort ON LoadingPort.intCityId = CD.intLoadingPortId
	LEFT JOIN tblSMCity DestPort ON DestPort.intCityId = CD.intDestinationPortId
	LEFT JOIN tblSMCity DestCity ON DestCity.intCityId = CD.intDestinationCityId
	WHERE (CD.dblDetailQuantity - IsNull((SELECT SUM (S.dblQuantity) from tblLGShipmentContractQty S Group By S.intContractDetailId Having CD.intContractDetailId = S.intContractDetailId), 0)) > 0 AND 
			CD.intContractTypeId = 1
