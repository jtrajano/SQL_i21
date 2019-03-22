CREATE VIEW [dbo].[vyuTMCustomer]
AS  
	SELECT 
		A.intCustomerID
		,C.strName
		,C.strEntityNo
		,intSiteCount = COUNT(A.intCustomerID)
		,B.intConcurrencyId
	FROM tblTMSite A
	INNER JOIN tblTMCustomer B
		ON A.intCustomerID = B.intCustomerID
	INNER JOIN tblEMEntity C
		ON B.intCustomerNumber = C.intEntityId
	GROUP BY A.intCustomerID,C.strName,C.strEntityNo,B.intConcurrencyId
GO
