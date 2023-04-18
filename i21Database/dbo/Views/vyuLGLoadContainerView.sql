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
		,LC.strContainerId
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
		,dblTotalCost = ROUND(
							(WeightUOM.dblUnitQty / ISNULL(PriceUOM.dblUnitQty, 1)) * ISNULL(LD.dblUnitPrice, PDetail.dblCashPrice) 
							* LC.dblNetWt / ISNULL(PBCur.intCent, 1)
						,2)
		,dblUnitCost = ISNULL(LD.dblUnitPrice, PDetail.dblCashPrice)
		,LC.dtmUnloading
		,LC.dtmCustoms
		,LC.dtmFDA
		,LC.dtmFreight
		,LC.dtmUSDA
		,LC.ysnCustomsHold
		,LC.ysnDutyPaid
		,LC.ysnFDAHold
		,CONVERT(BIT,ISNULL(LC.ysnRejected,0)) AS ysnRejected
		,LC.ysnUSDAHold
		,LC.dblCustomsClearedQty
		,LC.dblIntransitQty
		,LC.strDocumentNumber
		,LC.dtmClearanceDate
		,LC.strClearanceMonth
		,LC.dblDeclaredWeight
		,LC.dblStaticValue
		,LC.intStaticValueCurrencyId
		,CU.strCurrency AS strStaticValueCurrency
		,LC.dblAmount
		,LC.intAmountCurrencyId
		,ACU.strCurrency AS strAmountCurrency
		,LC.strRemarks
		,LC.intSort

		,LDCL.intLoadDetailContainerLinkId
		,LDCL.strIntegrationNumber
		,LDCL.dtmIntegrationRequested
		,LDCL.strIntegrationOrderNumber
		,LDCL.dtmIntegrationOrderDate
		,LDCL.dblIntegrationOrderPrice
		,CONVERT(BIT,ISNULL(LDCL.ysnExported,0)) AS ysnExported

		,Item.strDescription AS strItemDescription
		,Item.strItemNo
		,strBundleItemNo = ISNULL(PBundle.strItemNo, SBundle.strItemNo)
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
		,strSampleStatus = ISNULL(LSS.strStatus, CSS.strStatus)
		,LCWU.strUnitMeasure AS strWeightUnitMeasure
		,LCIU.strUnitMeasure AS strUnitMeasure
		,LSS.strShipmentStatus
		,LDCL.dblReceivedQty AS dblContainerReceivedQty
		,CAST((CASE WHEN ISNULL(LDCL.dblReceivedQty ,0) = 0 THEN 0 ELSE 1 END) AS BIT) AS  ysnReceived
		,PDetail.dblCashPrice AS dblPCashPrice
		,SDetail.dblCashPrice AS dblSCashPrice
		,LDCL.strExternalContainerId
		,PDetail.intPricingTypeId AS intPPricingTypeId
		,PTP.strPricingType AS strPPricingType
		,SDetail.intPricingTypeId AS intSPricingTypeId
		,PTS.strPricingType AS strSPricingType
		,PDetail.intContractDetailId AS intPContractDetailId
		,SDetail.intContractDetailId AS intSContractDetailId
	    ,L.intBookId
	    ,BO.strBook
	    ,L.intSubBookId
	    ,SB.strSubBook
		,L.ysnArrivedInPort
		,L.dtmArrivedInPort
		,L.ysnDocumentsApproved
		,L.dtmDocumentsApproved
		,L.ysnCustomsReleased
		,L.dtmCustomsReleased
		,L.strMVessel
		,L.strMVoyageNumber
		,L.strIMONumber
		,L.intUserLoc
FROM 
tblLGLoadContainer LC
JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadContainerId = LC.intLoadContainerId
JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDCL.intLoadDetailId
JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId 
JOIN vyuLGShipmentStatus LSS ON LSS.intLoadId = L.intLoadId
LEFT JOIN tblICUnitMeasure LCWU ON LCWU.intUnitMeasureId = LC.intWeightUnitMeasureId
LEFT JOIN tblICUnitMeasure LCIU ON LCIU.intUnitMeasureId = LC.intUnitMeasureId
LEFT JOIN tblICItem Item On Item.intItemId = LD.intItemId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblCTContractDetail PDetail ON PDetail.intContractDetailId = LD.intPContractDetailId
LEFT JOIN tblCTContractHeader PHeader ON PHeader.intContractHeaderId = PDetail.intContractHeaderId
LEFT JOIN tblCTContractDetail SDetail ON SDetail.intContractDetailId = LD.intSContractDetailId
LEFT JOIN tblCTContractHeader SHeader ON SHeader.intContractHeaderId = SDetail.intContractHeaderId
LEFT JOIN tblSMCurrency PBCur ON PBCur.intCurrencyID = PDetail.intBasisCurrencyId 
LEFT JOIN tblICItemUOM PriceUOM ON PriceUOM.intItemUOMId = PDetail.intPriceItemUOMId
LEFT JOIN tblICItemUOM WeightUOM ON WeightUOM.intItemUOMId = LD.intWeightItemUOMId
LEFT JOIN tblICItem PBundle ON PBundle.intItemId = PDetail.intItemBundleId
LEFT JOIN tblICItem SBundle ON SBundle.intItemId = SDetail.intItemBundleId
LEFT JOIN tblEMEntity CEN ON CEN.intEntityId = LD.intCustomerEntityId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = L.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = L.intEquipmentTypeId
LEFT JOIN tblSMUserSecurity US ON US.[intEntityId]	= L.intDispatcherId
LEFT JOIN tblCTPricingType PTP ON PTP.intPricingTypeId = PDetail.intPricingTypeId
LEFT JOIN tblCTPricingType PTS ON PTS.intPricingTypeId = SDetail.intPricingTypeId
LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = LC.intStaticValueCurrencyId
LEFT JOIN tblSMCurrency ACU ON ACU.intCurrencyID = LC.intAmountCurrencyId
LEFT JOIN tblCTBook BO ON BO.intBookId = L.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = L.intSubBookId
OUTER APPLY (SELECT TOP 1 strStatus = CASE WHEN (SS.strStatus NOT IN ('Approved', 'Rejected')) THEN 'Sample Sent' ELSE SS.strStatus END  
    FROM tblQMSample S JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId  
    WHERE (S.intContractDetailId = SDetail.intContractDetailId OR S.intContractDetailId = PDetail.intContractDetailId)  
     AND S.intLoadDetailId IS NULL  
    ORDER BY S.dtmTestingEndDate DESC, S.intSampleId DESC) CSS  
OUTER APPLY (SELECT TOP 1 strStatus = CASE WHEN (SS.strStatus NOT IN ('Approved', 'Rejected')) THEN 'Sample Sent' ELSE SS.strStatus END  
    FROM tblQMSample S JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId  
    WHERE S.intLoadDetailId = LD.intLoadDetailId  
     AND SS.strStatus <> 'Rejected'  
    ORDER BY S.dtmTestingEndDate DESC, S.intSampleId DESC) LSS