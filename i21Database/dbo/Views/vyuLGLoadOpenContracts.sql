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
	,CD.dtmPlannedAvailabilityDate
	,EY.intDefaultLocationId
	,ISNULL(CD.dblScheduleQty, 0) AS dblScheduleQty
	,CH.strCustomerContract
	,ISNULL(CD.dblBalance, 0) AS dblBalance
	,CASE WHEN CP.ysnValidateExternalPONo = 1 AND ISNULL(CD.strERPPONumber,'')= ''
		THEN CAST(0 AS BIT)
	ELSE
		CASE 
			WHEN (
					(
						CAST(CASE 
								WHEN CD.intContractStatusId IN (1,4)
									THEN 1
								ELSE 0
								END AS BIT) = 1
						)
					AND (
						(ISNULL(CD.dblBalance, 0) - ISNULL(CD.dblScheduleQty, 0) > 0)
						OR (CH.ysnUnlimitedQuantity = 1)
						)
					)
				THEN CAST(1 AS BIT)
			ELSE CAST(0 AS BIT)
			END 
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
	,S.strSampleStatus
	,S.strSampleNumber
	,S.strContainerNumber
	,S.strSampleTypeName
	,CONVERT(NVARCHAR(100), S.dtmTestingStartDate, 101) AS strTestingStartDate
	,CONVERT(NVARCHAR(100), S.dtmTestingEndDate, 101) AS strTestingEndDate
	,CASE 
		WHEN S.intCompanyLocationSubLocationId IS NULL
			THEN CD.intSubLocationId
		ELSE S.intCompanyLocationSubLocationId
		END AS intCompanyLocationSubLocationId
	,CASE 
		WHEN ISNULL(S.strSubLocationName, '') = ''
			THEN CLSL.strSubLocationName
		ELSE S.strSubLocationName
		END AS strSubLocationName
	,S.dblRepresentingQty AS dblContainerQty
	,SL.strName AS strStorageLocationName
	,CD.intStorageLocationId
	,intShipmentType = 1
	,CD.strERPPONumber
	,ISNULL(WG.ysnSample,0) AS ysnSampleRequired
FROM tblCTContractHeader CH
JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
JOIN tblICItem Item ON Item.intItemId = CD.intItemId
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
JOIN vyuCTEntity EY ON EY.intEntityId = CH.intEntityId
	AND EY.strEntityType = (
		CASE 
			WHEN CH.intContractTypeId = 1
				THEN 'Vendor'
			ELSE 'Customer'
			END
		)
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
LEFT JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
LEFT JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblSMCity LoadingPort ON LoadingPort.intCityId = CD.intLoadingPortId
LEFT JOIN tblSMCity DestPort ON DestPort.intCityId = CD.intDestinationPortId
LEFT JOIN tblSMCity DestCity ON DestCity.intCityId = CD.intDestinationCityId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CD.intSubLocationId
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = CD.intStorageLocationId
LEFT JOIN (
	SELECT *
	FROM (
		SELECT ROW_NUMBER() OVER (
				PARTITION BY S.intContractDetailId ORDER BY S.intSampleId DESC
				) intRowNum
			,S.intContractDetailId
			,S.strSampleNumber
			,S.strContainerNumber
			,ST.strSampleTypeName
			,SS.strStatus AS strSampleStatus
			,S.dtmTestingStartDate
			,S.dtmTestingEndDate
			,S.intCompanyLocationSubLocationId
			,CLSL.strSubLocationName
			,S.dblRepresentingQty
		FROM tblQMSample S
		JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
		JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
		LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
		WHERE S.intContractDetailId IS NOT NULL
		) t
	WHERE intRowNum = 1
	) S ON S.intContractDetailId = CD.intContractDetailId
CROSS APPLY tblLGCompanyPreference CP

UNION

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
	,ISNULL(CD.dblQuantity, 0) - ISNULL((
			SELECT SUM(LD.dblQuantity)
			FROM tblLGLoadDetail LD
			JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			WHERE LD.intPContractDetailId = CD.intContractDetailId
				AND L.intShipmentType = 2
				AND ISNULL(L.ysnCancelled,0) = 0 
			), 0) AS dblUnLoadedQuantity
	,CH.intContractTypeId intPurchaseSale
	,CH.intEntityId
	,CH.strContractNumber
	,CH.dtmContractDate
	,EY.strEntityName
	,CONVERT(NVARCHAR(100), CD.dtmStartDate, 101) AS strStartDate
	,CONVERT(NVARCHAR(100), CD.dtmEndDate, 101) AS strEndDate
	,CD.dtmStartDate
	,CD.dtmEndDate
	,CD.dtmPlannedAvailabilityDate
	,EY.intDefaultLocationId
	,ISNULL((SELECT SUM(LD.dblQuantity)
			 FROM tblLGLoadDetail LD
			 JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			 WHERE CD.intContractDetailId = (CASE WHEN CH.intContractTypeId = 1 THEN LD.intPContractDetailId ELSE LD.intSContractDetailId END)
				 AND L.intShipmentType = 2
				 AND ISNULL(L.ysnCancelled,0) = 0 
			 ), 0) AS dblScheduleQty
	,CH.strCustomerContract
	,ISNULL(CD.dblBalance, 0) AS dblBalance
	,CASE WHEN CP.ysnValidateExternalPONo = 1 AND ISNULL(CD.strERPPONumber,'')= ''
		THEN CAST(0 AS BIT)
		ELSE
			CASE 
				WHEN (
						(
							CAST(CASE 
									WHEN CD.intContractStatusId IN (1,4)
										THEN 1
									ELSE 0
									END AS BIT) = 1
							)
						AND (
							(
								ISNULL(CD.dblQuantity, 0) - ISNULL((
										SELECT SUM(LD.dblQuantity)
										FROM tblLGLoadDetail LD
										JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
										WHERE CD.intContractDetailId = (CASE WHEN CH.intContractTypeId = 1 THEN LD.intPContractDetailId ELSE LD.intSContractDetailId END)
											AND L.intShipmentType = 2
											AND ISNULL(L.ysnCancelled,0) = 0 
										), 0) > 0
								)
							OR (CH.ysnUnlimitedQuantity = 1)
							)
						)
					THEN CAST(1 AS BIT)
				ELSE CAST(0 AS BIT)
				END 
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
	,S.strSampleStatus
	,S.strSampleNumber
	,S.strContainerNumber
	,S.strSampleTypeName
	,CONVERT(NVARCHAR(100), S.dtmTestingStartDate, 101) AS strTestingStartDate
	,CONVERT(NVARCHAR(100), S.dtmTestingEndDate, 101) AS strTestingEndDate
	,CASE 
		WHEN S.intCompanyLocationSubLocationId IS NULL
			THEN CD.intSubLocationId
		ELSE S.intCompanyLocationSubLocationId
		END AS intCompanyLocationSubLocationId
	,CASE 
		WHEN ISNULL(S.strSubLocationName, '') = ''
			THEN CLSL.strSubLocationName
		ELSE S.strSubLocationName
		END AS strSubLocationName
	,S.dblRepresentingQty AS dblContainerQty
	,SL.strName AS strStorageLocationName
	,CD.intStorageLocationId
	,intShipmentType = 2
	,CD.strERPPONumber
	,ISNULL(WG.ysnSample,0) AS ysnSampleRequired
FROM tblCTContractHeader CH
JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
JOIN tblICItem Item ON Item.intItemId = CD.intItemId
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
JOIN vyuCTEntity EY ON EY.intEntityId = CH.intEntityId
	AND EY.strEntityType = (
		CASE 
			WHEN CH.intContractTypeId = 1
				THEN 'Vendor'
			ELSE 'Customer'
			END
		)
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
LEFT JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
LEFT JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblSMCity LoadingPort ON LoadingPort.intCityId = CD.intLoadingPortId
LEFT JOIN tblSMCity DestPort ON DestPort.intCityId = CD.intDestinationPortId
LEFT JOIN tblSMCity DestCity ON DestCity.intCityId = CD.intDestinationCityId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CD.intSubLocationId
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = CD.intStorageLocationId
LEFT JOIN (
	SELECT *
	FROM (
		SELECT ROW_NUMBER() OVER (
				PARTITION BY S.intContractDetailId ORDER BY S.intSampleId DESC
				) intRowNum
			,S.intContractDetailId
			,S.strSampleNumber
			,S.strContainerNumber
			,ST.strSampleTypeName
			,SS.strStatus AS strSampleStatus
			,S.dtmTestingStartDate
			,S.dtmTestingEndDate
			,S.intCompanyLocationSubLocationId
			,CLSL.strSubLocationName
			,S.dblRepresentingQty
		FROM tblQMSample S
		JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
		JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
		LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
		WHERE S.intContractDetailId IS NOT NULL
		) t
	WHERE intRowNum = 1
	) S ON S.intContractDetailId = CD.intContractDetailId
CROSS APPLY tblLGCompanyPreference CP
GROUP BY CD.intContractDetailId
	,CD.intContractHeaderId
	,CD.intContractSeq
	,CD.intItemId
	,Item.strDescription
	,Item.strItemNo
	,CD.dblQuantity
	,CD.intUnitMeasureId
	,CD.intItemUOMId
	,U1.strUnitMeasure
	,CD.intCompanyLocationId
	,CL.strLocationName
	,CD.dblBalance
	,CD.dblScheduleQty
	,CH.intContractTypeId
	,CH.intEntityId
	,CH.strContractNumber
	,CH.dtmContractDate
	,EY.strEntityName
	,CD.dtmStartDate
	,CD.dtmEndDate
	,CD.dtmPlannedAvailabilityDate
	,EY.intDefaultLocationId
	,CH.strCustomerContract
	,CD.intContractStatusId
	,CH.ysnUnlimitedQuantity
	,CH.ysnLoad
	,CD.dblQuantityPerLoad
	,CD.intNoOfLoad
	,Item.strType
	,CH.intPositionId
	,CD.intLoadingPortId
	,CD.intDestinationPortId
	,CD.intDestinationCityId
	,LoadingPort.strCity
	,DestCity.strCity
	,DestPort.strCity
	,CD.strPackingDescription
	,CD.intShippingLineId
	,CD.intNumberOfContainers
	,CD.intContainerTypeId
	,CD.strVessel
	,S.strSampleStatus
	,S.strSampleNumber
	,S.strContainerNumber
	,S.strSampleTypeName
	,S.dtmTestingStartDate
	,S.dtmTestingEndDate
	,S.intCompanyLocationSubLocationId
	,S.strSubLocationName
	,S.dblRepresentingQty
	,CD.strERPPONumber
	,ysnValidateExternalPONo
	,CD.intSubLocationId
	,CLSL.strSubLocationName
	,SL.strName
	,CD.intStorageLocationId
	,WG.ysnSample