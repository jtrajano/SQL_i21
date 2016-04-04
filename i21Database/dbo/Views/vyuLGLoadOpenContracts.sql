CREATE VIEW vyuLGLoadOpenContracts
AS
	SELECT 	CD.intContractDetailId, 
			CD.intContractHeaderId, 
			CD.intContractSeq, 
			CD.intItemId,
			CD.strItemDescription,
			CD.strItemNo,
			CD.dblDetailQuantity,
			CD.intUnitMeasureId,
			CD.intItemUOMId,
			CD.strItemUOM as strUnitMeasure,
			CD.intCompanyLocationId,
			CD.strLocationName,
			IsNull(CD.dblBalance, 0) - IsNull(CD.dblScheduleQty, 0)		AS dblUnLoadedQuantity,
			CD.intContractTypeId intPurchaseSale,
			CD.intEntityId,
			CD.strContractNumber,
			CD.dtmContractDate,
			CD.strEntityName,
			convert(nvarchar(100), CD.dtmStartDate, 101) as strStartDate,
			convert(nvarchar(100), CD.dtmEndDate, 101) as strEndDate,
			CD.dtmStartDate,
			CD.dtmEndDate,
			CD.intDefaultLocationId,
			IsNull(CD.dblScheduleQty, 0) as dblScheduleQty,
			CD.strCustomerContract,
			IsNull(CD.dblBalance, 0) as dblBalance,
			CASE WHEN ((CD.ysnAllowedToShow = 1) AND ((IsNull(CD.dblBalance, 0) - IsNull(CD.dblScheduleQty, 0) > 0) Or (CD.ysnUnlimitedQuantity = 1)))
				THEN CAST(1 as Bit)
				ELSE CAST (0 as Bit)
				END as ysnAllowedToShow,
			CD.ysnUnlimitedQuantity,
			CD.ysnLoad,
			CD.dblQuantityPerLoad,
			CD.intNoOfLoad,

			Item.strType as strItemType,
			CD.intPositionId,
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
			CD.intContractTypeId

	FROM vyuCTContractDetailView 		CD
	JOIN tblICItem Item ON Item.intItemId = CD.intItemId
	LEFT JOIN tblSMCity LoadingPort ON LoadingPort.intCityId = CD.intLoadingPortId
	LEFT JOIN tblSMCity DestPort ON DestPort.intCityId = CD.intDestinationPortId
	LEFT JOIN tblSMCity DestCity ON DestCity.intCityId = CD.intDestinationCityId