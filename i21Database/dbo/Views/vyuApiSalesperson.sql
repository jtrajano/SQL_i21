CREATE VIEW [dbo].[vyuApiSalesperson]
AS
SELECT
      e.ysnActive
    , e.intEntityId
    , e.strEntityNumber
    , e.strEntityName
    , e.strEntityType
    , e.strEntityAddress
    , e.strEntityCity
    , e.strEntityState
    , e.strEntityZipCode
    , e.strEntityCountry
    , e.strEntityPhone
    , created.dtmDate dtmDateCreated
	, COALESCE(updated.dtmDate, created.dtmDate) dtmDateLastUpdated
FROM vyuCTEntity e
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = e.intEntityId
		AND au.strAction = 'Created'
		AND au.strNamespace = 'EntityManagement.view.Entity'
) created
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = e.intEntityId
		AND au.strAction = 'Updated'
		AND au.strNamespace = 'EntityManagement.view.Entity'
) updated