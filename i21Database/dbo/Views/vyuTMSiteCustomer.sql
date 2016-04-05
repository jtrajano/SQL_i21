CREATE VIEW [dbo].[vyuTMSiteCustomer]
AS  
	SELECT 
		A.intSiteID
		,A.intCustomerID
		,B.intCurrentSiteNumber
		,C.strName
		,C.strEntityNo
		,A.intConcurrencyId
	FROM tblTMSite A
	INNER JOIN tblTMCustomer B
		ON A.intCustomerID = B.intCustomerID
	INNER JOIN tblEMEntity C
		ON B.intCustomerNumber = C.intEntityId
GO

