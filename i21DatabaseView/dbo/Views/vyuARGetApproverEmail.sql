CREATE VIEW [dbo].[vyuARGetApproverEmail]
AS 
SELECT AL.intApprovalListId
     , EC.strEmail
	 , EC.strEntityName
	 , ALUS.intEntityUserSecurityId 
FROM tblSMApprovalList AL
INNER JOIN tblSMApprovalListUserSecurity ALUS ON AL.intApprovalListId = ALUS.intApprovalListId
INNER JOIN vyuEMEntityContact EC ON ALUS.intEntityUserSecurityId = EC.intEntityId