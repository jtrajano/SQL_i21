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
FROM tblLGLoadWarehouse LW
JOIN tblLGLoad L ON L.intLoadId = LW.intLoadId
JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
LEFT JOIN tblEMEntity CLSLV ON CLSLV.intEntityId = CLSL.intVendorId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = LW.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
LEFT JOIN tblLGWarehouseRateMatrixHeader WRMH ON WRMH.intWarehouseRateMatrixHeaderId = LW.intWarehouseRateMatrixHeaderId
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = LW.intStorageLocationId
