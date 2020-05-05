CREATE VIEW vyuLGLoadWarehouseContainerView
AS
SELECT DISTINCT  
	L.intLoadId
	,L.strLoadNumber
	,L.strBLNumber
	,L.dtmBLDate
	,L.dtmScheduledDate
	,L.strExternalLoadNumber
	,L.strExternalShipmentNumber
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
	,L.ysnArrivedInPort
	,L.dtmArrivedInPort
	,L.ysnDocumentsApproved
	,L.dtmDocumentsApproved
	,L.ysnCustomsReleased
	,L.dtmCustomsReleased
	,strLSINumber = LSI.strLoadNumber

	,LD.intLoadDetailId
	,strCustomerFax = CEN.strFax
	,strCustomerMobile = CEN.strMobile
	,strCustomerNo = CEN.strEntityNo
	,strCustomerPhone = CEN.strPhone
	,strCustomerReference = LD.strCustomerReference
	,strDispatcher = US.strUserName 
	,strDriver = Driver.strName
	,strEquipmentType = EQ.strEquipmentType
	,strHauler = Hauler.strName
	,strItemNo = Item.strItemNo
	,strItemDescription = Item.strDescription
	,strBundleItemNo = Bundle.strItemNo
	,strLotTracking = Item.strLotTracking
	,dblQuantity = LD.dblQuantity
	,strItemUOM = UOM.strUnitMeasure
	,dblGross = LDCL.dblLinkGrossWt
	,dblTare = LDCL.dblLinkTareWt
	,dblNet = LDCL.dblLinkNetWt
	,strWeightUOM = LCUOM.strUnitMeasure
	,strLoadDirectionMsg = LD.strLoadDirectionMsg

	,strPCompanyLocation = PCL.strLocationName
	,strPContractNumber = PCH.strContractNumber
	,strVendor = VEN.strName
	,intPContractSeq = PCD.intContractSeq
	,strCommodity = PCMD.strCommodityCode
	,strContractItem = PICT.strContractItemName
	,strOrigin = Origin.strDescription

	,LC.intLoadContainerId
	,LC.strComments
	,LC.strContainerNumber
	,LC.dtmUnloading
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
	,strShippingLine = ShippingLine.strName
	,strTransactionType = CASE L.intPurchaseSale
		WHEN 1 THEN 'Inbound'
		WHEN 2 THEN 'Outbound'
		WHEN 3 THEN 'Drop Ship'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,strShipmentStatus = CASE L.intShipmentStatus
		WHEN 1 THEN 'Scheduled'
		WHEN 2 THEN 'Dispatched'
		WHEN 3 THEN 
			CASE WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
					WHEN (L.ysnDocumentsApproved = 1) THEN 'Documents Approved'
					WHEN (L.ysnArrivedInPort = 1) THEN 'Arrived in Port'
					ELSE 'Inbound Transit' END
		WHEN 4 THEN 'Received'
		WHEN 5 THEN 
			CASE WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
					WHEN (L.ysnDocumentsApproved = 1) THEN 'Documents Approved'
					WHEN (L.ysnArrivedInPort = 1) THEN 'Arrived in Port'
					ELSE 'Outbound Transit' END
		WHEN 6 THEN 
			CASE WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
					WHEN (L.ysnDocumentsApproved = 1) THEN 'Documents Approved'
					WHEN (L.ysnArrivedInPort = 1) THEN 'Arrived in Port'
					ELSE 'Delivered' END
		WHEN 7 THEN 
			CASE WHEN (ISNULL(L.strBookingReference, '') <> '') THEN 'Booked'
					ELSE 'Shipping Instruction Created' END
		WHEN 8 THEN 'Partial Shipment Created'
		WHEN 9 THEN 'Full Shipment Created'
		WHEN 10 THEN 'Cancelled'
		WHEN 11 THEN 'Invoiced'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,L.intShipmentType
	,strShipmentType = CASE L.intShipmentType
		WHEN 1 THEN 'Shipment'
		WHEN 2 THEN 'Shipping Instructions'
		WHEN 3 THEN 'Vessel Nomination'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,strTransportationMode = CASE L.intTransportationMode
		WHEN 1 THEN 'Truck'
		WHEN 2 THEN 'Ocean Vessel'
		WHEN 3 THEN 'Rail'
		END COLLATE Latin1_General_CI_AS
	,BI.strBillId
	,BI.intBillId
	,L.intBookId
	,BO.strBook
	,L.intSubBookId
	,SB.strSubBook
	,strERPPONUmber = PCD.strERPPONumber
	,strDocStatus = CASE WHEN L.ysnDocumentsReceived = 1 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
	,strRegistration = CASE WHEN L.ysn4cRegistration = 1 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = LD.intPContractDetailId
LEFT JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
LEFT JOIN tblSMCompanyLocation PCL ON PCL.intCompanyLocationId = LD.intPCompanyLocationId
LEFT JOIN tblICCommodity PCMD ON PCH.intCommodityId = PCMD.intCommodityId
LEFT JOIN tblICItemContract PICT ON PICT.intItemContractId = PCD.intItemContractId
LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId =  LDCL.intLoadContainerId
LEFT JOIN tblICUnitMeasure LCUOM ON LCUOM.intUnitMeasureId = LC.intUnitMeasureId
LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
LEFT JOIN tblEMEntity CLSLV ON CLSLV.intEntityId = CLSL.intVendorId
LEFT JOIN tblLGWarehouseRateMatrixHeader WRMH ON WRMH.intWarehouseRateMatrixHeaderId = LW.intWarehouseRateMatrixHeaderId
LEFT JOIN tblEMEntity CEN ON CEN.intEntityId = LD.intCustomerEntityId
LEFT JOIN tblEMEntityLocation CEL ON CEL.intEntityLocationId = LD.intCustomerEntityLocationId
LEFT JOIN tblEMEntity VEN ON VEN.intEntityId = LD.intVendorEntityId
LEFT JOIN tblEMEntityLocation VEL ON VEL.intEntityLocationId = LD.intVendorEntityLocationId
LEFT JOIN tblICItem Item On Item.intItemId = LD.intItemId
LEFT JOIN tblICItem Bundle ON Bundle.intItemId = PCD.intItemBundleId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICCommodityAttribute Origin ON Origin.intCommodityAttributeId = Item.intOriginId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = L.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = L.intEquipmentTypeId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = L.intDispatcherId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
LEFT JOIN tblLGLoadWarehouseServices LWS ON LWS.intLoadWarehouseId = LW.intLoadWarehouseId
LEFT JOIN tblAPBill BI ON BI.intBillId = LWS.intBillId
LEFT JOIN tblCTBook BO ON BO.intBookId = L.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = L.intSubBookId
LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
OUTER APPLY (SELECT TOP 1 ysnShowReceivedLoadsInWarehouseTab = ISNULL(ysnShowReceivedLoadsInWarehouseTab,0) FROM tblLGCompanyPreference) CP
WHERE L.intShipmentType = 1
	AND ((CP.ysnShowReceivedLoadsInWarehouseTab = 0 AND L.intShipmentStatus NOT IN (4, 10)) OR CP.ysnShowReceivedLoadsInWarehouseTab = 1)