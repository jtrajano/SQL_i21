CREATE VIEW vyuTRGetImportDTNForReprocess

AS

SELECT DISTINCT h.intImportDtnId
	, d.intImportDtnDetailId
	, h.strFileName
	, h.dtmImportDate
	, strSeller = ISNULL(em.strName, d.strSeller)
	, d.strBillOfLading
	, lh.strTransaction
	, ir.strReceiptNumber
	, dblDocumentTotal = d.dblInvoiceAmount
	, dblReceiptTotal = ir.dblGrandTotal
	, dblVariance = ISNULL(d.dblInvoiceAmount, 0) - ISNULL(ir.dblGrandTotal, 0)
	, v.strBillId
	, d.strMessage
	, ysnSuccess = CASE WHEN ISNULL(d.ysnValid, CAST(0 AS BIT)) = 1 AND ISNULL(d.intBillId, 0) <> 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	, ysnVarianceIssue = CASE WHEN d.strMessage LIKE '%Variance is greater than allowed%' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	, ysnException = ISNULL(d.ysnException, CAST(0 AS BIT))
FROM tblTRImportDtn h
JOIN tblTRImportDtnDetail d ON d.intImportDtnId = h.intImportDtnId
LEFT JOIN tblICInventoryReceipt ir ON ir.intInventoryReceiptId = d.intInventoryReceiptId
LEFT JOIN tblEMEntity em ON em.intEntityId = ir.intEntityVendorId
LEFT JOIN tblAPBill v ON v.intBillId = d.intBillId
LEFT JOIN tblTRLoadReceipt lr ON lr.intInventoryReceiptId = ir.intInventoryReceiptId
LEFT JOIN tblTRLoadHeader lh ON lh.intLoadHeaderId = lr.intLoadHeaderId
WHERE ISNULL(ysnReImport, 0) = 0