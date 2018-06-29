CREATE VIEW [dbo].[vyuTMVirtualMeterBilling]    
AS    
SELECT   
	strSiteCustomerNo = C.strEntityNo
	,strSiteCustomerName = C.strName
	,strSiteNumber =  RIGHT('0000'+CAST(A.intSiteNumber AS VARCHAR(4)),4)
	,strSiteDescription = A.strDescription
	,strSiteAddress = A.strSiteAddress
	,strSiteLocation = D.strLocationName
	,strItemNo = E.strItemNo
	,dblPercentInTankLastBilling = 0.0
	,dblGalsSinceLastBilling = 0.0
	,dblPercentInTank = A.dblEstimatedPercentLeft								
	,dblCalculatedGallons = 0.0
	,dblPrice = 0.0
	,dblTotal = 0.0
	,intSiteId = A.intSiteID
	,intCustomerId = A.intCustomerID
	,intLocationId = A.intLocationId
	,intConcurrencyId = A.intConcurrencyId
FROM tblTMSite A  
INNER JOIN tblTMCustomer B  
 ON A.intCustomerID = B.intCustomerID  
INNER JOIN tblEMEntity C  
 ON B.intCustomerNumber = C.intEntityId    
LEFT JOIN tblSMCompanyLocation D  
 ON A.intLocationId = D.intCompanyLocationId  
LEFT JOIN tblICItem E  
 ON A.intProduct = E.intItemId  
INNER JOIN tblARCustomer F  
 ON F.[intEntityId] = C.intEntityId  
WHERE F.ysnActive = 1  
 AND A.ysnActive = 1  
 AND A.strBillingBy = 'Virtual Meter'  