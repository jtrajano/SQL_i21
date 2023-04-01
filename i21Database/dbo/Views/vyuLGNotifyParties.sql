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
		ysnActive = E.ysnActive,
		intDefaultLocationId = EL.intEntityLocationId,
		strDefaultLocation = EL.strLocationName,
		ysnTransportTerminal = ISNULL(V.ysnTransportTerminal, 0),
		strTerminalControlNumber = TCN.strTerminalControlNumber,
		intCompanyLocationId = CompanyLocation.intCompanyLocationId
FROM vyuEMEntity E
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId AND EL.ysnDefaultLocation = 1
LEFT JOIN tblEMEntityToContact ETC ON ETC.intEntityId = E.intEntityId AND ETC.ysnDefaultContact = 1
LEFT JOIN tblEMEntity EC ON EC.intEntityId = ETC.intEntityId
LEFT JOIN tblAPVendor V ON V.intEntityId = E.intEntityId AND ISNULL(V.ysnPymtCtrlActive,0) = 1
LEFT JOIN tblTRSupplyPoint SP ON SP.intEntityLocationId = EL.intEntityLocationId
LEFT JOIN tblTFTerminalControlNumber TCN ON TCN.intTerminalControlNumberId = SP.intTerminalControlNumberId
LEFT JOIN tblAPVendorCompanyLocation AS VendorLocation ON E.intEntityId = VendorLocation.intEntityVendorId
LEFT JOIN tblSMCompanyLocation AS CompanyLocation ON VendorLocation.intCompanyLocationId = CompanyLocation.intCompanyLocationId
WHERE E.strType IN ('Vendor', 'Customer','Forwarding Agent','Shipping Line','Terminal', 'Broker')

UNION ALL

SELECT 	intEntityId = B.intBankId,
		strName = B.strBankName,
		strEntity = 'Bank',
		strEntityNo = B.strBankName,
		strAddress = B.strAddress,
		strCity = B.strCity,
		strState = B.strState,
		strZipCode = B.strZipCode,
		strCountry = B.strCountry,
		strPhone = B.strPhone,
		ysnActive = CAST(1 AS BIT),
		intDefaultLocationId = -1,
		strDefaultLocation = NULL,
		ysnTransportTerminal = CAST(0 AS BIT),
		strTerminalControlNumber = NULL,
		intCompanyLocationId = NULL
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
		ysnActive = CAST(1 AS BIT),
		intDefaultLocationId = -1,
		strDefaultLocation = NULL,
		ysnTransportTerminal = CAST(0 AS BIT),
		strTerminalControlNumber = NULL,
		intCompanyLocationId = NULL
FROM tblSMCompanySetup C
