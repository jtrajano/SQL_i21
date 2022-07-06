CREATE VIEW [dbo].[vyuApiCountry]
AS
SELECT
      c.intCountryID
    , c.strCountry
    , c.strISOCode
    , c.strCountryCode
    , c.strCountryFormat
    , c.strAreaCityFormat
    , c.strLocalNumberFormat
    , c.intAreaCityLength
    , COALESCE(updated.dtmDate, created.dtmDate) dtmDateLastUpdated
FROM tblSMCountry c
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = c.intCountryID
		AND au.strAction = 'Created'
		AND au.strNamespace = 'i21.view.Country'
) created
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = c.intCountryID
		AND au.strAction = 'Updated'
		AND au.strNamespace = 'i21.view.Country'
) updated