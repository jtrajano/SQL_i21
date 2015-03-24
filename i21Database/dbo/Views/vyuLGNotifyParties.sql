CREATE VIEW vyuLGNotifyParties
AS
SELECT	E.intEntityId,
		E.strName,
		'Customer' 				AS strEntity
FROM	tblEntity				E
JOIN	tblARCustomer			C
ON		C.intEntityId = E.intEntityId

UNION ALL

SELECT 	S.intShippingLineId 	AS intEntityId,
		S.strName,
		'Shipping Line' 		AS strEntity
FROM 	tblLGShippingLine 			S

UNION ALL

SELECT	F.intForwardingAgentId 	AS intEntityId,
		F.strName,
		'Forwarding Agent' 		AS strEntity
FROM 	tblLGForwardingAgent 	F

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
