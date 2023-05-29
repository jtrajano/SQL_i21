CREATE PROCEDURE [dbo].[uspMFStageWorkOrderByLot] 
(
	@strXML					NVARCHAR(MAX)
  , @intWorkOrderInputLotId INT = NULL OUTPUT
)
AS
BEGIN TRY
	DECLARE @idoc							INT
		  , @ErrMsg							NVARCHAR(MAX)
		  , @intLocationId					INT
		  , @intSubLocationId				INT
		  , @intManufacturingProcessId		INT
		  , @intMachineId					INT
		  , @intWorkOrderId					INT
		  , @dtmPlannedDate					DATETIME
		  , @intPlannedShiftId				INT
		  , @intItemId						INT
		  , @intStorageLocationId			INT
		  , @intInputLotId					INT
		  , @intInputItemId					INT
		  , @dblWeight						NUMERIC(38, 20)
		  , @dblInputWeight					NUMERIC(38, 20)
		  , @dblReadingQuantity				NUMERIC(38, 20)
		  , @intInputWeightUOMId			INT
		  , @intUserId						INT
		  , @ysnEmptyOut					BIT
		  , @intContainerId					INT
		  , @strReferenceNo					NVARCHAR(50)
		  , @dtmActualInputDateTime			DATETIME
		  , @intShiftId						INT
		  , @intNegativeQuantityAllowed		INT
		  , @ysnExcessConsumptionAllowed	BIT
		  , @strItemNo						NVARCHAR(50)
		  , @strInputItemNo					NVARCHAR(50)
		  , @intConsumptionMethodId			INT
		  , @intConsumptionStorageLocationId INT
		  , @dblDefaultResidueQty			NUMERIC(38, 20)
		  , @dblNewWeight					NUMERIC(38, 20)
		  , @intDestinationLotId			INT
		  , @strLotNumber					NVARCHAR(50)
		  , @strLotTracking					NVARCHAR(50)
		  , @intItemLocationId				INT
		  , @dtmCurrentDateTime				DATETIME
		  , @dblAdjustByQuantity			NUMERIC(18, 6)
		  , @intInventoryAdjustmentId		INT
		  , @intNewItemUOMId				INT
		  , @dblWeightPerQty				NUMERIC(18, 6)
		  , @strDestinationLotNumber		NVARCHAR(50)
		  , @intConsumptionSubLocationId	INT
		  , @intWeightUOMId					INT
		  , @intTransactionCount			INT
		  , @strWorkOrderNo					NVARCHAR(50)
		  , @strProcessName					NVARCHAR(50)
		  , @dtmBusinessDate				DATETIME
		  , @intBusinessShiftId				INT
		  , @strInventoryTracking			NVARCHAR(50)
		  , @intProductionStagingId			INT
		  , @intProductionStageLocationId	INT
		  , @intCategoryId					INT
		  , @intItemTypeId					INT
		  , @ItemsToReserve					dbo.ItemReservationTableType
		  , @intInventoryTransactionType	INT = 8
		  , @intAdjustItemUOMId				INT
		  , @intRecipeItemUOMId				INT
		  , @dblEnteredQty					NUMERIC(38, 20)
		  , @intEnteredItemUOMId			INT
		  , @intItemStockUOMId				INT
		  , @strMultipleMachinesShareCommonStagingLocation NVARCHAR(50)
		  , @intOrderHeaderId				INT
		  , @dblQty							NUMERIC(38, 20)
		  , @strErr							NVARCHAR(MAX)
		  , @intSwapToWorkOrderId			INT
		  , @intSwapToLotId					INT
		  , @intSwapToOrderHeaderId			INT
		  , @strSwapToWorkOrderNo			NVARCHAR(50)
		  , @intRecordId					INT
		  , @dblSwapToQty					NUMERIC(18, 6)
		  , @dblLotQty						NUMERIC(38, 20)
		  , @dblReservedQty					NUMERIC(18, 6)
		  , @dblInputWeight2				NUMERIC(18, 6)
		  , @dblRequiredQty					NUMERIC(18, 6)
		  , @dblSwapToQty2					NUMERIC(18, 6)
		  , @intMainItemId					INT
		  , @intWorkOrderStatusId			INT
		  , @strConsumeSourceLocation		NVARCHAR(50)

	DECLARE @tblMFSwapto TABLE 
	(
		intSwapTo		INT IDENTITY(1, 1)
	  , intWorkOrderId	INT
	  , strWorkOrderNo	NVARCHAR(50)
	  , dblQty			NUMERIC(18, 6)
	);

	DECLARE @tblMFReservation TABLE 
	(
		intRecordId		INT IDENTITY(1, 1)
	  , intWorkOrderId	INT
	  , strWorkOrderNo	NVARCHAR(50)
	  , dblQty			NUMERIC(18, 6)
	);

	DECLARE @tblMFLot TABLE 
	(
		intSwapToLotId	INT
	  , dblQty			NUMERIC(38, 20)
	);

	DECLARE @tblMFPickedLot TABLE 
	(
		intLotId	INT
	  , dblQty		NUMERIC(38, 20)
	);

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @dtmCurrentDateTime = GetDate()

	EXEC sp_xml_preparedocument @idoc OUTPUT
							  , @strXML

	SELECT @intLocationId				= intLocationId
		 , @intSubLocationId			= intSubLocationId
		 , @intManufacturingProcessId	= intManufacturingProcessId
		 , @intMachineId				= intMachineId
		 , @intWorkOrderId				= intWorkOrderId
		 , @dtmPlannedDate				= dtmPlannedDate
		 , @intPlannedShiftId			= intPlannedShiftId
		 , @intItemId					= intItemId
		 , @intStorageLocationId		= intStorageLocationId
		 , @intInputLotId				= intInputLotId
		 , @intInputItemId				= intInputItemId
		 , @dblInputWeight				= dblInputWeight
		 , @dblReadingQuantity			= dblReadingQuantity
		 , @intInputWeightUOMId			= intInputWeightUOMId
		 , @intUserId					= intUserId
		 , @ysnEmptyOut					= ysnEmptyOut
		 , @intContainerId				= intContainerId
		 , @strReferenceNo				= strReferenceNo
		 , @dtmActualInputDateTime		= dtmActualInputDateTime
		 , @intShiftId					= intShiftId
		 , @ysnExcessConsumptionAllowed = ysnExcessConsumptionAllowed
		 , @dblDefaultResidueQty		= dblDefaultResidueQty
		 , @intMainItemId				= intMainItemId
	FROM OPENXML(@idoc, 'root', 2) WITH 
	(
		intLocationId				INT
	  , intSubLocationId			INT
	  , intManufacturingProcessId	INT
	  , intMachineId				INT
	  , intWorkOrderId				INT
	  , dtmPlannedDate				DATETIME
	  , intPlannedShiftId			INT
	  , intItemId					INT
	  , intStorageLocationId		INT
	  , intInputLotId				INT
	  , intInputItemId				INT
	  , dblInputWeight				NUMERIC(38, 20)
	  , dblReadingQuantity			NUMERIC(38, 20)
	  , intInputWeightUOMId			INT
	  , intUserId					INT
	  , ysnEmptyOut					BIT
	  , intContainerId				INT
	  , strReferenceNo				NVARCHAR(50)
	  , dtmActualInputDateTime		DATETIME
	  , intShiftId					INT
	  , ysnExcessConsumptionAllowed BIT
	  , dblDefaultResidueQty		NUMERIC(38, 20)
	  , intMainItemId				INT
	);

	/* Feed Time validation. */
	IF @dtmActualInputDateTime > GETDATE()
		BEGIN
			RAISERROR 
			(
				'Feed time cannot be greater than current date and time.'
			  , 14
			  , 1
			);
		END
	/* End of Feed Time validation. */


	SELECT @dblEnteredQty		= @dblInputWeight
		 , @intEnteredItemUOMId = @intInputWeightUOMId

	SELECT @strInventoryTracking		= Item.strInventoryTracking
		 , @intCategoryId				= Item.intCategoryId
		 , @intNegativeQuantityAllowed	= ItemLocation.intAllowNegativeInventory
	FROM dbo.tblICItem AS Item
	OUTER APPLY (SELECT intAllowNegativeInventory
				 FROM tblICItemLocation AS ICItemLocation
				 WHERE ICItemLocation.intItemId = Item.intItemId AND ICItemLocation.intLocationId = @intLocationId) AS ItemLocation
	WHERE Item.intItemId = @intInputItemId;

	/* Lot Tracked Validation. */
	IF @strInventoryTracking = 'Lot Level'
		BEGIN

			/* Lot validation. */
			IF @intInputLotId IS NULL OR @intInputLotId = 0
				BEGIN
					RAISERROR 
					(
						'Lot cannot be blank.'
					  , 14
					  , 1
					)
				END
			/* End of Lot validation. */

			SELECT @strLotNumber	= strLotNumber
				 , @intInputLotId	= intLotId
				 , @dblWeight		= (CASE WHEN intWeightUOMId IS NOT NULL THEN dblWeight
											ELSE dblQty
									   END)
				 , @intNewItemUOMId = intItemUOMId
				 , @dblWeightPerQty = ISNULL(NULLIF(dblWeightPerQty, 0) ,1) 
				 , @intWeightUOMId	= intWeightUOMId
				 , @dblQty			= dblQty
			FROM tblICLot
			WHERE intLotId = @intInputLotId

			IF @intNewItemUOMId <> @intInputWeightUOMId AND ISNULL(@intWeightUOMId, @intNewItemUOMId) <> @intInputWeightUOMId
				BEGIN
					SELECT @dblInputWeight = dbo.fnMFConvertQuantityToTargetItemUOM(@intInputWeightUOMId, @intNewItemUOMId, @dblInputWeight)

					SELECT @intInputWeightUOMId = @intNewItemUOMId
				END

			/* Validation of Input quantity/weight greater than lot quantity/weight. */
			IF @dblInputWeight > @dblWeight AND @intNegativeQuantityAllowed <> 1
				BEGIN
					RAISERROR 
					(
						'The quantity to be consumed must not exceed the selected lot quantity.'
						, 14
						, 1
					);
				END
			/* End of Validation of Input quantity/weight greater than lot quantity/weight. */

			/* Validation of lot if empty/null . */
			IF @intInputLotId IS NULL OR @intInputLotId = 0
				BEGIN
					RAISERROR 
					(
						'Please select a valid lot'
					  , 14
					  , 1
					);
				END
			/* End of Validation of lot if empty/null . */

			/* Validation if lot have stock . */
			IF @dblWeight <= 0 AND @intNegativeQuantityAllowed <> 1
				BEGIN
					RAISERROR 
					(
						'Lot quantity should be greater than zero.'
					  , 14
					  , 1
					)
				END
			/* End of Validation if lot have stock . */

		END
	/* End of Lot Tracked Validation. */

	SELECT TOP 1 @strWorkOrderNo		= strWorkOrderNo
			   , @intWorkOrderStatusId  = intStatusId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF @intWorkOrderId IS NULL OR @intWorkOrderId = 0
		BEGIN
			SELECT TOP 1 @intWorkOrderId = intWorkOrderId
			FROM dbo.tblMFWorkOrder
			WHERE intItemId			= @intItemId
			  AND dtmPlannedDate	= @dtmPlannedDate
			  AND intPlannedShiftId = @intPlannedShiftId
			  AND intStatusId		= 10 /* Started */
			  AND intLocationId		= @intLocationId
			ORDER BY dtmCreated

			IF @intWorkOrderId IS NULL
				BEGIN
					SELECT @strItemNo = strItemNo
					FROM dbo.tblICItem
					WHERE intItemId = @intItemId

					RAISERROR 
					(
						'No open runs / Work Order does not exists for the target item ''%s''. Cannot consume.'
					  , 14
					  , 1
					  , @strItemNo
					)
				END
		END

	/* Retrieve Producation Staging Location/Unit. */
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


	SELECT @intConsumptionMethodId			= RI.intConsumptionMethodId
		 , @intConsumptionStorageLocationId = CASE WHEN RI.intConsumptionMethodId = 1 THEN @intProductionStageLocationId
												   ELSE RI.intStorageLocationId
											  END
		 , @intItemTypeId					= CASE WHEN RS.intSubstituteItemId IS NOT NULL AND RS.intSubstituteItemId = @intInputItemId THEN 3
												   ELSE 1
											  END
	FROM dbo.tblMFWorkOrderRecipeItem RI
	LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RS ON RS.intRecipeItemId = RI.intRecipeItemId
	WHERE RI.intWorkOrderId			= @intWorkOrderId
	  AND RI.intRecipeItemTypeId	= 1 /* Input Item Recipe. */
	  AND (RI.intItemId = @intInputItemId OR RS.intSubstituteItemId = @intInputItemId)

	SELECT @intConsumptionSubLocationId = intSubLocationId
	FROM dbo.tblICStorageLocation
	WHERE intStorageLocationId = @intConsumptionStorageLocationId

	/* Validate if Input Item is part of Recipe. */
	IF @intInputItemId IS NULL OR @intInputItemId = 0
		BEGIN
			/* Recipe Item. */
			SELECT @strItemNo = strItemNo
			FROM dbo.tblICItem
			WHERE intItemId = @intItemId

			/* Recipe Item. */
			SELECT @strInputItemNo = strItemNo
			FROM dbo.tblICItem
			WHERE intItemId = @intInputItemId

			RAISERROR 
			(
				'''%s'' is not part of Recipes Input Item for ''%s'' , Cannot proceed.'
			  , 14
			  , 1
			  , @strInputItemNo
			  , @strItemNo
			)
		END
	/* End of Validate if Input Item is part of Recipe. */

	/* Validation if there is Staging Location Setup. */
	IF @intConsumptionMethodId = 1 AND (@intConsumptionStorageLocationId IS NULL OR @intConsumptionStorageLocationId = 0)
		BEGIN
			RAISERROR 
			(
				'No Staging Location setup found. Check Manufacturing Process, Machine and Storage Location.'
			  , 14
			  , 1
			)
		END
	/* End of Validation if there is Staging Location Setup. */
	
	/* Validate if Manufacturing Process is associate/part of Work Order. */
	IF NOT EXISTS (SELECT * FROM dbo.tblMFWorkOrder WHERE intWorkOrderId = @intWorkOrderId AND intManufacturingProcessId = @intManufacturingProcessId)
		BEGIN
			SELECT @strWorkOrderNo			= strWorkOrderNo
			FROM dbo.tblMFWorkOrder
			WHERE intWorkOrderId = @intWorkOrderId

			SELECT @strProcessName = strProcessName
			FROM dbo.tblMFManufacturingProcess
			WHERE intManufacturingProcessId = @intManufacturingProcessId

			RAISERROR 
			(
				'Work Order ''%s'' is not associated on the Manufacturing Process ''%s'' .'
			  , 11
			  , 1
			  , @strWorkOrderNo
			  , @strProcessName
			)
		END
	/* End of Validate if Manufacturing Process is associate/part of Work Order. */


	/* Validate if Work Order can be still process based on Status. */
	IF (@intWorkOrderStatusId = 13)
		BEGIN
			RAISERROR 
			(
				'Work Order already Completed.'
			  , 11
			  , 1
			)
		END
	ELSE IF (@intWorkOrderStatusId = 11)
		BEGIN
			RAISERROR 
			(
				'Work Order currently Paused. Please re-start the Work Order.'
			  , 11
			  , 1
			)
		END
	ELSE IF (@intWorkOrderStatusId <> 10)
		BEGIN
			RAISERROR 
			(
				'Work Order is not Started yet.'
			  , 11
			  , 1
			)
		END

	SELECT @strMultipleMachinesShareCommonStagingLocation = ISNULL(strAttributeValue, 'False')
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
	  AND intLocationId = @intLocationId
	  AND intAttributeId = 102 /* Multiple machines share common staging location. */	


	SELECT @strConsumeSourceLocation = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 124

	IF @strConsumeSourceLocation = ''
		OR @strConsumeSourceLocation IS NULL
	BEGIN
		SELECT @strConsumeSourceLocation = 'False'
	END

	SELECT @dblReservedQty = ISNULL(dblWeight, 0)
	FROM vyuMFStockReservationByWorkOrder
	WHERE intWorkOrderId <> @intWorkOrderId
	  AND intLotId		  = @intInputLotId

	/* Validate Lot by checking Stock Reservation. */
	IF @dblInputWeight > @dblWeight - @dblReservedQty AND @dblInputWeight - (@dblWeight - @dblReservedQty) > 0.1 AND @dblReservedQty > 0
		BEGIN
			SELECT @dblRequiredQty = ABS((@dblWeight - @dblReservedQty) - @dblInputWeight)

			SELECT @dblReservedQty = ISNULL(SUM(dblWeight), 0)
			FROM vyuMFStockReservationByWorkOrder
			WHERE intWorkOrderId	= @intWorkOrderId
			  AND intItemId			= @intInputItemId
			  AND intInventoryTransactionType = 9 /* Produce. */

			IF @dblReservedQty - @dblInputWeight < 0
				BEGIN
					RAISERROR 
					(
						'There is a Reservation from this Lot.'
					  , 16
					  , 1
					)

					RETURN
				END
			ELSE
				BEGIN
					WHILE @dblRequiredQty > 0
						BEGIN
							INSERT INTO @tblMFSwapto 
							(
								intWorkOrderId
							  , strWorkOrderNo
							  , dblQty
							)
							SELECT intWorkOrderId
								 , strWorkOrderNo
								 , dblQty
							FROM vyuMFStockReservationByWorkOrder
							WHERE intWorkOrderId <> @intWorkOrderId AND intLotId = @intInputLotId

							SELECT @intRecordId = MIN(intSwapTo)
							FROM @tblMFSwapto

							WHILE @intRecordId IS NOT NULL
								BEGIN
									SELECT @intSwapToWorkOrderId = NULL
										 , @strSwapToWorkOrderNo = NULL
										 , @dblSwapToQty		 = NULL

									SELECT @intSwapToWorkOrderId	= intWorkOrderId
										 , @strSwapToWorkOrderNo	= strWorkOrderNo
										 , @dblSwapToQty			= dblQty
									FROM @tblMFSwapto
									WHERE intSwapTo = @intRecordId

									IF @dblRequiredQty > @dblSwapToQty
										BEGIN
											INSERT INTO @tblMFReservation
											SELECT @intSwapToWorkOrderId
												 , @strSwapToWorkOrderNo
												 , @dblSwapToQty

											SET @dblRequiredQty = @dblRequiredQty - @dblSwapToQty
										END
									ELSE
										BEGIN
											INSERT INTO @tblMFReservation
											SELECT @intSwapToWorkOrderId
												 , @strSwapToWorkOrderNo
												 , @dblRequiredQty

											SET @dblRequiredQty = 0
										END

									IF @dblRequiredQty = 0
										BEGIN
											BREAK
										END

									SELECT @intRecordId = MIN(intSwapTo)
									FROM @tblMFSwapto
									WHERE intSwapTo > @intRecordId
								END
						END
				END
		END
		/* End of Validate Lot by checking Stock Reservation. */

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

		SELECT @intOrderHeaderId = intOrderHeaderId
		FROM tblMFStageWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @intRecordId = NULL

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblMFReservation

		/* Create Pick List and Stock Reservation. */
		WHILE @intRecordId IS NOT NULL
			BEGIN
				SELECT @intSwapToWorkOrderId	= NULL
					 , @strSwapToWorkOrderNo	= NULL
					 , @dblSwapToQty			= NULL
					 , @dblSwapToQty2			= NULL
					 , @intSwapToLotId			= NULL

				SELECT @intSwapToWorkOrderId	= intWorkOrderId
					 , @strSwapToWorkOrderNo	= strWorkOrderNo
					 , @dblSwapToQty			= dblQty
					 , @dblSwapToQty2			= dblQty
				FROM @tblMFReservation
				WHERE intRecordId = @intRecordId

				SELECT @intSwapToOrderHeaderId = intOrderHeaderId
				FROM tblMFStageWorkOrder
				WHERE intWorkOrderId = @intSwapToWorkOrderId

				SELECT @intSwapToLotId = intLotId
				FROM vyuMFStockReservationByWorkOrder
				WHERE intWorkOrderId = @intWorkOrderId
				  AND intItemId = @intInputItemId
				  AND intInventoryTransactionType = 9 /* Produce. */
				  AND dblQty = @dblSwapToQty2

				IF @intSwapToLotId IS NOT NULL AND EXISTS (SELECT *
														   FROM tblMFTask
														   WHERE intOrderHeaderId	= @intSwapToOrderHeaderId
															 AND intLotId			= @intInputLotId
															 AND dblQty				= @dblSwapToQty2
														  )
					BEGIN
						UPDATE tblMFTask
						SET intLotId = @intSwapToLotId
						WHERE intOrderHeaderId = @intSwapToOrderHeaderId AND intLotId = @intInputLotId;

						DELETE FROM tblMFTask WHERE intOrderHeaderId = @intOrderHeaderId AND intLotId = @intSwapToLotId;

						INSERT INTO @tblMFPickedLot
						SELECT @intSwapToLotId
							 , @dblSwapToQty2
					END
				ELSE
					BEGIN
						DELETE FROM @tblMFLot

						INSERT INTO @tblMFLot 
						(
							intSwapToLotId
						  , dblQty
						)
						SELECT SR.intLotId
							 , SR.dblQty - ISNULL(L.dblQty, 0)
						FROM vyuMFStockReservationByWorkOrder SR
						LEFT JOIN @tblMFPickedLot L ON L.intLotId = SR.intLotId
						WHERE SR.intWorkOrderId = @intWorkOrderId
						  AND SR.intItemId = @intInputItemId
						  AND SR.intInventoryTransactionType = 9 /* Produce. */
						  AND SR.dblQty - IsNULL(L.dblQty, 0) > 0

						SELECT @intSwapToLotId = NULL

						SELECT @intSwapToLotId = MIN(intSwapToLotId)
						FROM @tblMFLot

						/* Pick List Creation. */
						WHILE @intSwapToLotId IS NOT NULL
							BEGIN
								SELECT @dblLotQty = NULL

								SELECT @dblLotQty = dblQty
								FROM @tblMFLot
								WHERE intSwapToLotId = @intSwapToLotId

								IF @dblSwapToQty > @dblLotQty
									BEGIN
										INSERT INTO tblMFTask 
										(
											intConcurrencyId
										  , strTaskNo
										  , intTaskTypeId
										  , intTaskStateId
										  , intAssigneeId
										  , intOrderHeaderId
										  , intOrderDetailId
										  , intTaskPriorityId
										  , dtmReleaseDate
										  , intFromStorageLocationId
										  , intToStorageLocationId
										  , intItemId
										  , intLotId
										  , dblQty
										  , intItemUOMId
										  , dblWeight
										  , intWeightUOMId
										  , dblWeightPerQty
										  , intCreatedUserId
										  , dtmCreated
										  , intLastModifiedUserId
										  , dtmLastModified
										  , dblPickQty
										)
										SELECT intConcurrencyId
											 , strTaskNo
											 , intTaskTypeId
											 , intTaskStateId
											 , intAssigneeId
											 , intOrderHeaderId
											 , intOrderDetailId
											 , intTaskPriorityId
											 , dtmReleaseDate
											 , intFromStorageLocationId
											 , intToStorageLocationId
											 , intItemId
											 , @intSwapToLotId
											 , @dblLotQty
											 , intItemUOMId
											 , @dblLotQty
											 , intItemUOMId
											 , 1
											 , intCreatedUserId
											 , dtmCreated
											 , intLastModifiedUserId
											 , dtmLastModified
											 , @dblLotQty
										FROM tblMFTask
										WHERE intOrderHeaderId	= @intSwapToOrderHeaderId
										  AND intLotId			= @intInputLotId

										SELECT @dblSwapToQty = @dblSwapToQty - @dblLotQty

										UPDATE dbo.tblMFTask
										SET dblQty		= dblQty - @dblLotQty
										  , dblWeight	= (dblQty - @dblLotQty) / dblWeightPerQty
										  , dblPickQty	= dblQty - @dblLotQty
										WHERE intOrderHeaderId	= @intOrderHeaderId
										  AND intLotId			= @intSwapToLotId

										INSERT INTO @tblMFPickedLot
										SELECT @intSwapToLotId
											 , @dblLotQty
									END
								ELSE
									BEGIN
										INSERT INTO tblMFTask 
										(
											intConcurrencyId
										  , strTaskNo
										  , intTaskTypeId
										  , intTaskStateId
										  , intAssigneeId
										  , intOrderHeaderId
										  , intOrderDetailId
										  , intTaskPriorityId
										  , dtmReleaseDate
										  , intFromStorageLocationId
										  , intToStorageLocationId
										  , intItemId
										  , intLotId
										  , dblQty
										  , intItemUOMId
										  , dblWeight
										  , intWeightUOMId
										  , dblWeightPerQty
										  , intCreatedUserId
										  , dtmCreated
										  , intLastModifiedUserId
										  , dtmLastModified
										  , dblPickQty
										)
										SELECT intConcurrencyId
											 , strTaskNo
											 , intTaskTypeId
											 , intTaskStateId
											 , intAssigneeId
											 , intOrderHeaderId
											 , intOrderDetailId
											 , intTaskPriorityId
											 , dtmReleaseDate
											 , intFromStorageLocationId
											 , intToStorageLocationId
											 , intItemId
											 , @intSwapToLotId
											 , @dblSwapToQty
											 , intItemUOMId
											 , @dblSwapToQty
											 , intItemUOMId
											 , 1
											 , intCreatedUserId
											 , dtmCreated
											 , intLastModifiedUserId
											 , dtmLastModified
											 , @dblSwapToQty
										FROM dbo.tblMFTask
										WHERE intOrderHeaderId = @intSwapToOrderHeaderId
										  AND intLotId = @intInputLotId;

										UPDATE dbo.tblMFTask
										SET dblQty		= dblQty - @dblSwapToQty
										  , dblWeight	= (dblQty - @dblSwapToQty) / dblWeightPerQty
										  , dblPickQty	= dblQty - @dblSwapToQty
										WHERE intOrderHeaderId	= @intOrderHeaderId
										  AND intLotId			= @intSwapToLotId

										INSERT INTO @tblMFPickedLot
										SELECT @intSwapToLotId
											 , @dblSwapToQty

										SELECT @dblSwapToQty = 0
									END

									DELETE FROM tblMFTask WHERE intOrderHeaderId = @intOrderHeaderId AND intLotId = @intSwapToLotId AND dblQty = 0;


								IF @dblSwapToQty <= 0
									BEGIN
										IF EXISTS (SELECT *
												   FROM dbo.tblMFTask
												   WHERE intOrderHeaderId = @intSwapToOrderHeaderId
												   	 AND intLotId		  = @intInputLotId
												   	 AND dblQty			  = @dblSwapToQty2
												  )
											BEGIN
												DELETE FROM dbo.tblMFTask WHERE intOrderHeaderId = @intSwapToOrderHeaderId AND intLotId = @intInputLotId;
											END
										ELSE
											BEGIN
												UPDATE dbo.tblMFTask
												SET dblQty		= dblQty - @dblSwapToQty2
												  , dblWeight	= (dblQty - @dblSwapToQty2) / dblWeightPerQty
												  , dblPickQty	= dblQty - @dblSwapToQty2
												WHERE intOrderHeaderId = @intSwapToOrderHeaderId
												  AND intLotId = @intInputLotId
											END
										BREAK
									END

									SELECT @intSwapToLotId = MIN(intSwapToLotId)
									FROM @tblMFLot
									WHERE intSwapToLotId > @intSwapToLotId
							END
					END

				EXEC dbo.uspICCreateStockReservation @ItemsToReserve			= @ItemsToReserve
												   , @intTransactionId			= @intSwapToWorkOrderId
												   , @intTransactionTypeId		= 9


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
				SELECT intItemId			= T.intItemId
					 , intItemLocationId	= IL.intItemLocationId
					 , intItemUOMId			= T.intItemUOMId
					 , intLotId				= T.intLotId
					 , intSubLocationId		= SL.intSubLocationId
					 , intStorageLocationId = NULL --We need to set this to NULL otherwise available Qty becomes zero in the inventoryshipment screen
					 , dblQty				= T.dblPickQty
					 , intTransactionId		= @intSwapToWorkOrderId
					 , strTransactionId		= @strSwapToWorkOrderNo
					 , intTransactionTypeId = 9
				FROM tblMFTask T
				JOIN tblICStorageLocation SL ON SL.intStorageLocationId = T.intFromStorageLocationId
				JOIN tblICItemLocation IL ON IL.intItemId = T.intItemId AND IL.intLocationId = SL.intLocationId
				WHERE T.intOrderHeaderId = @intSwapToOrderHeaderId
					AND T.intTaskStateId = 4

				EXEC dbo.uspICCreateStockReservation @ItemsToReserve			= @ItemsToReserve
												   , @intTransactionId			= @intSwapToWorkOrderId
												   , @intTransactionTypeId		= 9

				DELETE FROM @ItemsToReserve;

				SELECT @intRecordId = MIN(intRecordId)
				FROM @tblMFReservation
				WHERE intRecordId > @intRecordId
			END
		/* End of Create Pick List and Stock Reservation. */

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDateTime, @intLocationId)

	SELECT @intBusinessShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
	  AND @dtmCurrentDateTime BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset;

	/* Insertion of Work Order Input Lot/Staging. */
	INSERT INTO dbo.tblMFWorkOrderInputLot 
	(
		intWorkOrderId
	  , intItemId
	  , intLotId
	  , dblQuantity
	  , intItemUOMId
	  , dblIssuedQuantity
	  , intItemIssuedUOMId
	  , intSequenceNo
	  , dtmProductionDate
	  , intShiftId
	  , intStorageLocationId
	  , intMachineId
	  , ysnConsumptionReversed
	  , intContainerId
	  , strReferenceNo
	  , dtmActualInputDateTime
	  , dtmBusinessDate
	  , intBusinessShiftId
	  , dtmCreated
	  , intCreatedUserId
	  , dtmLastModified
	  , intLastModifiedUserId
	  , dblEnteredQty
	  , intEnteredItemUOMId
	  , intMainItemId
	  , dblLotQuantity
	)
	SELECT @intWorkOrderId
		 , @intInputItemId
		 , @intInputLotId
		 , CASE WHEN @intInputWeightUOMId = ISNULL(@intNewItemUOMId, 0) THEN @dblInputWeight * @dblWeightPerQty
				ELSE @dblInputWeight
		   END
		 , ISNULL(ISNULL(@intWeightUOMId, @intNewItemUOMId), @intInputWeightUOMId)
		 , @dblInputWeight
		 , @intInputWeightUOMId
		 , 1
		 , @dtmPlannedDate
		 , @intPlannedShiftId
		 , @intStorageLocationId
		 , @intMachineId
		 , 0
		 , @intContainerId
		 , @strReferenceNo
		 , @dtmActualInputDateTime
		 , @dtmBusinessDate
		 , @intBusinessShiftId
		 , @dtmCurrentDateTime
		 , @intUserId
		 , @dtmCurrentDateTime
		 , @intUserId
		 , @dblEnteredQty
		 , @intEnteredItemUOMId
		 , @intMainItemId
		 , CASE WHEN @dblInputWeight > @dblWeight AND @dblWeight > 0 THEN @dblWeight
				ELSE @dblInputWeight
		   END

	SELECT @intWorkOrderInputLotId = SCOPE_IDENTITY()

	/* Lot Tracked Inventory Adjusment. */
	IF @strInventoryTracking = 'Lot Level' AND @strConsumeSourceLocation = 'False'
		BEGIN
			SET @dblNewWeight = CASE WHEN @intNegativeQuantityAllowed = 1 THEN @dblInputWeight
									 WHEN @ysnEmptyOut = 0 AND @dblInputWeight >= @dblWeight THEN @dblWeight + @dblDefaultResidueQty
									 ELSE @dblInputWeight
								END;

			IF @dblNewWeight > @dblWeight
				BEGIN
					/* Validation of Input quantity/weight greater than lot quantity/weight. */
					IF @dblInputWeight > @dblWeight AND @intNegativeQuantityAllowed <> 1
						BEGIN
							RAISERROR 
							(
								'The quantity to be consumed must not exceed the selected lot quantity.'
								, 14
								, 1
							);
						END

					SELECT @dblAdjustByQuantity = @dblNewWeight - @dblWeight

					/* Use Inventory Adjustment for Allowed Negative Inventory = Yes and if the Input Lot Quantity is greater than On Hand Stock. 
					 * Adjust Quantity excess Stage.
					 */
					EXEC [uspICInventoryAdjustment_CreatePostQtyChange] @intItemId					= @intInputItemId
																	  , @dtmDate					= NULL
																	  , @intLocationId				= @intLocationId
																	  , @intSubLocationId			= @intSubLocationId
																	  , @intStorageLocationId		= @intStorageLocationId
																	  , @strLotNumber				= @strLotNumber
																	  -- Parameters for the new values: 
																	  , @dblAdjustByQuantity		= @dblAdjustByQuantity
																	  , @dblNewUnitCost				= NULL
																	  , @intItemUOMId				= @intInputWeightUOMId
																	  -- Parameters used for linking or FK (foreign key) relationships
																	  , @intSourceId				= @intWorkOrderId
																	  , @intSourceTransactionTypeId = 8
																	  , @intEntityUserSecurityId	= @intUserId
																	  , @intInventoryAdjustmentId	= @intInventoryAdjustmentId OUTPUT
																	  , @strDescription				= @strWorkOrderNo

					INSERT INTO dbo.tblMFWorkOrderProducedLotTransaction 
					(
						intWorkOrderId
					  , intLotId
					  , dblQuantity
					  , intItemUOMId
					  , intItemId
					  , intTransactionId
					  , intTransactionTypeId
					  , strTransactionType
					  , dtmTransactionDate
					  , intProcessId
					  , intShiftId
					)
					SELECT TOP 1 WI.intWorkOrderId
							   , WI.intLotId
							   , @dblNewWeight - @dblWeight
							   , WI.intItemUOMId
							   , WI.intItemId
							   , @intInventoryAdjustmentId
							   , 24
							   , 'Empty Out Adj'
							   , @dtmBusinessDate
							   , intManufacturingProcessId
							   , @intBusinessShiftId
					FROM dbo.tblMFWorkOrderInputLot WI
					JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WI.intWorkOrderId
					WHERE intLotId = @intInputLotId
				END

			IF @dblWeightPerQty = 0 OR @dblNewWeight % @dblWeightPerQty > 0
				BEGIN
					SELECT @dblAdjustByQuantity = - @dblNewWeight
						 , @intAdjustItemUOMId	= @intInputWeightUOMId
				END
			ELSE
				BEGIN
					SELECT @dblAdjustByQuantity = -@dblNewWeight / @dblWeightPerQty
						 , @intAdjustItemUOMId	= @intNewItemUOMId
				END

			/* Used IA - Lot Merge for Lot Tracked. */
			EXEC uspICInventoryAdjustment_CreatePostLotMerge @intItemId						= @intInputItemId
														   , @dtmDate						= NULL
														   , @intLocationId					= @intLocationId
														   , @intSubLocationId				= @intSubLocationId
														   , @intStorageLocationId			= @intStorageLocationId
														   , @strLotNumber					= @strLotNumber
														   -- Parameters for the new values: 
														   , @intNewLocationId				= @intLocationId
														   , @intNewSubLocationId			= @intConsumptionSubLocationId
														   , @intNewStorageLocationId		= @intConsumptionStorageLocationId
														   , @strNewLotNumber				= @strLotNumber
														   , @dblAdjustByQuantity			= @dblAdjustByQuantity
														   , @dblNewSplitLotQuantity		= NULL
														   , @dblNewWeight					= NULL
														   , @intNewItemUOMId				= NULL --New Item UOM Id should be NULL as per Feb
														   , @intNewWeightUOMId				= NULL
														   , @dblNewUnitCost				= NULL
														   , @intItemUOMId					= @intAdjustItemUOMId
														   -- Parameters used for linking or FK (foreign key) relationships
														   , @intSourceId					= @intWorkOrderId
														   , @intSourceTransactionTypeId	= 8
														   , @intEntityUserSecurityId		= @intUserId
														   , @intInventoryAdjustmentId		= @intInventoryAdjustmentId OUTPUT
														   , @strDescription				= @strWorkOrderNo
		END
		/* End of Lot Tracked Inventory Adjusment. */

	/* Item Level Inventory Transfer. */
	IF @strInventoryTracking = 'Item Level'
		BEGIN
			SELECT @intItemStockUOMId = intItemUOMId
			FROM tblICItemUOM
			WHERE intItemId = @intInputItemId AND ysnStockUnit = 1

			IF @intItemStockUOMId <> @intInputWeightUOMId
				BEGIN
					SELECT @dblInputWeight = dbo.fnMFConvertQuantityToTargetItemUOM(@intInputWeightUOMId, @intItemStockUOMId, @dblInputWeight)

					SELECT @intInputWeightUOMId = @intItemStockUOMId
				END

			/* Create Temp Table. */
			IF NOT EXISTS ( SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddInventoryTransferResult'))
				BEGIN
					CREATE TABLE #tmpAddInventoryTransferResult 
					(
						intSourceId				INT
					  , intInventoryTransferId	INT
					)
				END
			/* End of Create Temp Table. */

			DECLARE @TransferEntries AS InventoryTransferStagingTable


			/* Staging Data fro Inventory Transfer. */
			INSERT INTO @TransferEntries 
			(
				/* Header Data. */
				[dtmTransferDate]
			  , [strTransferType]
			  , [intSourceType]
			  , [strDescription]
			  , [intFromLocationId]
			  , [intToLocationId]
			  , [ysnShipmentRequired]
			  , [intStatusId]
			  , [intShipViaId]
			  , [intFreightUOMId]
				/* Detail Data. */
			  , [intItemId]
			  , [intLotId]
			  , [intItemUOMId]
			  , [dblQuantityToTransfer]
			  , [strNewLotId]
			  , [intFromSubLocationId]
			  , [intToSubLocationId]
			  , [intFromStorageLocationId]
			  , [intToStorageLocationId]
				/* Integration Data. */
			  , [intInventoryTransferId]
			  , [intSourceId]
			  , [strSourceId]
			  , [strSourceScreenName]
			)
			SELECT [dtmTransferDate]			= @dtmPlannedDate
				 , [strTransferType]			= 'Storage to Storage'
				 , [intSourceType]				= 0
				 , [strDescription]				= NULL
				 , [intFromLocationId]			= @intLocationId
				 , [intToLocationId]			= @intLocationId
				 , [ysnShipmentRequired]		= 0
				 , [intStatusId]				= 3 /* Closed. */
				 , [intShipViaId]				= NULL
				 , [intFreightUOMId]			= NULL
				   /* Detail Data. */
				 , [intItemId]					= @intInputItemId
				 , [intLotId]					= NULL
				 , [intItemUOMId]				= @intInputWeightUOMId
				 , [dblQuantityToTransfer]		= @dblInputWeight
				 , [strNewLotId]				= NULL
				 , [intFromSubLocationId]		= @intSubLocationId
				 , [intToSubLocationId]			= @intConsumptionSubLocationId
				 , [intFromStorageLocationId]	= @intStorageLocationId
				 , [intToStorageLocationId]		= @intConsumptionStorageLocationId
					/* Integration Data. */
				 , [intInventoryTransferId]		= NULL
				 , [intSourceId]				= @intWorkOrderInputLotId
				 , [strSourceId]				= @strWorkOrderNo
				 , [strSourceScreenName]		= 'Process Production Consume'

			-- Call uspICAddInventoryTransfer stored procedure.
			EXEC dbo.uspICAddInventoryTransfer @TransferEntries			= @TransferEntries
											 , @intEntityUserSecurityId = @intUserId

			-- Post the Inventory Transfers                                            
			DECLARE @intTransferId		INT
				  , @strTransactionId	NVARCHAR(50);

			WHILE EXISTS (SELECT TOP 1 1 FROM #tmpAddInventoryTransferResult)
				BEGIN
					SELECT @intTransferId		= NULL
						 , @strTransactionId	= NULL

					SELECT TOP 1 @intTransferId = intInventoryTransferId
					FROM #tmpAddInventoryTransferResult

					-- Post the Inventory Transfer that was created
					SELECT @strTransactionId = strTransferNo
					FROM tblICInventoryTransfer
					WHERE intInventoryTransferId = @intTransferId

					EXEC dbo.uspICPostInventoryTransfer @ysnPost				 = 1
													  , @ysnRecap				 = 0
													  , @strTransactionId		 = @strTransactionId
													  , @intEntityUserSecurityId = @intUserId;

					DELETE FROM #tmpAddInventoryTransferResult WHERE intInventoryTransferId = @intTransferId;
				END;
		END
		/* End of Item Level Inventory Transfer. */

	SELECT @intRecipeItemUOMId = RI.intItemUOMId
	FROM tblMFWorkOrderRecipeItem RI
	WHERE RI.intWorkOrderId = @intWorkOrderId AND RI.intItemId = @intInputItemId AND RI.intRecipeItemTypeId = 1

	IF @intRecipeItemUOMId IS NULL
		BEGIN
			SELECT @intRecipeItemUOMId = RS.intItemUOMId
			FROM tblMFWorkOrderRecipeSubstituteItem RS
			WHERE RS.intWorkOrderId = @intWorkOrderId AND RS.intSubstituteItemId = @intInputItemId
		END

	IF @strMultipleMachinesShareCommonStagingLocation = 'True'
		BEGIN
			SELECT @intMachineId = NULL
		END

	/* Set Production Summary Item. */
	IF @intMainItemId IS NOT NULL
		BEGIN
			UPDATE tblMFProductionSummary
			SET intMainItemId = @intMainItemId
			WHERE intWorkOrderId	= @intWorkOrderId
				AND intItemId		= @intInputItemId
				AND ISNULL(intMachineId, 0) = (CASE WHEN intMachineId IS NOT NULL THEN ISNULL(@intMachineId, 0)
													ELSE ISNULL(intMachineId, 0)
											   END)
				AND intItemTypeId IN (1, 3)
				AND intMainItemId IS NULL
		END

	/* Create Production Summary if not extists, Update if exists. */
	IF NOT EXISTS (SELECT * 
				   FROM tblMFProductionSummary 
				   WHERE intWorkOrderId		= @intWorkOrderId
					 AND intItemId			= @intInputItemId
					 AND ISNULL(intMachineId, 0) = (CASE WHEN intMachineId IS NOT NULL THEN ISNULL(@intMachineId, 0)
														 ELSE ISNULL(intMachineId, 0)
													END)
					 AND intItemTypeId IN (1, 3)
					 AND ISNULL(intMainItemId, ISNULL(@intMainItemId, 0)) = ISNULL(@intMainItemId, 0)
				  )
		BEGIN
			INSERT INTO tblMFProductionSummary 
			(
				intWorkOrderId
			  , intItemId
			  , dblOpeningQuantity
			  , dblOpeningOutputQuantity
			  , dblOpeningConversionQuantity
			  , dblInputQuantity
			  , dblConsumedQuantity
			  , dblOutputQuantity
			  , dblOutputConversionQuantity
			  , dblCountQuantity
			  , dblCountOutputQuantity
			  , dblCountConversionQuantity
			  , dblCalculatedQuantity
			  , intCategoryId
			  , intItemTypeId
			  , intMachineId
			  , intMainItemId
			)
			SELECT @intWorkOrderId
				 , @intInputItemId
				 , 0
				 , 0
				 , 0
				 , dbo.fnMFConvertQuantityToTargetItemUOM(@intInputWeightUOMId, @intRecipeItemUOMId, @dblInputWeight)
				 , 0
				 , 0
				 , 0
				 , 0
				 , 0
				 , 0
				 , 0
				 , @intCategoryId
				 , @intItemTypeId
				 , @intMachineId
				 , @intMainItemId
		END
	ELSE
		BEGIN
			UPDATE tblMFProductionSummary
			SET dblInputQuantity = ISNULL(dblInputQuantity, 0) + ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(@intInputWeightUOMId, @intRecipeItemUOMId, @dblInputWeight), 0)
			WHERE intWorkOrderId = @intWorkOrderId
				AND intItemId = @intInputItemId
				AND ISNULL(intMachineId, 0) = (CASE WHEN intMachineId IS NOT NULL THEN ISNULL(@intMachineId, 0)
													ELSE ISNULL(intMachineId, 0)
											   END)
				AND intItemTypeId IN (1, 3)
				AND ISNULL(intMainItemId, ISNULL(@intMainItemId, 0)) = ISNULL(@intMainItemId, 0)
		END
	/* End of Create Production Summary if not extists, Update if exists. */
	
	DELETE FROM @ItemsToReserve

	EXEC dbo.uspICCreateStockReservation @ItemsToReserve			= @ItemsToReserve
										, @intTransactionId			= @intWorkOrderId
										, @intTransactionTypeId		= 9

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
	SELECT intItemId			= T.intItemId
			, intItemLocationId	= IL.intItemLocationId
			, intItemUOMId			= T.intItemUOMId
			, intLotId				= T.intLotId
			, intSubLocationId		= SL.intSubLocationId
			, intStorageLocationId = NULL --We need to set this to NULL otherwise available Qty becomes zero in the inventoryshipment screen
			, dblQty				= T.dblPickQty
			, intTransactionId		= @intWorkOrderId
			, strTransactionId		= @strWorkOrderNo
			, intTransactionTypeId = 9 /* Produce. */
	FROM tblMFTask T
	JOIN tblICStorageLocation SL ON SL.intStorageLocationId = T.intFromStorageLocationId
	JOIN tblICItemLocation IL ON IL.intItemId = T.intItemId AND IL.intLocationId = SL.intLocationId
	WHERE T.intOrderHeaderId = @intOrderHeaderId
		AND T.intTaskStateId = 4 /* COMPLETED */

	EXEC dbo.uspICCreateStockReservation @ItemsToReserve			= @ItemsToReserve
										, @intTransactionId			= @intWorkOrderId
										, @intTransactionTypeId		= 9

	DELETE FROM @ItemsToReserve

	EXEC dbo.uspICCreateStockReservation @ItemsToReserve			= @ItemsToReserve
									   , @intTransactionId			= @intWorkOrderId
									   , @intTransactionTypeId		= @intInventoryTransactionType

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
		 , intLotId				= (SELECT TOP 1 intLotId
								   FROM tblICLot L1
								   WHERE L1.strLotNumber = L.strLotNumber AND L1.intStorageLocationId = @intConsumptionStorageLocationId
								  )
		 , intSubLocationId		= @intConsumptionSubLocationId
		 , intStorageLocationId = @intConsumptionStorageLocationId
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

	
	EXEC dbo.uspICCreateStockReservation @ItemsToReserve			= @ItemsToReserve
									   , @intTransactionId			= @intWorkOrderId
									   , @intTransactionTypeId		= @intInventoryTransactionType	

	SELECT @intDestinationLotId = intLotId
	FROM tblICLot L
	WHERE L.strLotNumber = @strLotNumber AND L.intStorageLocationId = @intConsumptionStorageLocationId;

	UPDATE tblMFWorkOrderInputLot
	SET intDestinationLotId = @intDestinationLotId
	WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId

	EXEC dbo.uspMFAdjustInventory @dtmDate						= @dtmPlannedDate
								, @intTransactionTypeId			= 104 --Stage
								, @intItemId					= @intInputItemId
								, @intSourceLotId				= @intInputLotId
								, @intDestinationLotId			= @intDestinationLotId
								, @dblQty						= @dblInputWeight
								, @intItemUOMId					= @intInputWeightUOMId
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
								, @intDestinationStorageLocationId = @intConsumptionStorageLocationId
								, @intWorkOrderInputLotId		= @intWorkOrderInputLotId
								, @intWorkOrderProducedLotId	= NULL
								, @intWorkOrderId				= @intWorkOrderId

	IF @intTransactionCount = 0
		BEGIN
			COMMIT TRANSACTION
		END

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