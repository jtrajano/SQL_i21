CREATE VIEW vyuTRGetImportDTNForReprocess

AS

SELECT DISTINCT h.intImportDtnId
	, d.intImportDtnDetailId
	, h.strFileName
	, h.dtmImportDate
	, d.strSeller
	, d.strBillOfLading
	, lh.strTransaction
	, ir.strReceiptNumber
	, dblDocumentTotal = d.dblInvoiceAmount
	, dblReceiptTotal = ir.dblGrandTotal
	, dblVariance = ISNULL(d.dblInvoiceAmount, 0) - ISNULL(ir.dblGrandTotal, 0)
	, v.strBillId
	, d.strMessage
	, ysnSuccess = ISNULL(d.ysnValid, CAST(0 AS BIT))
	, ysnVarianceIssue = CASE WHEN d.strMessage LIKE '%Variance is greater than allowed%' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
FROM tblTRImportDtn h
JOIN tblTRImportDtnDetail d ON d.intImportDtnId = h.intImportDtnId
LEFT JOIN tblICInventoryReceipt ir ON ir.intInventoryReceiptId = d.intInventoryReceiptId
LEFT JOIN tblAPBill v ON v.intBillId = d.intBillId
LEFT JOIN tblTRLoadReceipt lr ON lr.intInventoryReceiptId = ir.intInventoryReceiptId
LEFT JOIN tblTRLoadHeader lh ON lh.intLoadHeaderId = lr.intLoadHeaderId
WHERE ISNULL(ysnReImport, 0) = 0