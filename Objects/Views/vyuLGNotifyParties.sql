CREATE VIEW vyuLGNotifyParties
AS
SELECT	E.intEntityId,
		E.strName,
		E.strType 				AS strEntity
FROM	vyuEMEntity				E
LEFT JOIN tblAPVendor V ON V.intEntityId = E.intEntityId AND ISNULL(V.ysnPymtCtrlActive,0) = 1
WHERE strType IN ('Vendor', 'Customer','Forwarding Agent','Shipping Line','Terminal')

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
