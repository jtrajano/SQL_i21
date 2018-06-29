CREATE VIEW [dbo].vyuTMDeliveryFillGroupSubReport  
AS 

SELECT 
	strCustomerNumber = A.vwcus_key 
	,strCustomerName = A.strFullCustomerName
	,C.intSiteNumber
	,strSiteAddress = REPLACE(REPLACE (C.strSiteAddress, CHAR(13), ' '),CHAR(10), ' ') 
	,strSiteDescription = C.strDescription 
	,strFillGroupCode = ISNULL(D.strFillGroupCode, '')  
	,C.intFillGroupId 
	,strFillGroupDescription = D.strDescription
	,ysnFillGroupActive = D.ysnActive
	,intSiteId = intSiteID
FROM vyuTMCustomerEntityView A 
INNER JOIN tblTMCustomer B 
	ON A.A4GLIdentity = B.intCustomerNumber 
INNER JOIN tblTMSite C 
	ON B.intCustomerID = C.intCustomerID 
INNER JOIN tblTMFillGroup D 
	ON D.intFillGroupId = C.intFillGroupId
WHERE C.ysnActive= 1 
	AND  A.vwcus_active_yn = 'Y' 
	AND (C.ysnOnHold = 0 OR C.dtmOnHoldEndDate < DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0))    

GO