CREATE VIEW vyuLGShipmentOpenContracts
AS
	SELECT * FROM (
		SELECT 	CD.intContractDetailId, 
			CD.intContractHeaderId, 
			CD.strContractNumber,
			CD.intContractSeq, 
			CD.intItemId, 					
			CD.strItemDescription,
			CD.dblDetailQuantity,
			CD.intUnitMeasureId,
			CD.strItemUOM as strUnitMeasure,
			CD.dblDetailQuantity - 
				IsNull((SELECT SUM (S.dblQuantity) 
						from tblLGShipmentContractQty S Group By S.intContractDetailId Having CD.intContractDetailId = S.intContractDetailId), 0) +
				IsNull((SELECT SUM(S.dblQuantity)
						from tblLGShipmentBLContainerContract S 
						LEFT JOIN tblLGShipmentContractQty SC ON SC.intShipmentContractQtyId = S.intShipmentContractQtyId
						LEFT JOIN tblLGShipmentBLContainer C ON C.intShipmentBLContainerId = S.intShipmentBLContainerId
						Group By C.ysnRejected, SC.intContractDetailId Having SC.intContractDetailId = CD.intContractDetailId AND C.ysnRejected = 1), 0) 
				AS dblUnShippedQuantity,
			CD.intContractTypeId as intPurchaseSale,
			CD.intEntityId,
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
			CD.strVessel,
			CD.intContractTypeId,
			Item.strType as strItemType,
			convert(nvarchar(100), CD.dtmStartDate, 101) as strStartDate,
			convert(nvarchar(100), CD.dtmEndDate, 101) as strEndDate

	FROM 	vyuCTContractDetailView 		CD
	LEFT JOIN tblICItem Item ON Item.intItemId = CD.intItemId
	LEFT JOIN tblSMCity LoadingPort ON LoadingPort.intCityId = CD.intLoadingPortId
	LEFT JOIN tblSMCity DestPort ON DestPort.intCityId = CD.intDestinationPortId
	LEFT JOIN tblSMCity DestCity ON DestCity.intCityId = CD.intDestinationCityId) t1
	WHERE t1.dblUnShippedQuantity > 0 AND t1.intContractTypeId = 1
