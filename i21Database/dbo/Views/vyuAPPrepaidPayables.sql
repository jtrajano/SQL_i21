/**
	Note: Consider all origin prepaid was already paid.
*/
CREATE  VIEW vyuAPPrepaidPayables

AS

WITH VendorEntity AS (
	SELECT C1.intEntityId
		, C2.intEntityClassId
		, C1.strVendorId
		, C2.strName
	FROM tblAPVendor C1
	INNER JOIN tblEMEntity C2 ON C1.intEntityId = C2.intEntityId
), BillVendorEntity AS (
	SELECT A.dtmDate
		, A.intBillId
		, A.strBillId
		, A.dblAmountDue
		, A.dtmDueDate
		, A.ysnPosted 
		, A.ysnPaid
		, A.intAccountId
		, A.intTransactionType
		, E.intEntityClassId
		, E.strVendorId
		, E.strName
		, A.ysnOrigin
		, A.dblTotal
		, A.dblTax
		, A.intTransactionReversed
		, A.dblWithheld
		, A.dblDiscount
		, A.dblInterest
	FROM tblAPBill A
	INNER JOIN VendorEntity E ON E.intEntityId = A.intEntityVendorId
), BillVendorEntityDetail AS (
	SELECT bill.*
		, dblDetailRate = prepaidDetail.dblRate
		, intDetailAccountId = prepaidDetail.intAccountId
	FROM BillVendorEntity bill
	OUTER APPLY (
		SELECT TOP 1 bd.dblRate
			, bd.intAccountId
		FROM tblAPBillDetail bd
		WHERE bd.intBillId = bill.intBillId
	) prepaidDetail
), BillVendorEntityUnpaid AS (
	SELECT * FROM BillVendorEntity A
	WHERE NOT EXISTS (SELECT 1 FROM vyuAPPaidOriginPrepaid originPrepaid WHERE originPrepaid.intBillId = A.intBillId)
), BillVendorEntityDetailUnpaid AS (
	SELECT * FROM BillVendorEntityDetail A
	WHERE NOT EXISTS (SELECT 1 FROM vyuAPPaidOriginPrepaid originPrepaid WHERE originPrepaid.intBillId = A.intBillId)
)

SELECT tbl.dtmDate	
	, tbl.intBillId 
	, tbl.strBillId 
	, tbl.dblAmountPaid 
	, tbl.dblTotal
	, tbl.dblAmountDue 
	, tbl.dblWithheld
	, tbl.dblDiscount 
	, tbl.dblInterest
	, tbl.dblPrepaidAmount
	, tbl.strVendorId 
	, tbl.strVendorIdName 
	, tbl.dtmDueDate
	, tbl.ysnPosted 
	, tbl.ysnPaid
	, tbl.intAccountId
	, gl.strAccountId
	, ec.strClass
	, tbl.intPrepaidRowType
FROM (
	--VENDOR PREPAYMENT
	--POSITIVE PART
	SELECT A.dtmDate	
		, A.intBillId 
		, A.strBillId 
		, 0 AS dblAmountPaid 
		, CAST(A.dblTotal * A.dblDetailRate AS DECIMAL(18,2)) AS dblTotal
		, CAST(A.dblAmountDue * A.dblDetailRate AS DECIMAL(18,2)) AS dblAmountDue 
		, dblWithheld = 0
		, dblDiscount = 0 
		, dblInterest = 0
		, dblPrepaidAmount = 0  
		, A.strVendorId 
		, isnull(A.strVendorId,'') + ' - ' + isnull(A.strName,'') as strVendorIdName 
		, A.dtmDueDate
		, A.ysnPosted 
		, A.ysnPaid
		, intAccountId = A.intDetailAccountId
		, intPrepaidRowType = 1
		, A.intEntityClassId
	FROM BillVendorEntityDetailUnpaid A
	WHERE A.intTransactionType IN (2, 13) AND A.ysnPosted = 1
	AND A.intTransactionReversed IS NULL --Remove if already reversed, negative part will be offset by the reversal transaction	

	--VENDOR PREPAYMENT PAYMENT TRANSACTION (this will remove the positive part and leave the negative part)
	UNION ALL SELECT A.dtmDatePaid AS dtmDate 
		, ISNULL(B.intBillId ,B.intOrigBillId) AS intBillId  
		, C.strBillId
		, CAST(B.dblPayment * C.dblDetailRate AS DECIMAL(18,2))  AS dblAmountPaid     
		, dblTotal = 0 
		, dblAmountDue = 0 
		, dblWithheld = B.dblWithheld
		, B.dblDiscount AS dblDiscount
		, B.dblInterest AS dblInterest 
		, dblPrepaidAmount = 0  
		, C.strVendorId 
		, isnull(C.strVendorId,'') + ' - ' + isnull(C.strName,'') as strVendorIdName 
		, C.dtmDueDate 
		, C.ysnPosted 
		, C.ysnPaid
		, B.intAccountId
		, 1
		, C.intEntityClassId
	FROM dbo.tblAPPayment A
	INNER JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
	INNER JOIN BillVendorEntityDetailUnpaid C ON ISNULL(B.intBillId,B.intOrigBillId) = C.intBillId
	LEFT JOIN dbo.tblCMBankTransaction E ON A.strPaymentRecordNum = E.strTransactionId
	WHERE A.ysnPosted = 1
		AND C.ysnPosted = 1
		AND C.intTransactionType IN (2, 13)
		AND B.ysnOffset = 0

	--VENDOR PREPAYMENT PAYMENT TRANSACTION (this will remove the positive part and leave the negative part)
	--HANDLE THOSE ORIGIN PREPAYMENT THAT HAS BEEN IMPORTED UNPAID AND PAID IN i21 BUT DO NOT HAVE PAYMENT TRANSACTION (ysnPrepay = 1)
	UNION ALL SELECT A.dtmDate AS dtmDate 
		, A.intBillId  
		, A.strBillId
		, CAST(A.dblTotal * A.dblDetailRate AS DECIMAL(18,2))  AS dblAmountPaid     
		, dblTotal = 0 
		, dblAmountDue = 0 
		, A.dblWithheld
		, A.dblDiscount AS dblDiscount
		, A.dblInterest AS dblInterest 
		, dblPrepaidAmount = 0  
		, A.strVendorId 
		, isnull(A.strVendorId,'') + ' - ' + isnull(A.strName,'') as strVendorIdName 
		, A.dtmDueDate 
		, A.ysnPosted 
		, A.ysnPaid
		, A.intDetailAccountId
		, 1
		, A.intEntityClassId
	FROM BillVendorEntityDetailUnpaid A
	WHERE A.ysnPosted = 1
		AND A.intTransactionType IN (2, 13)
		AND NOT EXISTS (
			SELECT 1 FROM tblAPPaymentDetail B INNER JOIN tblAPPayment C ON B.intPaymentId = C.intPaymentId
			WHERE B.intBillId = A.intBillId AND C.ysnPrepay = 1
		)
		AND A.ysnOrigin = 1
		AND A.intTransactionReversed IS NULL --REMOVE ALREADY REVERSED

	--NEGATIVE PART
	UNION ALL SELECT A.dtmDate	
		, A.intBillId 
		, A.strBillId 
		, 0 AS dblAmountPaid 
		, CAST(A.dblTotal * A.dblDetailRate AS DECIMAL(18,2)) * -1 AS dblTotal
		, CAST(A.dblAmountDue * A.dblDetailRate AS DECIMAL(18,2)) * -1 AS dblAmountDue
		, dblWithheld = 0
		, dblDiscount = 0 
		, dblInterest = 0
		, dblPrepaidAmount = 0   
		, A.strVendorId 
		, isnull(A.strVendorId,'') + ' - ' + isnull(A.strName,'') as strVendorIdName 
		, A.dtmDueDate
		, A.ysnPosted 
		, A.ysnPaid
		, A.intAccountId
		, 2
		, A.intEntityClassId
	FROM BillVendorEntityDetailUnpaid A
	WHERE A.intTransactionType IN (2, 13) AND A.ysnPosted = 1

	--PREPAYMENT REVERSAL
	UNION ALL SELECT A.dtmDate	
		, A.intBillId --Use the original prepaid primary key but display the bill id of reversal (-R)
		, B.strBillId 
		, 0 AS dblAmountPaid 
		, CAST(B.dblTotal * A.dblDetailRate AS DECIMAL(18,2)) AS dblTotal
		, CAST(B.dblAmountDue * A.dblDetailRate AS DECIMAL(18,2)) AS dblAmountDue
		, dblWithheld = 0
		, dblDiscount = 0 
		, dblInterest = 0
		, dblPrepaidAmount = 0   
		, A.strVendorId 
		, isnull(A.strVendorId,'') + ' - ' + isnull(A.strName,'') as strVendorIdName 
		, B.dtmDueDate
		, B.ysnPosted 
		, B.ysnPaid
		, B.intAccountId
		, 2
		, A.intEntityClassId
	FROM BillVendorEntityDetailUnpaid A
	INNER JOIN tblAPBill B ON A.intTransactionReversed = B.intBillId
	WHERE B.intTransactionType IN (12) AND A.ysnPosted = 1 AND B.ysnPosted = 1

	--OFFSET VENDOR PREPAYMENT TRANSACTION
	UNION ALL SELECT A.dtmDatePaid AS dtmDate 
		, B.intBillId  
		, C.strBillId
		, CAST(B.dblPayment * C.dblDetailRate AS DECIMAL(18,2)) AS dblAmountPaid     
		, dblTotal = 0 
		, dblAmountDue = 0 
		, dblWithheld = B.dblWithheld
		, CAST(B.dblDiscount * C.dblDetailRate AS DECIMAL(18,2)) AS dblDiscount
		, CAST(B.dblInterest * C.dblDetailRate AS DECIMAL(18,2)) AS dblInterest
		, dblPrepaidAmount = 0   
		, C.strVendorId 
		, isnull(C.strVendorId,'') + ' - ' + isnull(C.strName,'') as strVendorIdName 
		, C.dtmDueDate 
		, C.ysnPosted 
		, C.ysnPaid
		, B.intAccountId
		, 2
		, C.intEntityClassId
	FROM dbo.tblAPPayment A
	LEFT JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
	LEFT JOIN BillVendorEntityDetailUnpaid C ON B.intBillId = C.intBillId
	LEFT JOIN dbo.tblCMBankTransaction E ON A.strPaymentRecordNum = E.strTransactionId
	WHERE A.ysnPosted = 1
		AND C.ysnPosted = 1
		AND C.intTransactionType IN (2, 13)
		AND B.ysnOffset = 1

	--APPLIED PREPAYMENT
	UNION ALL SELECT A.dtmDate
		, B.intTransactionId
		, C.strBillId
		, B.dblAmountApplied * -1
		, 0 AS dblTotal
		, 0 AS dblAmountDue
		, 0 AS dblWithheld
		, 0 AS dblDiscount
		, 0 AS dblInterest
		,  dblPrepaidAmount = 0  
		, ISNULL(A.strVendorId,'') + ' - ' + ISNULL(A.strName,'') as strVendorIdName 
		, A.strVendorId
		, A.dtmDueDate
		, A.ysnPosted
		, C.ysnPaid
		, C.intAccountId
		, 2
		, A.intEntityClassId
	FROM BillVendorEntityUnpaid A
	INNER JOIN dbo.tblAPAppliedPrepaidAndDebit B ON A.intBillId = B.intBillId
	INNER JOIN dbo.tblAPBill C ON B.intTransactionId = C.intBillId
	WHERE A.ysnPosted = 1 AND C.intTransactionType IN (2, 13)
		AND B.ysnApplied = 1 AND A.ysnPosted = 1

	--PAYMENT MADE TO AR TO OFFSET THE PREPAYMENT
	UNION ALL SELECT A.dtmDatePaid AS dtmDate
		, B.intBillId AS intTransactionId
		, C.strBillId
		, B.dblPayment * ISNULL(A.dblExchangeRate,1) * - 1 AS dblAmountPaid --ALWAYS CONVERT TO POSSITIVE TO OFFSET THE PAYMENT
		, dblTotal = 0 
		, dblAmountDue = 0 
		, dblWithheld = 0
		, CASE WHEN C.intTransactionType NOT IN (1,2) AND abs(B.dblDiscount) > 0 THEN B.dblDiscount * -1 ELSE B.dblDiscount END AS dblDiscount
		, CASE WHEN C.intTransactionType NOT IN (1,2) AND abs(B.dblInterest) > 0 THEN B.dblInterest * -1 ELSE B.dblInterest END AS dblInterest 
		, dblPrepaidAmount = 0 
		, C.strVendorId 
		, ISNULL(C.strVendorId,'') + ' - ' + ISNULL(C.strName,'') as strVendorIdName 
		, C.dtmDueDate 
		, C.ysnPosted 
		, C.ysnPaid
		, B.intAccountId
		, 2
		, C.intEntityClassId
	FROM dbo.tblARPayment A
	LEFT JOIN dbo.tblARPaymentDetail B ON A.intPaymentId = B.intPaymentId
	LEFT JOIN BillVendorEntity C ON B.intBillId = C.intBillId
	LEFT JOIN dbo.tblCMBankTransaction E ON A.strRecordNumber = E.strTransactionId
	WHERE A.ysnPosted = 1
		AND C.ysnPosted = 1
		AND C.intTransactionType IN (2)

	--CLAIM TRANSACTION IN AR
	UNION ALL SELECT A.dtmDatePaid AS dtmDate
		, F.intBillId AS intTransactionId
		, F.strBillId
		, (B.dblPayment + prepaid.dblFranchiseAmount) * ISNULL(A.dblExchangeRate,1) * - 1 AS dblAmountPaid
		, dblTotal = 0 
		, dblAmountDue = 0 
		, dblWithheld = 0
		, CASE WHEN F.intTransactionType NOT IN (1,2) AND abs(B.dblDiscount) > 0 THEN B.dblDiscount * -1 ELSE B.dblDiscount END AS dblDiscount
		, CASE WHEN F.intTransactionType NOT IN (1,2) AND abs(B.dblInterest) > 0 THEN B.dblInterest * -1 ELSE B.dblInterest END AS dblInterest 
		, dblPrepaidAmount = 0 
		, C.strVendorId 
		, ISNULL(C.strVendorId,'') + ' - ' + ISNULL(C.strName,'') as strVendorIdName 
		, C.dtmDueDate 
		, C.ysnPosted 
		, C.ysnPaid
		, B.intAccountId
		, 2
		, C.intEntityClassId
	FROM dbo.tblARPayment A
	LEFT JOIN dbo.tblARPaymentDetail B ON A.intPaymentId = B.intPaymentId
	LEFT JOIN BillVendorEntity C ON B.intBillId = C.intBillId
	LEFT JOIN dbo.tblCMBankTransaction E ON A.strRecordNumber = E.strTransactionId
	OUTER APPLY (
		--claim transaction
		SELECT TOP 1 C2.intPrepayTransactionId
			, C2.dblFranchiseAmount
		FROM tblAPBillDetail C2
		WHERE C2.intBillId = C.intBillId
	) prepaid
	LEFT JOIN tblAPBill F ON F.intBillId = prepaid.intPrepayTransactionId
	WHERE A.ysnPosted = 1
		AND C.intTransactionType IN (11)
) tbl
LEFT JOIN tblEMEntityClass ec ON ec.intEntityClassId = tbl.intEntityClassId
LEFT JOIN tblGLAccount gl ON gl.intAccountId = tbl.intAccountId