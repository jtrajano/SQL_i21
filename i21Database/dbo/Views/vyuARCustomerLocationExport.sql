CREATE VIEW [dbo].[vyuARCustomerLocationExport]
AS
SELECT intEntityId				= ARC.intEntityId
	 , strCustomerName			= EME.strName
     , intEntityLocationId		= EMEL.intEntityLocationId
     , strLocationName			= EMEL.strLocationName
     , strAddress				= ISNULL(EMEL.strAddress, '')
     , strCity					= ISNULL(EMEL.strCity, '')
     , strCountry				= ISNULL(EMEL.strCountry, '')
     , strCounty				= ISNULL(EMEL.strCounty, '')
     , strState					= ISNULL(EMEL.strState, '')
     , strZipCode				= ISNULL(EMEL.strZipCode, '')
     , strPhone					= ISNULL(EMEL.strPhone, '')
     , strFax					= ISNULL(EMEL.strFax, '')
     , strNotes					= ISNULL(EMEL.strNotes, '')
     , ysnActive				= EMEL.ysnActive
     , dblLongitude				= EMEL.dblLongitude
     , dblLatitude				= EMEL.dblLatitude
     , strTimezone				= ISNULL(EMEL.strTimezone, '')
     , strShipVia				= ISNULL(SMSV.strShipVia, '')
FROM tblARCustomer ARC
INNER JOIN tblEMEntityLocation EMEL ON ARC.intEntityId = EMEL.intEntityId
INNER JOIN tblEMEntity EME ON ARC.intEntityId = EME.intEntityId
LEFT JOIN tblSMShipVia SMSV ON EMEL.intShipViaId = SMSV.intEntityId