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
	  ,WRMH.strServiceContractNo AS strServiceContract
	  ,Hauler.strName AS strShipVia
	  ,CLSL.strSubLocationName AS strWarehouse
	  ,LW.intStorageLocationId
	  ,SL.strName AS strStorageLocationName
FROM tblLGLoadWarehouse LW
JOIN tblLGLoad L ON L.intLoadId = LW.intLoadId
JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = LW.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
LEFT JOIN tblLGWarehouseRateMatrixHeader WRMH ON WRMH.intWarehouseRateMatrixHeaderId = LW.intWarehouseRateMatrixHeaderId
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = LW.intStorageLocationId
