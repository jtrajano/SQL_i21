CREATE PROCEDURE [dbo].[uspICInventoryReceiptAfterSave]
	@ReceiptId INT,
	@ForDelete BIT = 0,
	@UserId INT = NULL

AS

	SET QUOTED_IDENTIFIER OFF  
	SET ANSI_NULLS ON  
	SET NOCOUNT ON  
	SET XACT_ABORT ON  
	SET ANSI_WARNINGS OFF  

BEGIN
	
	DECLARE @ReceiptType AS INT

	DECLARE @ReceiptType_PurchaseContract AS INT = 1
	DECLARE @ReceiptType_PurchaseOrder AS INT = 2
	DECLARE @ReceiptType_TransferOrder AS INT = 3
	DECLARE @ReceiptType_Direct AS INT = 4

	DECLARE @SourceType_None AS INT = 0
	DECLARE @SourceType_Scale AS INT = 1
	DECLARE @SourceType_InboundShipment AS INT = 2
	DECLARE @SourceType_Transport AS INT = 3

	SELECT @ReceiptType = (
		CASE WHEN strReceiptType = 'Purchase Contract' THEN @ReceiptType_PurchaseContract
			WHEN strReceiptType = 'Purchase Order' THEN @ReceiptType_PurchaseOrder
			WHEN strReceiptType = 'Transfer Order' THEN @ReceiptType_TransferOrder
			WHEN strReceiptType = 'Direct' THEN @ReceiptType_Direct
		END) FROM tblICInventoryReceipt
	WHERE intInventoryReceiptId = @ReceiptId
	
	IF (@ReceiptType = @ReceiptType_PurchaseContract)
	BEGIN
		-- Create current snapshot of Receipt Items after Save
		SELECT
			ReceiptItem.intInventoryReceiptId,
			ReceiptItem.intInventoryReceiptItemId,
			intOrderType = (
				CASE WHEN strReceiptType = 'Purchase Contract' THEN @ReceiptType_PurchaseContract
					WHEN strReceiptType = 'Purchase Order' THEN @ReceiptType_PurchaseOrder
					WHEN strReceiptType = 'Transfer Order' THEN @ReceiptType_TransferOrder
					WHEN strReceiptType = 'Direct' THEN @ReceiptType_Direct
				END),
			ReceiptItem.intOrderId,
			Receipt.intSourceType,
			ReceiptItem.intSourceId,
			ReceiptItem.intLineNo,
			ReceiptItem.intItemId,
			intItemUOMId = ReceiptItem.intUnitMeasureId,
			ReceiptItem.dblOpenReceive
		INTO #tmpReceiptItems
		FROM tblICInventoryReceiptItem ReceiptItem
			LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		WHERE ReceiptItem.intInventoryReceiptId = @ReceiptId
		-- Create snapshot of Receipt Items before Save
		SELECT 
			intInventoryReceiptId = intTransactionId,
			intInventoryReceiptItemId = intTransactionDetailId,
			intOrderType,
			intOrderId = intOrderNumberId,
			intSourceType,
			intSourceId = intSourceNumberId,
			intLineNo,
			intItemId,
			intItemUOMId,
			dblOpenReceive = dblQuantity
		INTO #tmpLogReceiptItems
		FROM tblICTransactionDetailLog
		WHERE intTransactionId = @ReceiptId
			AND strTransactionType = 'Inventory Receipt'

		-- Changed Quantity/UOM
		SELECT 
			 currentSnapshot.intInventoryReceiptItemId,
			 currentSnapshot.intLineNo,
			 currentSnapshot.intItemUOMId,
			 dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (CASE WHEN @ForDelete = 1 THEN currentSnapshot.dblOpenReceive ELSE (currentSnapshot.dblOpenReceive - previousSnapshot.dblOpenReceive) END))
		FROM #tmpReceiptItems currentSnapshot
		INNER JOIN #tmpLogReceiptItems previousSnapshot
			ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
			AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
		INNER JOIN tblCTContractDetail ContractDetail
			ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
		WHERE
			currentSnapshot.intLineNo IS NOT NULL
			AND currentSnapshot.intLineNo = previousSnapshot.intLineNo
			AND currentSnapshot.intItemId = previousSnapshot.intItemId		
			AND (currentSnapshot.intItemUOMId <> previousSnapshot.intItemUOMId OR currentSnapshot.dblOpenReceive <> previousSnapshot.dblOpenReceive)



		DROP TABLE #tmpLogReceiptItems
		DROP TABLE #tmpReceiptItems
	END

	DELETE FROM tblICTransactionDetailLog WHERE intTransactionId = @ReceiptId AND strTransactionType = 'Inventory Receipt'

END
