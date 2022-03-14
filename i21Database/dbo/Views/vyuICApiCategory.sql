CREATE VIEW [dbo].[vyuICApiCategory]
AS

SELECT c.intCategoryId, c.strCategoryCode, c.strDescription, c.ysnRetailValuation, lob.strLineOfBusiness, c.dtmDateCreated, c.dtmDateModified
, COALESCE(updated.dtmDate, created.dtmDate, c.dtmDateModified, c.dtmDateCreated) dtmDateLastUpdated
FROM tblICCategory c
LEFT OUTER JOIN tblSMLineOfBusiness lob ON lob.intLineOfBusinessId = c.intLineOfBusinessId
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = c.intCategoryId
		AND au.strAction = 'Created'
		AND au.strNamespace = 'Inventory.view.Category'
) created
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = c.intCategoryId
		AND au.strAction = 'Updated'
		AND au.strNamespace = 'Inventory.view.Category'
) updated