
--CHECK ALSO the recreate SP
CREATE VIEW [dbo].[vyuTMDriverUsedBySite]  
AS 

SELECT DISTINCT
	A.strEntityNo
	,A.intEntityId
	,intConcurrencyId = 0
FROM tblEntity A
INNER JOIN tblEntityType B
	ON A.intEntityId = B.intEntityId
INNER JOIN tblTMSite C
	ON A.intEntityId = C.intDriverID
WHERE B.strType = 'Salesperson'
		
GO