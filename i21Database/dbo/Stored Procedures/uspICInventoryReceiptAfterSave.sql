CREATE PROCEDURE [dbo].[uspICInventoryReceiptAfterSave]
	@ReceiptId INT,
	@ForDelete BIT = 0,
	@UserId INT = NULL

AS

	--SET QUOTED_IDENTIFIER OFF  
	--SET ANSI_NULLS ON  
	--SET NOCOUNT ON  
	--SET XACT_ABORT ON  
	--SET ANSI_WARNINGS OFF  

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

	DECLARE @ErrMsg NVARCHAR(MAX)

	BEGIN TRY

		SELECT @ReceiptType = (
			CASE WHEN strReceiptType = 'Purchase Contract' THEN @ReceiptType_PurchaseContract
				WHEN strReceiptType = 'Purchase Order' THEN @ReceiptType_PurchaseOrder
				WHEN strReceiptType = 'Transfer Order' THEN @ReceiptType_TransferOrder
				WHEN strReceiptType = 'Direct' THEN @ReceiptType_Direct
			END) FROM tblICInventoryReceipt
		WHERE intInventoryReceiptId = @ReceiptId
	
		-- Purchase Contracts
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

			UNION ALL 
		
			--New Contract Selected
			SELECT
				currentSnapshot.intInventoryReceiptItemId
				,currentSnapshot.intLineNo
				,currentSnapshot.intItemUOMId
				,dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, previousSnapshot.intItemUOMId, currentSnapshot.dblOpenReceive)
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
				,dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (previousSnapshot.dblOpenReceive * -1))
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
				,dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (previousSnapshot.dblOpenReceive * -1))
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
				,dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (previousSnapshot.dblOpenReceive * -1))
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
				,dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, ContractDetail.intItemUOMId, currentSnapshot.dblOpenReceive)
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
						@dblQty						=	dblQty * (CASE WHEN @ForDelete = 1 THEN -1 ELSE 1 END),
						@intInventoryReceiptItemId	=	intInventoryReceiptItemId
				FROM	@tblToProcess 
				WHERE	intKeyId				=	 @Id

				IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
				BEGIN
					RAISERROR('Contract does not exist.',16,1)
				END

				IF ISNULL(@dblQty,0) = 0
				BEGIN
					RAISERROR('UOM does not exist.',16,1)
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
