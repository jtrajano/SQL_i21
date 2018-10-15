CREATE FUNCTION [dbo].[fnAPValidateVoucherPayableQty]
(
	@voucherPayables AS VoucherPayable READONLY
)
RETURNS @returnTable TABLE
(
	intVoucherPayableId INT,
	strError NVARCHAR(1000)
)
AS
BEGIN

	INSERT INTO @returnTable
	--CHECK IF PAYABLE WAS FULLY VOUCHERED
	SELECT TOP 1
		'Payable id(' + CAST(A.intVoucherPayableId AS NVARCHAR) + ') do not have an available quantity to voucher.'
		,A.intVoucherPayableId
	FROM @voucherPayables C
	WHERE 
	NOT EXISTS (
		SELECT TOP 1 1
		FROM tblAPVoucherPayable A
			WHERE ISNULL(C.intPurchaseDetailId,1) = ISNULL(A.intPurchaseDetailId,1)
			AND ISNULL(C.intContractDetailId,1) = ISNULL(A.intContractDetailId,1)
			AND ISNULL(C.intScaleTicketId,1) = ISNULL(A.intScaleTicketId,1)
			AND ISNULL(C.intInventoryReceiptChargeId,1) = ISNULL(A.intInventoryReceiptChargeId,1)
			AND ISNULL(C.intInventoryReceiptItemId,1) = ISNULL(A.intInventoryReceiptItemId,1)
			AND ISNULL(C.intInventoryShipmentChargeId,1) = ISNULL(A.intInventoryShipmentChargeId,1)
			AND ISNULL(C.intLoadShipmentDetailId,1) = ISNULL(A.intLoadShipmentDetailId,1)
			AND ISNULL(C.intEntityVendorId,1) = ISNULL(A.intEntityVendorId,1)
	)
	AND
	EXISTS (
		SELECT TOP 1 1
		FROM tblAPVoucherPayableCompleted A
			WHERE ISNULL(C.intPurchaseDetailId,1) = ISNULL(A.intPurchaseDetailId,1)
			AND ISNULL(C.intContractDetailId,1) = ISNULL(A.intContractDetailId,1)
			AND ISNULL(C.intScaleTicketId,1) = ISNULL(A.intScaleTicketId,1)
			AND ISNULL(C.intInventoryReceiptChargeId,1) = ISNULL(A.intInventoryReceiptChargeId,1)
			AND ISNULL(C.intInventoryReceiptItemId,1) = ISNULL(A.intInventoryReceiptItemId,1)
			AND ISNULL(C.intInventoryShipmentChargeId,1) = ISNULL(A.intInventoryShipmentChargeId,1)
			AND ISNULL(C.intLoadShipmentDetailId,1) = ISNULL(A.intLoadShipmentDetailId,1)
			AND ISNULL(C.intEntityVendorId,1) = ISNULL(A.intEntityVendorId,1)
			AND A.dblQuantityToBill = 0
	)

	RETURN;

END