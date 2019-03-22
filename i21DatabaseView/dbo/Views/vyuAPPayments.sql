﻿CREATE VIEW [dbo].[vyuAPPayments]
WITH SCHEMABINDING
AS 

SELECT 
	ISNULL(A.dblAmountPaid,0) AS dblAmountPaid ,
	ISNULL(A.dblUnapplied,0) AS dblUnapplied,
	ISNULL(A.dblWithheld,0) AS dblWithheld,
	A.dtmDatePaid ,
	A.dtmDateCreated,
	A.intAccountId ,
	A.intBankAccountId ,
	A.intCurrencyId ,
	A.intEntityId ,
	A.intPaymentId ,
	A.intPaymentMethodId ,
	A.intUserId ,
	A.[intEntityVendorId] ,
	A.strNotes ,
	A.strPaymentInfo ,
	A.strPaymentRecordNum ,
	A.ysnOrigin ,
	A.intBatchId,
	A.ysnPosted ,
	CAST(CASE WHEN E.dtmCheckPrinted IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS ysnPrinted,
	ISNULL(E.ysnCheckVoid,0) AS ysnVoid,
	C.strBankName,
	dbo.[fnAESDecryptASym](B.strBankAccountNo) AS strBankAccountNo,
	ISNULL(D.dblCreditLimit,0) AS dblCredit,
	D.strVendorId,
	D1.strName,
	ISNULL(E.ysnClr,0) AS ysnClear,
	F.strPaymentMethod
	FROM dbo.tblAPPayment A
		LEFT JOIN dbo.tblCMBankAccount B
			ON A.intBankAccountId = B.intBankAccountId
		LEFT JOIN dbo.tblCMBank C
			ON B.intBankId = C.intBankId
		LEFT JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D1 ON D.[intEntityId] = D1.intEntityId)
			ON A.[intEntityVendorId] = D.[intEntityId]
		LEFT JOIN dbo.tblCMBankTransaction E
			ON A.strPaymentRecordNum = E.strTransactionId
		LEFT JOIN dbo.tblSMPaymentMethod F
			ON A.intPaymentMethodId = F.intPaymentMethodID