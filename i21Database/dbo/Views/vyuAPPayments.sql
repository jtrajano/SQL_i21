﻿CREATE VIEW [dbo].[vyuAPPayments]
WITH SCHEMABINDING
AS 

SELECT 
	A.dblAmountPaid ,
	A.dblUnapplied ,
	A.dblWithheld ,
	A.dtmDatePaid ,
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
	B.strBankAccountNo,
	D.dblCreditLimit AS dblCredit,
	D.strVendorId,
	D1.strName,
	ISNULL(E.ysnClr,0) AS ysnClear
	FROM dbo.tblAPPayment A
		LEFT JOIN dbo.tblCMBankAccount B
			ON A.intBankAccountId = B.intBankAccountId
		LEFT JOIN dbo.tblCMBank C
			ON B.intBankId = C.intBankId
		LEFT JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEntity D1 ON D.intEntityVendorId = D1.intEntityId)
			ON A.[intEntityVendorId] = D.[intEntityVendorId]
		LEFT JOIN dbo.tblCMBankTransaction E
			ON A.strPaymentRecordNum = E.strTransactionId
