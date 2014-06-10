
CREATE VIEW vyuVendorHistory
AS
SELECT 
	strVendorId = A.strVendorId
	,A.dtmDate
	,intTransactionId = A.intBillId 
	,strTransactionType = 'Bill'
	,strBillId = A.strBillId
	,strInvoiceNumber = strVendorOrderNumber
	,dblTotal = ISNULL(A.dblTotal,0)
	,dblAmountPaid = CASE WHEN A.ysnPaid = 1 THEN A.dblTotal ELSE ISNULL(SUM(B.dblPayment),0) END
	,A.ysnPaid
	,A.dblAmountDue
FROM tblAPBill A
		LEFT JOIN tblAPPaymentDetail B ON A.intBillId = B.intBillId
GROUP BY A.intBillId,
	A.dtmDate,
	A.dblTotal,
	A.strVendorId,
    strVendorOrderNumber,
	A.strBillId,
	A.ysnPaid,
	A.dblAmountDue