CREATE PROCEDURE [dbo].[uspAPUpdateVoucherPayable]
	@voucherId INT
AS

--Update PO MISC
UPDATE A
	SET A.dblInvoicedQty = (CASE WHEN voucherDetails.ysnPosted = 1 
									THEN A.dblInvoicedQty + voucherDetails.dblQtyReceived
								ELSE A.dblInvoicedQty - voucherDetails.dblQtyReceived END),
		ysnComplete = CASE WHEN A.dblReceivedQty = 
								(CASE WHEN voucherDetails.ysnPosted = 1 
									THEN A.dblInvoicedQty + voucherDetails.dblQtyReceived
								ELSE A.dblInvoicedQty - voucherDetails.dblQtyReceived END)
							THEN 1 ELSE 0 END
FROM tblAPVoucherPayable A
CROSS APPLY (
	SELECT 
		B2.*,
		B.ysnPosted
	FROM tblAPBill B
	INNER JOIN tblAPBillDetail B2 ON B2.intBillId = B.intBillId
	WHERE B.intBillId = @voucherId AND A.intPurchaseDetailId = B2.intPurchaseDetailId
) voucherDetails
WHERE A.intTransactionCode = 1