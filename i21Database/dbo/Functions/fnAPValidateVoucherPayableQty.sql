CREATE FUNCTION [dbo].[fnAPValidateVoucherPayableQty]
(
	@voucherPayables AS VoucherPayable READONLY
)
RETURNS @returnTable TABLE
(
	intErrorKey INT,
	intVoucherPayableId INT,
	strError NVARCHAR(1000)
)
AS
BEGIN

	INSERT INTO @returnTable
	--CHECK IF PAYABLE WAS FULLY VOUCHERED
	SELECT
		1
		,C.intVoucherPayableId
		,'Payable ' + ISNULL(B.strItemNo,B.strMiscDescription) + ' do not have an available quantity to voucher.'
	FROM @voucherPayables C
	LEFT JOIN tblAPVoucherPayable A
			ON ISNULL(C.intPurchaseDetailId,-1) = ISNULL(A.intPurchaseDetailId,-1)
			AND ISNULL(C.intContractDetailId,-1) = ISNULL(A.intContractDetailId,-1)
			AND ISNULL(C.intScaleTicketId,-1) = ISNULL(A.intScaleTicketId,-1)
			AND ISNULL(C.intInventoryReceiptChargeId,-1) = ISNULL(A.intInventoryReceiptChargeId,-1)
			AND ISNULL(C.intInventoryReceiptItemId,-1) = ISNULL(A.intInventoryReceiptItemId,-1)
			AND ISNULL(C.intInventoryShipmentChargeId,-1) = ISNULL(A.intInventoryShipmentChargeId,-1)
			AND ISNULL(C.intLoadShipmentDetailId,-1) = ISNULL(A.intLoadShipmentDetailId,-1)
			AND ISNULL(C.intLoadHeaderId,-1) = ISNULL(A.intLoadHeaderId,-1)
			AND ISNULL(C.intEntityVendorId,-1) = ISNULL(A.intEntityVendorId,-1)
	LEFT JOIN tblAPVoucherPayableCompleted B
			ON ISNULL(C.intPurchaseDetailId,-1) = ISNULL(B.intPurchaseDetailId,-1)
			AND ISNULL(C.intContractDetailId,-1) = ISNULL(B.intContractDetailId,-1)
			AND ISNULL(C.intScaleTicketId,-1) = ISNULL(B.intScaleTicketId,-1)
			AND ISNULL(C.intInventoryReceiptChargeId,-1) = ISNULL(B.intInventoryReceiptChargeId,-1)
			AND ISNULL(C.intInventoryReceiptItemId,-1) = ISNULL(B.intInventoryReceiptItemId,-1)
			AND ISNULL(C.intInventoryShipmentChargeId,-1) = ISNULL(B.intInventoryShipmentChargeId,-1)
			AND ISNULL(C.intLoadShipmentDetailId,-1) = ISNULL(B.intLoadShipmentDetailId,-1)
			AND ISNULL(C.intLoadHeaderId,-1) = ISNULL(B.intLoadHeaderId,-1)
			AND ISNULL(C.intEntityVendorId,-1) = ISNULL(B.intEntityVendorId,-1)
			AND A.dblQuantityToBill = 0
	WHERE A.intVoucherPayableId IS NULL AND B.intVoucherPayableId IS NOT NULL
	UNION ALL
	--CHECK IF PAYABLE QTY IS LESS THAN THE QTY OF VOUCHER
	SELECT
		2
		,C.intVoucherPayableId
		,'Payable ' + ISNULL(A.strItemNo,A.strMiscDescription) + ' do not have enough available quantity to voucher.'
	FROM @voucherPayables C
	INNER JOIN tblAPVoucherPayable A
			ON ISNULL(C.intPurchaseDetailId,-1) = ISNULL(A.intPurchaseDetailId,-1)
			AND ISNULL(C.intContractDetailId,-1) = ISNULL(A.intContractDetailId,-1)
			AND ISNULL(C.intScaleTicketId,-1) = ISNULL(A.intScaleTicketId,-1)
			AND ISNULL(C.intInventoryReceiptChargeId,-1) = ISNULL(A.intInventoryReceiptChargeId,-1)
			AND ISNULL(C.intInventoryReceiptItemId,-1) = ISNULL(A.intInventoryReceiptItemId,-1)
			AND ISNULL(C.intInventoryShipmentChargeId,-1) = ISNULL(A.intInventoryShipmentChargeId,-1)
			AND ISNULL(C.intLoadShipmentDetailId,-1) = ISNULL(A.intLoadShipmentDetailId,-1)
			AND ISNULL(C.intLoadHeaderId,-1) = ISNULL(A.intLoadHeaderId,-1)
			AND ISNULL(C.intEntityVendorId,-1) = ISNULL(A.intEntityVendorId,-1)
			AND A.dblQuantityToBill < C.dblQuantityToBill

	RETURN;

END