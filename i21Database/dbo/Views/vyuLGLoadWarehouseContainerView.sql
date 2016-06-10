﻿CREATE VIEW vyuLGLoadWarehouseContainerView
AS
SELECT   L.intLoadId
		,L.strLoadNumber
		,L.strBLNumber
		,L.dtmBLDate
		,L.dtmScheduledDate
		,L.strExternalLoadNumber

		,LD.intLoadDetailId
		,strCustomerFax = CEN.strFax
		,strCustomerMobile = CEN.strMobile
		,strCustomerNo = CEN.strEntityNo
		,strCustomerPhone = CEN.strPhone
		,LD.strCustomerReference
		,strDispatcher = US.strUserName 
		,strDriver = Driver.strName
		,strEquipmentType = EQ.strEquipmentType
		,strHauler = Hauler.strName
		,Item.strDescription AS strItemDescription
		,Item.strItemNo
		,Item.strLotTracking
		,strItemUOM = UOM.strUnitMeasure
		,LD.strLoadDirectionMsg

		,LC.intLoadContainerId
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

		,LWC.intLoadWarehouseContainerId
		,CLSL.strSubLocationName
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
JOIN tblLGLoadContainer LC ON LC.intLoadContainerId =  LDCL.intLoadContainerId
JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
LEFT JOIN tblEMEntity CEN ON CEN.intEntityId = LD.intCustomerEntityId
LEFT JOIN tblEMEntityLocation CEL ON CEL.intEntityLocationId = LD.intCustomerEntityLocationId
LEFT JOIN tblICItem Item On Item.intItemId = LD.intItemId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = L.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = L.intEquipmentTypeId
LEFT JOIN tblSMUserSecurity US ON US.intEntityUserSecurityId = L.intDispatcherId