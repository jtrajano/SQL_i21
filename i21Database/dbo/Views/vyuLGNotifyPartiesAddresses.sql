CREATE VIEW vyuLGNotifyPartiesAddresses
AS
	SELECT	ENLOC.intEntityId, 
			ENLOC.intEntityLocationId, 
			ENLOC.strLocationName,
			ENLOC.strAddress, 
			ENLOC.strCity, 
			ENLOC.strCountry, 
			ENLOC.strState, 
			ENLOC.strZipCode, 
			ENLOC.strPhone, 
			ENLOC.strFax,
			ENTYPE.strType
	FROM	tblEntityLocation ENLOC
	JOIN	tblEntityType ENTYPE ON ENTYPE.intEntityId = ENLOC.intEntityId  

	UNION ALL

	SELECT	intCompanySetupID	AS			intEntityId, 
			-1					AS			intEntityLocationId, 
			strCompanyName AS strLocationName,
			strAddress, 
			strCity, 
			strCountry, 
			strState, 
			strZip				AS			strZipCode, 
			strPhone, 
			strFax,
			'Company'			AS			strType
	FROM	tblSMCompanySetup
