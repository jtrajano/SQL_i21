CREATE VIEW vyuLGLoadWarehouseView
AS
SELECT LW.intLoadWarehouseId
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
	  ,WRMH.strServiceContractNo AS strServiceContract
	  ,Hauler.strName AS strShipVia
	  ,CLSL.strSubLocationName AS strWarehouse
	  ,CLSL.strSubLocationName
	  ,LW.intStorageLocationId
	  ,SL.strName AS strStorageLocationName
	  ,CLSLV.intEntityId 
	  ,ShippingLine.strName AS strShippingLine
	  ,CASE L.intShipmentStatus
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
			WHEN 7
				THEN 'Instruction created'
			WHEN 8
				THEN 'Partial Shipment Created'
			WHEN 9
				THEN 'Full Shipment Created'
			WHEN 10
				THEN 'Cancelled'
			ELSE ''
			END COLLATE Latin1_General_CI_AS AS strShipmentStatus
		,L.intShipmentType
		,CASE L.intShipmentType
		WHEN 1
			THEN 'Shipment'
		WHEN 2
			THEN 'Shipping Instructions'
		WHEN 3
			THEN 'Vessel Nomination'
		ELSE ''
		END COLLATE Latin1_General_CI_AS AS strShipmentType
FROM tblLGLoadWarehouse LW
JOIN tblLGLoad L ON L.intLoadId = LW.intLoadId
JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
LEFT JOIN tblEMEntity CLSLV ON CLSLV.intEntityId = CLSL.intVendorId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = LW.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
LEFT JOIN tblLGWarehouseRateMatrixHeader WRMH ON WRMH.intWarehouseRateMatrixHeaderId = LW.intWarehouseRateMatrixHeaderId
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = LW.intStorageLocationId
