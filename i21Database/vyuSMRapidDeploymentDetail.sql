CREATE VIEW [dbo].[vyuSMRapidDeploymentDetail]
AS 
SELECT
	  A.*
	, strUserAssigned = E.strName
	, strUserCompleted = E1.strName
FROM tblSMRapidDeploymentDetail A
LEFT JOIN tblEMEntity E
	ON E.intEntityId = A.intUserAssignedId
LEFT JOIN tblEMEntity E1
	ON E1.intEntityId = A.intUserCompletedId