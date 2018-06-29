CREATE VIEW [dbo].[vyuTMETExportConsumptionSiteInstruction]  
AS 

SELECT  
	 dipat = C.strEntityNo
	,diseq = REPLICATE('0',4 - LEN(CAST(intSiteNumber AS NVARCHAR))) + CAST(intSiteNumber AS NVARCHAR)
	,ditype = 'S'
	,diinfo = ISNULL(A.strCity,'')+',' + ISNULL(A.strState,'') + ' ' + ISNULL(A.strZipCode,'')
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
	ON B.intCustomerNumber = C.intEntityId
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
LEFT JOIN  (
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
WHERE C.ysnActive = 1
AND A.ysnActive = 1

UNION

SELECT  
	 dipat = C.strEntityNo
	,diseq = REPLICATE('0',4 - LEN(CAST(intSiteNumber AS NVARCHAR))) + CAST(intSiteNumber AS NVARCHAR)
	,ditype = 'C'
	,diinfo = ISNULL(A.strInstruction,'')
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
	ON B.intCustomerNumber = C.intEntityId
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
LEFT JOIN  (
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
WHERE C.ysnActive = 1
AND A.ysnActive = 1

UNION

SELECT  
	 dipat = C.strEntityNo
	,diseq = REPLICATE('0',4 - LEN(CAST(intSiteNumber AS NVARCHAR))) + CAST(intSiteNumber AS NVARCHAR)
	,ditype = 'O'
	,diinfo = ISNULL(A.strComment,'')
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
	ON B.intCustomerNumber = C.intEntityId
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
LEFT JOIN  (
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
WHERE C.ysnActive = 1
AND A.ysnActive = 1


