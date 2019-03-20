CREATE FUNCTION [dbo].[fnAPGetVouchersPaymentInfo]
(
	
)
RETURNS @returntable TABLE
(
	intBillId INT,
	ysnPaid BIT,
	strPaymentInfo NVARCHAR(MAX),
	strPaymentInfoKey NVARCHAR(MAX)
)
AS
BEGIN
	INSERT @returntable
	SELECT 
		A.intBillId,
		A.ysnPaid,
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
								)
	FROM tblAPBill A
	RETURN;
END
