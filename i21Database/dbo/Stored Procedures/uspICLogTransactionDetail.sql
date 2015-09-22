CREATE PROCEDURE [dbo].[uspICLogTransactionDetail]
	@TransactionType int,
	@TransactionId int
AS
BEGIN
	DECLARE @TransactionType_Receipt AS INT = 1
	DECLARE @TransactionType_Shipment AS INT = 2
	DECLARE @TransactionType_Transfer AS INT = 3

	IF (@TransactionType = @TransactionType_Receipt)
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @TransactionId)
		BEGIN
			INSERT INTO tblICTransactionDetailLog(
				strTransactionType,
				intTransactionId, 
				intTransactionDetailId,
				intOrderNumberId,
				intSourceNumberId,
				intLineNo,
				intItemId,
				intItemUOMId,
				dblQuantity)
			SELECT 'Inventory Receipt',
				intInventoryReceiptId, 
				intInventoryReceiptItemId,
				intOrderId,
				intSourceId,
				intLineNo,
				intItemId,
				intUnitMeasureId,
				dblOpenReceive
			FROM tblICInventoryReceiptItem
			WHERE intInventoryReceiptId = @TransactionId
		END
		ELSE
		BEGIN
			RAISERROR ('Specified Receipt transaction does not exist.',16,1)
			RETURN
		END
	END
	ELSE IF (@TransactionType = @TransactionType_Shipment)
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @TransactionId)
		BEGIN
			INSERT INTO tblICTransactionDetailLog(
				strTransactionType,
				intTransactionId, 
				intTransactionDetailId,
				intOrderNumberId,
				intSourceNumberId,
				intLineNo,
				intItemId,
				intItemUOMId,
				dblQuantity)
			SELECT 'Inventory Shipment',
				intInventoryShipmentId, 
				intInventoryShipmentItemId,
				intOrderId,
				intSourceId,
				intLineNo,
				intItemId,
				intItemUOMId,
				dblQuantity
			FROM tblICInventoryShipmentItem
			WHERE intInventoryShipmentId = @TransactionId
		END
		ELSE
		BEGIN
			RAISERROR ('Specified Shipment transaction does not exist.',16,1)
			RETURN
		END
	END

END