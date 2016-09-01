﻿CREATE VIEW [dbo].[vyuTMBEExportDispatch]  
AS 

SELECT 
	 routeNum = J.strRouteId
	 ,seqNum = ''
	 ,account = CAST(C.strEntityNo AS NVARCHAR(16))
	 ,asset = REPLACE(STR(A.intSiteNumber, 4), SPACE(1), '0')
	 ,orderQty = CAST(ROUND((CASE WHEN ISNULL(D.dblMinimumQuantity,0) = 0 THEN ISNULL(D.dblQuantity,0.0) ELSE D.dblMinimumQuantity END),0) AS INT)
	 ,priceID = CAST(D.dblPrice AS NVARCHAR(16))
	 ,invoice = ''
	 ,"message" = CAST(D.strComments AS NVARCHAR(64))
	 ,reference = D.intDispatchID
	 ,taxCode = A.intTaxStateID
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
	ON B.intCustomerNumber =C.intEntityId
INNER JOIN tblTMDispatch D
	ON A.intSiteID = D.intSiteID
LEFT JOIN tblTMRoute J
	ON A.intRouteId = J.intRouteId
LEFT JOIN tblSMTaxGroup H
	ON A.intTaxStateID = H.intTaxGroupId
WHERE C.ysnActive = 1 AND A.ysnActive = 1
GO