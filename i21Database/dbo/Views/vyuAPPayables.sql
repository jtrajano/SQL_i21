/*
	Note: Standard amount of void payment transaction is negative. The original transaction should be positive
*/
CREATE VIEW vyuAPPayables
WITH SCHEMABINDING
AS 
SELECT 
	A.dtmDate
	, A.intBillId 
	, A.strBillId 
	, 0 AS dblAmountPaid 
	, CASE WHEN A.intTransactionType != 1 AND A.dblTotal > 0 THEN A.dblTotal * -1 ELSE A.dblTotal END AS dblTotal
	, CASE WHEN A.intTransactionType != 1 AND A.dblAmountDue > 0 THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END AS dblAmountDue 
	, dblWithheld = 0
	, dblDiscount = 0 
	, dblInterest = 0 
	, C1.strVendorId 
	, isnull(C1.strVendorId,'') + ' - ' + isnull(C2.strName,'') as strVendorIdName 
	, A.dtmDueDate
	, A.ysnPosted 
	, A.ysnPaid
	, A.intAccountId
FROM dbo.tblAPBill A
LEFT JOIN (dbo.tblAPVendor C1 INNER JOIN dbo.tblEMEntity C2 ON C1.[intEntityVendorId] = C2.intEntityId)
	ON C1.[intEntityVendorId] = A.[intEntityVendorId]
WHERE A.ysnPosted = 1 AND intTransactionType != 7
UNION ALL   
SELECT A.dtmDatePaid AS dtmDate,   
	 B.intBillId,   
	 C.strBillId ,
	 CASE WHEN C.intTransactionType != 1 AND B.dblPayment > 0
			THEN (CASE WHEN (E.intBankTransactionTypeId <> 19 OR E.intBankTransactionTypeId IS NULL)
						 THEN B.dblPayment * -1 ELSE B.dblPayment END)
			WHEN C.intTransactionType != 1 AND B.dblPayment < 0 AND E.intBankTransactionTypeId = 19
				THEN B.dblPayment * -1 --MAKE THE REVERSAL DEBIT MEMO TRANSACTION POSITIVE
			ELSE B.dblPayment END AS dblAmountPaid,     
	 dblTotal = 0 
	, dblAmountDue = 0 
	, dblWithheld = B.dblWithheld
	, CASE WHEN C.intTransactionType != 1 AND abs(B.dblDiscount) > 0 THEN B.dblDiscount * -1 ELSE B.dblDiscount END AS dblDiscount
	, B.dblInterest 
	, D.strVendorId 
	, isnull(D.strVendorId,'') + ' - ' + isnull(D2.strName,'') as strVendorIdName 
	, C.dtmDueDate 
	, C.ysnPosted 
	, C.ysnPaid
	, B.intAccountId
FROM dbo.tblAPPayment  A
 LEFT JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
 LEFT JOIN dbo.tblAPBill C ON B.intBillId = C.intBillId
 LEFT JOIN (dbo.tblAPVendor D INNER JOIN dbo.tblEMEntity D2 ON D.[intEntityVendorId] = D2.intEntityId)
 	ON A.[intEntityVendorId] = D.[intEntityVendorId]
LEFT JOIN dbo.tblCMBankTransaction E
	ON A.strPaymentRecordNum = E.strTransactionId
 WHERE A.ysnPosted = 1  
	AND C.ysnPosted = 1
