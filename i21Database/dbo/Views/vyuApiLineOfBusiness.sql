CREATE VIEW [dbo].[vyuApiLineOfBusiness]
AS

SELECT
      lb.intLineOfBusinessId
    , lb.strLineOfBusiness
    , lb.intEntityId
	, e.strName strSalesperson
    , lb.strSICCode
    , lb.strType
    , dtmDateLastUpdated = COALESCE(updated.dtmDate, created.dtmDate)
FROM tblSMLineOfBusiness lb
LEFT JOIN tblEMEntity e ON e.intEntityId = lb.intEntityId
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = lb.intLineOfBusinessId
		AND au.strAction = 'Created'
		AND au.strNamespace = 'i21.view.LineOfBusiness'
) created
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = lb.intLineOfBusinessId
		AND au.strAction = 'Updated'
		AND au.strNamespace = 'i21.view.LineOfBusiness'
) updated