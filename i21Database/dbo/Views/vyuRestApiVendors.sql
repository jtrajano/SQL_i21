CREATE VIEW [dbo].[vyuRestApiVendors]
AS
SELECT
	strVendorNumber = vendor.strVendorId,
	strVendorName = entity.strName,
	entity.intEntityId,
	strAccountType = CASE vendor.intVendorType WHEN 0 THEN 'Company' ELSE 'Person' END,
	contactEntity.strName strContactName,
	vendor.intShipFromId intShipFromLocationId,
	entityLocation.strLocationName shipFromLocationName,
	vendor.dtmCreated,
	vendor.dtmLastModified dtmDateModified,
	vendor.ysnPymtCtrlActive ysnActive,
	entity.dtmOriginationDate,
	-- Contact Info
	strFirstName = CASE WHEN vendor.intVendorType = 0 THEN contactEntity.strName ELSE SUBSTRING(contactEntity.strName, 0, dbo.fnLastIndex(contactEntity.strName,' ')) END,
	strLastName = CASE WHEN vendor.intVendorType = 0 THEN contactEntity.strName ELSE SUBSTRING(contactEntity.strName, 0, dbo.fnLastIndex(contactEntity.strName,' ')) END,
	strAddress1	= CAST(CASE WHEN CHARINDEX(CHAR(10), entityLocation.strAddress) > 0 
				THEN SUBSTRING(entityLocation.strAddress, 0, CHARINDEX(CHAR(10),entityLocation.strAddress)) 
				ELSE entityLocation.strAddress END AS VARCHAR(30)),
	strAddress2	= CAST(CASE WHEN CHARINDEX(CHAR(10), entityLocation.strAddress) > 0 
					THEN SUBSTRING(entityLocation.strAddress, CHARINDEX(CHAR(10),entityLocation.strAddress), LEN(entityLocation.strAddress)) 
					ELSE '' END AS VARCHAR(30)),
	strCity				=	ISNULL(entityLocation.strCity,''),
	strStateProv		=	ISNULL(entityLocation.strState,''),
	strPostalCode		=	ISNULL(entityLocation.strZipCode,''),
	strPhone			=	ISNULL(phoneNumber.strPhone,''),
	strMobile			=	ISNULL(contactEntity.strMobile,''),
	strFax				=	ISNULL(contactEntity.strFax,''),
	strEmail			=	ISNULL(contactEntity.strEmail,''),
	strWebsite			=	ISNULL(contactEntity.strWebsite,''),
	strCountry			=	ISNULL(entityLocation.strCountry, ''),
	CAST(CASE terminal.ysnTransportTerminal WHEN 1 THEN 1 ELSE 0 END AS BIT) ysnTransportTerminal,
	CAST(CASE WHEN ISNULL(terminal.ysnTransportTerminal, 0) = 0 AND vendor.ysnTransportTerminal = 1 THEN 1 ELSE 0 END AS BIT) ysnSupplier,
	entityLocation.intShipViaId,
	shipVia.strShipVia
FROM tblAPVendor vendor
JOIN tblEMEntity entity ON entity.intEntityId = vendor.intEntityId
JOIN tblEMEntityType entityType ON entityType.intEntityId = entity.intEntityId
	AND entityType.strType = 'Vendor'
LEFT JOIN tblEMEntityToContact entityContact ON entityContact.intEntityId = entity.intEntityId
	AND entityContact.ysnDefaultContact = 1
LEFT JOIN tblEMEntity contactEntity ON entityContact.intEntityContactId = contactEntity.intEntityId
LEFT JOIN tblEMEntityLocation entityLocation ON entityLocation.intEntityId = entityContact.intEntityId
	AND entityLocation.intEntityLocationId = entityContact.intEntityLocationId
LEFT JOIN tblEMEntityLocation shipFromLocation ON shipFromLocation.intEntityLocationId = vendor.intShipFromId
	AND shipFromLocation.intEntityId = vendor.intEntityId
LEFT JOIN tblEMEntityPhoneNumber phoneNumber ON phoneNumber.intEntityId = contactEntity.intEntityId
LEFT JOIN tblSMShipVia shipVia ON shipVia.intEntityId = entityLocation.intShipViaId
OUTER APPLY (
	SELECT TOP 1 CAST(1 AS BIT) AS ysnTransportTerminal
	FROM vyuApiTransportTerminals t
	WHERE t.intEntityId = vendor.intEntityId
) terminal
--ORDER BY v.strName ASC, v.ysnActive DESC, v.dtmOriginationDate ASC

GO


