CREATE VIEW [dbo].[vyuTMBEExportAssetAct]  
AS 

SELECT 
	 account = C.strEntityNo
	 ,number = REPLACE(STR(intSiteNumber, 4), SPACE(1), '0') + '-' + ISNULL(G.strSerialNumber,'')
	 ,reference = ''
	 ,priceID = CAST(F.dblSalePrice AS NUMERIC(8,6))
	 ,priceDiscount = 0.0000
	 ,cashCode = ''
	 ,miscTranCode = ''
	 ,misPriceID = ''
	 ,lastDate =  CONVERT(VARCHAR(10), dtmLastDeliveryDate, 112)
	 ,lastAmount = CAST(ROUND(dblLastDeliveredGal,2) AS NUMERIC(18,2))
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
		A.intItemId
		,A.strItemNo 
		,A.intLocationId
		,A.dblSalePrice
		,A.intUnitMeasureId
	FROM vyuICGetItemPricing A
	WHERE intUnitMeasureId = (SELECT TOP 1 intIssueUOMId FROM tblICItemLocation WHERE intItemId = A.intItemId AND intLocationId = A.intLocationId)
	) F
	ON 	F.intItemId = A.intProduct
		AND A.intLocationId = F.intLocationId
LEFT JOIN (
SELECT 
	AA.intSiteID
	,BB.strSerialNumber
	,intCntId = ROW_NUMBER() OVER (PARTITION BY AA.intSiteID ORDER BY AA.intSiteDeviceID ASC)
FROM tblTMSiteDevice AA
INNER JOIN tblTMDevice BB
	ON AA.intDeviceId = BB.intDeviceId
WHERE ISNULL(BB.ysnAppliance,0) = 0
) G
	ON A.intSiteID = G.intSiteID
	AND G.intCntId = 1
WHERE C.ysnActive = 1 AND A.ysnActive = 1
GO