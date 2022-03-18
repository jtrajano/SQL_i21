CREATE VIEW [dbo].[vyuApiCompanyLocation]
AS
SELECT 
      l.intCompanyLocationId
    , l.strLocationName
    , l.strLocationNumber
    , l.strLocationType
    , l.strAddress
    , l.strZipPostalCode
    , l.strCity
    , l.strStateProvince
    , l.strCountry
    , l.strPhone
    , l.strFax
    , l.strEmail
    , l.strWebsite
    , l.dblLatitude
    , l.dblLongitude
	, created.dtmDate dtmDateCreated
	, COALESCE(updated.dtmDate, created.dtmDate) dtmDateLastUpdated
FROM tblSMCompanyLocation l
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = l.intCompanyLocationId
		AND au.strAction = 'Created'
		AND au.strNamespace = 'i21.view.CompanyLocation'
) created
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = l.intCompanyLocationId
		AND au.strAction = 'Updated'
		AND au.strNamespace = 'i21.view.CompanyLocation'
) updated