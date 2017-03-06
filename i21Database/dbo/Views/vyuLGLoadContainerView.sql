CREATE VIEW [dbo].vyuLGLoadContainerView
AS
SELECT   L.intLoadId
		,L.strLoadNumber
		,L.strBLNumber
		,L.dtmBLDate
		,L.dtmScheduledDate
		,L.strExternalLoadNumber
		,LD.intLoadDetailId
		,LD.strCustomerReference
		,LD.strLoadDirectionMsg
		,LC.intLoadContainerId
		,LC.strComments
		,LC.strContainerNumber
		,LC.strCustomsComments
		,LC.strFDAComments
		,LC.strFreightComments
		,LC.strLotNumber
		,LC.strMarks
		,LC.strOtherMarks
		,LC.strSealNumber
		,LC.strUSDAComments
		,LC.dblGrossWt
		,LC.dblNetWt
		,LC.dblQuantity
		,LC.dblTareWt
		,LC.dblTotalCost
		,LC.dblUnitCost
		,LC.dtmCustoms
		,LC.dtmFDA
		,LC.dtmFreight
		,LC.dtmUSDA
		,LC.ysnCustomsHold
		,LC.ysnDutyPaid
		,LC.ysnFDAHold
		,CONVERT(BIT,ISNULL(LC.ysnRejected,0)) AS ysnRejected
		,LC.ysnUSDAHold

		,LDCL.intLoadDetailContainerLinkId
		,LDCL.strIntegrationNumber
		,LDCL.dtmIntegrationRequested
		,LDCL.strIntegrationOrderNumber
		,LDCL.dtmIntegrationOrderDate
		,LDCL.dblIntegrationOrderPrice
		,CONVERT(BIT,ISNULL(LDCL.ysnExported,0)) AS ysnExported

		,Item.strDescription AS strItemDescription
		,Item.strItemNo
		,Item.strLotTracking

		,strCustomerFax = CEN.strFax
		,strCustomerMobile = CEN.strMobile
		,strCustomerNo = CEN.strEntityNo
		,strCustomerPhone = CEN.strPhone
		,strDispatcher = US.strUserName 
        ,strDriver = Driver.strName
        ,strEquipmentType = EQ.strEquipmentType
        ,strHauler = Hauler.strName
		,strItemUOM = UOM.strUnitMeasure
		,PHeader.strContractNumber AS strPContractNumber
		,PDetail.intContractSeq AS intPContractSeq
		,SHeader.strContractNumber AS strSContractNumber
		,SDetail.intContractSeq AS	intSContractSeq
		,strSampleStatus = (SELECT TOP 1 SS.strStatus
								     FROM tblQMSample S
									 JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
									 AND S.strContainerNumber = LC.strContainerNumber ORDER BY dtmTestedOn DESC)
		,LCWU.strUnitMeasure AS strWeightUnitMeasure
		,LCIU.strUnitMeasure AS strUnitMeasure
		,strShipmentStatus = CASE L.intShipmentStatus
								WHEN 1
									THEN 'Scheduled'
								WHEN 2
									THEN 'Dispatched'
								WHEN 3
									THEN 'Inbound transit'
								WHEN 4
									THEN 'Received'
								WHEN 5
									THEN 'Outbound transit'
								WHEN 6
									THEN 'Delivered'
								ELSE ''
							  END
		,LDCL.dblReceivedQty AS dblContainerReceivedQty
		,CAST((CASE WHEN ISNULL(LDCL.dblReceivedQty ,0) = 0 THEN 0 ELSE 1 END) AS BIT) AS  ysnReceived
		,PDetail.dblCashPrice AS dblPCashPrice
		,SDetail.dblCashPrice AS dblSCashPrice
		,LDCL.strExternalContainerId

FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
JOIN tblLGLoadContainer LC ON LDCL.intLoadContainerId = LC.intLoadContainerId
LEFT JOIN tblICUnitMeasure LCWU ON LCWU.intUnitMeasureId = LC.intWeightUnitMeasureId
LEFT JOIN tblICUnitMeasure LCIU ON LCIU.intUnitMeasureId = LC.intUnitMeasureId
LEFT JOIN tblICItem Item On Item.intItemId = LD.intItemId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblCTContractDetail PDetail ON PDetail.intContractDetailId = LD.intPContractDetailId
LEFT JOIN tblCTContractHeader PHeader ON PHeader.intContractHeaderId = PDetail.intContractHeaderId
LEFT JOIN tblCTContractDetail SDetail ON SDetail.intContractDetailId = LD.intSContractDetailId
LEFT JOIN tblCTContractHeader SHeader ON SHeader.intContractHeaderId = SDetail.intContractHeaderId
LEFT JOIN tblEMEntity CEN ON CEN.intEntityId = LD.intCustomerEntityId
LEFT JOIN tblEMEntityLocation CEL ON CEL.intEntityLocationId = LD.intCustomerEntityLocationId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = L.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = L.intEquipmentTypeId
LEFT JOIN tblSMUserSecurity US ON US.[intEntityUserSecurityId]	= L.intDispatcherId