CREATE VIEW [dbo].[vyuAPBillPaymentSorted]

AS

SELECT 
	B.intBillId,
	VP.intPaymentId, 
	VP.intARPaymentId, 
	VP.ysnVoid, 
	VP.ysnPrinted, 
	VP.ysnCleared, 
	VP.ysnPosted  AS ysnPaymentPosted,
	VP.strBatchId, 
	VP.dtmDatePaid, 
	strPaymentInfoKey =	STUFF((
							SELECT ',' + CAST(paymentData.intPaymentId AS NVARCHAR)
							FROM (
								SELECT 
									P.intPaymentId
								FROM tblAPPayment P
								INNER JOIN tblAPPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
								WHERE PD.intBillId = B.intBillId
								UNION ALL
								SELECT 
									P.intPaymentId
								FROM tblAPPayment P
								INNER JOIN tblAPPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
								WHERE PD.intOrigBillId = B.intBillId
								UNION ALL
								SELECT
									P.intPaymentId 
								FROM dbo.tblARPayment P
								LEFT JOIN dbo.tblARPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
								WHERE PD.intBillId = B.intBillId
							) paymentData
						FOR XML PATH('')), 1, 1, '')
FROM tblAPBill B
CROSS APPLY (
	SELECT TOP 1 * FROM (
		SELECT
			ISNULL(PD.intBillId, PD.intOrigBillId) AS intBillId,
			P.intPaymentId,
			NULL AS intARPaymentId,
			ISNULL(T.ysnCheckVoid,0) AS ysnVoid,
			CAST(CASE WHEN T.dtmCheckPrinted IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS ysnPrinted,
			ISNULL(T.ysnClr,0) AS ysnCleared,
			P.ysnPosted,
			T.strLink AS strBatchId,
			P.dtmDatePaid
		FROM dbo.tblAPPayment P
		LEFT JOIN tblAPPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
		LEFT JOIN tblCMBankTransaction T ON T.strTransactionId = P.strPaymentRecordNum
		WHERE PD.intBillId = B.intBillId
		UNION ALL
		SELECT
			PD.intBillId,
			NULL,
			P.intPaymentId,
			ISNULL(T.ysnCheckVoid,0) AS ysnVoid,
			CAST(CASE WHEN T.dtmCheckPrinted IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS ysnPrinted,
			ISNULL(T.ysnClr,0) AS ysnCleared,
			P.ysnPosted,
			T.strLink AS strBatchId,
			P.dtmDatePaid
		FROM dbo.tblARPayment P
		LEFT JOIN tblARPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
		LEFT JOIN tblCMBankTransaction T ON T.strTransactionId = P.strRecordNumber
		WHERE PD.intBillId = B.intBillId
	) P
	ORDER BY P.intPaymentId DESC
) VP