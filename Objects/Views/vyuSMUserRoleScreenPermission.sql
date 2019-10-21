CREATE VIEW [dbo].[vyuSMUserRoleScreenPermission]
	AS 
SELECT intUserRoleScreenPermissionId
,intUserRoleId
,sp.intScreenId
,strPermission
,s.strScreenName as strUserScreen
,cs.strScreenName as strContactScreen
,s.strModule
,s.strNamespace
,sp.intConcurrencyId 
FROM tblSMUserRoleScreenPermission sp
LEFT JOIN tblSMScreen s ON sp.intScreenId = s.intScreenId
LEFT JOIN vyuSMContactScreen cs ON cs.intScreenId = s.intScreenId
