CREATE VIEW vyuLGLoadWarehouseView
AS
SELECT  
	LW.intLoadWarehouseId
	,LW.intConcurrencyId
	,LW.strDeliveryNoticeNumber
	,LW.dtmDeliveryNoticeDate
	,LW.intSubLocationId
	,LW.intHaulerEntityId
	,LW.dtmPickupDate
	,LW.dtmDeliveryDate
	,LW.dtmLastFreeDate
	,LW.dtmStrippingReportReceivedDate
	,LW.dtmSampleAuthorizedDate
	,LW.strStrippingReportComments
	,LW.strFreightComments
	,LW.strSampleComments
	,LW.strOtherComments
	,LW.intWarehouseRateMatrixHeaderId
	,L.intLoadId
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
	,strPCompanyLocation = PCL.strLocationName
	,strPContractNumber = PCH.strContractNumber
	,intPContractSeq = PCD.intContractSeq
	,strCommodity = PCMD.strCommodityCode
	,strContractItem = PICT.strContractItemName
	,strItemNo = Item.strItemNo
	,strItemDescription = Item.strDescription
	,LD.dblQuantity
	,strItemUOM = UOM.strUnitMeasure
	,strOrigin = Origin.strDescription
	,LD.dblGross
	,LD.dblTare
	,LD.dblNet
	,strWeightUOM = WUOM.strUnitMeasure
	,strServiceContract = WRMH.strServiceContractNo
	,strShipVia = Hauler.strName
	,strWarehouse = CLSL.strSubLocationName
	,CLSL.strSubLocationName
	,LW.intStorageLocationId
	,strStorageLocationName = SL.strName
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
	,strLSINumber = LSI.strLoadNumber
	,strERPPONumber = PCD.strERPPONumber
	,strDocStatus = CASE WHEN L.ysnDocumentsReceived = 1 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
	,strRegistration = CASE WHEN L.ysn4cRegistration = 1 THEN 'Y' ELSE 'N' END COLLATE Latin1_General_CI_AS
	,L.intBookId
	,L.intSubBookId
FROM tblLGLoadWarehouse LW
	JOIN tblLGLoad L ON L.intLoadId = LW.intLoadId
	JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
	LEFT JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = LD.intPContractDetailId
	LEFT JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
	LEFT JOIN tblSMCompanyLocation PCL ON PCL.intCompanyLocationId = LD.intPCompanyLocationId
	LEFT JOIN tblICCommodity PCMD ON PCH.intCommodityId = PCMD.intCommodityId
	LEFT JOIN tblICItemContract PICT ON PICT.intItemContractId = PCD.intItemContractId
	LEFT JOIN tblICItem Item ON Item.intItemId = LD.intItemId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblICCommodityAttribute Origin ON Origin.intCommodityAttributeId = Item.intOriginId
	LEFT JOIN tblICItemUOM WeightUOM ON WeightUOM.intItemUOMId = LD.intWeightItemUOMId
	LEFT JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = WeightUOM.intUnitMeasureId
	LEFT JOIN tblEMEntity CLSLV ON CLSLV.intEntityId = CLSL.intVendorId
	LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = LW.intHaulerEntityId
	LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
	LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
	LEFT JOIN tblLGWarehouseRateMatrixHeader WRMH ON WRMH.intWarehouseRateMatrixHeaderId = LW.intWarehouseRateMatrixHeaderId
	LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = LW.intStorageLocationId
	LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
	OUTER APPLY (SELECT TOP 1 BI.strBillId FROM tblLGLoadWarehouseServices LWS LEFT JOIN tblAPBill BI ON BI.intBillId = LWS.intBillId
				WHERE LWS.intLoadWarehouseId = LW.intLoadWarehouseId AND LWS.intBillId IS NOT NULL) BI
	OUTER APPLY (SELECT TOP 1 ysnShowReceivedLoadsInWarehouseTab = ISNULL(ysnShowReceivedLoadsInWarehouseTab,0) FROM tblLGCompanyPreference) CP
WHERE 
	(CP.ysnShowReceivedLoadsInWarehouseTab = 0 AND L.intShipmentStatus NOT IN (4, 10) AND L.intShipmentType = 1)
	OR CP.ysnShowReceivedLoadsInWarehouseTab = 1