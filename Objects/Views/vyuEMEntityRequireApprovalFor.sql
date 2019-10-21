CREATE VIEW [dbo].[vyuEMEntityRequireApprovalFor]
AS 
SELECT CAST (ROW_NUMBER() OVER (ORDER BY strEntityName DESC) AS INT) AS intEntityRequireApprovalForId
,intEntityId
,strEntityName
,strScreenName
,strApprovalList
,ysnPortalUserOnly
,intEntityUserSecurityId
,strApproverName
,strEmail
FROM
(
	SELECT a.intEntityId as intEntityId, c.strName as strEntityName, b.strScreenName, d.strApprovalList, a.ysnPortalUserOnly, e.intEntityUserSecurityId, f.strName as strApproverName, f.strEmail
	FROM tblEMEntityRequireApprovalFor a
	INNER JOIN tblSMScreen b ON a.intScreenId = b.intScreenId
	INNER JOIN tblEMEntity c ON c.intEntityId = a.intEntityId
	INNER JOIN tblSMApprovalList d ON d.intApprovalListId = a.intApprovalListId
	INNER JOIN tblSMApprovalListUserSecurity e ON e.intApprovalListId = d.intApprovalListId
	INNER JOIN tblEMEntity f ON f.intEntityId = e.intEntityUserSecurityId
	UNION ALL
	SELECT a.intEntityId as intEntityId,c.strName as strEntityName, b.strScreenName, d.strApprovalList, a.ysnPortalUserOnly, f.intEntityUserSecurityId, g.strName as strApproverName, g.strEmail
	FROM tblEMEntityRequireApprovalFor a
	INNER JOIN tblSMScreen b ON a.intScreenId = b.intScreenId
	INNER JOIN tblEMEntity c ON c.intEntityId = a.intEntityId
	INNER JOIN tblSMApprovalList d ON d.intApprovalListId = a.intApprovalListId
	INNER JOIN tblSMApprovalListUserSecurity e ON d.intApprovalListId = e.intApprovalListId
	INNER JOIN tblSMApproverGroupUserSecurity f ON f.intApproverGroupId = e.intApproverGroupId
	INNER JOIN tblEMEntity g ON g.intEntityId = f.intEntityUserSecurityId
) tbl
