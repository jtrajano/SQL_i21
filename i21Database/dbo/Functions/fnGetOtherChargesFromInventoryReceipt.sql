﻿-- This function returns the cost per lot item. 
CREATE FUNCTION [dbo].[fnGetOtherChargesFromInventoryReceipt] ( 
	@intInventoryReceiptItemId AS INT
)
RETURNS NUMERIC(18,6)
AS
BEGIN 
	DECLARE @totalOtherCharges AS NUMERIC(18,6)
			,@units AS NUMERIC(18,6)

	SELECT	@totalOtherCharges= SUM(ItemOtherCharges.dblAmount)
	FROM	dbo.tblICInventoryReceiptItem ReceiptItems INNER JOIN dbo.tblICInventoryReceiptItemAllocatedCharge ItemOtherCharges 
				ON ReceiptItems.intInventoryReceiptItemId = ItemOtherCharges.intInventoryReceiptItemId
	WHERE	ReceiptItems.intInventoryReceiptItemId = @intInventoryReceiptItemId
			AND ItemOtherCharges.ysnInventoryCost = 1

	SELECT	@units = ReceiptItems.dblOpenReceive
	FROM	dbo.tblICInventoryReceiptItem ReceiptItems 
	WHERE	ReceiptItems.intInventoryReceiptItemId = @intInventoryReceiptItemId

	IF @units <> 0 
		RETURN ISNULL(@totalOtherCharges / @units, 0);

	RETURN 0
	;
END