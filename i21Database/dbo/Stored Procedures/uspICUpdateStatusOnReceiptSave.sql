CREATE PROCEDURE [dbo].[uspICUpdateStatusOnReceiptSave]
	@intReceiptNo INT,
	@ysnOpenStatus BIT = 0
AS

DECLARE @POId INT
		,@ScaleId INT 

BEGIN
	DECLARE @ReceiptTypePurchaseContract AS NVARCHAR(50) = 'Purchase Contract'
			,@ReceiptTypePurchaseOrder AS NVARCHAR(50) = 'Purchase Order'
			,@ReceiptTypeTransferOrder AS NVARCHAR(50) = 'Transfer Order'
			,@ReceiptTypeDirect AS NVARCHAR(50) = 'Direct'

	DECLARE @SourceTypeNone AS INT = 0
			,@SourceTypeScale AS INT = 1
			,@SourceTypeInboundShipment AS INT = 2
			,@SourceTypeTransport AS INT = 3

	-- Update the status of the Purchase Order
	IF EXISTS(SELECT TOP 1 1 FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @intReceiptNo AND strReceiptType = @ReceiptTypePurchaseOrder)
	BEGIN
		SELECT	DISTINCT intOrderId 
		INTO	#tmpPOList 
		FROM	tblICInventoryReceiptItem
		WHERE	intInventoryReceiptId = @intReceiptNo
				AND intOrderId IS NOT NULL 

		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpPOList)
		BEGIN
			SELECT TOP 1 @POId = intOrderId FROM #tmpPOList

			IF (@ysnOpenStatus = 1)
				EXEC uspPOUpdateStatus @POId, 1
			ELSE
				EXEC uspPOUpdateStatus @POId, NULL

			DELETE FROM #tmpPOList WHERE intOrderId = @POId
		END
		
		DROP TABLE #tmpPOList
	END

	-- Update the Status of the Scale Ticket
	IF EXISTS(SELECT TOP 1 1 FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @intReceiptNo AND intSourceType = @SourceTypeScale)
	BEGIN
		SELECT	DISTINCT intSourceId 
		INTO	#tmpScaleTickets 
		FROM	tblICInventoryReceiptItem
		WHERE	intInventoryReceiptId = @intReceiptNo
				AND intSourceId IS NOT NULL 

		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpScaleTickets)
		BEGIN
			SELECT TOP 1 @ScaleId = intSourceId FROM #tmpScaleTickets

			IF (@ysnOpenStatus = 1)
				EXEC uspSCUpdateStatus @ScaleId, 1
			ELSE
				EXEC uspSCUpdateStatus @ScaleId, NULL

			DELETE FROM #tmpScaleTickets WHERE intSourceId = @ScaleId
		END
		
		DROP TABLE #tmpScaleTickets
	END

	RETURN
END