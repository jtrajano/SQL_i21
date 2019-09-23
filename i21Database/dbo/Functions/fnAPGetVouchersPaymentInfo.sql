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
	ysnClr BIT, 
	dtmClr DATETIME,
    PRIMARY KEY CLUSTERED ([intBillId] ASC)
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
									SELECT ',' + CAST(paymentData.strPaymentRecordNum AS NVARCHAR)
									FROM
									(
										SELECT B.strPaymentRecordNum
										FROM tblAPPayment B
										INNER JOIN tblAPPaymentDetail C
											ON B.intPaymentId = C.intPaymentId
										WHERE C.intBillId = A.intBillId
										UNION ALL
										SELECT B.strPaymentRecordNum
										FROM tblAPPayment B
										INNER JOIN tblAPPaymentDetail C
											ON B.intPaymentId = C.intPaymentId
										WHERE C.intOrigBillId = A.intBillId AND C.intOrigBillId IS NOT NULL
										UNION ALL
										SELECT TOP 1
										B.strRecordNumber 
										FROM dbo.tblARPayment B 
											LEFT JOIN dbo.tblARPaymentDetail C ON B.intPaymentId = C.intPaymentId
										WHERE C.intBillId > 0 AND C.intBillId = A.intBillId 
										ORDER BY B.intPaymentId DESC
									) paymentData
									FOR XML PATH('')),1,1,''
								),
		strPaymentInfoKey	=	STUFF((
									SELECT ',' + CAST(paymentData.intPaymentId AS NVARCHAR)
									FROM
									(
										SELECT B.intPaymentId
										FROM tblAPPayment B
										INNER JOIN tblAPPaymentDetail C
											ON B.intPaymentId = C.intPaymentId
										WHERE C.intBillId = A.intBillId
										UNION ALL
										SELECT B.intPaymentId
										FROM tblAPPayment B
										INNER JOIN tblAPPaymentDetail C
											ON B.intPaymentId = C.intPaymentId
										WHERE C.intOrigBillId = A.intBillId AND C.intOrigBillId IS NOT NULL
										UNION ALL
										SELECT TOP 1
										B.intPaymentId 
										FROM dbo.tblARPayment B 
											LEFT JOIN dbo.tblARPaymentDetail C ON B.intPaymentId = C.intPaymentId
										WHERE C.intBillId > 0 AND C.intBillId = A.intBillId 
										ORDER BY B.intPaymentId DESC
									) paymentData
									FOR XML PATH('')),1,1,''
								),
		dtmPaymentDateReconciled=	latestPay.dtmDateReconciled,
		ysnClr =	latestPay.ysnClr,
		dtmClr =	latestPay.dtmClr
	FROM tblAPBill A
	OUTER APPLY (
		SELECT TOP 1
			C.intBillId,
			D.dtmDateReconciled,
			D.ysnClr,
			D.dtmClr
		FROM tblAPPayment B
		INNER JOIN tblAPPaymentDetail C
			ON B.intPaymentId = C.intPaymentId
		INNER JOIN tblCMBankTransaction D
			ON D.strTransactionId = B.strPaymentRecordNum
		WHERE C.intBillId = A.intBillId
		ORDER BY B.intPaymentId DESC
	) latestPay
	WHERE A.ysnPosted = 1
	ORDER BY A.intBillId DESC
	RETURN;
END
