CREATE FUNCTION [dbo].[fnAPGetVouchersPaymentInfo]
(
	
)
RETURNS @returntable TABLE
(
	intBillId INT,
	ysnPaid BIT,
	dtmDatePaid DATETIME,
	dblPayment DECIMAL(18,2),
	strPaymentInfo NVARCHAR(MAX),
	strPaymentInfoKey NVARCHAR(MAX),
	dtmPaymentDateReconciled DATETIME,
	ysnClr BIT
)
AS
BEGIN
	INSERT @returntable
	SELECT 
		A.intBillId,
		A.ysnPaid,
		A.dtmDatePaid,
		A.dblPayment,
		strPaymentInfo		=	STUFF((
									SELECT ',' + CAST(B.strPaymentRecordNum AS NVARCHAR)
									FROM tblAPPayment B
									INNER JOIN tblAPPaymentDetail C
										ON B.intPaymentId = C.intPaymentId
									WHERE A.ysnPosted = 1 AND C.intBillId = A.intBillId
									FOR XML PATH('')),1,1,''
								),
		strPaymentInfoKey	=	STUFF((
									SELECT ',' + CAST(B.intPaymentId AS NVARCHAR)
									FROM tblAPPayment B
									INNER JOIN tblAPPaymentDetail C
										ON B.intPaymentId = C.intPaymentId
									WHERE A.ysnPosted = 1 AND C.intBillId = A.intBillId
									FOR XML PATH('')),1,1,''
								),
		dtmPaymentDateReconciled=	latestPay.dtmDateReconciled,
		ysnClr =	latestPay.ysnClr
	FROM tblAPBill A
	OUTER APPLY (
		SELECT TOP 1
			D.dtmDateReconciled, D.ysnClr
		FROM tblAPPayment B
		INNER JOIN tblAPPaymentDetail C
			ON B.intPaymentId = C.intPaymentId
		INNER JOIN tblCMBankTransaction D
			ON D.strTransactionId = B.strPaymentRecordNum
		WHERE A.ysnPosted = 1 AND C.intBillId = A.intBillId
		ORDER BY B.intPaymentId DESC
	) latestPay
	RETURN;
END
