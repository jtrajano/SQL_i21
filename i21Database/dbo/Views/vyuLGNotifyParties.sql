CREATE VIEW vyuLGNotifyParties
AS
SELECT	E.intEntityId,
		E.strName,
		'Customer' 				AS strEntity
FROM	tblEntity				E
JOIN	tblARCustomer			C
ON		C.intEntityCustomerId = E.intEntityId

UNION ALL

SELECT 	S.intEntityId 			AS intEntityId,
		S.strName,
		'Shipping Line' 		AS strEntity
FROM 	tblEntity 				S
JOIN	tblEntityType			SE
ON		S.intEntityId			= SE.intEntityId and SE.strType = 'Shipping Line'

UNION ALL

SELECT 	F.intEntityId 			AS intEntityId,
		F.strName,
		'Forwarding Agent' 		AS strEntity
FROM 	tblEntity 				F
JOIN	tblEntityType			FE
ON		F.intEntityId			= FE.intEntityId and FE.strType = 'Forwarding Agent'

UNION ALL

SELECT 	T.intEntityId 			AS intEntityId,
		T.strName,
		'Trucker' 				AS strEntity
FROM 	tblEntity 				T
JOIN	tblEntityType			TE
ON		T.intEntityId			= TE.intEntityId and TE.strType = 'Trucker'

UNION ALL

SELECT 	TM.intEntityId 			AS intEntityId,
		TM.strName,
		'Terminal' 				AS strEntity
FROM 	tblEntity 				TM
JOIN	tblEntityType			TME
ON		TM.intEntityId			= TME.intEntityId and TME.strType = 'Terminal'

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
