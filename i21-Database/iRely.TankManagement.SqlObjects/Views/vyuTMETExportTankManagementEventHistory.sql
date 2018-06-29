CREATE VIEW [dbo].[vyuTMETExportTankManagementEventHistory]  
AS 

SELECT
	ISNULL(D.strEntityNo,'') CustomerNumber
	,REPLICATE('0',4-LEN(CAST(B.intSiteNumber  AS NVARCHAR(20)))) + CAST(B.intSiteNumber  AS NVARCHAR(20)) ConsumptionSiteNumber   
	,ISNULL(CONVERT(VARCHAR(10),A.dtmDate, 101),'') EventDate
	,ISNULL(E.strDescription,'') EventTypeDescription
	,ISNULL(A.strDeviceType,'') DeviceType
	,ISNULL(A.strDeviceSerialNumber,'') DeviceSerialNumber
	,ISNULL(A.strDeviceOwnership,'') DeviceOwnership
	,ISNULL(F.strEntityNo,'') Performer
	,ISNULL(A.strDescription,'') [EventDescription]
FROM tblTMEvent A
INNER JOIN tblTMSite B
	ON A.intSiteID =B.intSiteID
INNER JOIN tblTMCustomer C
	ON C.intCustomerID = B.intCustomerID
INNER JOIN (SELECT 
				Ent.strEntityNo
				,Ent.intEntityId
				,Cus.ysnActive
			FROM tblEMEntity Ent
			INNER JOIN tblARCustomer Cus 
				ON Ent.intEntityId = Cus.[intEntityId]) D
	ON D.intEntityId =C.intCustomerNumber
LEFT JOIN tblTMEventType E
	ON E.intEventTypeID=A.intEventTypeID
LEFT JOIN (
	SELECT 
		 A.strEntityNo
		 ,A.intEntityId
	FROM tblEMEntity A
	LEFT JOIN [tblEMEntityLocation] B
		ON A.intEntityId = B.intEntityId
			AND B.ysnDefaultLocation = 1
	LEFT JOIN [tblEMEntityToContact] D
		ON A.intEntityId = D.intEntityId
			AND D.ysnDefaultContact = 1
	LEFT JOIN tblEMEntity E
		ON D.intEntityContactId = E.intEntityId
	INNER JOIN [tblEMEntityType] C
		ON A.intEntityId = C.intEntityId
	WHERE strType = 'Salesperson'
	) F	
	ON F.intEntityId = A.intPerformerID
WHERE B.ysnActive =1
AND D.ysnActive=1