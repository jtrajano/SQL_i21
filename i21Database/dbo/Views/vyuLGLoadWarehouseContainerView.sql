CREATE VIEW vyuLGLoadWarehouseContainerView
AS
SELECT   L.intLoadId
		,L.strLoadNumber
		,L.strBLNumber
		,L.dtmBLDate
		,L.dtmScheduledDate
		,L.strExternalLoadNumber
		,L.strMVessel
		,L.strMVoyageNumber
		,L.strFVessel
		,L.strFVoyageNumber
		,L.strOriginPort
		,L.strDestinationPort
		,L.strShippingMode
		,L.dtmETAPOD
		,L.dtmETAPOL
		,L.dtmETSPOL

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
		,LW.intSubLocationId

		,LWC.intLoadWarehouseContainerId
		,CLSL.strSubLocationName
		,WRMH.strServiceContractNo
		,CLSLV.intEntityId 
		,ShippingLine.strName as strShippingLine
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId =  LDCL.intLoadContainerId
LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
LEFT JOIN tblEMEntity CLSLV ON CLSLV.intEntityId = CLSL.intVendorId
LEFT JOIN tblLGWarehouseRateMatrixHeader WRMH ON WRMH.intWarehouseRateMatrixHeaderId = LW.intWarehouseRateMatrixHeaderId
LEFT JOIN tblEMEntity CEN ON CEN.intEntityId = LD.intCustomerEntityId
LEFT JOIN tblEMEntityLocation CEL ON CEL.intEntityLocationId = LD.intCustomerEntityLocationId
LEFT JOIN tblICItem Item On Item.intItemId = LD.intItemId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = L.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = L.intEquipmentTypeId
LEFT JOIN tblSMUserSecurity US ON US.[intEntityId] = L.intDispatcherId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
WHERE L.intShipmentType = 1