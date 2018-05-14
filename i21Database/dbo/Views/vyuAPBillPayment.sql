CREATE VIEW [dbo].[vyuAPBillPayment]
WITH SCHEMABINDING
AS
SELECT 
intId
,A.intBillId
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
,Payments.ysnPrepay
,Payments.ysnPosted AS ysnPaymentPosted
,Payments.strPaymentInfo
,Payments.strBankAccountNo
,Payments.intPaymentId
,Payments.intARPaymentId
,Payments.dtmDatePaid
,Payments.ysnCleared
,Payments.dtmDateReconciled
,Payments.strBatchId
FROM dbo.tblAPBill A
	INNER JOIN 
	(
		SELECT 
			CAST(ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS INT) AS intId
			,allPayment.intEntityVendorId
			,allPayment.intPaymentId
			,allPayment.intARPaymentId
			,allPayment.ysnPosted
			,allPayment.intBillId
			,allPayment.dblPayment
			,allPayment.dblDiscount
			,allPayment.dblInterest
			,allPayment.dblWithheld
			,allPayment.strPaymentInfo
			,allPayment.strBankAccountNo
			,allPayment.ysnPrinted
			,allPayment.ysnVoid
			,allPayment.ysnCleared
			,allPayment.dtmDatePaid
			,allPayment.ysnPrepay
			,allPayment.strBatchId
			,allPayment.dtmDateReconciled
		FROM (
			SELECT
				B.[intEntityVendorId]
				,B.intPaymentId
				,NULL AS intARPaymentId
				,B.ysnPosted
				,ISNULL(C.intBillId,C.intOrigBillId) AS intBillId
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
				,B.ysnPrepay
				,H.strLink AS strBatchId
				,H.dtmDateReconciled
			FROM dbo.tblAPPayment B 
				LEFT JOIN dbo.tblAPPaymentDetail C ON B.intPaymentId = C.intPaymentId
			LEFT JOIN dbo.tblCMBankAccount G ON B.intBankAccountId = G.intBankAccountId
			LEFT JOIN dbo.tblCMBankTransaction H ON B.strPaymentRecordNum = H.strTransactionId
			--WHERE B.ysnPosted = 1
			GROUP BY [intEntityVendorId], intBillId, intOrigBillId, H.dtmCheckPrinted, H.ysnCheckVoid, H.ysnClr,
			G.strBankAccountNo, B.strPaymentInfo, B.intPaymentId, B.dtmDatePaid, H.dtmDateReconciled, B.ysnPosted
			,H.strLink, B.ysnPrepay
			UNION ALL
			SELECT
				B.[intCurrencyId]
				,NULL
				,B.intPaymentId AS intARPaymentId
				,B.ysnPosted
				,C.intBillId
				,SUM(dblPayment) dblPayment
				,SUM(dblDiscount) dblDiscount
				,SUM(dblInterest) dblInterest
				,0
				,B.strPaymentInfo
				,G.strBankAccountNo
				,CAST(CASE WHEN H.dtmCheckPrinted IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS ysnPrinted
				,ISNULL(H.ysnCheckVoid,0) AS ysnVoid
				,ISNULL(H.ysnClr,0) AS ysnCleared
				,B.dtmDatePaid
				,0
				,H.strLink AS strBatchId
				,H.dtmDateReconciled
			FROM dbo.tblARPayment B 
				LEFT JOIN dbo.tblARPaymentDetail C ON B.intPaymentId = C.intPaymentId
			LEFT JOIN dbo.tblCMBankAccount G ON B.intBankAccountId = G.intBankAccountId
			LEFT JOIN dbo.tblCMBankTransaction H ON B.strRecordNumber = H.strTransactionId
			WHERE C.intBillId > 0
			GROUP BY B.[intCurrencyId], intBillId, intBillId, H.dtmCheckPrinted, H.ysnCheckVoid, H.ysnClr,
				G.strBankAccountNo, B.strPaymentInfo, B.intPaymentId, B.dtmDatePaid, H.dtmDateReconciled, B.ysnPosted
				,H.strLink
		) allPayment
	) Payments
	ON A.intBillId = Payments.intBillId