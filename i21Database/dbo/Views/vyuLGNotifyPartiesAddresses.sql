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
			ENTYPE.strType,
			ENLOC.strNotes,
			TCN.strTerminalControlNumber,
			CONVERT(BIT,ENLOC.ysnActive)									AS ysnActive
	FROM	[tblEMEntityLocation] ENLOC
	JOIN	[tblEMEntityType] ENTYPE ON ENTYPE.intEntityId = ENLOC.intEntityId  
	LEFT JOIN tblTRSupplyPoint SP ON SP.intEntityLocationId = ENLOC.intEntityLocationId
	LEFT JOIN tblTFTerminalControlNumber TCN ON TCN.intTerminalControlNumberId = SP.intTerminalControlNumberId

	UNION ALL

	SELECT	(SELECT Top(1) intCompanySetupID FROM tblSMCompanySetup)		AS intEntityId, 
			L.intCompanyLocationId											AS intEntityLocationId, 
			L.strLocationName,
			L.strAddress, 
			L.strCity, 
			L.strCountry, 
			L.strStateProvince												AS strState, 
			L.strZipPostalCode												AS strZipCode, 
			L.strPhone, 
			L.strFax,
			'Company'														AS strType,
			''																AS strNotes,
			''																AS strTerminalControlNumber,
			CONVERT(BIT,L.ysnActive) 										AS ysnActive
	FROM	tblSMCompanyLocation L

	UNION ALL

	SELECT	intBankId														AS intEntityId, 
			-1																AS intEntityLocationId, 
			strBankName														AS strLocationName,
			strAddress, 
			strCity, 
			strCountry, 
			strState, 
			''																AS strZipCode, 
			strPhone, 
			strFax,
			'Bank'															AS strType,
			''																AS strNotes,
			''																AS strTerminalControlNumber,
			CONVERT(BIT,1)													AS ysnActive
	FROM	tblCMBank