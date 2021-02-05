CREATE VIEW vyuIPAuditView
AS
SELECT 
	A.intAuditId
	,A.intLogId
	,A.strAction
	,A.strChange
	,A.strFrom
	,A.strTo
	,A.strAlias
	,A.ysnField
	,A.ysnHidden
	,A.intParentAuditId
FROM tblSMAudit A 
