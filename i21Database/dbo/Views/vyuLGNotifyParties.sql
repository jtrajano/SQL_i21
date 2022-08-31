CREATE VIEW vyuLGNotifyParties
AS
SELECT	E.intEntityId,
		E.strName,
		strEntity = E.strType,
		strEntityNo = E.strEntityNo,
		strAddress = EL.strAddress,
		strCity = EL.strCity,
		strState = EL.strState,
		strZipCode = EL.strZipCode,
		strCountry = EL.strCountry,
		strPhone = EC.strPhone,
		intDefaultLocationId = EL.intEntityLocationId,
		strDefaultLocation = EL.strLocationName,
		ysnTransportTerminal = ISNULL(V.ysnTransportTerminal, 0)
FROM vyuEMEntity E
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId AND EL.ysnDefaultLocation = 1
LEFT JOIN tblEMEntityToContact ETC ON ETC.intEntityId = E.intEntityId AND ETC.ysnDefaultContact = 1
LEFT JOIN tblEMEntity EC ON EC.intEntityId = ETC.intEntityId
LEFT JOIN tblAPVendor V ON V.intEntityId = E.intEntityId AND ISNULL(V.ysnPymtCtrlActive,0) = 1
WHERE strType IN ('Vendor', 'Customer','Forwarding Agent','Shipping Line','Terminal', 'Broker')

UNION ALL

SELECT 	intEntityId = B.intBankId,
		strName = B.strBankName,
		strEntity = 'Bank',
		strEntityNo = B.strRTN,
		strAddress = B.strAddress,
		strCity = B.strCity,
		strState = B.strState,
		strZipCode = B.strZipCode,
		strCountry = B.strCountry,
		strPhone = B.strPhone,
		intDefaultLocationId = -1,
		strDefaultLocation = NULL,
		ysnTransportTerminal = CAST(0 AS BIT)
FROM 	tblCMBank B

UNION ALL

SELECT 	intEntityId = C.intCompanySetupID,
		strName = C.strCompanyName,
		strEntity = 'Company',
		strEntityNo = C.strEin,
		strAddress = C.strAddress,
		strCity = C.strCity,
		strState = C.strState,
		strZipCode = C.strZip,
		strCountry = C.strCountry,
		strPhone = C.strPhone,
		intDefaultLocationId = -1,
		strDefaultLocation = NULL,
		ysnTransportTerminal = CAST(0 AS BIT)
FROM tblSMCompanySetup C
