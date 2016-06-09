CREATE VIEW [dbo].[vyuLGLoadContainerView]
AS
SELECT  L.intLoadId
		,LDV.intLoadDetailId
		,LC.intLoadContainerId
		,LDCL.intLoadDetailContainerLinkId
		,L.strLoadNumber
		,L.strBLNumber
		,L.dtmBLDate
		,L.dtmScheduledDate
		,LDV.strCustomerFax
		,LDV.strCustomerMobile
		,LDV.strCustomerNo
		,LDV.strCustomerPhone
		,LDV.strCustomerReference
		,LDV.strDispatcher
		,LDV.strDriver
		,LDV.strEquipmentType
		,LDV.strExternalLoadNumber
		,LDV.strHauler
		,LDV.strItemDescription
		,LDV.strItemNo
		,LDV.strItemUOM
		,LDV.strLoadDirectionMsg
		,LDV.strLotTracking
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
		,PCDV.strContractNumber AS strPContractNumber
		,PCDV.intContractSeq AS intPContractSeq
		,SCDV.strContractNumber AS strSContractNumber
		,SCDV.intContractSeq AS	intSContractSeq
		,strSampleStatus = (SELECT TOP 1 SS.strStatus
								     FROM tblQMSample S
									 JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
									 AND S.strContainerNumber = LC.strContainerNumber ORDER BY dtmTestedOn DESC)
		,LDCL.strIntegrationNumber
		,LDCL.dtmIntegrationRequested
		,LDCL.strIntegrationOrderNumber
		,LDCL.dtmIntegrationOrderDate
		,LDCL.dblIntegrationOrderPrice
		,CONVERT(BIT,ISNULL(LDCL.ysnExported,0)) AS ysnExported

FROM vyuLGLoadView L
JOIN vyuLGLoadDetailView LDV ON L.intLoadId = LDV.intLoadId
JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LDV.intLoadDetailId
JOIN tblLGLoadContainer LC ON LDCL.intLoadContainerId = LC.intLoadContainerId
LEFT JOIN vyuCTContractDetailView PCDV ON PCDV.intContractDetailId = LDV.intPContractDetailId
LEFT JOIN vyuCTContractDetailView SCDV ON SCDV.intContractDetailId = LDV.intSContractDetailId