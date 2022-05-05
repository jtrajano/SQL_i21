CREATE VIEW [dbo].[vyuLGCustomerConsumptionSite]
AS  
	SELECT 
		A.intSiteID
		,strSiteID = RIGHT('000'+ CAST(A.intSiteNumber AS NVARCHAR(4)),4)  COLLATE Latin1_General_CI_AS
		,A.strDescription
		,A.intCustomerID
		,C.strName
		,C.strEntityNo
		,D.intEntityLocationId
		,D.strLocationName
		,B.intCurrentSiteNumber
		,ysnLocationActive = D.ysnActive
		,ysnSiteActive = A.ysnActive 
		,A.intConcurrencyId
	FROM tblTMSite A
	INNER JOIN tblTMCustomer B
		ON A.intCustomerID = B.intCustomerID
	INNER JOIN tblEMEntity C
		ON B.intCustomerNumber = C.intEntityId
	INNER JOIN tblEMEntityLocation D
		ON C.intEntityId = D.intEntityId 
	INNER JOIN tblEMEntityLocationConsumptionSite E
		ON D.intEntityLocationId = E.intEntityLocationId
GO