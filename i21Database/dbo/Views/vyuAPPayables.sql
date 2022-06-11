/*
	Note: Standard amount of void payment transaction is negative. The original transaction should be positive
	Note: Origin transaction do not have multi currency implementation, also to handle issue (see 792717-000, CISCO transaction of COPP)
	Note: Handle negative quantity received
*/
CREATE VIEW dbo.vyuAPPayables
--WITH SCHEMABINDING
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
	FROM tblAPBill A
	INNER JOIN VendorEntity E ON E.intEntityId = A.intEntityVendorId
), BillVendorEntityDetail AS (
	SELECT bill.*
		, dblDetailTotal = billDetail.dblTotal
		, dblDetailRate = billDetail.dblRate
		, dblDetailTax = billDetail.dblTax
	FROM BillVendorEntity bill
	JOIN tblAPBillDetail billDetail ON billDetail.intBillId = bill.intBillId
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
FROM (
	SELECT A.dtmDate
		, A.intBillId
		, A.strBillId
		, 0 AS dblAmountPaid
		, CAST(CASE WHEN A.intTransactionType NOT IN (1,14) THEN (A.dblDetailTotal) *  A.dblDetailRate * -1
					ELSE (A.dblDetailTotal) * A.dblDetailRate
					END AS DECIMAL(18,2)) AS dblTotal
		, CASE WHEN A.intTransactionType NOT IN (1,14) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue
				END * A.dblDetailRate AS dblAmountDue
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
		, A.intEntityClassId
	FROM BillVendorEntityDetail A
	WHERE A.ysnPosted = 1 AND intTransactionType NOT IN (7, 2, 12, 13)  AND A.ysnOrigin = 0

	--VOID VOUCHER DELETED
	UNION ALL SELECT A.dtmDate	
		, A.intBillId 
		, A.strBillId 
		, 0 AS dblAmountPaid 
		, CAST(CASE WHEN A.intTransactionType NOT IN (1,14) THEN (B.dblTotal) *  B.dblRate * -1 
					ELSE (B.dblTotal) * B.dblRate
					END AS DECIMAL(18,2)) AS dblTotal
		, CASE WHEN A.intTransactionType NOT IN (1,14) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue
				END * B.dblRate AS dblAmountDue 
		, dblWithheld = 0
		, dblDiscount = 0 
		, dblInterest = 0 
		, dblPrepaidAmount = 0 
		, C1.strVendorId 
		, isnull(C1.strVendorId,'') + ' - ' + isnull(C1.strName,'') as strVendorIdName 
		, A.dtmDueDate
		, A.ysnPosted 
		, A.ysnPaid
		, A.intAccountId
		, C1.intEntityClassId
	FROM dbo.tblAPBillArchive A
	LEFT JOIN VendorEntity C1 ON C1.intEntityId = A.intEntityVendorId
	LEFT JOIN dbo.tblAPBillDetailArchive B ON B.intBillId = A.intBillId
	WHERE A.ysnPosted = 1 AND intTransactionType NOT IN (7, 2, 12, 13)  AND A.ysnOrigin = 0

	--Taxes, Separate the tax and use the detail tax to match with GL calculation
	UNION ALL SELECT A.dtmDate	
		, A.intBillId 
		, A.strBillId 
		, 0 AS dblAmountPaid 
		, CAST(CASE WHEN A.intTransactionType NOT IN (1,14) THEN ISNULL(A.dblDetailTax, 0) *  A.dblDetailRate * -1 
					ELSE ISNULL(A.dblDetailTax, 0) * A.dblDetailRate
			END AS DECIMAL(18,2)) AS dblTotal
		, CASE WHEN A.intTransactionType NOT IN (1,14) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue
			END * A.dblDetailRate AS dblAmountDue 
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
		, A.intEntityClassId
	FROM BillVendorEntityDetail A
	WHERE A.ysnPosted = 1 AND intTransactionType NOT IN (7, 2, 12, 13)  AND A.ysnOrigin = 0 AND A.dblDetailTax != 0

	--ORIGIN
	UNION ALL SELECT A.dtmDate	
		, A.intBillId 
		, A.strBillId 
		, 0 AS dblAmountPaid 
		, CAST(CASE WHEN A.intTransactionType NOT IN (1,14) AND A.dblTotal > 0 THEN (A.dblTotal + A.dblTax) * -1 ELSE A.dblTotal + A.dblTax END AS DECIMAL(18,2)) AS dblTotal
		, CASE WHEN A.intTransactionType NOT IN (1,14) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END AS dblAmountDue 
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
		, A.intEntityClassId
	FROM BillVendorEntity A
	WHERE A.ysnPosted = 1 AND intTransactionType NOT IN (7, 2, 12, 13) AND A.ysnOrigin = 1

	UNION ALL SELECT A.dtmDatePaid AS dtmDate
		, C.intBillId
		, C.strBillId
		, CAST(B.dblPayment  * ISNULL(avgRate.dblExchangeRate,1) AS DECIMAL(18,2)) AS dblAmountPaid
		, dblTotal = 0
		, dblAmountDue = 0
		, dblWithheld = B.dblWithheld
		, CAST(CASE WHEN C.intTransactionType NOT IN (1,2,14) AND ABS(B.dblDiscount) > 0
						THEN B.dblDiscount --* -1 note: we expect that the discount in 20.1 is already negative
					ELSE (
						--Honor only the discount if full payment, consider only for voucher
						CASE WHEN B.dblAmountDue = 0 AND ISNULL(E.ysnCheckVoid,0) = 0 THEN B.dblDiscount
							ELSE 0 END)
					END * ISNULL(avgRate.dblExchangeRate,1) AS DECIMAL(18,2)) AS dblDiscount
		, CAST(CASE WHEN C.intTransactionType NOT IN (1,2,14) AND ABS(B.dblInterest) > 0 THEN B.dblInterest --* -1
					ELSE B.dblInterest
					END * ISNULL(avgRate.dblExchangeRate,1) AS DECIMAL(18,2)) AS dblInterest 
		, dblPrepaidAmount = 0
		, C.strVendorId
		, isnull(C.strVendorId,'') + ' - ' + isnull(C.strName,'') as strVendorIdName
		, C.dtmDueDate
		, C.ysnPosted
		, C.ysnPaid
		, B.intAccountId
		, C.intEntityClassId
	FROM dbo.tblAPPayment A
	INNER JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
	INNER JOIN BillVendorEntity C ON ISNULL(B.intBillId,B.intOrigBillId) = C.intBillId
	LEFT JOIN (
		SELECT A.intBillId
			, dblExchangeRate = SUM(ISNULL(NULLIF(A.dblRate,0), 1)) / COUNT(1)
		FROM tblAPBillDetail A
		GROUP BY A.intBillId
	) avgRate ON C.intBillId = avgRate.intBillId --handled payment for origin old payment import
	LEFT JOIN dbo.tblCMBankTransaction E ON A.strPaymentRecordNum = E.strTransactionId
	WHERE A.ysnPosted = 1
		AND C.ysnPosted = 1
		AND C.intTransactionType NOT IN (2, 12, 13)
		AND A.ysnPrepay = 0 --EXCLUDE THE PREPAYMENT

	--APPLIED VOUCHER, (Payment have been made using prepaid and debit memos tab)
	UNION ALL SELECT A.dtmDate
		, A.intBillId
		, A.strBillId
		, B.dblAmountApplied
		, 0 AS dblTotal
		, 0 AS dblAmountDue
		, 0 AS dblWithheld
		, 0 AS dblDiscount
		, 0 AS dblInterest
		, 0 AS dblPrepaidAmount 
		, ISNULL(A.strVendorId,'') + ' - ' + ISNULL(A.strName,'') as strVendorIdName 
		, A.strVendorId
		, A.dtmDueDate
		, A.ysnPosted
		, C.ysnPaid
		, A.intAccountId
		, A.intEntityClassId
	FROM BillVendorEntity A
	INNER JOIN dbo.tblAPAppliedPrepaidAndDebit B ON A.intBillId = B.intBillId
	INNER JOIN dbo.tblAPBill C ON B.intTransactionId = C.intBillId
	OUTER APPLY (
		SELECT TOP 1 voucherDetail.dblRate
		FROM tblAPBillDetail voucherDetail
		WHERE voucherDetail.intBillDetailId = B.intBillDetailApplied
	) voucherDetailApplied
	WHERE A.ysnPosted = 1 AND B.ysnApplied = 1

	--APPLIED DM, (DM HAVE BEEN USED AS OFFSET IN PREPAID AND DEBIT MEMO TABS)
	UNION ALL SELECT C.dtmDate --THIS SHOUD BE THE DATE OF THE VOUCHER THAT APPLIED THE DM
		, A.intBillId
		, A.strBillId
		, B.dblAmountApplied * (CASE WHEN A.intTransactionType NOT IN (1,14) THEN -1 ELSE 1 END)
		, 0 AS dblTotal
		, 0 AS dblAmountDue
		, 0 AS dblWithheld
		, 0 AS dblDiscount
		, 0 AS dblInterest
		, 0 AS dblPrepaidAmount 
		, ISNULL(A.strVendorId,'') + ' - ' + ISNULL(A.strName,'') as strVendorIdName 
		, A.strVendorId
		, A.dtmDueDate
		, A.ysnPosted
		, C.ysnPaid
		, A.intAccountId
		, A.intEntityClassId
	FROM BillVendorEntity A
	INNER JOIN dbo.tblAPAppliedPrepaidAndDebit B ON A.intBillId = B.intTransactionId
	INNER JOIN dbo.tblAPBill C ON B.intBillId = C.intBillId
	WHERE C.ysnPosted = 1 AND A.intTransactionType = 3 AND B.ysnApplied = 1 AND A.ysnPosted = 1

	--OVERPAYMENT
	UNION ALL SELECT A.dtmDate
		, A.intBillId 
		, A.strBillId 
		, 0 AS dblAmountPaid 
		, CASE WHEN A.intTransactionType NOT IN (1,14) AND A.dblTotal > 0 THEN A.dblTotal * -1 ELSE A.dblTotal END AS dblTotal
		, CASE WHEN A.intTransactionType NOT IN (1,14) AND A.dblAmountDue > 0 THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END AS dblAmountDue 
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
		, A.intEntityClassId
	FROM BillVendorEntity A
	WHERE intTransactionType IN (8) AND A.ysnPaid != 1

	--PAYMENT MADE TO AR
	UNION ALL SELECT A.dtmDatePaid AS dtmDate
		, B.intBillId
		, C.strBillId
		, CAST(CASE WHEN C.intTransactionType NOT IN (1,2, 14) AND B.dblPayment != 0
						THEN (CASE WHEN (E.intBankTransactionTypeId <> 19 OR E.intBankTransactionTypeId <> 116 OR E.intBankTransactionTypeId IS NULL) THEN B.dblPayment * -1 ELSE B.dblPayment END)
					WHEN C.intTransactionType NOT IN (1,2, 14) AND B.dblPayment < 0 AND (E.intBankTransactionTypeId = 116 OR E.intBankTransactionTypeId = 19)
						THEN B.dblPayment * -1 --MAKE THE REVERSAL DEBIT MEMO TRANSACTION POSITIVE
					ELSE ABS(B.dblPayment) * ISNULL(A.dblExchangeRate,1) END AS DECIMAL(18,2)) AS dblAmountPaid --ALWAYS CONVERT TO POSSITIVE TO OFFSET THE PAYMENT
		, dblTotal = 0 
		, dblAmountDue = 0 
		, dblWithheld = 0
		, CASE WHEN C.intTransactionType NOT IN (1,2,14) AND B.dblDiscount > 0 THEN B.dblDiscount * -1 ELSE ABS(B.dblDiscount) END AS dblDiscount
		, CASE WHEN C.intTransactionType NOT IN (1,2,14) AND B.dblInterest > 0 THEN B.dblInterest * -1 ELSE ABS(B.dblInterest) END AS dblInterest 
		, dblPrepaidAmount = 0 
		, C.strVendorId 
		, isnull(C.strVendorId,'') + ' - ' + isnull(C.strName,'') as strVendorIdName 
		, C.dtmDueDate 
		, C.ysnPosted 
		, C.ysnPaid
		, B.intAccountId
		, C.intEntityClassId
	FROM dbo.tblARPayment  A
	LEFT JOIN dbo.tblARPaymentDetail B ON A.intPaymentId = B.intPaymentId
	LEFT JOIN BillVendorEntity C ON B.intBillId = C.intBillId
	LEFT JOIN dbo.tblCMBankTransaction E ON A.strRecordNumber = E.strTransactionId
	WHERE A.ysnPosted = 1
		AND C.ysnPosted = 1
		AND C.intTransactionType NOT IN (2)

	--BILL PAYMENT TRANSACTION (PAYMENT TRANSACTION FOR DELETE PAY SCENARIO)
	UNION ALL SELECT A.dtmDatePaid AS dtmDate 
		, ISNULL(B.intBillId ,B.intOrigBillId) AS intBillId  
		, C.strBillId
		, CAST(B.dblPayment * prepaidDetail.dblRate AS DECIMAL(18,2))  AS dblAmountPaid
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
		, C.intEntityClassId
	FROM dbo.tblAPPayment  A
	INNER JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
	INNER JOIN BillVendorEntity C ON ISNULL(B.intBillId,B.intOrigBillId) = C.intBillId
	LEFT JOIN dbo.tblCMBankTransaction E ON A.strPaymentRecordNum = E.strTransactionId
	OUTER APPLY (
		SELECT TOP 1 bd.dblRate
		FROM tblAPBillDetail bd
		WHERE bd.intBillId = C.intBillId
	) prepaidDetail
	WHERE A.ysnPosted = 1
		AND C.ysnPosted = 1
		AND C.intTransactionType IN (1, 3) --BILL TRANSACTION ONLY
		AND A.ysnPrepay = 1
		AND NOT EXISTS (SELECT 1 FROM vyuAPPaidOriginPrepaid originPrepaid WHERE originPrepaid.intBillId = C.intBillId)
) tbl
LEFT JOIN tblEMEntityClass ec ON ec.intEntityClassId = tbl.intEntityClassId
LEFT JOIN tblGLAccount gl ON gl.intAccountId = tbl.intAccountId
