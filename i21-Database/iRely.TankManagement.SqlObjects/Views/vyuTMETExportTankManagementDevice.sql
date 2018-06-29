CREATE VIEW [dbo].[vyuTMETExportTankManagementDevice]  
AS 

SELECT
	ISNULL(E.strEntityNo,'') CustomerNumber
	,REPLICATE('0',4-LEN(CAST(C.intSiteNumber  AS NVARCHAR(20)))) + CAST(C.intSiteNumber  AS NVARCHAR(20)) ConsumptionSiteNumber
	,CASE WHEN ISNULL(C.intSiteID,0)=0  THEN NULL ELSE ROW_NUMBER() OVER (PARTITION BY C.intSiteID ORDER BY A.intDeviceId DESC) END AS DeviceNumber
	,ISNULL(F.strDeviceType,'') DeviceType
	,ISNULL((SELECT strInventoryStatusType FROM tblTMInventoryStatusType WHERE intInventoryStatusTypeId=A.intInventoryStatusTypeId),'') InventoryStatus	
	,ISNULL(A.strManufacturerID,'') ManufactureID	
	,ISNULL(A.strManufacturerName,'') ManufactureName
	,ISNULL(A.strModelNumber,'') ModelNumber
	,ISNULL(A.strSerialNumber,'') SerialNumber
	,ISNULL(A.strBulkPlant,'') BulkPlantnumber
	,ISNULL(A.strDescription,'') [Description]
	,ISNULL(A.strComment,'') Comment
	,ISNULL(A.strOwnership,'') [Ownership]
	,ISNULL(A.strAssetNumber,'') AssetNumber
	,ISNULL(CONVERT(VARCHAR(10),A.dtmPurchaseDate, 101),'') PurchaseDate
	,ISNULL(A.dblPurchasePrice,0) PurchasePrice
	,ISNULL(CONVERT(VARCHAR(10),A.dtmManufacturedDate, 101),'') ManufacturedDate
	,ISNULL(G.strSerialNumber,'') InstalledonTank
	,ISNULL(H.strLeaseNumber,'') LeaseNumber
	,0 TankSize
	,ISNULL(A.dblTankCapacity,0) TankCapacity
	,ISNULL(A.dblTankReserve,0.0) TankReserve
	,ISNULL(I.strTankType,'') TankType
	,ISNULL(A.dblEstimatedGalTank,0) EstimatedGallonsinTank
	,CASE ISNULL(A.ysnUnderground,0) WHEN 1 THEN 'Yes' ELSE 'No' END Underground
	,ISNULL(J.strRegulatorType,'') RegulatorType
	,ISNULL(K.strMeterType,'') MeterType
	,ISNULL(A.intMeterCycle,0) MeterCycle
	,ISNULL(A.strMeterStatus,'') MeterStatus
	,ISNULL(A.dblMeterReading,0) MeterReading
FROM tblTMDevice A
LEFT JOIN tblTMLeaseDevice AA
	ON A.intDeviceId = AA.intDeviceId
LEFT JOIN tblTMSiteDevice B
	ON A.intDeviceId = B.intDeviceId
LEFT JOIN tblTMSite C
	ON B.intSiteID = C.intSiteID
LEFT JOIN tblTMCustomer D
	ON D.intCustomerID = C.intCustomerID
LEFT JOIN (SELECT 
				Ent.strEntityNo
				,Ent.intEntityId
				,Cus.ysnActive
			FROM tblEMEntity Ent
			INNER JOIN tblARCustomer Cus 
				ON Ent.intEntityId = Cus.[intEntityId]) E
	ON E.intEntityId =D.intCustomerNumber
LEFT JOIN tblTMDeviceType F
	ON F.intDeviceTypeId = A.intDeviceTypeId
LEFT JOIN tblTMDevice G
	ON A.intLinkedToTankID = G.intDeviceId
LEFT JOIN tblTMLease H
	ON H.intLeaseId =AA.intLeaseId
LEFT JOIN tblTMTankType I
	ON I.intTankTypeId = A.intTankTypeId
LEFT JOIN tblTMRegulatorType J
	ON J.intRegulatorTypeId =A.intRegulatorTypeId
LEFT JOIN tblTMMeterType K
	ON K.intMeterTypeId = A.intMeterTypeId
WHERE A.ysnAppliance =0
AND ISNULL(E.strEntityNo,'') <> ''
AND E.ysnActive = 1 AND C.ysnActive=1