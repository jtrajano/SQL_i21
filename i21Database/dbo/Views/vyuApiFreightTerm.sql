CREATE VIEW [dbo].[vyuApiFreightTerm]
AS

SELECT
      f.intFreightTermId
    , f.strFreightTerm
    , f.strDescription
    , f.strFobPoint
    , f.ysnActive
    , dtmLastUpdated = COALESCE(updated.dtmDate, created.dtmDate)
FROM tblSMFreightTerms f
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = f.intFreightTermId
		AND au.strAction = 'Created'
		AND au.strNamespace = 'i21.view.FreightTerm'
) created
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = f.intFreightTermId
		AND au.strAction = 'Updated'
		AND au.strNamespace = 'i21.view.FreightTerm'
) updated