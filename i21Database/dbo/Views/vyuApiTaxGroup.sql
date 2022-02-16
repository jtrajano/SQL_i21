CREATE VIEW [dbo].[vyuApiTaxGroup]
AS

SELECT
      t.intTaxGroupId
    , t.strTaxGroup
    , t.strDescription
    , created.dtmDate dtmDateCreated
	, COALESCE(updated.dtmDate, created.dtmDate) dtmDateLastUpdated
FROM tblSMTaxGroup t
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = t.intTaxGroupId
		AND au.strAction = 'Created'
		AND au.strNamespace = 'i21.view.TaxGroup'
) created
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = t.intTaxGroupId
		AND au.strAction = 'Updated'
		AND au.strNamespace = 'i21.view.TaxGroup'
) updated