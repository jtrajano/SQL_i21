CREATE VIEW [dbo].[vyuTMBEExportAssetAct]  
AS 

SELECT 
	 account = C.strEntityNo
	 ,number = REPLACE(STR(intSiteNumber, 4), SPACE(1), '0')
	 ,reference = ''
	 ,priceID = dblStandardCost
	 ,priceDiscount = 0.0000
	 ,cashCode = ''
	 ,miscTranCode = ''
	 ,misPriceID = ''
	 ,lastDate =  CONVERT(VARCHAR(10), dtmLastDeliveryDate, 112)
	 ,lastAmount = dblLastDeliveredGal
FROM tblTMSite A
INNER JOIN tblTMCustomer B
	ON A.intCustomerID =B.intCustomerID
INNER JOIN (SELECT 
				Ent.strEntityNo
				,Ent.intEntityId
				,Cus.ysnActive
			FROM tblEMEntity Ent
			INNER JOIN tblARCustomer Cus 
				ON Ent.intEntityId = Cus.intEntityCustomerId) C
	ON B.intCustomerNumber = C.intEntityId
LEFT JOIN (
	SELECT 
		A.intItemId
		,A.strItemNo 
		,A.intLocationId
		,A.dblStandardCost
	FROM vyuICGetItemPricing A
	) F
	ON 	F.intItemId = A.intProduct
		AND A.intLocationId = F.intLocationId
WHERE C.ysnActive = 1 AND A.ysnActive = 1
GO