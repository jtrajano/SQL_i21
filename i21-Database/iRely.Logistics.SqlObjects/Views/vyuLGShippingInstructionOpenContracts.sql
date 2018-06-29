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
			CD.strContractNumber,
			CD.dtmContractDate,
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
			convert(nvarchar(100), CD.dtmStartDate, 101) as strStartDate,
			convert(nvarchar(100), CD.dtmEndDate, 101) as strEndDate

	FROM vyuCTContractDetailView 		CD
	LEFT JOIN tblSMCity LoadingPort ON LoadingPort.intCityId = CD.intLoadingPortId
	LEFT JOIN tblSMCity DestPort ON DestPort.intCityId = CD.intDestinationPortId
	LEFT JOIN tblSMCity DestCity ON DestCity.intCityId = CD.intDestinationCityId
	WHERE (CD.dblDetailQuantity - IsNull((select sum (SI.dblQuantity) from tblLGShippingInstructionContractQty SI Group By SI.intContractDetailId Having CD.intContractDetailId = SI.intContractDetailId), 0)) > 0	

