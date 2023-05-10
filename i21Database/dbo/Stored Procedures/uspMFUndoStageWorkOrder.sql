CREATE PROCEDURE [dbo].[uspMFUndoStageWorkOrder] 
(
	@strXML NVARCHAR(MAX)
)
AS
BEGIN TRY

	DECLARE @idoc							INT
		  , @ErrMsg							NVARCHAR(MAX)
		  , @intWorkOrderId					INT
		  , @intWorkOrderInputLotId			INT
		  , @ysnNegativeQtyAllowed			BIT
		  , @intUserId						INT
		  , @dtmCurrentDateTime				DATETIME = GETDATE()
		  , @intTransactionCount			INT
		  , @ItemsToReserve					dbo.ItemReservationTableType
		  , @intInventoryTransactionType	INT = 8
		  , @intRecipeItemUOMId				INT
		  , @strConsumeSourceLocation		NVARCHAR(50)


	SELECT @intTransactionCount = @@TRANCOUNT

	EXEC sp_xml_preparedocument @idoc OUTPUT
							  , @strXML

	SELECT @intWorkOrderId			= intWorkOrderId
		 , @intWorkOrderInputLotId	= intWorkOrderInputLotId
		 , @ysnNegativeQtyAllowed	= ysnNegativeQtyAllowed
		 , @intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH 
	(
		intWorkOrderId			INT
	  , intWorkOrderInputLotId	INT
	  , ysnNegativeQtyAllowed	BIT
	  , intUserId				INT
	)

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	DECLARE @RecordKey					INT
		  , @intLotId					INT
		  , @strNewLotNumber			NVARCHAR(50)
		  , @intNewLocationId			INT
		  , @intNewSubLocationId		INT
		  , @intNewStorageLocationId	INT
		  , @dblNewWeight				NUMERIC(38, 20)
		  , @intNewItemUOMId			INT
		  , @dblWeightPerQty			NUMERIC(38, 20)
		  , @dblAdjustByQuantity		NUMERIC(38, 20)
		  , @intInventoryAdjustmentId	INT
		  , @intItemId					INT
		  , @intLocationId				INT
		  , @intRecipeId				INT
		  , @intStorageLocationId		INT
		  , @intInputItemId				INT
		  , @strLotNumber				NVARCHAR(50)
		  , @intSubLocationId			INT
		  , @intConsumptionMethodId		INT
		  , @intWeightUOMId				INT
		  , @intItemUOMId				INT
		  , @strInventoryTracking		NVARCHAR(50)
		  , @strTransferNo				NVARCHAR(50)
		  , @intInventoryTransferId		INT
		  , @intMachineId				INT
		  , @intManufacturingProcessId	INT
		  , @intProductionStageLocationId INT
		  , @intProductionStagingId		INT
		  , @strStagedLotNumber			NVARCHAR(50)
		  , @strWorkOrderNo				NVARCHAR(50)
		  , @dtmProductionDate			DATETIME
		  , @intDestinationLotId		INT
		  , @intMainItemId				INT
		  , @dblLotQuantity				NUMERIC(38, 20)
		  , @intEnteredUOMId			INT
		  , @dblSummaryQty				NUMERIC(38, 20)

	SELECT @strWorkOrderNo = strWorkOrderNo
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intLotId				= intLotId
		 , @intInputItemId			= intItemId
		 , @dblNewWeight			= dblQuantity
		 , @intNewItemUOMId			= intItemUOMId
		 , @intNewStorageLocationId = intStorageLocationId
		 , @intMachineId			= intMachineId
		 , @dtmProductionDate		= dtmProductionDate
		 , @intDestinationLotId		= intDestinationLotId
		 , @intMainItemId			= intMainItemId
		 , @dblLotQuantity			= dblLotQuantity
		 , @intEnteredUOMId			= intEnteredItemUOMId
	FROM tblMFWorkOrderInputLot
	WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId

	SELECT @strStagedLotNumber = strLotNumber
	FROM tblICLot
	WHERE intLotId = @intLotId

	SELECT @strInventoryTracking = strInventoryTracking
	FROM dbo.tblICItem
	WHERE intItemId = @intInputItemId

	SELECT @intItemId					= intItemId
		 , @intLocationId				= intLocationId
		 , @intManufacturingProcessId	= intManufacturingProcessId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @strConsumeSourceLocation = ISNULL(NULLIF(strAttributeValue, ''), 'False')
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 124

	/* Adjust by Consume Source Location. */
	IF @strConsumeSourceLocation = 'False'
		BEGIN
			/* Lot Track post Inventory Adjustment Lot Merge. */
			IF @strInventoryTracking = 'Lot Level'
				BEGIN
					SELECT @intStorageLocationId	= ri.intStorageLocationId
						 , @intConsumptionMethodId	= intConsumptionMethodId
					FROM dbo.tblMFWorkOrderRecipeItem ri
					WHERE ri.intWorkOrderId		 = @intWorkOrderId
					  AND ri.intItemId			 = @intInputItemId
					  AND ri.intRecipeItemTypeId = 1 /* Input Recipe. */

					/* Set Consumption if not supplied based on Recipe Consumption Method. */
					IF @intConsumptionMethodId IS NULL
						BEGIN
							SELECT @intStorageLocationId	= ri.intStorageLocationId
								 , @intConsumptionMethodId	= ri.intConsumptionMethodId
							FROM dbo.tblMFWorkOrderRecipeSubstituteItem rs
							JOIN dbo.tblMFWorkOrderRecipeItem ri ON ri.intRecipeItemId = rs.intRecipeItemId
							WHERE rs.intWorkOrderId = @intWorkOrderId
							  AND rs.intSubstituteItemId = @intInputItemId
							  AND rs.intRecipeItemTypeId = 1
						END
					/* End of Set Consumption if not supplied based on Recipe Consumption Method. */

					SELECT @strNewLotNumber = strLotNumber
						 , @dblWeightPerQty = dblWeightPerQty
						 , @intItemUOMId	= intItemUOMId
					FROM dbo.tblICLot
					WHERE intLotId = @intLotId

					SELECT @intNewLocationId	= intLocationId
						 , @intNewSubLocationId = intSubLocationId
					FROM tblICStorageLocation
					WHERE intStorageLocationId = @intNewStorageLocationId

					SELECT @intProductionStageLocationId = ISNULL(intProductionStagingLocationId, 
																  (
																	SELECT strAttributeValue		
																	FROM vyuMFProcessAttributeDetail
																	WHERE intManufacturingProcessId = @intManufacturingProcessId
																	  AND intLocationId			    = @intLocationId
																	  AND strAttributeName		    = 'Production Staging Location'
																  ))
					FROM tblMFManufacturingProcessMachine
					WHERE intManufacturingProcessId = @intManufacturingProcessId
					  AND intMachineId				= @intMachineId

					SELECT TOP 1 @strLotNumber			= L.strLotNumber
							   , @intLocationId			= L.intLocationId
							   , @intSubLocationId		= L.intSubLocationId
							   , @intStorageLocationId	= L.intStorageLocationId
							   , @intWeightUOMId		= L.intWeightUOMId
					FROM dbo.tblICLot L
					JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
					WHERE L.intItemId = @intInputItemId
						AND L.intLocationId = @intLocationId
						AND L.intLotStatusId = 1
						AND ISNULL(dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
						AND L.intStorageLocationId = (CASE WHEN @intStorageLocationId IS NULL AND @intProductionStageLocationId IS NULL THEN L.intStorageLocationId
														   ELSE (CASE WHEN @intConsumptionMethodId = 1 THEN @intProductionStageLocationId
																	  WHEN @intConsumptionMethodId = 2 THEN @intStorageLocationId
																	  ELSE L.intStorageLocationId
																 END) --By location, then apply location filter
													  END)
						AND L.intLotId = @strStagedLotNumber
					ORDER BY L.dblQty			DESC
						   , L.dtmDateCreated	ASC


					IF @strLotNumber IS NULL
						BEGIN
							SELECT TOP 1 @strLotNumber			= L.strLotNumber
									   , @intLocationId			= L.intLocationId
									   , @intSubLocationId		= L.intSubLocationId
									   , @intStorageLocationId	= L.intStorageLocationId
									   , @intWeightUOMId		= L.intWeightUOMId
							FROM dbo.tblICLot L
							JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
							WHERE L.intItemId = @intInputItemId
								AND L.intLocationId = @intLocationId
								AND L.intLotStatusId = 1
								AND ISNULL(dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
								AND L.intStorageLocationId = (CASE WHEN @intStorageLocationId IS NULL AND @intProductionStageLocationId IS NULL THEN L.intStorageLocationId
																   ELSE (CASE WHEN @intConsumptionMethodId = 1 THEN @intProductionStageLocationId
																			  WHEN @intConsumptionMethodId = 2 THEN @intStorageLocationId
																			  ELSE L.intStorageLocationId
																   END) --By location, then apply location filter
															  END)
							ORDER BY L.dblQty			DESC
								   , L.dtmDateCreated	ASC
						END
			
					DECLARE @dblAdjustWeight NUMERIC(38, 20) = CASE WHEN @dblNewWeight > @dblLotQuantity AND ISNULL(@dblLotQuantity, 0) > 0 THEN @dblLotQuantity
																	ELSE @dblNewWeight
															   END

			SELECT @dblAdjustByQuantity = -@dblAdjustWeight
				 , @dblSummaryQty		= -@dblNewWeight;

			/* If the Stage Quantity is divisible by Weight Per Qty. */
			IF @dblWeightPerQty = 0 OR @dblNewWeight % @dblWeightPerQty > 0
				BEGIN
					SET @intNewItemUOMId = @intNewItemUOMId;
				END
			ELSE
				BEGIN
					SELECT @dblAdjustByQuantity = -@dblAdjustWeight / @dblWeightPerQty
						 , @intNewItemUOMId		= @intItemUOMId
						 , @dblSummaryQty		= -@dblSummaryQty / @dblWeightPerQty
				END
			/* End of if the Stage Quantity is divisible by Weight Per Qty. */

					IF NOT EXISTS (SELECT *
								   FROM tblICLot
								   WHERE strLotNumber = @strLotNumber
									 AND intStorageLocationId = @intStorageLocationId
									 AND (intItemUOMId = @intNewItemUOMId OR ISNULL(intWeightUOMId, intItemUOMId) = @intNewItemUOMId)
								  )
						BEGIN
							SELECT @dblAdjustByQuantity = - dbo.fnMFConvertQuantityToTargetItemUOM(@intNewItemUOMId, @intItemUOMId, @dblAdjustWeight)

							SELECT @intNewItemUOMId = @intItemUOMId
						END

					EXEC dbo.uspICCreateStockReservation @ItemsToReserve		= @ItemsToReserve
													   , @intTransactionId		= @intWorkOrderId
													   , @intTransactionTypeId	= @intInventoryTransactionType

			EXEC uspICInventoryAdjustment_CreatePostLotMerge @intItemId					= @intInputItemId
														   , @dtmDate					= NULL
														   , @intLocationId				= @intLocationId
														   , @intSubLocationId			= @intSubLocationId
														   , @intStorageLocationId		= @intStorageLocationId
														   , @strLotNumber				= @strLotNumber
														   /* New Value/Data */ 
														   , @intNewLocationId			= @intNewLocationId
														   , @intNewSubLocationId		= @intNewSubLocationId
														   , @intNewStorageLocationId	= @intNewStorageLocationId
														   , @strNewLotNumber			= @strNewLotNumber
														   , @dblAdjustByQuantity		= @dblAdjustByQuantity
														   , @dblNewSplitLotQuantity	= NULL
														   , @dblNewWeight				= NULL
														   , @intNewItemUOMId			= NULL
														   , @intNewWeightUOMId			= NULL
														   , @dblNewUnitCost			= NULL
														   , @intItemUOMId				= @intNewItemUOMId
														   /* Parameters used for linking or FK (foreign key) relationships. */
														   , @intSourceId				= @intWorkOrderId
														   , @intSourceTransactionTypeId = 8
														   , @intEntityUserSecurityId	= @intUserId
														   , @intInventoryAdjustmentId	= @intInventoryAdjustmentId OUTPUT

			IF @dblNewWeight > @dblLotQuantity AND ISNULL(@dblLotQuantity, 0) > 0
				BEGIN

					/* Retrieve and negate excess stage qty. */
					DECLARE @dblExcessStageQty NUMERIC(38, 20) = -(@dblNewWeight - @dblLotQuantity)

					/* Remove excess stage lot.
					 * Reverting Quantity to original stock before item was staged.
					*/
					EXEC [uspICInventoryAdjustment_CreatePostQtyChange] @intItemId					= @intInputItemId
																	  , @dtmDate					= NULL
																	  , @intLocationId				= @intLocationId
																	  , @intSubLocationId			= @intSubLocationId
																	  , @intStorageLocationId		= @intStorageLocationId
																	  , @strLotNumber				= @strLotNumber
																	  -- Parameters for the new values: 
																	  , @dblAdjustByQuantity		= @dblExcessStageQty
																	  , @dblNewUnitCost				= NULL
																	  , @intItemUOMId				= @intEnteredUOMId
																	  -- Parameters used for linking or FK (foreign key) relationships
																	  , @intSourceId				= @intWorkOrderId
																	  , @intSourceTransactionTypeId = 8
																	  , @intEntityUserSecurityId	= @intUserId
																	  , @intInventoryAdjustmentId	= @intInventoryAdjustmentId OUTPUT
																	  , @strDescription				= @strWorkOrderNo
				END
			
		END
				/* End of Lot Track post Inventory Adjustment Lot Merge. */
			ELSE
				/* Inventory Transfer for Non Lot Track Item */
				BEGIN
					SELECT @intInventoryTransferId = intInventoryTransferId,@intStorageLocationId=intToStorageLocationId
					FROM dbo.tblICInventoryTransferDetail
					WHERE intSourceId = @intWorkOrderInputLotId

					SELECT @strTransferNo = strTransferNo
					FROM dbo.tblICInventoryTransfer
					WHERE intInventoryTransferId = @intInventoryTransferId

					EXEC dbo.uspICPostStockReservation @intTransactionId		= @intWorkOrderId
														, @intTransactionTypeId	= 8
														, @ysnPosted				= 1

					EXEC dbo.uspICPostInventoryTransfer @ysnPost				= 0
														, @ysnRecap				= 0
														, @strTransactionId		= @strTransferNo
														, @intEntityUserSecurityId = @intUserId;

					SET @dblAdjustByQuantity = - @dblNewWeight

					SET @dblSummaryQty = -dblNewWeight;
				END
				/* End of Inventory Transfer for Non Lot Track Item */
		END
	ELSE
		BEGIN
			SET @dblAdjustByQuantity = -(CASE WHEN @dblNewWeight > @dblLotQuantity AND ISNULL(@dblLotQuantity, 0) > 0 THEN @dblLotQuantity
											  ELSE @dblNewWeight
										 END)

			EXEC dbo.uspICPostStockReservation @intTransactionId		= @intWorkOrderId
											 , @intTransactionTypeId	= 8
											 , @ysnPosted				= 1

			SET @dblSummaryQty = dblAdjustByQuantity;
		END
		/* End of Adjust by Consume Source Location. */
	
	

	/* Set Work Order Stage Line to Reversed.  */
	UPDATE tblMFWorkOrderInputLot
	SET ysnConsumptionReversed	= 1
	  , dtmLastModified			= @dtmCurrentDateTime
	  , intLastModifiedUserId	= @intUserId
	WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId

	SELECT @intRecipeItemUOMId = ISNULL(RI.intItemUOMId, 
									   (
											SELECT RS.intItemUOMId
											FROM tblMFWorkOrderRecipeSubstituteItem RS
											WHERE RS.intWorkOrderId		 = @intWorkOrderId
											  AND RS.intSubstituteItemId = @intInputItemId
									   ))
	FROM tblMFWorkOrderRecipeItem RI
	WHERE RI.intWorkOrderId			= @intWorkOrderId
		AND RI.intItemId			= @intInputItemId
		AND RI.intRecipeItemTypeId	= 1


	SET @dblSummaryQty = ABS(@dblSummaryQty)

	/* Update Production Summary - Negate Input/Stage Qty. */
	UPDATE tblMFProductionSummary
	SET dblInputQuantity = dblInputQuantity - ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(@intNewItemUOMId, @intRecipeItemUOMId, @dblSummaryQty), 0)
	WHERE intWorkOrderId = @intWorkOrderId
	  AND intItemId = @intInputItemId
	  AND ISNULL(intMachineId, 0) = CASE WHEN intMachineId IS NOT NULL THEN ISNULL(@intMachineId, 0)
										 ELSE ISNULL(intMachineId, 0)
									END
	  AND ISNULL(intMainItemId, ISNULL(@intMainItemId, 0)) = ISNULL(@intMainItemId, 0)

	DELETE FROM tblMFProductionSummary 
	WHERE intWorkOrderId = @intWorkOrderId
		AND intItemId = @intInputItemId
		AND ISNULL(intMachineId, 0) = CASE WHEN intMachineId IS NOT NULL THEN ISNULL(@intMachineId, 0)
										   ELSE ISNULL(intMachineId, 0)
									  END
		AND dblInputQuantity = 0
		AND ISNULL(intMainItemId, ISNULL(@intMainItemId, 0)) = ISNULL(@intMainItemId,0)

	SET @intLotId = NULL;

	SELECT TOP 1 @intLotId = intLotId
	FROM tblICLot
	WHERE strLotNumber = @strNewLotNumber AND intStorageLocationId = @intNewStorageLocationId

	INSERT INTO @ItemsToReserve 
	(
		intItemId
	  , intItemLocationId
	  , intItemUOMId
	  , intLotId
	  , intSubLocationId
	  , intStorageLocationId
	  , dblQty
	  , intTransactionId
	  , strTransactionId
	  , intTransactionTypeId
	)
	SELECT intItemId			= WI.intItemId
		 , intItemLocationId	= IL.intItemLocationId
		 , intItemUOMId			= WI.intItemIssuedUOMId
		 , intLotId = (SELECT TOP 1 intLotId
					   FROM tblICLot L1
					   WHERE L1.strLotNumber = L.strLotNumber AND L1.intStorageLocationId = @intStorageLocationId)
		 , intSubLocationId		= @intSubLocationId
		 , intStorageLocationId = @intStorageLocationId
		 , dblQty				= SUM(WI.dblIssuedQuantity)
		 , intTransactionId		= @intWorkOrderId
		 , strTransactionId		= @strWorkOrderNo
		 , intTransactionTypeId = @intInventoryTransactionType
	FROM tblMFWorkOrderInputLot WI 
	JOIN tblICItemLocation IL ON IL.intItemId = WI.intItemId AND IL.intLocationId = @intLocationId AND WI.ysnConsumptionReversed = 0
	LEFT JOIN tblICLot L ON L.intLotId = WI.intLotId
	WHERE intWorkOrderId = @intWorkOrderId
	GROUP BY WI.intItemId
		   , IL.intItemLocationId
		   , WI.intItemIssuedUOMId
		   , L.strLotNumber

	EXEC dbo.uspICCreateStockReservation @ItemsToReserve		= @ItemsToReserve
									   , @intTransactionId		= @intWorkOrderId
									   , @intTransactionTypeId	= @intInventoryTransactionType

	SET @dblSummaryQty = -@dblSummaryQty;

	EXEC dbo.uspMFAdjustInventory @dtmDate						= @dtmProductionDate
								, @intTransactionTypeId			= 104--Stage
								, @intItemId					= @intInputItemId
								, @intSourceLotId				= @intDestinationLotId
								, @intDestinationLotId			= @intLotId
								, @dblQty						= @dblSummaryQty
								, @intItemUOMId					= @intNewItemUOMId
								, @intOldItemId					= NULL
								, @dtmOldExpiryDate				= NULL
								, @dtmNewExpiryDate				= NULL
								, @intOldLotStatusId			= NULL
								, @intNewLotStatusId			= NULL
								, @intUserId					= @intUserId
								, @strNote						= NULL
								, @strReason					= NULL
								, @intLocationId				= @intLocationId
								, @intInventoryAdjustmentId		= NULL
								, @intStorageLocationId			= @intStorageLocationId
								, @intDestinationStorageLocationId  = @intNewStorageLocationId
								, @intWorkOrderInputLotId		= @intWorkOrderInputLotId
								, @intWorkOrderProducedLotId	= NULL
								, @intWorkOrderId				= @intWorkOrderId

	IF @intTransactionCount = 0
		COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0 AND @intTransactionCount = 0
		BEGIN
			ROLLBACK TRANSACTION
		END

	IF @idoc <> 0
		BEGIN
			EXEC sp_xml_removedocument @idoc
		END

	RAISERROR 
	(
		@ErrMsg
	  , 16
	  , 1
	  , 'WITH NOWAIT'
	);

END CATCH