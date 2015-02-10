CREATE VIEW [dbo].[vyuAPBillLatestPayment]
AS
SELECT
	D.intBillId
	,E.strPaymentInfo
	,ROW_NUMBER() OVER(PARTITION BY D.intBillId ORDER BY E.dtmDatePaid DESC) AS Id
FROM tblAPPaymentDetail D
	INNER JOIN tblAPPayment E ON D.intPaymentId = E.intPaymentId
WHERE E.ysnPosted = 1

