
CREATE VIEW vyuAPVendorHistory
AS
SELECT 
	strVendorId = tblAPVendor.strVendorId
	,A.dtmDate
	,intTransactionId = A.intBillId 
	,strTransactionType = 'Bill'
	,strBillId = A.strBillId
	,strInvoiceNumber = strVendorOrderNumber
	,dblTotal = ISNULL(A.dblTotal,0)
	,dblDiscount = A.dblDiscount
	,dblWithheld = A.dblWithheld
	,dblAmountPaid = CASE WHEN A.ysnPaid = 1 THEN A.dblTotal ELSE ISNULL(SUM(B.dblPayment),0) END
	,A.ysnPaid
	,A.dblAmountDue
FROM tblAPBill A
		LEFT JOIN tblAPPaymentDetail B ON A.intBillId = B.intBillId
		LEFT JOIN tblAPVendor
			ON tblAPVendor.intVendorId = A.intVendorId
GROUP BY A.intBillId,
	A.dtmDate,
	A.dblTotal,
	A.dblDiscount,
	A.dblWithheld,
	tblAPVendor.strVendorId,
    strVendorOrderNumber,
	A.strBillId,
	A.ysnPaid,
	A.dblAmountDue