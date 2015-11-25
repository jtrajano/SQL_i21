
--CHECK ALSO the recreate SP
CREATE VIEW [dbo].[vyuTMRouteUsedBySite]  
AS 

SELECT DISTINCT
	A.strRouteId
	,A.intRouteId
	,intConcurrencyId = 0
FROM tblTMRoute A
INNER JOIN tblTMSite B
	ON A.intRouteId = B.intRouteId
		
GO