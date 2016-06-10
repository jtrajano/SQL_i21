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
	DECLARE @SourceType AS INT

	DECLARE @ReceiptType_PurchaseContract AS INT = 1
	DECLARE @ReceiptType_PurchaseOrder AS INT = 2
	DECLARE @ReceiptType_TransferOrder AS INT = 3
	DECLARE @ReceiptType_Direct AS INT = 4

	DECLARE @SourceType_None AS INT = 0
	DECLARE @SourceType_Scale AS INT = 1
	DECLARE @SourceType_InboundShipment AS INT = 2
	DECLARE @SourceType_Transport AS INT = 3

	DECLARE @ErrMsg NVARCHAR(MAX)

	BEGIN TRY

		IF (@ForDelete = 1)
		BEGIN
			SELECT @ReceiptType = (
				CASE WHEN intOrderType = 1 THEN @ReceiptType_PurchaseContract
					WHEN intOrderType = 2 THEN @ReceiptType_PurchaseOrder
					WHEN intOrderType = 3 THEN @ReceiptType_TransferOrder
					WHEN intOrderType = 4 THEN @ReceiptType_Direct
				END) FROM tblICTransactionDetailLog
			WHERE intTransactionId = @ReceiptId
			AND strTransactionType = 'Inventory Receipt'
			SELECT @SourceType = (
				CASE WHEN intSourceType = 2 THEN @SourceType_InboundShipment
					 END) FROM tblICTransactionDetailLog
			WHERE intTransactionId = @ReceiptId
			AND strTransactionType = 'Inventory Receipt' 
		END
		ELSE
		BEGIN
			SELECT @ReceiptType = (
				CASE WHEN strReceiptType = 'Purchase Contract' THEN @ReceiptType_PurchaseContract
					WHEN strReceiptType = 'Purchase Order' THEN @ReceiptType_PurchaseOrder
					WHEN strReceiptType = 'Transfer Order' THEN @ReceiptType_TransferOrder
					WHEN strReceiptType = 'Direct' THEN @ReceiptType_Direct
				END) FROM tblICInventoryReceipt
			WHERE intInventoryReceiptId = @ReceiptId
			SELECT @SourceType = (
				CASE WHEN intSourceType = 2 THEN @SourceType_InboundShipment
				END) FROM tblICInventoryReceipt
			WHERE intInventoryReceiptId = @ReceiptId
		END
	
		-- Purchase Contracts
		IF (@ReceiptType = @ReceiptType_PurchaseContract) AND (ISNULL(@SourceType,0) <> @SourceType_InboundShipment)
		BEGIN

			-- Create current snapshot of Receipt Items after Save
			SELECT
				ReceiptItem.intInventoryReceiptId,
				ReceiptItem.intInventoryReceiptItemId,
				intOrderType = (
					CASE WHEN Receipt.strReceiptType = 'Purchase Contract' THEN @ReceiptType_PurchaseContract
						WHEN Receipt.strReceiptType = 'Purchase Order' THEN @ReceiptType_PurchaseOrder
						WHEN Receipt.strReceiptType = 'Transfer Order' THEN @ReceiptType_TransferOrder
						WHEN Receipt.strReceiptType = 'Direct' THEN @ReceiptType_Direct
					END),
				ReceiptItem.intOrderId,
				Receipt.intSourceType,
				ReceiptItem.intSourceId,
				ReceiptItem.intLineNo,
				ReceiptItem.intItemId,
				intItemUOMId = ReceiptItem.intUnitMeasureId,
				ReceiptItem.dblOpenReceive,
				ReceiptItemSource.ysnLoad,
				ReceiptItem.intLoadReceive
			INTO #tmpReceiptItems
			FROM tblICInventoryReceiptItem ReceiptItem
				LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				LEFT JOIN vyuICGetReceiptItemSource ReceiptItemSource ON ReceiptItemSource.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
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
				dblOpenReceive = dblQuantity,
				ysnLoad,
				intLoadReceive
			INTO #tmpLogReceiptItems
			FROM tblICTransactionDetailLog
			WHERE intTransactionId = @ReceiptId
				AND strTransactionType = 'Inventory Receipt'

			-- Create temporary table for processing records
			DECLARE @tblToProcess TABLE
			(
				intKeyId					INT IDENTITY,
				intInventoryReceiptItemId	INT,
				intContractDetailId			INT,
				intItemUOMId				INT,
				dblQty						NUMERIC(12,4)	
			)

			INSERT INTO @tblToProcess(
				intInventoryReceiptItemId,
				intContractDetailId,
				intItemUOMId,
				dblQty)

			-- Changed Quantity/UOM
			SELECT 
				currentSnapshot.intInventoryReceiptItemId,
				currentSnapshot.intLineNo,
				currentSnapshot.intItemUOMId,
				CASE WHEN (ISNULL(currentSnapshot.ysnLoad, 0) = 0) THEN dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (CASE WHEN @ForDelete = 1 THEN currentSnapshot.dblOpenReceive ELSE (currentSnapshot.dblOpenReceive - previousSnapshot.dblOpenReceive) END))
					ELSE currentSnapshot.intLoadReceive END 
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

			UNION ALL 
		
			--New Contract Selected
			SELECT
				currentSnapshot.intInventoryReceiptItemId
				,currentSnapshot.intLineNo
				,currentSnapshot.intItemUOMId
				,CASE WHEN (ISNULL(currentSnapshot.ysnLoad, 0) = 0) THEN dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, previousSnapshot.intItemUOMId, currentSnapshot.dblOpenReceive)
					ELSE currentSnapshot.intLoadReceive END
			FROM #tmpReceiptItems currentSnapshot
			INNER JOIN #tmpLogReceiptItems previousSnapshot
				ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
				AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
			WHERE
				currentSnapshot.intLineNo IS NOT NULL
				AND currentSnapshot.intLineNo <> previousSnapshot.intLineNo		
				AND currentSnapshot.intItemId = previousSnapshot.intItemId		
		
			UNION ALL

			--Replaced Contract
			SELECT
				currentSnapshot.intInventoryReceiptItemId
				,previousSnapshot.intLineNo
				,previousSnapshot.intItemUOMId
				,CASE WHEN (ISNULL(previousSnapshot.ysnLoad, 0) = 0) THEN dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (previousSnapshot.dblOpenReceive * -1))
					ELSE previousSnapshot.intLoadReceive END
			FROM #tmpReceiptItems currentSnapshot
			INNER JOIN #tmpLogReceiptItems previousSnapshot
				ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
				AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
			WHERE
				currentSnapshot.intLineNo IS NOT NULL
				AND currentSnapshot.intLineNo <> previousSnapshot.intLineNo
				AND currentSnapshot.intItemId = previousSnapshot.intItemId

			UNION ALL
		
			--Removed Contract
			SELECT
				currentSnapshot.intInventoryReceiptItemId
				,previousSnapshot.intLineNo
				,previousSnapshot.intItemUOMId
				,CASE WHEN (ISNULL(previousSnapshot.ysnLoad, 0) = 0) THEN dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (previousSnapshot.dblOpenReceive * -1))
					ELSE previousSnapshot.intLoadReceive END
			FROM #tmpReceiptItems currentSnapshot
			INNER JOIN #tmpLogReceiptItems previousSnapshot
				ON previousSnapshot.intInventoryReceiptId = currentSnapshot.intInventoryReceiptId
				AND previousSnapshot.intInventoryReceiptItemId = currentSnapshot.intInventoryReceiptItemId
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
			WHERE
				currentSnapshot.intLineNo IS NULL
				AND previousSnapshot.intLineNo IS NOT NULL
		
			UNION ALL	

			--Deleted Item
			SELECT
				previousSnapshot.intInventoryReceiptItemId
				,previousSnapshot.intLineNo
				,previousSnapshot.intItemUOMId
				,CASE WHEN (ISNULL(previousSnapshot.ysnLoad, 0) = 0) THEN dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (previousSnapshot.dblOpenReceive * -1))
					ELSE previousSnapshot.intLoadReceive END
			FROM #tmpLogReceiptItems previousSnapshot
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = previousSnapshot.intLineNo
			WHERE
				previousSnapshot.intLineNo IS NOT NULL
				AND previousSnapshot.intInventoryReceiptItemId NOT IN (SELECT intInventoryReceiptItemId FROM #tmpReceiptItems)
		
			UNION ALL
		
			--Added Item
			SELECT
				currentSnapshot.intInventoryReceiptItemId
				,currentSnapshot.intLineNo
				,currentSnapshot.intItemUOMId
				,CASE WHEN (ISNULL(currentSnapshot.ysnLoad, 0) = 0) THEN dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, ContractDetail.intItemUOMId, currentSnapshot.dblOpenReceive)
					ELSE currentSnapshot.intLoadReceive END
			FROM #tmpReceiptItems currentSnapshot
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
			WHERE
				currentSnapshot.intLineNo IS NOT NULL
				AND currentSnapshot.intInventoryReceiptItemId NOT IN (SELECT intInventoryReceiptItemId FROM #tmpLogReceiptItems)
			
			-- Iterate and process records
			DECLARE @Id INT = NULL,
					@intInventoryReceiptItemId	INT = NULL,
					@intContractDetailId		INT = NULL,
					@intFromItemUOMId			INT = NULL,
					@intToItemUOMId				INT = NULL,
					@dblQty				NUMERIC(12,4) = 0

			SELECT @Id = MIN(intKeyId) FROM @tblToProcess

			WHILE ISNULL(@Id,0) > 0
			BEGIN
				SELECT	@intContractDetailId		=	intContractDetailId,
						@intFromItemUOMId			=	intItemUOMId,
						@dblQty						=	dblQty,
						@intInventoryReceiptItemId	=	intInventoryReceiptItemId
				FROM	@tblToProcess 
				WHERE	intKeyId				=	 @Id

				IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
				BEGIN
					RAISERROR('Contract does not exist.',16,1)
				END
									
				EXEC	uspCTUpdateScheduleQuantity
						@intContractDetailId	=	@intContractDetailId,
						@dblQuantityToUpdate	=	@dblQty,
						@intUserId				=	@UserId,
						@intExternalId			=	@intInventoryReceiptItemId,
						@strScreenName			=	'Inventory Receipt'

				SELECT @Id = MIN(intKeyId) FROM @tblToProcess WHERE intKeyId > @Id
			END

			DELETE FROM tblICTransactionDetailLog WHERE strTransactionType = 'Inventory Receipt' AND intTransactionId = @ReceiptId
			DROP TABLE #tmpLogReceiptItems
			DROP TABLE #tmpReceiptItems

		END

	END TRY

	BEGIN CATCH

		SET @ErrMsg = ERROR_MESSAGE()  
		RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')  

	END CATCH

	DELETE FROM tblICTransactionDetailLog WHERE intTransactionId = @ReceiptId AND strTransactionType = 'Inventory Receipt'

END
