CREATE VIEW [dbo].[vyuTMBudgetCalculationSite]  
AS 

SELECT 
	strCustomerNumber = C.strEntityNo
	,strCustomerName = C.strName
	,strLocation = D.strLocationName 
	,intSiteNumber = A.intSiteNumber
	,strSiteDescription  = A.strDescription
	,strSiteAddress = A.strSiteAddress
	,dblYTDGalsThisSeason = A.dblYTDGalsThisSeason
	,dblYTDGalsLastSeason = A.dblYTDGalsLastSeason
	,dblYTDGals2SeasonsAgo = A.dblYTDGals2SeasonsAgo
	,dblSiteBurnRate = A.dblBurnRate
	,dblSiteEstimatedGallonsLeft = A.dblEstimatedGallonsLeft
	,dblCurrentARBalance = CAST((ISNULL(F.dbl10Days,0.0) + ISNULL(F.dbl30Days,0.0) + ISNULL(F.dbl60Days,0.0)+ ISNULL(F.dbl90Days,0.0) + ISNULL(F.dbl91Days,0.0) + ISNULL(F.dblFuture,0.0) - ISNULL(F.dblUnappliedCredits,0.0)) AS NUMERIC(18,6))
	,E.*
FROM tblTMSite A
INNER JOIN tblTMCustomer B
	ON A.intCustomerID = B.intCustomerID
INNER JOIN tblEntity C
	ON B.intCustomerNumber = C.intEntityId
LEFT JOIN tblSMCompanyLocation D
	ON A.intLocationId = D.intCompanyLocationId
INNER JOIN tblTMBudgetCalculationSite E
	ON A.intSiteID = E.intSiteId
LEFT JOIN vyuARCustomerInquiryReport F
	ON C.intEntityId = F.intEntityCustomerId
		
GO