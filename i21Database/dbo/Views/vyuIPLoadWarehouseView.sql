CREATE VIEW vyuIPLoadWarehouseView
AS
SELECT  
	LW.intLoadWarehouseId
	,LW.strDeliveryNoticeNumber
	,LW.dtmDeliveryNoticeDate
	,LW.dtmPickupDate
	,LW.dtmDeliveryDate
	,LW.dtmLastFreeDate
	,LW.dtmStrippingReportReceivedDate
	,LW.dtmSampleAuthorizedDate
	,LW.strStrippingReportComments
	,LW.strFreightComments
	,LW.strSampleComments
	,LW.strOtherComments
	,L.intLoadId
	,strShipVia = Hauler.strName
	,strWarehouse = CLSL.strSubLocationName
	,strStorageLocationName = SL.strName
FROM tblLGLoadWarehouse LW
	JOIN tblLGLoad L ON L.intLoadId = LW.intLoadId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
	LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = LW.intHaulerEntityId
	LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = LW.intStorageLocationId
	OUTER APPLY (SELECT TOP 1 ysnShowReceivedLoadsInWarehouseTab = ISNULL(ysnShowReceivedLoadsInWarehouseTab,0) FROM tblLGCompanyPreference) CP
WHERE 
	(CP.ysnShowReceivedLoadsInWarehouseTab = 0 AND L.intShipmentStatus NOT IN (4, 10) AND L.intShipmentType = 1)
	OR CP.ysnShowReceivedLoadsInWarehouseTab = 1
