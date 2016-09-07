CREATE VIEW vyuLGLoadOpenContracts
AS
SELECT CD.intContractDetailId
	,CD.intContractHeaderId
	,CD.intContractSeq
	,CD.intItemId
	,Item.strDescription strItemDescription
	,Item.strItemNo
	,CD.dblQuantity AS dblDetailQuantity
	,CD.intUnitMeasureId
	,CD.intItemUOMId
	,U1.strUnitMeasure AS strUnitMeasure
	,CD.intCompanyLocationId
	,CL.strLocationName AS strLocationName
	,ISNULL(CD.dblBalance, 0) - ISNULL(CD.dblScheduleQty, 0) AS dblUnLoadedQuantity
	,CH.intContractTypeId intPurchaseSale
	,CH.intEntityId
	,CH.strContractNumber
	,CH.dtmContractDate
	,EY.strEntityName
	,CONVERT(NVARCHAR(100), CD.dtmStartDate, 101) AS strStartDate
	,CONVERT(NVARCHAR(100), CD.dtmEndDate, 101) AS strEndDate
	,CD.dtmStartDate
	,CD.dtmEndDate
	,EY.intDefaultLocationId
	,ISNULL(CD.dblScheduleQty, 0) AS dblScheduleQty
	,CH.strCustomerContract
	,ISNULL(CD.dblBalance, 0) AS dblBalance
	,CASE 
		WHEN ((CAST(CASE 
						WHEN CD.intContractStatusId IN (1,4)
							THEN 1
						ELSE 0
						END AS BIT) = 1
			  ) AND ((ISNULL(CD.dblBalance, 0) - ISNULL(CD.dblScheduleQty, 0) > 0) OR (CH.ysnUnlimitedQuantity = 1)))
			THEN CAST(1 AS BIT)
		ELSE CAST(0 AS BIT)
		END AS ysnAllowedToShow
	,CH.ysnUnlimitedQuantity
	,CH.ysnLoad
	,CD.dblQuantityPerLoad
	,CD.intNoOfLoad
	,Item.strType AS strItemType
	,CH.intPositionId
	,CD.intLoadingPortId
	,CD.intDestinationPortId
	,CD.intDestinationCityId
	,LoadingPort.strCity AS strOriginPort
	,DestPort.strCity AS strDestinationPort
	,DestCity.strCity AS strDestinationCity
	,CD.strPackingDescription
	,CD.intShippingLineId AS intShippingLineEntityId
	,CD.intNumberOfContainers
	,CD.intContainerTypeId
	,CD.strVessel
	,CH.intContractTypeId
FROM tblCTContractHeader CH
JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
JOIN tblICItem Item ON Item.intItemId = CD.intItemId
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
JOIN vyuCTEntity EY ON EY.intEntityId = CH.intEntityId
	AND EY.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer'END)
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
LEFT JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblSMCity LoadingPort ON LoadingPort.intCityId = CD.intLoadingPortId
LEFT JOIN tblSMCity DestPort ON DestPort.intCityId = CD.intDestinationPortId
LEFT JOIN tblSMCity DestCity ON DestCity.intCityId = CD.intDestinationCityId