CREATE FUNCTION [dbo].[fnTRGetLoadTransferWeightedAveCost] (
	@intLoadReceiptId INT
)
RETURNS NUMERIC(38,20)
AS
BEGIN 	
	DECLARE @returnBalance AS NUMERIC(38,20)

	SELECT	@returnBalance = 
				dbo.fnICGetTransWeightedAveCost (
					t.strTransferNo
					,td.intInventoryTransferId
					,td.intInventoryTransferDetailId
				)
	FROM	tblICInventoryTransfer t INNER JOIN tblICInventoryTransferDetail td
				ON t.intInventoryTransferId = td.intInventoryTransferId
				AND t.ysnPosted = 1
			INNER JOIN tblTRLoadReceipt tr
				ON tr.intInventoryTransferId = t.intInventoryTransferId
				AND tr.intLoadReceiptId = td.intSourceId				
	WHERE	tr.intLoadReceiptId = @intLoadReceiptId
	
	RETURN ISNULL(@returnBalance, 0)
END 