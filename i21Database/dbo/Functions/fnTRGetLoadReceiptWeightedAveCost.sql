CREATE FUNCTION [dbo].[fnTRGetLoadReceiptWeightedAveCost] (
	@intLoadReceiptId INT
)
RETURNS NUMERIC(38,20)
AS
BEGIN 	
	DECLARE @returnBalance AS NUMERIC(38,20)

	SELECT	@returnBalance = 
				dbo.fnICGetTransWeightedAveCost (
					r.strReceiptNumber
					,ri.intInventoryReceiptId
					,ri.intInventoryReceiptItemId				
				)
	FROM	tblICInventoryReceiptItem ri INNER JOIN tblICInventoryReceipt r
				ON ri.intInventoryReceiptId = r.intInventoryReceiptId
				AND r.ysnPosted = 1
			INNER JOIN tblTRLoadReceipt tr
				ON tr.intInventoryReceiptId = r.intInventoryReceiptId
				AND tr.intLoadReceiptId = ri.intSourceId				
	WHERE	tr.intLoadReceiptId = @intLoadReceiptId
	
	RETURN ISNULL(@returnBalance, 0)
END 