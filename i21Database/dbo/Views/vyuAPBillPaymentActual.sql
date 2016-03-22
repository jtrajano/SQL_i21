﻿CREATE VIEW [dbo].[vyuAPBillPaymentActual]
WITH SCHEMABINDING
AS
SELECT 
A.intBillId
,A.strBillId
,A.dblTotal
,A.intShipToId AS intLocationId
,Payments.dblPayment AS dblPayment
,Payments.dblDiscount AS dblDiscount
,Payments.dblInterest AS dblInterest
,Payments.dblWithheld AS dblWithheld
,A.[intEntityVendorId]
,Payments.[intEntityVendorId] AS intPaymentVendor
,A.ysnPosted
,A.ysnPaid
,A.ysnOrigin
,Payments.ysnPrinted
,Payments.ysnVoid
,Payments.ysnPosted AS ysnPaymentPosted
,Payments.strPaymentInfo
,Payments.strBankAccountNo
,Payments.intPaymentId
,Payments.dtmDatePaid
,Payments.ysnCleared
,Payments.dtmDateReconciled
,Payments.strBatchId
FROM dbo.tblAPBill A
	INNER JOIN 
	(
		SELECT 
			B.[intEntityVendorId]
			,B.intPaymentId
			,B.ysnPosted
			,C.intBillId
			,SUM(dblPayment) dblPayment
			,SUM(dblDiscount) dblDiscount
			,SUM(dblInterest) dblInterest
			,SUM(C.dblWithheld) dblWithheld
			,B.strPaymentInfo
			,G.strBankAccountNo
			,CAST(CASE WHEN H.dtmCheckPrinted IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS ysnPrinted
			,ISNULL(H.ysnCheckVoid,0) AS ysnVoid
			,ISNULL(H.ysnClr,0) AS ysnCleared
			,B.dtmDatePaid
			,H.strLink AS strBatchId
			,H.dtmDateReconciled
		FROM dbo.tblAPPayment B 
			LEFT JOIN dbo.tblAPPaymentDetail C ON B.intPaymentId = C.intPaymentId
		INNER JOIN dbo.tblCMBankAccount G ON B.intAccountId = G.intGLAccountId
		LEFT JOIN dbo.tblCMBankTransaction H ON B.strPaymentRecordNum = H.strTransactionId
		WHERE B.ysnPosted = 1 AND H.ysnCheckVoid = 0
		GROUP BY [intEntityVendorId], intBillId, H.dtmCheckPrinted, H.ysnCheckVoid, H.ysnClr,
		 G.strBankAccountNo, B.strPaymentInfo, B.intPaymentId, B.dtmDatePaid, H.dtmDateReconciled, B.ysnPosted
		 ,H.strLink
	) Payments
	ON A.intBillId = Payments.intBillId