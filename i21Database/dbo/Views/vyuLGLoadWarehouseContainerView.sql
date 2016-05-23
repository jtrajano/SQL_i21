CREATE VIEW vyuLGLoadWarehouseContainerView
AS
SELECT  L.intLoadId
		,LDV.intLoadDetailId
		,LC.intLoadContainerId
		,LWC.intLoadWarehouseContainerId
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
		,LC.strLotNumber
		,LC.strMarks
		,LC.strOtherMarks
		,LC.strSealNumber
		,LC.strUSDAComments
		,LW.intLoadWarehouseId
		,LW.strDeliveryNoticeNumber
		,LW.dtmDeliveryDate
		,LW.dtmDeliveryNoticeDate
		,LW.dtmPickupDate
		,LW.strFreightComments
		,LW.strOtherComments
		,LW.strSampleComments
		,CLSL.strSubLocationName
FROM vyuLGLoadView L
JOIN vyuLGLoadDetailView LDV ON L.intLoadId = LDV.intLoadId
JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LDV.intLoadDetailId
JOIN tblLGLoadContainer LC ON LC.intLoadContainerId =  LDCL.intLoadContainerId
JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId