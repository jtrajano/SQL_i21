CREATE VIEW [dbo].[vyuTMETExportTankManagementAppliance]  
AS 

SELECT
	ISNULL(E.strEntityNo,'') CustomerNumber
	,REPLICATE('0',4-LEN(CAST(C.intSiteNumber  AS NVARCHAR(20)))) + CAST(C.intSiteNumber  AS NVARCHAR(20)) ConsumptionSiteNumber
	,ISNULL(F.strApplianceType,'') ApplianceType
	,ISNULL(A.strDescription,'') [Description]
	,ISNULL(A.strManufacturerName,'') ManufactureName
	,ISNULL(A.strModelNumber,'') ModelNumber
	,ISNULL(A.strSerialNumber,'')SerialNumber
	,ISNULL(CONVERT(VARCHAR(10),A.dtmPurchaseDate, 101),'') PurchaseDate
	,ISNULL(CONVERT(VARCHAR(10),A.dtmManufacturedDate, 101),'') ManufacturedDate
	,ISNULL(A.strComment,'')Comment
FROM tblTMDevice A
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
	ON E.intEntityId = D.intCustomerNumber
LEFT JOIN tblTMApplianceType F
	ON F.intApplianceTypeID = A.intApplianceTypeID
WHERE A.ysnAppliance =1
AND 
	(E.strEntityNo IS NOT NULL
	OR F.strApplianceType IS NOT NULL
	OR A.strDescription IS NOT NULL
	OR A.strManufacturerName IS NOT NULL
	OR A.strModelNumber IS NOT NULL
	OR A.strSerialNumber  IS NOT NULL
	OR A.strComment  IS NOT NULL
	)
AND RTRIM(ISNULL(E.strEntityNo,'')) <> ''
AND E.ysnActive = 1 AND C.ysnActive=1