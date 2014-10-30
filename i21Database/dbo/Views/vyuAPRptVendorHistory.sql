CREATE VIEW [dbo].[vyuAPRptVendorHistory]
AS

	SELECT 
		strVendorId = tblAPVendor.strVendorId
		,tblAPVendor.intEntityId
		,tblAPVendor.intVendorId
		,A.dtmDate
		,intTransactionId = A.intBillId 
		,CASE WHEN A.intTransactionType = 1 THEN 'Bill' ELSE 'Vendor Prepayment' END AS strTransactionType 
		,strBillId = A.strBillId
		,strInvoiceNumber = strVendorOrderNumber
		,dblTotal = ISNULL(A.dblTotal,0)
		,dblDiscount = A.dblDiscount
		,dblWithheld = A.dblWithheld
		,dblAmountPaid = CASE WHEN A.ysnPaid = 1 THEN A.dblTotal ELSE ISNULL(SUM(B.dblPayment),0) END
		,A.ysnPaid
		,strVendorOrderNumber
		,A.strDescription
		,A.dblAmountDue
	FROM dbo.tblAPBill A
			LEFT JOIN (dbo.tblAPPayment B1 INNER JOIN dbo.tblAPPaymentDetail B ON B1.intPaymentId = B.intPaymentId)
			 ON A.intBillId = B.intBillId
			LEFT JOIN dbo.tblAPVendor
				ON tblAPVendor.intVendorId = A.intVendorId
	WHERE B1.ysnPosted = 1
	GROUP BY A.intBillId,
		A.dtmDate,
		A.dblTotal,
		A.dblDiscount,
		A.dblWithheld,
		A.strDescription,
		A.intTransactionType,
		tblAPVendor.strVendorId,
		tblAPVendor.intEntityId,
		tblAPVendor.intVendorId,
		strVendorOrderNumber,
		A.strBillId,
		A.ysnPaid,
		A.dblAmountDue
	
