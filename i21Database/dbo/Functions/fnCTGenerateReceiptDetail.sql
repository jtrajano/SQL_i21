CREATE FUNCTION [dbo].[fnCTGenerateReceiptDetail]
(
	@intInventoryReceiptItemId INT,
	@intBillId INT,
	@intBillDetailId INT,
	@dblQtyToBill NUMERIC(18,6),
	@total NUMERIC(18,6)
)
RETURNS @table TABLE
(
	[intInventoryReceiptItemId]		INT,
	[intInventoryReceiptChargeId]	INT,
	[intInventoryShipmentChargeId]	INT,
	[intSourceTransactionNoId]		INT,
	[strSourceTransactionNo]		NVARCHAR(50),
	[intItemId]						INT,
	[intToBillUOMId]				INT,
	[dblToBillQty]					NUMERIC(18,6),
	[dblAmountToBill]				NUMERIC(18,6)
)
AS
BEGIN
	
	INSERT INTO @table
	(
		[intInventoryReceiptItemId],
		[intInventoryReceiptChargeId],
		[intInventoryShipmentChargeId],
		[intSourceTransactionNoId],
		[strSourceTransactionNo],
		[intItemId],
		[intToBillUOMId],
		[dblToBillQty],
		[dblAmountToBill]
	)
	SELECT
		[intInventoryReceiptItemId]		=	@intInventoryReceiptItemId,
		[intInventoryReceiptChargeId]	=	NULL,
		[intInventoryShipmentChargeId]	=	NULL,
		[intSourceTransactionNoId]		=	@intBillId,
		[strSourceTransactionNo]		=	strBillId,
		[intItemId]						=	B.intItemId,
		[intToBillUOMId]				=	B.intUnitOfMeasureId,
		[dblToBillQty]					=	@dblQtyToBill - @total,
		[dblAmountToBill]				=	B.dblTotal * -1
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	WHERE A.intBillId = @intBillId 
	AND B.intBillDetailId = @intBillDetailId

	RETURN
END
