CREATE VIEW vyuLGNotifyParties
AS
SELECT	E.intEntityId,
		E.strName,
		E.strType 				AS strEntity
FROM	vyuEMEntity				E
WHERE strType IN ('Vendor', 'Customer','Forwarding Agent')

UNION ALL

SELECT 	B.intBankId 			AS intEntityId,
		B.strBankName 			AS strName,
		'Bank' 					AS strEntity
FROM 	tblCMBank 				B

UNION ALL

SELECT 	C.intCompanySetupID 	AS intEntityId,
		C.strCompanyName 		AS strName,
		'Company' 				AS strEntity
FROM tblSMCompanySetup C
