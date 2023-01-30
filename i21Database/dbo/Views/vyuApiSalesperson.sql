CREATE VIEW [dbo].[vyuApiSalesperson]
AS
SELECT
      e.ysnActive
    , e.intEntityId
    , e.strSalespersonId as strEntityNumber
    , e.strSalespersonName as strEntityName
    --, CASE WHEN e.strType = 'Sales Representative' THEN 'Salesperson' ELSE e.strType END as strEntityType
	, 'Salesperson' as strEntityType
    , e.strAddress as strEntityAddress
    , e.strCity as strEntityCity
    , e.strState as strEntityState
    , e.strZipCode as strEntityZipCode
    , e.strCountry as strEntityCountry
    , e.strPhone as strEntityPhone
    , e.strEmail
    , created.dtmDate dtmDateCreated
	, COALESCE(updated.dtmDate, created.dtmDate) dtmDateLastUpdated
FROM vyuEMSalesperson e
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
WHERE  e.ysnActive = 1