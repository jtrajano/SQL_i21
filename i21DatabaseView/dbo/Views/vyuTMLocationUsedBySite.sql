
--CHECK ALSO the recreate SP
CREATE VIEW [dbo].[vyuTMLocationUsedBySite]  
AS 

SELECT DISTINCT
	A.strLocationName
	,intLocationId = A.intCompanyLocationId
	,intConcurrencyId = 0
FROM tblSMCompanyLocation A
INNER JOIN tblTMSite B
	ON A.intCompanyLocationId = B.intLocationId
		
GO