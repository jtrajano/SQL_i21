CREATE VIEW [dbo].[vyuTMBEExportConsumptionSite]  
AS 

SELECT 
	 account = C.strEntityNo
	 ,number = REPLACE(STR(intSiteNumber, 4), SPACE(1), '0') + '-' + ISNULL(H.strSerialNumber,'')
	 ,productCode = F.strItemNo
	 ,size = CAST(ROUND(A.dblTotalCapacity,2) AS NUMERIC(18,2))
	 ,taxCode = A.intTaxStateID
	 ,deliveryType = E.strFillMethod
	 ,address1 = CAST((CASE WHEN CHARINDEX(CHAR(10),A.strSiteAddress,0) = 0 THEN A.strSiteAddress ELSE SUBSTRING(A.strSiteAddress,0,CHARINDEX(CHAR(10),A.strSiteAddress,0)) END) AS NVARCHAR(35))
	 ,address2 = CAST((CASE WHEN CHARINDEX(CHAR(10),A.strSiteAddress,0) = 0 THEN '' ELSE SUBSTRING(A.strSiteAddress,CHARINDEX(CHAR(10),A.strSiteAddress,0) + 1, LEN(A.strSiteAddress) -  CHARINDEX(CHAR(10),A.strSiteAddress,0) + 1) END)  AS NVARCHAR(35))
	 ,city = A.strCity
	 ,"state" = CAST(A.strState AS NVARCHAR(2))
	 ,"zip" = A.strZipCode
	 ,"country" = A.strCountry
	 ,"zone" = ''
	 ,"applications"= 'FFFF'
	 ,"longitude" = dblLongitude
	 ,"latitude" = A.dblLatitude
	 ,"altitude" = ''
	 ,"directions" = A.strInstruction
FROM tblTMSite A
INNER JOIN tblTMCustomer B
	ON A.intCustomerID =B.intCustomerID
INNER JOIN (SELECT 
				Ent.strEntityNo
				,Ent.intEntityId
				,Cus.ysnActive
			FROM tblEMEntity Ent
			INNER JOIN tblARCustomer Cus 
				ON Ent.intEntityId = Cus.[intEntityId]) C
	ON B.intCustomerNumber =C.intEntityId
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
LEFT JOIN (
	SELECT 
		AA.intSiteID
		,BB.strSerialNumber
		,intCntId = ROW_NUMBER() OVER (PARTITION BY AA.intSiteID ORDER BY AA.intSiteDeviceID ASC)
	FROM tblTMSiteDevice AA
	INNER JOIN tblTMDevice BB
		ON AA.intDeviceId = BB.intDeviceId
	WHERE ISNULL(BB.ysnAppliance,0) = 0
) H
	ON A.intSiteID = H.intSiteID
	AND H.intCntId = 1
WHERE C.ysnActive = 1 AND A.ysnActive = 1
GO