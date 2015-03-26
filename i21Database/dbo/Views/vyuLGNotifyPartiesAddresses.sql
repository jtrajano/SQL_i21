CREATE VIEW vyuLGNotifyPartiesAddresses
AS
	SELECT	intEntityId, 
			intEntityLocationId, 
			strAddress, 
			strCity, 
			strCountry, 
			strState, 
			strZipCode, 
			strPhone, 
			strFax,
			'Entity'			AS			strType
	FROM	tblEntityLocation

	UNION ALL

	SELECT	intCompanySetupID	AS			intEntityId, 
			-1					AS			intEntityLocationId, 
			strAddress, 
			strCity, 
			strCountry, 
			strState, 
			strZip				AS			strZipCode, 
			strPhone, 
			strFax,
			'Company'			AS			strType
	FROM	tblSMCompanySetup
