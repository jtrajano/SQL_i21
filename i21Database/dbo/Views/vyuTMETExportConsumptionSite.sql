﻿CREATE VIEW [dbo].[vyuTMETExportConsumptionSite]  
AS 

SELECT 
 dmpat = C.strEntityNo 
,dmtank = REPLICATE('0',4-LEN(CAST(intSiteNumber AS NVARCHAR))) + CAST(intSiteNumber AS NVARCHAR)
,dbtype = 0
,dmdriv = D.strEntityNo
,rmrte =  G.strRouteId
,dmtsze = ISNULL(A.dblTotalCapacity,0)
,dmldd = ISNULL(A.intLastDeliveryDegreeDay,0)
,dmndd = ISNULL(A.intNextDeliveryDegreeDay,0)
,ddytdg = ISNULL(A.dblYTDGalsThisSeason,0)
,ddgal = ISNULL(A.dblLastDeliveredGal,0)
,ddming = ISNULL(A.dblLastGalsInTank,0)
,ddonhg = 0
,dmusab = ISNULL(A.dblTotalCapacity,0)
,ddkfac = ISNULL(A.dblBurnRate,0.00) 
,ddwill = ISNULL(E.strFillMethod,'')
,dmdate = ISNULL(CONVERT(VARCHAR,A.dtmLastDeliveryDate,112),'00000000')
,dmetype =	CASE (SELECT TOP 1 strOwnership FROM tblTMDevice WHERE intDeviceId IN 
					(SELECT intDeviceId FROM tblTMSiteDevice WHERE intSiteID =A.intSiteID))
			WHEN 'Company Owned' THEN
				'CO'
			WHEN 'Customer Owned' THEN
				'O'
			WHEN 'Lease' THEN
				'L'
			WHEN 'Lease to Own' THEN
				'LTO'
			WHEN 'Rent' THEN
				'R'
			ELSE
				''
			END
,dmserl = ISNULL((SELECT TOP 1 strSerialNumber FROM tblTMDevice WHERE intDeviceId IN 
				(SELECT intDeviceId FROM tblTMSiteDevice WHERE intSiteID = A.intSiteID) 
				and ysnAppliance = 0 
				AND intDeviceTypeId = (SELECT TOP 1 intDeviceTypeId 
					  FROM tblTMDeviceType 
					  where strDeviceType = 'Tank') 
				  ), '')
,dmset = CASE (SELECT TOP 1 1 FROM tblTMEvent A INNER JOIN tblTMEventType B ON A.intEventTypeID = B.intEventTypeID WHERE B.strEventType = 'Event-009' AND intSiteID = A.intSiteID) WHEN NULL THEN 
			0 
		 ELSE 
			ISNULL(CONVERT(VARCHAR,dtmLastDeliveryDate,112),'00000000') 
		 END
,dmuse = LEFT(ISNULL(A.strAcctStatus,''),3)
,dmprcd = ''
,dmcomm = ISNULL(F.strItemNo,'')
,dbcoun = ISNULL(A.strCountry,'')
,dmtwns = ISNULL((SELECT strTankTownship FROM tblTMTankTownship WHERE intTankTownshipId = A.intTankTownshipId),'')
,dmrtpr = ''
,dmrtsq = CASE WHEN ISNUMERIC(CAST(A.strSequenceID AS NVARCHAR(50))) = 1 THEN LEFT(CAST(ISNULL(A.strSequenceID,0) AS NUMERIC(18,0)),5) ELSE 0 END
,dmtref = 0
FROM tblTMSite A
INNER JOIN tblTMCustomer B
	ON A.intCustomerID =B.intCustomerID
INNER JOIN (SELECT 
				Ent.strEntityNo
				,Ent.intEntityId
				,Cus.ysnActive
			FROM tblEntity Ent
			INNER JOIN tblARCustomer Cus 
				ON Ent.intEntityId = Cus.intEntityCustomerId) C
	ON B.intCustomerNumber =C.intEntityId
LEFT JOIN (
	SELECT 
		 A.strEntityNo
		 ,A.intEntityId
	FROM tblEntity A
	LEFT JOIN tblEntityLocation B
		ON A.intEntityId = B.intEntityId
			AND B.ysnDefaultLocation = 1
	LEFT JOIN tblEntityToContact D
		ON A.intEntityId = D.intEntityId
			AND D.ysnDefaultContact = 1
	LEFT JOIN tblEntity E
		ON D.intEntityContactId = E.intEntityId
	INNER JOIN tblEntityType C
		ON A.intEntityId = C.intEntityId
	WHERE strType = 'Salesperson'
	) D
	ON D.intEntityId = A.intDriverID
LEFT JOIN tblTMFillMethod E
	ON A.intFillMethodId = E.intFillMethodId
LEFT JOIN (
	SELECT 
		A.intItemId
		,A.strItemNo 
		,C.intCompanyLocationId
	FROM tblICItem A
	INNER JOIN tblICItemLocation B
		ON A.intItemId = B.intItemId
	INNER JOIN tblSMCompanyLocation C
		ON B.intLocationId = C.intCompanyLocationId
	LEFT JOIN tblICCategory D
		ON A.intCategoryId = D.intCategoryId
	LEFT JOIN tblICItemPricing E
		ON A.intItemId = E.intItemId 
		AND B.intLocationId = E.intItemLocationId
	) F
	ON 	F.intItemId = A.intProduct
		AND A.intLocationId = F.intCompanyLocationId
LEFT JOIN tblTMRoute G
	ON A.intRouteId = G.intRouteId
WHERE C.ysnActive = 1 AND A.ysnActive = 1
GO