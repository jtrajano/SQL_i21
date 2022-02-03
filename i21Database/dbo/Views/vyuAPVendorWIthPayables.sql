CREATE VIEW [dbo].[vyuAPVendorWIthPayables]
AS

SELECT DISTINCT intEntityVendorId
FROM (
	SELECT G.intEntityVendorId
	FROM dbo.tblAPBill G 
	WHERE G.ysnPosted = 1 AND G.ysnPaid = 0
	UNION 
	SELECT AA.intEntityCustomerId
	FROM tblARInvoice AA
	LEFT JOIN (tblAPBillDetail A2 INNER JOIN tblAPBill A3 ON A2.intBillId = A3.intBillId AND A3.ysnPosted = 1) ON AA.intInvoiceId = A2.intInvoiceId
	WHERE 
		-- NOT EXISTS( SELECT TOP 1 1 
		-- 			FROM tblAPBillDetail apbilldetail
		-- 			INNER JOIN tblAPBill apbill 
		-- 				ON apbilldetail.intBillId = apbill.intBillId 
		-- 			WHERE apbill.ysnPosted = 1
		-- 				AND intInvoiceId = AA.intInvoiceId
		-- 			)
		-- AND 
			AA.ysnPosted = 1
		AND A2.intBillId IS NULL
		AND AA.dblAmountDue != 0
		AND AA.strTransactionType IN ('Cash Refund','Invoice','Debit Memo', 'Cash')
		AND AA.strType != 'CT Tran'
) tmpVendos