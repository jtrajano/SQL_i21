
--CHECK ALSO the recreate SP
CREATE VIEW [dbo].[vyuTMDriverUsedBySite]  
AS 

SELECT DISTINCT
	A.strEntityNo
	,A.intEntityId
	,strName = A.strName
	,intConcurrencyId = 0
FROM tblEMEntity A
INNER JOIN [tblEMEntityType] B
	ON A.intEntityId = B.intEntityId
INNER JOIN tblTMSite C
	ON A.intEntityId = C.intDriverID
WHERE B.strType = 'Salesperson'
		
GO