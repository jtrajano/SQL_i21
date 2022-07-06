CREATE VIEW [dbo].[vyuAPDiscrepancy]
AS 

SELECT ISNULL(AP.intBillId, GL.intTransactionId) intTransactionId,
	   ISNULL(AP.strBillId, GL.strTransactionId) strTransactionId,
	   ISNULL(GL.dtmTransactionDate, AP.dtmBillDate) dtmTransactionDate,
	   ISNULL(E.strName, 'Unknown') strVendorName,
	   ISNULL(AP.dtmDate, GL.dtmDate) dtmDate,
	   ISNULL(GL.dblAmountDue, 0) dblGLAmount,
	   ISNULL(AP.dblAmountDue, 0) dblAPAmount,
	   (ISNULL(GL.dblAmountDue, 0) - ISNULL(AP.dblAmountDue, 0)) dblDifference,
	   ISNULL(E2.strName, 'Unknown') strUserName
FROM (
	SELECT P.intBillId, B.strBillId, B.dtmBillDate, B.intEntityVendorId, B.dtmDate, P.dblAmountDue, B.intEntityId, B.ysnOrigin
	FROM (
		SELECT intBillId, CAST((SUM(dblTotal) + SUM(dblInterest) - SUM(dblAmountPaid) - SUM(dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
		FROM vyuAPPayables
		GROUP BY intBillId, strBillId
		UNION ALL
		SELECT intBillId, CAST((SUM(dblTotal) + SUM(dblInterest) - SUM(dblAmountPaid) - SUM(dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
		FROM vyuAPPrepaidPayables
		GROUP BY intBillId
	) P
	INNER JOIN tblAPBill B ON B.intBillId = P.intBillId
	UNION ALL
	SELECT P.intInvoiceId, I.strInvoiceNumber, I.dtmDate, I.intEntityCustomerId, I.dtmPostDate, P.dblAmountDue, I.intEntityId, 0 ysnOrigin
	FROM (
		SELECT intInvoiceId, CAST((SUM(dblTotal) + SUM(dblInterest) - SUM(dblAmountPaid) - SUM(dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
		FROM vyuAPSalesForPayables
		GROUP BY intInvoiceId
	) P
	INNER JOIN tblARInvoice I ON I.intInvoiceId = P.intInvoiceId
) AP
FULL OUTER JOIN (
	SELECT ISNULL(B.intBillId, I.intInvoiceId) intTransactionId, A2.strTransactionId, B.ysnOrigin, ISNULL(B.dtmBillDate, I.dtmDate) dtmTransactionDate, ISNULL(B.dtmDate, I.dtmPostDate) dtmDate, ISNULL(B.intEntityVendorId, I.intEntityCustomerId) intEntityId, ISNULL(U.intUserId, ISNULL(B.intUserId, I.intEntityId)) intUserId, A2.dblAmountDue
	FROM (
		SELECT A.strTransactionId, SUM(A.dblTotal - A.dblPayment) dblAmountDue
		FROM (
			--VOUCHER
			SELECT D.strTransactionId, SUM(ROUND(D.dblCredit, 2) - ROUND(D.dblDebit, 2)) dblTotal, 0 dblPayment
			FROM tblGLDetail D
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = D.intAccountId
			WHERE D.ysnIsUnposted = 0 AND AD.intAccountCategoryId = 1 AND D.strTransactionForm = 'Bill' AND D.intJournalLineNo = 1
			GROUP BY D.strTransactionId
			--INVOICE
			UNION ALL
			SELECT D.strTransactionId, SUM(ROUND(D.dblCredit, 2) - ROUND(D.dblDebit, 2)) dblTotal, 0 dblPayment
			FROM tblGLDetail D
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = D.intAccountId
			WHERE D.ysnIsUnposted = 0 AND AD.intAccountCategoryId IN (1, 53) AND D.strTransactionForm = 'Invoice' AND D.strTransactionType = 'Cash Refund'
			GROUP BY D.strTransactionId
			--POSITIVE PREPAYMENT
			UNION ALL
			SELECT D.strTransactionId, SUM(ROUND(D.dblCredit, 2) - ROUND(D.dblDebit, 2)) dblTotal, 0 dblPayment
			FROM tblGLDetail D
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = D.intAccountId
			WHERE D.ysnIsUnposted = 0 AND AD.intAccountCategoryId IN (53) AND D.strTransactionForm = 'Bill' AND D.intJournalLineNo = 1
			GROUP BY D.strTransactionId
			--NEGATIVE PREPAYMENT
			UNION ALL
			SELECT D.strTransactionId, SUM(ROUND(D.dblDebit, 2) - ROUND(D.dblCredit, 2)) dblTotal, 0 dblPayment
			FROM tblGLDetail D
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = D.intAccountId
			WHERE D.ysnIsUnposted = 0 AND AD.intAccountCategoryId IN (53) AND D.strTransactionForm = 'Bill' AND D.intJournalLineNo = 1
			GROUP BY D.strTransactionId
			--APPLIED PAYMENT IN tblAppliedPrepaidAndDebit
			UNION ALL
			SELECT D.strTransactionId, 0 dblTotal, SUM(ROUND(D.dblDebit, 2) - ROUND(D.dblCredit, 2)) dblPayment
			FROM tblGLDetail D
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = D.intAccountId
			INNER JOIN tblAPBill B ON B.intBillId = D.intTransactionId AND B.strBillId = D.strTransactionId
			INNER JOIN tblAPAppliedPrepaidAndDebit APD ON APD.intBillId = B.intBillId AND APD.intTransactionId = D.intJournalLineNo
			INNER JOIN tblAPBill B2 ON B2.intBillId = APD.intTransactionId
			WHERE D.ysnIsUnposted = 0 AND AD.intAccountCategoryId IN (1, 53) AND D.dblDebit != 0 AND D.strJournalLineDescription = 'Applied Debit Memo'
			GROUP BY D.strTransactionId
			--APPLIED PAYMENT FOR DM/VPRE
			UNION ALL
			SELECT D.strTransactionId, 0 dblTotal, SUM(ROUND(D.dblCredit, 2) - ROUND(D.dblDebit, 2)) dblPayment
			FROM tblGLDetail D
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = D.intAccountId
			INNER JOIN tblAPBill B ON B.intBillId = D.intTransactionId AND B.strBillId = D.strTransactionId
			INNER JOIN tblAPAppliedPrepaidAndDebit APD ON APD.intBillId = B.intBillId AND APD.intTransactionId = D.intJournalLineNo
			INNER JOIN tblAPBill B2 ON B2.intBillId = APD.intTransactionId
			WHERE D.ysnIsUnposted = 0 AND AD.intAccountCategoryId IN (1, 53) AND D.dblCredit != 0 AND D.strJournalLineDescription = 'Applied Debit Memo'
			GROUP BY D.strTransactionId
			--POSTED INTEREST
			UNION ALL
			SELECT D.strJournalLineDescription strTransactionId, 0 dblTotal, SUM(CASE WHEN CHARINDEX(D.strTransactionId, 'V') > 0 THEN B.dblInterest * -1 ELSE B.dblInterest END) dblPayment
			FROM tblGLDetail D
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = D.intAccountId
			INNER JOIN tblAPBill B ON B.strBillId = D.strJournalLineDescription
			WHERE D.ysnIsUnposted = 0 AND AD.intAccountCategoryId IN (1, 53) AND D.strTransactionForm = 'Payable' AND D.strJournalLineDescription != 'Posted Payment'
			AND EXISTS (
				SELECT TOP 1 1 FROM tblGLDetail WHERE strTransactionId = D.strTransactionId AND strJournalLineDescription = 'Interest'
			)
			GROUP BY D.strJournalLineDescription
			--AP PAYMENT
			UNION ALL
			SELECT D.strJournalLineDescription strTransactionId, 0 dblTotal, SUM(ROUND(D.dblDebit, 2) - ROUND(D.dblCredit, 2)) dblPayment
			FROM tblGLDetail D
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = D.intAccountId
			WHERE D.ysnIsUnposted = 0 AND AD.intAccountCategoryId IN (1, 53) AND D.strTransactionForm = 'Payable' AND D.strJournalLineDescription != 'Posted Payment'
			GROUP BY D.strJournalLineDescription
			--AR PAYMENT
			UNION ALL
			SELECT B.strBillId strTransactionId, 0 dblTotal, SUM(ROUND(D.dblDebit, 2) - ROUND(D.dblCredit, 2)) dblPayment
			FROM tblGLDetail D
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = D.intAccountId
			INNER JOIN tblARPayment P ON P.intPaymentId = D.intTransactionId AND P.strRecordNumber = D.strTransactionId
			INNER JOIN tblARPaymentDetail PD ON PD.intPaymentId = P.intPaymentId AND PD.intPaymentDetailId = D.intJournalLineNo
			INNER JOIN tblAPBill B ON B.intBillId = PD.intBillId
			WHERE D.ysnIsUnposted = 0 AND AD.intAccountCategoryId IN (1, 53) AND D.strTransactionForm = 'Receive Payments'
			GROUP BY B.strBillId
		) A
		GROUP BY A.strTransactionId
	) A2
	OUTER APPLY (
		SELECT TOP 1 intSourceEntityId, intUserId FROM tblGLDetail WHERE strTransactionId = A2.strTransactionId
	) U
	LEFT JOIN tblAPBill B ON B.strBillId = A2.strTransactionId
	LEFT JOIN tblARInvoice I ON I.strReceiptNumber = A2.strTransactionId
	WHERE A2.dblAmountDue != 0
) GL ON GL.intTransactionId = AP.intBillId AND GL.strTransactionId = AP.strBillId
LEFT JOIN tblEMEntity E ON E.intEntityId = ISNULL(GL.intEntityId, AP.intEntityVendorId)
LEFT JOIN tblEMEntity E2 ON E2.intEntityId = ISNULL(GL.intUserId, AP.intEntityId)
WHERE ISNULL(AP.dblAmountDue, 0) <> ISNULL(GL.dblAmountDue, 0) AND ISNULL(AP.ysnOrigin, 0) = 0 AND ISNULL(GL.ysnOrigin, 0) = 0