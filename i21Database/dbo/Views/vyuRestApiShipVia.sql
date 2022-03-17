CREATE VIEW [dbo].[vyuRestApiShipVia]
AS
SELECT
      v.intEntityId
    , e.strEntityNo
	, e.strName strEntityName --Carrier Name
    , v.strShipVia
    , e.strExternalERPId
    , l.strLocationName
    , l.strAddress
    , l.strCity
    , l.strState
    , l.strZipCode
    , l.strTimezone
    , l.dblLatitude
    , l.dblLongitude
    , c.strEmail
	, c.strName strContactName
	, c.strPhone
	, c.strMobile
  , v.strShippingService
  , v.strTransportationMode
  , v.strFreightBilledBy
FROM tblSMShipVia v
INNER JOIN tblEMEntity e ON e.intEntityId = v.intEntityId
OUTER APPLY (
    SELECT  *
    FROM tblEMEntityLocation el
    WHERE el.intEntityId = e.intEntityId
		AND el.ysnDefaultLocation = 1
) l
OUTER APPLY (
    SELECT Contact.intEntityId
		, Contact.strName
		, Contact.strEmail
		, Contact.strPhone
		, Contact.strMobile
    FROM tblEMEntityToContact EntityToContact
	JOIN tblEMEntity Contact ON EntityToContact.intEntityContactId = Contact.intEntityId
		AND EntityToContact.ysnDefaultContact = 1
    WHERE EntityToContact.intEntityId = e.intEntityId
) c