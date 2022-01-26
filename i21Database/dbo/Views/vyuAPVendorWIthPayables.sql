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
	WHERE 
		NOT EXISTS( SELECT TOP 1 1 
					FROM tblAPBillDetail apbilldetail
					INNER JOIN tblAPBill apbill 
						ON apbilldetail.intBillId = apbill.intBillId 
					WHERE apbill.ysnPosted = 1
						AND intInvoiceId = AA.intInvoiceId
					)
		AND AA.ysnPosted = 1
		AND AA.dblAmountDue != 0
		AND AA.strTransactionType IN ('Cash Refund','Invoice','Debit Memo', 'Cash')
		AND AA.strType != 'CT Tran'
) tmpVendos