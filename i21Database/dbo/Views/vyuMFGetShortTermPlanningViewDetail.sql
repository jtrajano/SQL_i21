CREATE VIEW vyuMFGetShortTermPlanningViewDetail
AS
SELECT CONVERT(INT, ROW_NUMBER() OVER (
			ORDER BY (
					SELECT 1
					)
			)) AS intRowNo
	,L.strLoadNumber AS strLoadNo
	,CL.strLocationName AS strCompanyLocation
	,CL.strLotOrigin AS strCompany
	,D.dblBalanceMonthForecast
	,D.dblNextMonthForecast
	,CH.strContractNumber AS strContractNo
	,CASE L.intShipmentStatus
		WHEN 1
			THEN 'Scheduled'
		WHEN 3
			THEN CASE 
					WHEN (L.ysnArrivedInPort = 1)
						THEN 'Arrived in Port'
					ELSE 'Inbound Transit'
					END
		WHEN 4
			THEN 'Received'
		ELSE ''
		END COLLATE Latin1_General_CI_AS AS strShipmentstatus
	,CD.dtmEndDate dtmContractEndDate
	,I.strItemNo
	,I.strDescription AS strItemDescription
	,CA1.strDescription AS strOrigin
	,C2.strCertificationName AS strCertification
	,E.strName AS strVendor
	,CASE 
		WHEN D.intAttributeId IN (5,12,13,15)
			THEN D.dblQty
		ELSE LC.dblQuantity-ISNULL(LDCL.dblReceivedQty, 0)
		END dblQty
	,CASE 
		WHEN D.intAttributeId IN (5,15)
			THEN D.strQtyUOM
		ELSE LCIU.strUnitMeasure
		END AS strQtyUOM
	,CASE WHEN D .intAttributeId IN (5, 12, 13, 15) THEN 
		D .dblWeight 
		ELSE
		dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, CD.intUnitMeasureId, IU.intUnitMeasureId, LDCL.dblQuantity - ISNULL(LDCL.dblReceivedQty, 0))
		END AS dblWeight
	,CASE 
		WHEN D.intAttributeId IN (5,15)
			THEN D.strWeightUOM
		ELSE LCWU.strUnitMeasure
		END AS strWeightUOM
	,Comm.strCommodityCode strCommodity
	,CASE 
		WHEN D.intAttributeId IN (5,15)
			THEN D.strContainerNumber
		ELSE LC.strContainerNumber
		END strContainerNo
	,CASE 
		WHEN D.intAttributeId IN (5,15)
			THEN D.strMarks
		ELSE LC.strMarks
		END AS strMarks
	,SL.strSubLocationName strStorageLocation
	,SS.strStatus strSampleStatus
	,L.dtmETAPOD dtmETAWHSE
	,L.strComments
	,(
		CASE 
			WHEN L.dtmETAPOD IS NULL
				THEN 'No ETA'
			WHEN L.dtmETAPOD > CD.dtmEndDate
				THEN 'Late'
			ELSE 'Expected'
			END
		) COLLATE Latin1_General_CI_AS  AS strOnTime
	,D.dblDOH AS dblDOPDOH
	,CASE 
		WHEN intAttributeId = 5
			THEN 'Available Inventory'
		WHEN intAttributeId = 6
			THEN 'Approved Qty'
		WHEN intAttributeId = 7
			THEN 'Not Approved Qty'
		WHEN intAttributeId = 8
			THEN 'In-Transit to WHSE'
		WHEN intAttributeId = 9
			THEN 'Arrived in Port'
		WHEN intAttributeId = 10
			THEN 'Scheduled'
		WHEN intAttributeId = 11
			THEN 'CBS'
		WHEN intAttributeId = 12
			THEN 'Late Open Contracts'
		WHEN intAttributeId = 13
			THEN 'Forward Open Contracts'
		WHEN intAttributeId = 14
			THEN 'No ETA'
		WHEN intAttributeId = 15
			THEN 'Not Available Inventory'
		END COLLATE Latin1_General_CI_AS AS strContainerStatus
	,(
		CASE 
			WHEN SS.strStatus IS NOT NULL
				OR SL.strSubLocationName IS NOT NULL
				THEN 'Warehouse'
			ELSE 'No Warehouse'
			END
		) COLLATE Latin1_General_CI_AS AS strStorage
	,D.intUserId
FROM tblMFShortTermPlanningViewDetail D
LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = D.intLoadContainerId
LEFT JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = D.intLocationId
LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = D.intContractDetailId
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblICItem I ON I.intItemId = D.intItemId
LEFT JOIN tblICCommodityAttribute CA1 ON CA1.intCommodityAttributeId = I.intOriginId
LEFT JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intNetWeightUOMId
LEFT JOIN tblICUnitMeasure LCWU ON LCWU.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICUnitMeasure LCIU ON LCIU.intUnitMeasureId = CD.intUnitMeasureId
JOIN tblICCommodity Comm ON Comm.intCommodityId = I.intCommodityId
LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = D.intLoadContainerId
LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
LEFT JOIN tblSMCompanyLocationSubLocation SL ON SL.intCompanyLocationSubLocationId = IsNULL(D.intSubLocationId, LW.intSubLocationId)
LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadContainerId = D.intLoadContainerId
OUTER APPLY (
	SELECT TOP 1 S.intSampleStatusId
	FROM tblQMSample S
	WHERE S.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId
		AND S.intLoadContainerId = D.intLoadContainerId
		AND S.intSampleStatusId = 3 -->Approved
	ORDER BY S.intSampleId DESC
	) C3
LEFT JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = C3.intSampleStatusId
OUTER APPLY (
	SELECT TOP 1 C2.strCertificationName
	FROM tblICItemCertification IC
	JOIN tblICCertification C2 ON C2.intCertificationId = IC.intCertificationId
		AND IC.intItemId = I.intItemId
	) C2
GO


