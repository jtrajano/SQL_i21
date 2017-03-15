CREATE PROCEDURE [dbo].[uspICLogTransactionDetail]
	@TransactionType int,
	@TransactionId int
AS
	SET QUOTED_IDENTIFIER OFF  
	SET ANSI_NULLS ON  
	SET NOCOUNT ON  
	SET XACT_ABORT ON  
	SET ANSI_WARNINGS OFF  

BEGIN

	DECLARE @TransactionType_Receipt AS INT = 1
	DECLARE @TransactionType_Shipment AS INT = 2
	DECLARE @TransactionType_Transfer AS INT = 3

	DECLARE @OrderType_PurchaseContract AS INT = 1
	DECLARE @OrderType_SalesContract AS INT = 1
	DECLARE @OrderType_PurchaseOrder AS INT = 2
	DECLARE @OrderType_SalesOrder AS INT = 2
	DECLARE @OrderType_TransferOrder AS INT = 3
	DECLARE @OrderType_Direct AS INT = 4
	DECLARE @OrderType_InventoryReturn AS INT = 5

	DECLARE @SourceType_None AS INT = 0
	DECLARE @SourceType_Scale AS INT = 1
	DECLARE @SourceType_InboundShipment AS INT = 2
	DECLARE @SourceType_Transport AS INT = 3

	IF (@TransactionType = @TransactionType_Receipt)
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @TransactionId)
		BEGIN
			DELETE FROM tblICTransactionDetailLog WHERE strTransactionType = 'Inventory Receipt' AND intTransactionId = @TransactionId

			INSERT INTO tblICTransactionDetailLog(
				strTransactionType
				,intTransactionId 
				,intTransactionDetailId
				,intOrderNumberId
				,intOrderType
				,intSourceNumberId
				,intSourceType
				,intLineNo
				,intItemId
				,intItemUOMId
				,dblQuantity
				,ysnLoad
				,intLoadReceive
				,dblNet
				,intSourceInventoryDetailId
			)
			SELECT 'Inventory Receipt',
				ReceiptItem.intInventoryReceiptId, 
				ReceiptItem.intInventoryReceiptItemId,
				ReceiptItem.intOrderId,
				intOrderType = (
					CASE WHEN Receipt.strReceiptType = 'Purchase Contract' THEN @OrderType_PurchaseContract
						WHEN Receipt.strReceiptType = 'Purchase Order' THEN @OrderType_PurchaseOrder
						WHEN Receipt.strReceiptType = 'Transfer Order' THEN @OrderType_TransferOrder
						WHEN Receipt.strReceiptType = 'Direct' THEN @OrderType_Direct
						WHEN Receipt.strReceiptType = 'Inventory Return' THEN @OrderType_InventoryReturn
					END), 
				ReceiptItem.intSourceId,
				intSourceType = Receipt.intSourceType,
				ReceiptItem.intLineNo,
				ReceiptItem.intItemId,
				ReceiptItem.intUnitMeasureId,
				ReceiptItem.dblOpenReceive,
				ReceiptItemSource.ysnLoad,
				ReceiptItem.intLoadReceive,
				ReceiptItem.dblNet,
				ReceiptItem.intSourceInventoryReceiptItemId 
			FROM tblICInventoryReceiptItem ReceiptItem
				LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				LEFT JOIN vyuICGetReceiptItemSource ReceiptItemSource ON ReceiptItemSource.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
			WHERE ReceiptItem.intInventoryReceiptId = @TransactionId
		END
	END
	ELSE IF (@TransactionType = @TransactionType_Shipment)
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblICInventoryShipment WHERE intInventoryShipmentId = @TransactionId)
		BEGIN
			DELETE FROM tblICTransactionDetailLog WHERE strTransactionType = 'Inventory Shipment' AND intTransactionId = @TransactionId

			INSERT INTO tblICTransactionDetailLog(
				strTransactionType
				,intTransactionId 
				,intTransactionDetailId
				,intOrderNumberId
				,intOrderType
				,intSourceNumberId
				,intSourceType
				,intLineNo
				,intItemId
				,intItemUOMId
				,dblQuantity
			)
			SELECT 'Inventory Shipment',
				ShipmentItem.intInventoryShipmentId, 
				ShipmentItem.intInventoryShipmentItemId,
				ShipmentItem.intOrderId,
				Shipment.intOrderType,
				ShipmentItem.intSourceId,
				Shipment.intSourceType,
				ShipmentItem.intLineNo,
				ShipmentItem.intItemId,
				ShipmentItem.intItemUOMId,
				ShipmentItem.dblQuantity
			FROM tblICInventoryShipmentItem ShipmentItem
				LEFT JOIN tblICInventoryShipment Shipment ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
			WHERE ShipmentItem.intInventoryShipmentId = @TransactionId
		END
	END

END