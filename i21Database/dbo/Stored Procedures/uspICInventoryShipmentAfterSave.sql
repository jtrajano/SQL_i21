CREATE PROCEDURE [dbo].[uspICInventoryShipmentAfterSave]
	@ShipmentId INT,
	@ForDelete BIT = 0,
	@UserId INT = NULL

AS

	SET QUOTED_IDENTIFIER OFF  
	SET ANSI_NULLS ON  
	SET NOCOUNT ON  
	SET XACT_ABORT ON  
	SET ANSI_WARNINGS OFF  

BEGIN
	
	DECLARE @ShipmentType AS INT

	DECLARE @ShipmentType_SalesContract AS INT = 1
	DECLARE @ShipmentType_SalesOrder AS INT = 2
	DECLARE @ShipmentType_TransferOrder AS INT = 3
	DECLARE @ShipmentType_Direct AS INT = 4

	DECLARE @SourceType_None AS INT = 0
	DECLARE @SourceType_Scale AS INT = 1
	DECLARE @SourceType_InboundShipment AS INT = 2
	DECLARE @SourceType_Transport AS INT = 3

	DECLARE @ErrMsg NVARCHAR(MAX)

	BEGIN TRY

		SELECT @ShipmentType = intOrderType
		FROM tblICInventoryShipment
		WHERE intInventoryShipmentId = @ShipmentId
	
		-- Create current snapshot of Shipment Items after Save
		SELECT
			ShipmentItem.intInventoryShipmentId,
			ShipmentItem.intInventoryShipmentItemId,
			Shipment.intOrderType,
			ShipmentItem.intOrderId,
			Shipment.intSourceType,
			ShipmentItem.intSourceId,
			ShipmentItem.intLineNo,
			ShipmentItem.intItemId,
			ShipmentItem.intItemUOMId,
			ShipmentItem.dblQuantity
		INTO #tmpShipmentItems
		FROM tblICInventoryShipmentItem ShipmentItem
			LEFT JOIN tblICInventoryShipment Shipment ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
		WHERE ShipmentItem.intInventoryShipmentId = @ShipmentId

		-- Create snapshot of Shipment Items before Save
		SELECT 
			intInventoryShipmentId = intTransactionId,
			intInventoryShipmentItemId = intTransactionDetailId,
			intOrderType,
			intOrderId = intOrderNumberId,
			intSourceType,
			intSourceId = intSourceNumberId,
			intLineNo,
			intItemId,
			intItemUOMId,
			dblQuantity
		INTO #tmpLogShipmentItems
		FROM tblICTransactionDetailLog
		WHERE intTransactionId = @ShipmentId
			AND strTransactionType = 'Inventory Shipment'

		-- Sales Contracts
		IF (@ShipmentType = @ShipmentType_SalesContract)
		BEGIN
			-- Create temporary table for processing records
			DECLARE @tblContractsToProcess TABLE
			(
				intKeyId					INT IDENTITY,
				intInventoryShipmentItemId	INT,
				intContractDetailId			INT,
				intItemUOMId				INT,
				dblQty						NUMERIC(12,4)	
			)

			INSERT INTO @tblContractsToProcess(
				intInventoryShipmentItemId,
				intContractDetailId,
				intItemUOMId,
				dblQty)

			-- Changed Quantity/UOM
			SELECT 
				currentSnapshot.intInventoryShipmentItemId,
				currentSnapshot.intLineNo,
				currentSnapshot.intItemUOMId,
				dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (CASE WHEN @ForDelete = 1 THEN currentSnapshot.dblQuantity ELSE (currentSnapshot.dblQuantity - previousSnapshot.dblQuantity) END))
			FROM #tmpShipmentItems currentSnapshot
			INNER JOIN #tmpLogShipmentItems previousSnapshot
				ON previousSnapshot.intInventoryShipmentId = currentSnapshot.intInventoryShipmentId
				AND previousSnapshot.intInventoryShipmentItemId = currentSnapshot.intInventoryShipmentItemId
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
			WHERE
				currentSnapshot.intLineNo IS NOT NULL
				AND currentSnapshot.intLineNo = previousSnapshot.intLineNo
				AND currentSnapshot.intItemId = previousSnapshot.intItemId		
				AND (currentSnapshot.intItemUOMId <> previousSnapshot.intItemUOMId OR currentSnapshot.dblQuantity <> previousSnapshot.dblQuantity)

			UNION ALL 
		
			--New Contract Selected
			SELECT
				currentSnapshot.intInventoryShipmentItemId
				,currentSnapshot.intLineNo
				,currentSnapshot.intItemUOMId
				,dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, previousSnapshot.intItemUOMId, currentSnapshot.dblQuantity)
			FROM #tmpShipmentItems currentSnapshot
			INNER JOIN #tmpLogShipmentItems previousSnapshot
				ON previousSnapshot.intInventoryShipmentId = currentSnapshot.intInventoryShipmentId
				AND previousSnapshot.intInventoryShipmentItemId = currentSnapshot.intInventoryShipmentItemId
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
			WHERE
				currentSnapshot.intLineNo IS NOT NULL
				AND currentSnapshot.intLineNo <> previousSnapshot.intLineNo		
				AND currentSnapshot.intItemId = previousSnapshot.intItemId		
		
			UNION ALL

			--Replaced Contract
			SELECT
				currentSnapshot.intInventoryShipmentItemId
				,previousSnapshot.intLineNo
				,previousSnapshot.intItemUOMId
				,dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (previousSnapshot.dblQuantity * -1))
			FROM #tmpShipmentItems currentSnapshot
			INNER JOIN #tmpLogShipmentItems previousSnapshot
				ON previousSnapshot.intInventoryShipmentId = currentSnapshot.intInventoryShipmentId
				AND previousSnapshot.intInventoryShipmentItemId = currentSnapshot.intInventoryShipmentItemId
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
			WHERE
				currentSnapshot.intLineNo IS NOT NULL
				AND currentSnapshot.intLineNo <> previousSnapshot.intLineNo
				AND currentSnapshot.intItemId = previousSnapshot.intItemId

			UNION ALL
		
			--Removed Contract
			SELECT
				currentSnapshot.intInventoryShipmentItemId
				,previousSnapshot.intLineNo
				,previousSnapshot.intItemUOMId
				,dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (previousSnapshot.dblQuantity * -1))
			FROM #tmpShipmentItems currentSnapshot
			INNER JOIN #tmpLogShipmentItems previousSnapshot
				ON previousSnapshot.intInventoryShipmentId = currentSnapshot.intInventoryShipmentId
				AND previousSnapshot.intInventoryShipmentItemId = currentSnapshot.intInventoryShipmentItemId
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
			WHERE
				currentSnapshot.intLineNo IS NULL
				AND previousSnapshot.intLineNo IS NOT NULL
		
			UNION ALL	

			--Deleted Item
			SELECT
				previousSnapshot.intInventoryShipmentItemId
				,previousSnapshot.intLineNo
				,previousSnapshot.intItemUOMId
				,dbo.fnCalculateQtyBetweenUOM(previousSnapshot.intItemUOMId, ContractDetail.intItemUOMId, (previousSnapshot.dblQuantity * -1))
			FROM #tmpLogShipmentItems previousSnapshot
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = previousSnapshot.intLineNo
			WHERE
				previousSnapshot.intLineNo IS NOT NULL
				AND previousSnapshot.intInventoryShipmentItemId NOT IN (SELECT intInventoryShipmentItemId FROM #tmpShipmentItems)
		
			UNION ALL
		
			--Added Item
			SELECT
				currentSnapshot.intInventoryShipmentItemId
				,currentSnapshot.intLineNo
				,currentSnapshot.intItemUOMId
				,dbo.fnCalculateQtyBetweenUOM(currentSnapshot.intItemUOMId, ContractDetail.intItemUOMId, currentSnapshot.dblQuantity)
			FROM #tmpShipmentItems currentSnapshot
			INNER JOIN tblCTContractDetail ContractDetail
				ON ContractDetail.intContractDetailId = currentSnapshot.intLineNo
			WHERE
				currentSnapshot.intLineNo IS NOT NULL
				AND currentSnapshot.intInventoryShipmentItemId NOT IN (SELECT intInventoryShipmentItemId FROM #tmpLogShipmentItems)

			-- Iterate and process records
			DECLARE @Id INT = NULL,
					@intInventoryShipmentItemId	INT = NULL,
					@intContractDetailId		INT = NULL,
					@intFromItemUOMId			INT = NULL,
					@intToItemUOMId				INT = NULL,
					@dblQty				NUMERIC(12,4) = 0

			SELECT @Id = MIN(intKeyId) FROM @tblContractsToProcess

			WHILE ISNULL(@Id,0) > 0
			BEGIN
				SELECT	@intContractDetailId		=	intContractDetailId,
						@intFromItemUOMId			=	intItemUOMId,
						@dblQty						=	dblQty * (CASE WHEN @ForDelete = 1 THEN -1 ELSE 1 END), -- * -1,
						@intInventoryShipmentItemId	=	intInventoryShipmentItemId
				FROM	@tblContractsToProcess 
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
						@intExternalId			=	@intInventoryShipmentItemId,
						@strScreenName			=	'Inventory Shipment'

				SELECT @Id = MIN(intKeyId) FROM @tblContractsToProcess WHERE intKeyId > @Id
			END
		END
		
		-- Create temporary table for processing records
		DECLARE @tblTransactionsToProcess TABLE
		(
			intKeyId				INT IDENTITY,
			intInventoryShipmentId	INT
		)

		INSERT INTO @tblTransactionsToProcess(intInventoryShipmentId)

		-- Get Previous snapshots
		SELECT previousSnapshot.intInventoryShipmentId
		FROM #tmpLogShipmentItems previousSnapshot
		WHERE
			previousSnapshot.intInventoryShipmentId NOT IN (
				SELECT currentSnapshot.intInventoryShipmentId
				FROM #tmpShipmentItems currentSnapshot
			)

		UNION ALL 
		
		-- Get latest snapshots
		SELECT currentSnapshot.intInventoryShipmentId
		FROM #tmpShipmentItems currentSnapshot
		WHERE
			currentSnapshot.intInventoryShipmentId NOT IN (
				SELECT previousSnapshot.intInventoryShipmentId
				FROM #tmpLogShipmentItems previousSnapshot
			)
		
		-- Iterate and process records
		DECLARE @KeyId INT = NULL,
				@intInventoryShipmentId	INT = NULL

		SELECT @KeyId = MIN(intKeyId) FROM @tblTransactionsToProcess

		WHILE ISNULL(@KeyId,0) > 0
		BEGIN
			SELECT	@intInventoryShipmentId		=	intInventoryShipmentId
			FROM	@tblTransactionsToProcess 
			WHERE	intKeyId				=	 @KeyId

			EXEC	uspICReserveStockForInventoryShipment
					@intTransactionId	=	@intInventoryShipmentId

			SELECT @KeyId = MIN(intKeyId) FROM @tblTransactionsToProcess WHERE intKeyId > @KeyId
		END

		DELETE FROM tblICTransactionDetailLog WHERE strTransactionType = 'Inventory Shipment' AND intTransactionId = @ShipmentId
		DROP TABLE #tmpLogShipmentItems
		DROP TABLE #tmpShipmentItems

	END TRY

	BEGIN CATCH

		SET @ErrMsg = ERROR_MESSAGE()  
		RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')  

	END CATCH

	DELETE FROM tblICTransactionDetailLog WHERE intTransactionId = @ShipmentId AND strTransactionType = 'Inventory Shipment'

END

