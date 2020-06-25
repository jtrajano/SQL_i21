CREATE VIEW vyuAPStatus
AS

WITH vouchertransactions AS ( --voucher transactions
	SELECT
		intBillId
		,strBillId
		,intTransactionType
		,dblTotal
		,dblAmountDue
		,dblInterest
		,dblDiscount
		,dblPayment
		,ysnPaid
		,ysnOrigin
		,ysnPosted
	FROM tblAPBill
	WHERE dtmDate BETWEEN '1/1/2014' AND '12/31/2014'
),
	vouchers AS ( --voucher type transaction
	SELECT
		intBillId
		,strBillId
		,intTransactionType
		,dblTotal
		,dblAmountDue
		,dblInterest
		,dblDiscount
		,dblPayment
		,ysnPaid
		,ysnOrigin
		,ysnPosted
	FROM vouchertransactions
	WHERE intTransactionType = 1
),
	vendorprepayments AS ( --prepayment type transaction
	SELECT
		intBillId
		,strBillId
		,intTransactionType
		,(CASE WHEN dblTotal > 0 THEN dblTotal * -1 ELSE dblTotal END) AS dblTotal
		,dblAmountDue
		,ysnPaid
		,ysnOrigin
		,ysnPosted
	FROM vouchertransactions
	WHERE intTransactionType = 2 AND ysnPaid = 0 AND ysnPosted = 1
),
	debitmemos AS ( --debit memo type transaction
	SELECT
		intBillId
		,strBillId
		,intTransactionType
		,CASE WHEN dblTotal > 0 THEN dblTotal * -1 ELSE dblTotal END AS dblTotal
		,CASE WHEN dblAmountDue > 0 THEN dblAmountDue * -1 ELSE dblAmountDue END AS dblAmountDue
		,CASE WHEN dblInterest > 0 THEN dblInterest * -1 ELSE dblInterest END AS dblInterest
		,CASE WHEN dblDiscount > 0 THEN dblDiscount * -1 ELSE dblDiscount END AS dblDiscount
		,CASE WHEN dblPayment != 0 THEN dblPayment * -1 ELSE dblPayment END AS dblPayment
		,ysnPaid
		,ysnOrigin
		,ysnPosted
	FROM vouchertransactions
	WHERE intTransactionType = 3
),
	overpayments AS ( --overpayment type transaction
	SELECT
		intBillId
		,strBillId
		,intTransactionType
		,CASE WHEN dblTotal > 0 THEN dblTotal * -1 ELSE dblTotal END AS dblTotal
		,dblAmountDue
		,dblInterest
		,dblDiscount
		,dblPayment
		,ysnPaid
		,ysnOrigin
		,ysnPosted
	FROM vouchertransactions
	WHERE ysnPosted = 0 AND intTransactionType = 8
),
	payments AS ( --payment transactions
	SELECT
		A.intPaymentId
		,A.strPaymentRecordNum
		,A.dblAmountPaid
		,A.ysnPosted
		,A.ysnOrigin
	FROM tblAPPayment A
	INNER JOIN tblCMBankTransaction B ON A.strPaymentRecordNum = B.strTransactionId
	WHERE B.ysnCheckVoid = 0
	AND A.strPaymentInfo NOT LIKE '%Voided%'
	AND A.dtmDatePaid BETWEEN '1/1/2014' AND '12/31/2014'
),
	originpayments AS ( --origin payment transactions
	SELECT
		A.intPaymentId
		,A.dblAmountPaid
		,A.ysnPosted
		,A.ysnOrigin
	FROM payments A
	WHERE A.ysnPosted = 1 AND A.ysnOrigin = 1
),
	gl AS ( --AP GL records
	SELECT
		C.intAccountId
		,C.intTransactionId
		,C.strTransactionId
		,C.strTransactionForm
		,C.strTransactionType
		,C.strModuleName
		,C.strJournalLineDescription
		,C.intJournalLineNo
		,CAST((C.dblCredit - dblDebit) AS DECIMAL(18,6)) AS dblTotal
	FROM tblGLDetail C
	INNER JOIN vyuGLAccountDetail D ON C.intAccountId = D.intAccountId
	WHERE ysnIsUnposted = 0 
	AND dtmDate BETWEEN '1/1/2014' AND '12/31/2014'
	AND D.intAccountCategoryId IN (
		SELECT intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'AP Account'
		UNION ALL
		SELECT intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'Vendor Prepayments'
	)
),
	glDiscount AS ( --AP GL Discount Records
	SELECT
		C.intAccountId
		,C.intTransactionId
		,C.strTransactionId
		,C.strTransactionForm
		,C.strTransactionType
		,C.strModuleName
		,C.strJournalLineDescription
		,CAST((C.dblCredit - dblDebit) AS DECIMAL(18,6)) AS dblTotal
	FROM tblGLDetail C
	INNER JOIN vyuGLAccountDetail D ON C.intAccountId = D.intAccountId
	WHERE ysnIsUnposted = 0 
	AND dtmDate BETWEEN '1/1/2014' AND '12/31/2014'
	AND strJournalLineDescription = 'Discount' AND C.strCode = 'AP' AND C.strTransactionType = 'Payable'
)

SELECT
	[Description] COLLATE Latin1_General_CI_AS AS [Description]
	,[Total]
FROM (
	SELECT 
		--ORIGIN DEBIT MEMO
		ISNULL(OriginDebitMemo.dblTotalOriginDebitMemo,0) AS [Total Origin DebitMemos],
		ISNULL(OriginDebitMemoUnposted.dblTotalOriginDebitMemoUnposted,0) AS [Total Origin DebitMemos Unposted],
		ISNULL(OriginDebitMemoPosted.dblTotalOriginDebitMemoPosted,0) AS [Total Origin DebitMemos Posted],
		ISNULL(OriginDebitMemoPostedi21.dblTotalOriginDebitMemoPostedi21,0) AS [Total Origin DebitMemos Posted in i21],
		ISNULL(OriginDebitMemoPostedi21GL.dblOriginDebitMemoGLTotal,0) AS [Total Origin DebitMemos GL Posted in i21],
		ISNULL(OriginDebitMemoUnpaid.dblTotalOriginDebitMemoUnpaid,0) AS [Total Origin DebitMemos Unpaid],
		ISNULL(OriginDebitMemoPayment.dblTotalOriginDebitMemoPayment,0) AS [Total Origin DebitMemos Payment],
		ISNULL(OriginDebitMemoPayment.dblTotalOriginDebitMemoDiscount,0) AS [Total Origin DebitMemos Payment Discount],
		ISNULL(OriginDebitMemoPayment.dblTotalOriginDebitMemoInterest,0) AS [Total Origin DebitMemos Payment Interest],
		ISNULL(OriginDebitMemoPaymenti21.dblTotalOriginDebitMemoPaymenti21,0) AS [Total Origin DebitMemos Payment in i21],
		ISNULL(OriginDebitMemoPaymenti21GL.dblOriginDebitMemoPaymentGLTotal,0) AS [Total Origin DebitMemos Payment GL in i21],
		ISNULL(OriginDebitMemoPaymenti21.dblTotalOriginDebitMemoDiscounti21,0) AS [Total Origin DebitMemos Discount in i21],
		ISNULL(OriginDebitMemoPaymenti21.dblTotalOriginDebitMemoInteresti21,0) AS [Total Origin DebitMemos Interest in i21],
		(
			ISNULL(OriginDebitMemoPosted.dblTotalOriginDebitMemoPosted,0) + ISNULL(OriginDebitMemoPostedi21.dblTotalOriginDebitMemoPostedi21,0)
		+	ISNULL(OriginDebitMemoPayment.dblTotalOriginDebitMemoInterest,0)
		+	ISNULL(OriginDebitMemoPaymenti21.dblTotalOriginDebitMemoInteresti21,0)
		-	ISNULL(OriginDebitMemoPayment.dblTotalOriginDebitMemoDiscount,0)
		-	ISNULL(OriginDebitMemoPaymenti21.dblTotalOriginDebitMemoDiscounti21,0)
		) 
		+ (
			ISNULL(OriginDebitMemoPayment.dblTotalOriginDebitMemoPayment,0) + ISNULL(OriginDebitMemoPaymenti21.dblTotalOriginDebitMemoPaymenti21,0)
		) AS [Total Origin DM Payables],
		--ORIGIN VOUCHER
		ISNULL(OriginVouchers.dblTotalOriginVouchers,0) AS [Total Origin Vouchers],
		ISNULL(OriginVouchersUnposted.dblTotalOriginVouchersUnposted,0) AS [Total Origin Vouchers Unposted],
		ISNULL(OriginVouchersPosted.dblTotalOriginVouchersPosted,0) AS [Total Origin Vouchers Posted],
		ISNULL(OriginVouchersPostedi21.dblTotalOriginVouchersPostedi21,0) AS [Total Origin Vouchers Posted in i21],
		ISNULL(OriginVoucherPostedi21GL.dblOriginVoucherGLTotal,0) AS [Total Origin Vouchers GL Posted in i21],
		ISNULL(OriginVouchersUnpaid.dblTotalOriginVoucherUnpaid,0) AS [Total Origin Vouchers Unpaid],
		ISNULL(OriginVouchersPayment.dblTotalOriginVoucherPayment,0) AS [Total Origin Vouchers Payment],
		ISNULL(OriginVouchersPayment.dblTotalOriginVoucherDiscount,0) AS [Total Origin Vouchers Discount],
		ISNULL(OriginVouchersPayment.dblTotalOriginVoucherInterest,0) AS [Total Origin Vouchers Interest],
		ISNULL(OriginVouchersPaymenti21.dblTotalOriginVoucherPaymenti21,0) AS [Total Origin Vouchers Payment in i21],
		ISNULL(OriginVoucherPaymenti21GL.dblOriginVoucherPaymentGLTotal,0) AS [Total Origin Vouchers Payment GL in i21],
		ISNULL(OriginVouchersPaymenti21.dblTotalOriginVoucherDiscounti21,0) AS [Total Origin Vouchers Discount in i21],
		ISNULL(OriginVouchersPaymenti21.dblTotalOriginVoucherInteresti21,0) AS [Total Origin Vouchers Interest in i21],
		(
			ISNULL(OriginVouchersPosted.dblTotalOriginVouchersPosted,0) + ISNULL(OriginVouchersPostedi21.dblTotalOriginVouchersPostedi21,0)
		+	ISNULL(OriginVouchersPayment.dblTotalOriginVoucherInterest,0)
		+	ISNULL(OriginVouchersPaymenti21.dblTotalOriginVoucherInteresti21,0)
		-	ISNULL(OriginVouchersPayment.dblTotalOriginVoucherDiscount,0)
		-	ISNULL(OriginVouchersPaymenti21.dblTotalOriginVoucherDiscounti21,0)
		) 
		-(
			ISNULL(OriginVouchersPayment.dblTotalOriginVoucherPayment,0) + ISNULL(OriginVouchersPaymenti21.dblTotalOriginVoucherPaymenti21,0)
		) AS [Total Origin Voucher Payables],
		--Origin Transactions Summary
		ISNULL(OriginPrepayment.dblTotalOriginPrepayments,0) AS [Total Origin Prepayments],
		(ISNULL(OriginDebitMemo.dblTotalOriginDebitMemo,0) + ISNULL(OriginPrepayment.dblTotalOriginPrepayments,0) + ISNULL(OriginVouchers.dblTotalOriginVouchers,0)) AS [Total Origin Voucher Transactions],
		(
			(ISNULL(OriginVouchersPayment.dblTotalOriginVoucherPayment,0) + ISNULL(OriginVouchersPaymenti21.dblTotalOriginVoucherPaymenti21,0))
		-	(ISNULL(OriginDebitMemoPayment.dblTotalOriginDebitMemoPayment,0) + ISNULL(OriginDebitMemoPaymenti21.dblTotalOriginDebitMemoPaymenti21,0))
		)
		AS [Total Origin Payments],
		(
			ISNULL(OriginVouchersUnpaid.dblTotalOriginVoucherUnpaid,0) 
		+	ISNULL(OriginDebitMemoUnpaid.dblTotalOriginDebitMemoUnpaid,0)
		) AS [Total Origin Payables],
		ISNULL(OriginAPGL.dblOriginAPGLTotal,0) AS [Total Origin AP GL Payables],
		(
			(
				ISNULL(OriginVouchersUnpaid.dblTotalOriginVoucherUnpaid,0) 
			+	ISNULL(OriginDebitMemoUnpaid.dblTotalOriginDebitMemoUnpaid,0)
			) 
			-	ISNULL(OriginAPGL.dblOriginAPGLTotal,0)
		) AS [Origin Payables Discrepancy],
		--i21 Debit Memos
		ISNULL(i21DebitMemo.dblTotali21DebitMemo,0) AS [Total i21 Debit Memos],
		ISNULL(i21DebitMemoUnposted.dblTotali21DebitMemoUnposted,0) AS [Total i21 Debit Memos Unposted],
		ISNULL(i21DebitMemoPosted.dblTotali21DebitMemoPosted,0) AS [Total i21 Debit Memos Posted],
		ISNULL(i21DebitMemoPayment.dblTotalDebitMemoPaymenti21,0) AS [Total i21 Debit Memos Payment],
		ISNULL(i21DebitMemoPayment.dblTotalDebitMemoInteresti21,0) AS [Total i21 Debit Memos Interest],
		ISNULL(i21DebitMemoPayment.dblTotalDebitMemoDiscounti21,0) AS [Total i21 Debit Memos Discount],
		ISNULL(i21DebitMemoUnpaid.dblTotali21DebitMemoUnpaid,0) AS [Total i21 Debit Memos Unpaid],
		ISNULL(i21APDebitMemoGL.dbli21APDebitMemoGLTotal,0) AS [Total i21 Debit Memos GL],
		--i21 Vouchers
		ISNULL(i21Prepayment.dblTotali21Prepayments,0) AS [Total i21 Prepayments],
		ISNULL(i21Vouchers.dblTotali21Vouchers,0) AS [Total i21 Vouchers],
		ISNULL(i21VouchersUnposted.dblTotali21VouchersUnposted,0) AS [Total i21 Vouchers Unposted],
		ISNULL(i21VouchersPosted.dblTotali21VouchersPosted,0) AS [Total i21 Vouchers Posted],
		ISNULL(i21VoucherUnpaid.dblTotali21VoucherUnpaid,0) AS [Total i21 Vouchers Unpaid],
		ISNULL(i21VoucherPayment.dblTotalVoucherPaymenti21,0) AS [Total i21 Vouchers Payment],
		ISNULL(i21VoucherPayment.dblTotalVoucherDiscounti21,0) AS [Total i21 Vouchers Discount],
		ISNULL(i21VoucherPayment.dblTotalVoucherInteresti21,0) AS [Total i21 Vouchers Interest],
		ISNULL(i21APVoucherGL.dbli21APVoucherGLTotal,0) AS [Total i21 Vouchers GL],
		(ISNULL(i21DebitMemo.dblTotali21DebitMemo,0) + ISNULL(i21Prepayment.dblTotali21Prepayments,0) + ISNULL(i21Vouchers.dblTotali21Vouchers,0)) AS [Total i21 Voucher Transactions],
		(
			ISNULL(i21VoucherUnpaid.dblTotali21VoucherUnpaid,0) 
		+	ISNULL(i21DebitMemoUnpaid.dblTotali21DebitMemoUnpaid,0)
		) AS [Total i21 Payables],
		--ISNULL(i21Payments.dblTotali21Payments,0) AS [Total i21 Payments],
		ISNULL(i21APPaymentGL.dbli21APPaymentGLTotal,0) AS [Total i21 GL Payments],
		ISNULL(i21APPaymentDiscountGL.dbli21APPaymentDiscountGLTotal,0) AS [Total i21 GL Payments Discount],
		--(ISNULL(i21DebitMemo.dblTotali21DebitMemo,0) + ISNULL(i21Prepayment.dblTotali21Prepayments,0) + ISNULL(i21Vouchers.dblTotali21Vouchers,0))
		--- ISNULL(i21Payments.dblTotali21Payments,0) AS [Total i21 Payables],
		ISNULL(i21APGL.dbli21APGLTotal,0) AS [Total AP GL Payables],
		--((ISNULL(i21DebitMemo.dblTotali21DebitMemo,0) + ISNULL(i21Prepayment.dblTotali21Prepayments,0) + ISNULL(i21Vouchers.dblTotali21Vouchers,0))
		--- ISNULL(i21Payments.dblTotali21Payments,0))
		--- (ISNULL(i21APGL.dbli21APGLTotal,0) + ISNULL(i21APPaymentDiscountGL.dbli21APPaymentDiscountGLTotal,0)) AS [Total i21 Payables Discrepancy],
		--((ISNULL(i21DebitMemo.dblTotali21DebitMemo,0) + ISNULL(i21Prepayment.dblTotali21Prepayments,0) + ISNULL(i21Vouchers.dblTotali21Vouchers,0))
		--- ISNULL(i21Payments.dblTotali21Payments,0))
		--+
		--((ISNULL(OriginDebitMemo.dblTotalOriginDebitMemo,0) + ISNULL(OriginPrepayment.dblTotalOriginPrepayments,0) + ISNULL(OriginVouchers.dblTotalOriginVouchers,0)) - (ISNULL(OriginPayments.dblOriginPayments,0))) 
		--AS [Computed AP Payables(origin + i21)],
		ISNULL(OriginAPGL.dblOriginAPGLTotal,0) + ISNULL(i21APGL.dbli21APGLTotal,0) AS [Computed AP GL Payables(origin + i21)]
	FROM (
		SELECT 
			SUM(dblTotal) dblTotalOriginDebitMemo
		FROM debitmemos
		WHERE ysnOrigin = 1
		--AND NOT EXISTS (
		--	SELECT 1 FROM gl WHERE gl.intTransactionId = intBillId AND gl.strTransactionId = strBillId
		--)
	) OriginDebitMemo
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) dblTotalOriginDebitMemoUnposted
		FROM debitmemos
		WHERE ysnOrigin = 1 AND ysnPosted = 0
		--AND NOT EXISTS (
		--	SELECT 1 FROM gl WHERE gl.intTransactionId = intBillId AND gl.strTransactionId = strBillId
		--)
	) OriginDebitMemoUnposted
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) dblTotalOriginDebitMemoPosted
		FROM debitmemos
		WHERE ysnOrigin = 1 AND ysnPosted = 1
		AND NOT EXISTS (
			SELECT 1 FROM gl WHERE gl.intTransactionId = intBillId AND gl.strTransactionId = strBillId
		)
	) OriginDebitMemoPosted
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) dblTotalOriginDebitMemoPostedi21
		FROM debitmemos
		WHERE ysnOrigin = 1 AND ysnPosted = 1
		AND EXISTS (
			SELECT 1 FROM gl WHERE gl.intTransactionId = intBillId AND gl.strTransactionId = strBillId
		)
	) OriginDebitMemoPostedi21
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) AS dblOriginDebitMemoGLTotal
		FROM gl
		WHERE 
			strModuleName = 'Accounts Payable'  AND 
			strTransactionType = 'Debit Memo' AND
			strTransactionForm = 'Bill' AND
			EXISTS (
				--make sure get only the gl of debit memo created in i21
				SELECT 1 FROM tblAPBill Bill 
				WHERE Bill.strBillId = gl.strTransactionId 
				AND Bill.intBillId = gl.intTransactionId 
				AND Bill.ysnOrigin = 1 
				AND Bill.ysnPosted = 1 
				AND Bill.intTransactionType = 3
			)
	) OriginDebitMemoPostedi21GL
	CROSS APPLY (
		SELECT 
			SUM(debitmemos.dblAmountDue) dblTotalOriginDebitMemoUnpaid
		FROM debitmemos
		LEFT JOIN tblAPPaymentDetail DMPaymentDetail ON debitmemos.intBillId = DMPaymentDetail.intBillId
		WHERE debitmemos.ysnOrigin = 1 AND debitmemos.ysnPosted = 1 
		AND (DMPaymentDetail.intPaymentDetailId IS NULL OR debitmemos.dblAmountDue > 0)
		AND debitmemos.ysnPaid = 0
		--AND NOT EXISTS (
		--	SELECT 1 FROM gl WHERE gl.intTransactionId = debitmemos.intBillId AND gl.strTransactionId = debitmemos.strBillId
		--)
	) OriginDebitMemoUnpaid
	CROSS APPLY (
		SELECT 
			SUM(DMPaymentDetail.dblPayment) dblTotalOriginDebitMemoPayment
			,SUM(DMPaymentDetail.dblDiscount) dblTotalOriginDebitMemoDiscount
			,SUM(DMPaymentDetail.dblInterest) dblTotalOriginDebitMemoInterest
		FROM debitmemos
		INNER JOIN tblAPPaymentDetail DMPaymentDetail ON debitmemos.intBillId = DMPaymentDetail.intBillId
		INNER JOIN tblAPPayment DMPayment ON DMPaymentDetail.intPaymentId = DMPayment.intPaymentId
		WHERE debitmemos.ysnOrigin = 1 AND debitmemos.ysnPosted = 1 
		AND DMPayment.ysnOrigin = 1
		AND DMPayment.strPaymentInfo NOT LIKE '%Voided%'
		--AND NOT EXISTS (
		--	SELECT 1 FROM gl WHERE gl.intTransactionId = debitmemos.intBillId AND gl.strTransactionId = debitmemos.strBillId
		--)
	) OriginDebitMemoPayment
	CROSS APPLY (
		SELECT 
			SUM(DMPaymentDetail.dblPayment) dblTotalOriginDebitMemoPaymenti21
			,SUM(DMPaymentDetail.dblDiscount) dblTotalOriginDebitMemoDiscounti21
			,SUM(DMPaymentDetail.dblInterest) dblTotalOriginDebitMemoInteresti21
		FROM debitmemos
		INNER JOIN tblAPPaymentDetail DMPaymentDetail ON debitmemos.intBillId = DMPaymentDetail.intBillId
		INNER JOIN tblAPPayment DMPayment ON DMPaymentDetail.intPaymentId = DMPayment.intPaymentId
		WHERE debitmemos.ysnOrigin = 1 AND debitmemos.ysnPosted = 1 
		AND DMPayment.ysnOrigin = 0
		AND DMPayment.strPaymentInfo NOT LIKE '%Voided%'
		--AND NOT EXISTS (
		--	SELECT 1 FROM gl WHERE gl.intTransactionId = debitmemos.intBillId AND gl.strTransactionId = debitmemos.strBillId
		--)
	) OriginDebitMemoPaymenti21
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) AS dblOriginDebitMemoPaymentGLTotal
		FROM gl
		WHERE 
			strModuleName = 'Accounts Payable'  AND 
			strTransactionType = 'Payable' AND
			strTransactionForm = 'Payable' AND
			EXISTS (
				--make sure get only the gl of debit memo created in i21
				SELECT 1 FROM tblAPBill Bill 
				WHERE Bill.strBillId = gl.strJournalLineDescription 
				--AND Bill.intBillId = gl.intJournalLineNo 
				AND Bill.ysnOrigin = 1 
				AND Bill.ysnPosted = 1 
				AND Bill.intTransactionType = 3
			)
	) OriginDebitMemoPaymenti21GL
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) dblTotalOriginVouchers
		FROM vouchers
		WHERE ysnOrigin = 1
		--AND NOT EXISTS (
		--	SELECT 1 FROM gl WHERE gl.intTransactionId = intBillId AND gl.strTransactionId = strBillId
		--)
	) OriginVouchers
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) dblTotalOriginVouchersUnposted
		FROM vouchers
		WHERE ysnOrigin = 1 AND ysnPosted = 0
		--AND NOT EXISTS (
		--	SELECT 1 FROM gl WHERE gl.intTransactionId = intBillId AND gl.strTransactionId = strBillId
		--)
	) OriginVouchersUnposted
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) dblTotalOriginVouchersPosted
		FROM vouchers
		WHERE ysnOrigin = 1 AND ysnPosted = 1
		AND NOT EXISTS (
			SELECT 1 FROM gl WHERE gl.intTransactionId = intBillId AND gl.strTransactionId = strBillId
		)
	) OriginVouchersPosted
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) dblTotalOriginVouchersPostedi21
		FROM vouchers
		WHERE ysnOrigin = 1 AND ysnPosted = 1
		AND EXISTS (
			SELECT 1 FROM gl WHERE gl.intTransactionId = intBillId AND gl.strTransactionId = strBillId
		)
	) OriginVouchersPostedi21
		CROSS APPLY (
		SELECT 
			SUM(dblTotal) AS dblOriginVoucherGLTotal
		FROM gl
		WHERE 
			strModuleName = 'Accounts Payable'  AND 
			strTransactionType = 'Bill' AND
			strTransactionForm = 'Bill' AND
			EXISTS (
				--make sure get only the gl of debit memo created in i21
				SELECT 1 FROM tblAPBill Bill 
				WHERE Bill.strBillId = gl.strTransactionId 
				AND Bill.intBillId = gl.intTransactionId 
				AND Bill.ysnOrigin = 1 
				AND Bill.ysnPosted = 1 
				AND Bill.intTransactionType = 1
			)
	) OriginVoucherPostedi21GL
	CROSS APPLY (
		SELECT 
			SUM(vouchers.dblAmountDue) dblTotalOriginVoucherUnpaid
		FROM vouchers
		--LEFT JOIN tblAPPaymentDetail DMPaymentDetail ON vouchers.intBillId = DMPaymentDetail.intBillId --LEFT JOIN to Include partial and unpartial
		WHERE vouchers.ysnOrigin = 1 AND vouchers.ysnPosted = 1 AND vouchers.ysnPaid = 0
		--AND (DMPaymentDetail.intPaymentDetailId IS NULL OR vouchers.dblAmountDue > 0)
		--AND NOT EXISTS (
		--	SELECT 1 FROM gl WHERE gl.intTransactionId = vouchers.intBillId AND gl.strTransactionId = vouchers.strBillId
		--)
	) OriginVouchersUnpaid
	CROSS APPLY (
		SELECT 
			SUM(DMPaymentDetail.dblPayment) dblTotalOriginVoucherPayment
			,SUM(DMPaymentDetail.dblDiscount) dblTotalOriginVoucherDiscount
			,SUM(DMPaymentDetail.dblInterest) dblTotalOriginVoucherInterest
		FROM vouchers
		INNER JOIN tblAPPaymentDetail DMPaymentDetail ON vouchers.intBillId = DMPaymentDetail.intBillId
		INNER JOIN tblAPPayment DMPayment ON DMPaymentDetail.intPaymentId = DMPayment.intPaymentId
		WHERE vouchers.ysnOrigin = 1 AND vouchers.ysnPosted = 1
		AND DMPayment.ysnOrigin = 1
		--AND DMPayment.strPaymentRecordNum NOT LIKE '%V%'
		--AND NOT EXISTS (
		--	SELECT 1 FROM gl WHERE gl.intTransactionId = vouchers.intBillId AND gl.strTransactionId = vouchers.strBillId
		--)
	) OriginVouchersPayment
	CROSS APPLY (
		SELECT 
			SUM(DMPaymentDetail.dblPayment) dblTotalOriginVoucherPaymenti21
			,SUM(DMPaymentDetail.dblDiscount) dblTotalOriginVoucherDiscounti21
			,SUM(DMPaymentDetail.dblInterest) dblTotalOriginVoucherInteresti21
		FROM vouchers
		INNER JOIN tblAPPaymentDetail DMPaymentDetail ON vouchers.intBillId = DMPaymentDetail.intBillId
		INNER JOIN tblAPPayment DMPayment ON DMPaymentDetail.intPaymentId = DMPayment.intPaymentId
		WHERE vouchers.ysnOrigin = 1 AND vouchers.ysnPosted = 1 
		AND DMPayment.strPaymentInfo NOT LIKE '%Voided%'
		AND DMPayment.ysnPosted = 1
		AND DMPayment.ysnOrigin = 0
		--AND NOT EXISTS (
		--	SELECT 1 FROM gl WHERE gl.intTransactionId = vouchers.intBillId AND gl.strTransactionId = vouchers.strBillId
		--)
	) OriginVouchersPaymenti21
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) AS dblOriginVoucherPaymentGLTotal
		FROM gl
		WHERE 
			strModuleName = 'Accounts Payable'  AND 
			strTransactionType = 'Payable' AND
			strTransactionForm = 'Payable' AND
			EXISTS (
				--make sure get only the gl of debit memo created in i21
				SELECT 1 FROM tblAPBill Bill 
				WHERE Bill.strBillId = gl.strJournalLineDescription 
				--AND Bill.intBillId = gl.intJournalLineNo 
				AND Bill.ysnOrigin = 1 
				AND Bill.ysnPosted = 1 
				AND Bill.intTransactionType = 1
			)
	) OriginVoucherPaymenti21GL
	CROSS APPLY (
		SELECT 
			SUM(dblAmountPaid) AS dblOriginPayments
		FROM originpayments
	) OriginPayments
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) dblTotalOriginPrepayments
		FROM vendorprepayments
		WHERE ysnOrigin = 1 AND ysnPosted = 1
		AND NOT EXISTS (
			SELECT 1 FROM gl WHERE gl.intTransactionId = intBillId AND gl.strTransactionId = strBillId
		)
	) OriginPrepayment
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) AS dblOriginAPGLTotal
		FROM gl
		WHERE strModuleName != 'Accounts Payable'
	) OriginAPGL
	CROSS APPLY (
		SELECT
			SUM(dblTotal) AS dblTotali21DebitMemo
		FROM debitmemos
		WHERE ysnOrigin = 0
		--OR( ysnOrigin = 1 AND
		--	EXISTS (
		--	SELECT 1 FROM gl WHERE gl.intTransactionId = intBillId AND gl.strTransactionId = strBillId
		--	)
		--)
	) i21DebitMemo
	CROSS APPLY (
		SELECT
			SUM(dblTotal) AS dblTotali21DebitMemoUnposted
		FROM debitmemos
		WHERE ysnPosted = 0 AND ysnOrigin = 0
		--OR( ysnOrigin = 1 AND
		--	EXISTS (
		--	SELECT 1 FROM gl WHERE gl.intTransactionId = intBillId AND gl.strTransactionId = strBillId
		--	)
		--)
	) i21DebitMemoUnposted
	CROSS APPLY (
		SELECT
			SUM(dblTotal) AS dblTotali21DebitMemoPosted
		FROM debitmemos
		WHERE ysnPosted = 1 AND ysnOrigin = 0
		--OR( ysnOrigin = 1 AND
		--	EXISTS (
		--	SELECT 1 FROM gl WHERE gl.intTransactionId = intBillId AND gl.strTransactionId = strBillId
		--	)
		--)
	) i21DebitMemoPosted
		CROSS APPLY (
		SELECT
			SUM(dblAmountDue) AS dblTotali21DebitMemoUnpaid
		FROM debitmemos
		WHERE ysnPosted = 1 AND ysnOrigin = 0 AND ysnPaid = 0
	) i21DebitMemoUnpaid
	CROSS APPLY (
		SELECT 
			SUM(DMPaymentDetail.dblPayment) dblTotalDebitMemoPaymenti21
			,SUM(DMPaymentDetail.dblDiscount) dblTotalDebitMemoDiscounti21
			,SUM(DMPaymentDetail.dblInterest) dblTotalDebitMemoInteresti21
		FROM debitmemos
		INNER JOIN tblAPPaymentDetail DMPaymentDetail ON debitmemos.intBillId = DMPaymentDetail.intBillId
		INNER JOIN tblAPPayment DMPayment ON DMPaymentDetail.intPaymentId = DMPayment.intPaymentId
		WHERE debitmemos.ysnOrigin = 0 AND debitmemos.ysnPosted = 1 
		AND DMPayment.ysnOrigin = 0
		AND DMPayment.ysnPosted = 1
		AND DMPayment.strPaymentInfo NOT LIKE '%Voided%'
	) i21DebitMemoPayment
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) dblTotali21Prepayments
		FROM vendorprepayments
		WHERE ysnOrigin = 0
	) i21Prepayment
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) dblTotali21Vouchers
		FROM vouchers
		WHERE ysnOrigin = 0
		--OR( ysnOrigin = 1 AND
		--	EXISTS (
		--	SELECT 1 FROM gl WHERE gl.intTransactionId = intBillId AND gl.strTransactionId = strBillId
		--	)
		--)
	) i21Vouchers
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) dblTotali21VouchersUnposted
		FROM vouchers
		WHERE ysnOrigin = 0 AND ysnPosted = 0
		--OR( ysnOrigin = 1 AND
		--	EXISTS (
		--	SELECT 1 FROM gl WHERE gl.intTransactionId = intBillId AND gl.strTransactionId = strBillId
		--	)
		--)
	) i21VouchersUnposted
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) dblTotali21VouchersPosted
		FROM vouchers
		WHERE ysnOrigin = 0 AND ysnPosted = 1
		--OR( ysnOrigin = 1 AND
		--	EXISTS (
		--	SELECT 1 FROM gl WHERE gl.intTransactionId = intBillId AND gl.strTransactionId = strBillId
		--	)
		--)
	) i21VouchersPosted
	CROSS APPLY (
		SELECT
			SUM(dblAmountDue) AS dblTotali21VoucherUnpaid
		FROM vouchers
		WHERE ysnPosted = 1 AND ysnOrigin = 0 AND ysnPaid = 0
	) i21VoucherUnpaid
	CROSS APPLY (
		SELECT 
			SUM(DMPaymentDetail.dblPayment) dblTotalVoucherPaymenti21
			,SUM(DMPaymentDetail.dblDiscount) dblTotalVoucherDiscounti21
			,SUM(DMPaymentDetail.dblInterest) dblTotalVoucherInteresti21
		FROM vouchers
		INNER JOIN tblAPPaymentDetail DMPaymentDetail ON vouchers.intBillId = DMPaymentDetail.intBillId
		INNER JOIN tblAPPayment DMPayment ON DMPaymentDetail.intPaymentId = DMPayment.intPaymentId
		WHERE vouchers.ysnOrigin = 0 AND vouchers.ysnPosted = 1 
		AND DMPayment.ysnOrigin = 0
		AND DMPayment.ysnPosted = 1
		AND DMPayment.strPaymentInfo NOT LIKE '%Voided%'
	) i21VoucherPayment
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) AS dbli21APDebitMemoGLTotal
		FROM gl
		WHERE 
			strModuleName = 'Accounts Payable'  AND 
			strTransactionType = 'Debit Memo' AND
			strTransactionForm = 'Bill' AND
			EXISTS (
				--make sure get only the gl of debit memo created in i21
				SELECT 1 FROM tblAPBill Bill 
				WHERE Bill.strBillId = gl.strTransactionId 
				AND Bill.intBillId = gl.intTransactionId 
				AND Bill.ysnOrigin = 0 
				AND Bill.ysnPosted = 1 
				AND Bill.intTransactionType = 3
			)
	) i21APDebitMemoGL
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) AS dbli21APVoucherGLTotal
		FROM gl
		WHERE 
			strModuleName = 'Accounts Payable'  AND 
			strTransactionType = 'Bill' AND
			strTransactionForm = 'Bill' AND
			EXISTS (
				--make sure get only the gl of debit memo created in i21
				SELECT 1 FROM tblAPBill Bill 
				WHERE Bill.strBillId = gl.strTransactionId 
				AND Bill.intBillId = gl.intTransactionId 
				AND Bill.ysnOrigin = 0 
				AND Bill.ysnPosted = 1 
				AND Bill.intTransactionType = 1
			)
	) i21APVoucherGL
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) AS dbli21APPaymentGLTotal
		FROM gl
		WHERE 
			strModuleName = 'Accounts Payable'  AND 
			strTransactionType = 'Payable' AND
			strTransactionForm = 'Payable' AND
			strJournalLineDescription != 'Posted Payment'
	) i21APPaymentGL
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) AS dbli21APPaymentDiscountGLTotal
		FROM glDiscount
		WHERE 
			strModuleName = 'Accounts Payable'  AND 
			strTransactionType = 'Payable' AND
			strTransactionForm = 'Payable'
	) i21APPaymentDiscountGL
	CROSS APPLY (
		SELECT 
			SUM(dblTotal) AS dbli21APGLTotal
		FROM gl
		WHERE strModuleName = 'Accounts Payable'
	) i21APGL
) SourceData
UNPIVOT (
	[Total]
	FOR [Description] IN (
		[Total Origin DebitMemos],
		[Total Origin DebitMemos Unposted],
		[Total Origin DebitMemos Posted],
		[Total Origin DebitMemos Posted in i21],
		[Total Origin DebitMemos GL Posted in i21],
		[Total Origin DebitMemos Unpaid],
		[Total Origin DebitMemos Payment],
		[Total Origin DebitMemos Payment Discount],
		[Total Origin DebitMemos Payment Interest],
		[Total Origin DebitMemos Payment in i21],
		[Total Origin DebitMemos Payment GL in i21],
		[Total Origin DebitMemos Discount in i21],
		[Total Origin DebitMemos Interest in i21],
		[Total Origin DM Payables],
		[Total Origin Prepayments],
		[Total Origin Vouchers],
		[Total Origin Vouchers Unposted],
		[Total Origin Vouchers Posted],
		[Total Origin Vouchers Posted in i21],
		[Total Origin Vouchers GL Posted in i21],
		[Total Origin Vouchers Unpaid],
		[Total Origin Vouchers Payment],
		[Total Origin Vouchers Discount],
		[Total Origin Vouchers Interest],
		[Total Origin Vouchers Payment in i21],
		[Total Origin Vouchers Payment GL in i21],
		[Total Origin Vouchers Discount in i21],
		[Total Origin Vouchers Interest in i21],
		[Total Origin Voucher Payables],
		[Total Origin Voucher Transactions],
		[Total Origin Payments],
		[Total Origin Payables],
		[Total Origin AP GL Payables],
		[Origin Payables Discrepancy],
		[Total i21 Debit Memos],
		[Total i21 Debit Memos Unposted],
		[Total i21 Debit Memos Posted],
		[Total i21 Debit Memos Payment],
		[Total i21 Debit Memos Discount],
		[Total i21 Debit Memos Interest],
		[Total i21 Debit Memos Unpaid],
		[Total i21 Debit Memos GL],
		--[Total i21 Prepayments],
		[Total i21 Vouchers],
		[Total i21 Vouchers Unposted],
		[Total i21 Vouchers Posted],
		[Total i21 Vouchers Unpaid],
		[Total i21 Vouchers Payment],
		[Total i21 Vouchers Discount],
		[Total i21 Vouchers Interest],
		[Total i21 Vouchers GL],
		[Total i21 Voucher Transactions],
		--[Total i21 Payments],
		--[Total i21 GL Payments],
		--[Total i21 GL Payments Discount],
		[Total i21 Payables]
		--[Total AP GL Payables],
		--[Total i21 Payables Discrepancy],
		--[Computed AP Payables(origin + i21)],
		--[Computed AP GL Payables(origin + i21)]
	)
) unpivotdata
GO

--SELECT * FROM vyuAPStatus