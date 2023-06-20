CREATE VIEW vyuTRGetImportDTNForReprocess

AS

SELECT intImportDtnId
	, intImportDtnDetailId
	, strFileName
	, dtmImportDate
	, strSeller
	, strBillOfLading
	, strTransaction
	, strReceiptNumber
	, dblDocumentTotal
	, dblReceiptTotal
	, dblVariance
	, strBillId
	, strMessage
	, ysnSuccess
	, ysnVarianceIssue
	, ysnException
FROM (
	SELECT DISTINCT h.intImportDtnId
		, d.intImportDtnDetailId
		, h.strFileName
		, h.dtmImportDate
		, strSeller = ISNULL(em.strName, d.strSeller)
		, d.strBillOfLading
		, lh.strTransaction
		, ir.strReceiptNumber
		, dblDocumentTotal = d.dblInvoiceAmount
		, dblReceiptTotal = dbo.fnICGetInventoryReceiptTotal(ir.intInventoryReceiptId)
		, dblVariance = ISNULL(d.dblInvoiceAmount, 0) - ISNULL(ir.dblGrandTotal, 0)
		, v.strBillId
		, d.strMessage
		, ysnSuccess = CASE WHEN ISNULL(d.ysnValid, CAST(0 AS BIT)) = 1 AND ISNULL(d.intBillId, 0) <> 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
		, ysnVarianceIssue = CASE WHEN d.strMessage LIKE '%Variance is greater than allowed%' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
		, ysnException = ISNULL(d.ysnException, CAST(0 AS BIT))
		, ysnVouchered = CASE WHEN ISNULL(HasVoucher.intInventoryReceiptId, 0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
	FROM tblTRImportDtn h
	JOIN tblTRImportDtnDetail d ON d.intImportDtnId = h.intImportDtnId
	LEFT JOIN tblICInventoryReceipt ir ON ir.intInventoryReceiptId = d.intInventoryReceiptId
	LEFT JOIN tblEMEntity em ON em.intEntityId = ir.intEntityVendorId
	LEFT JOIN tblAPBill v ON v.intBillId = d.intBillId
	LEFT JOIN tblTRLoadReceipt lr ON lr.intInventoryReceiptId = ir.intInventoryReceiptId
	LEFT JOIN tblTRLoadHeader lh ON lh.intLoadHeaderId = lr.intLoadHeaderId
	LEFT JOIN
		(
		SELECT DISTINCT IR.intInventoryReceiptId
		FROM tblICInventoryReceipt IR
		JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
		JOIN tblAPBillDetail BD ON BD.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
		JOIN tblAPBill B ON BD.intBillId = B.intBillId AND IR.intEntityVendorId = B.intEntityVendorId 
		) HasVoucher ON HasVoucher.intInventoryReceiptId = d.intInventoryReceiptId
	WHERE ISNULL(ysnReImport, 0) = 0
) tbl
WHERE ysnVarianceIssue = 0 OR (ysnVarianceIssue = 1 AND ysnVouchered = 0)