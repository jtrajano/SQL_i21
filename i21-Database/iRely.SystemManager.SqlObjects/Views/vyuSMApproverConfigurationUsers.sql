CREATE VIEW [dbo].[vyuSMApproverConfigurationUsers]
AS 
SELECT SearchEntityUserSecurity.intEntityId
,SearchEntityUserSecurity.strName
,CAST(ISNULL(ApproverConfiguration.intEntityId, 0) AS BIT) AS ysnConfigured 
FROM vyuEMSearchEntityUserSecurity SearchEntityUserSecurity
LEFT JOIN tblSMApproverConfiguration ApproverConfiguration ON SearchEntityUserSecurity.intEntityId = ApproverConfiguration.intEntityId 
