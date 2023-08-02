CREATE VIEW [dbo].[vyuTMFeeSearch]
AS  
	SELECT 
		intFeeId = A.intFeeId
		,dtmDate = A.dtmDateTime
		,strFeeTypeDescription = D.strFeeTypeDescription
		,strDescription = A.strDescription
		,dblAmount = A.dblAmount
		,ysnUniversal = A.ysnUniversal
		,strCustomer = A.strCustomers
		,intConcurrencyId = 0
	FROM tblTMFee A
	LEFT JOIN tblTMSiteFee B
		ON A.intFeeId = B.intFeeId
	LEFT JOIN tblTMSite C
		ON B.intSiteID = C.intSiteID
	LEFT JOIN tblTMFeeType D
		ON A.intFeeTypeId = D.intFeeTypeId
	LEFT JOIN tblTMCustomer F
		ON C.intCustomerID = F.intCustomerID
	LEFT JOIN tblEMEntity G
		ON F.intCustomerNumber = G.intEntityId
	
GO