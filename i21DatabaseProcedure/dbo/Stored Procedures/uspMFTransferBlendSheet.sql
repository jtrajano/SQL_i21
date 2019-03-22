CREATE PROCEDURE [dbo].[uspMFTransferBlendSheet] @strWorkOrderIds NVARCHAR(max)
	,@intLoggedOnLocationId INT
	,@intDestinationLocationId INT
	,@intDestinationCellId INT
	,@intDestinationStagingLocationId INT
	,@intUserId INT
AS
BEGIN TRY
	DECLARE @intSourceLocationId INT
	DECLARE @intLotId INT
	DECLARE @intNewSubLocationId INT
	DECLARE @strLotNumber NVARCHAR(50)
	DECLARE @intNewLotId INT
	DECLARE @intBlendItemId INT
	DECLARE @strBlendItemNo NVARCHAR(50)
	DECLARE @intItemId INT
	DECLARE @ErrMsg NVARCHAR(max)
	DECLARE @intMinWorkOrder INT
	DECLARE @intMinConsumedLot INT
	DECLARE @intWorkOrderId INT
	DECLARE @intParentLotId INT
	DECLARE @intWorkOrderConsumedLotId INT
	DECLARE @dblQuantity NUMERIC(18, 6)
	DECLARE @dtmCurrentDateTime DATETIME = GETDATE()
	DECLARE @index INT
	DECLARE @id INT
	DECLARE @strWorkOrderNo NVARCHAR(50)
	DECLARE @intStatusId INT
		,@intItemUOMId INT
	DECLARE @ItemsToReserve AS dbo.ItemReservationTableType
	DECLARE @tblWorkOrder TABLE (
		intRowNo INT Identity(1, 1)
		,intWorkOrderId INT
		)
	DECLARE @tblConsumedLot TABLE (
		intRowNo INT Identity(1, 1)
		,intWorkOrderConsumedLotId INT
		,intLotId INT
		,intItemId INT
		,dblQuantity NUMERIC(18, 6)
		,intItemUOMId INT
		)

	--Get the Comma Separated Work Order Ids into a table
	SET @index = CharIndex(',', @strWorkOrderIds)

	WHILE @index > 0
	BEGIN
		SET @id = SUBSTRING(@strWorkOrderIds, 1, @index - 1)
		SET @strWorkOrderIds = SUBSTRING(@strWorkOrderIds, @index + 1, LEN(@strWorkOrderIds) - @index)

		INSERT INTO @tblWorkOrder (intWorkOrderId)
		VALUES (@id)

		SET @index = CharIndex(',', @strWorkOrderIds)
	END

	SET @id = @strWorkOrderIds

	INSERT INTO @tblWorkOrder (intWorkOrderId)
	VALUES (@id)

	SELECT @intNewSubLocationId = intSubLocationId
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intDestinationStagingLocationId

	SELECT @intMinWorkOrder = Min(intRowNo)
	FROM @tblWorkOrder

	WHILE (@intMinWorkOrder IS NOT NULL) --Loop WorkOrders
	BEGIN
		BEGIN TRY
			SELECT @intWorkOrderId = w.intWorkOrderId
				,@strWorkOrderNo = w.strWorkOrderNo
				,@intStatusId = w.intStatusId
				,@intSourceLocationId = w.intLocationId
				,@intBlendItemId = w.intItemId
				,@strBlendItemNo = i.strItemNo
			FROM @tblWorkOrder tw
			JOIN tblMFWorkOrder w ON tw.intWorkOrderId = w.intWorkOrderId
			JOIN tblICItem i ON w.intItemId = i.intItemId
			WHERE intRowNo = @intMinWorkOrder

			DELETE
			FROM @ItemsToReserve

			INSERT INTO @ItemsToReserve (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,intLotId
				,intSubLocationId
				,intStorageLocationId
				,dblQty
				,intTransactionId
				,strTransactionId
				,intTransactionTypeId
				)
			SELECT SR.intItemId
				,SR.intItemLocationId
				,SR.intItemUOMId
				,SR.intLotId
				,SR.intSubLocationId
				,SR.intStorageLocationId
				,SR.dblQty
				,SR.intTransactionId
				,SR.strTransactionId
				,SR.intInventoryTransactionType
			FROM tblICStockReservation SR
			WHERE intTransactionId = @intWorkOrderId
				AND intInventoryTransactionType = 8

			--Validate Transfer
			IF @intStatusId <> 9
			BEGIN
				SET @ErrMsg = 'Blend sheet ''' + @strWorkOrderNo + ''' transfer cannot be performed, since it is already started.'

				RAISERROR (
						@ErrMsg
						,16
						,1
						)
			END

			IF EXISTS (
					SELECT 1
					FROM tblMFRecipe r
					JOIN tblMFRecipeItem ri ON r.intRecipeId = ri.intRecipeId
						AND r.ysnActive = 1
						AND r.intLocationId = @intSourceLocationId
						AND r.intItemId = @intBlendItemId
						AND ri.intItemId NOT IN (
							SELECT ri1.intItemId
							FROM tblMFRecipe r1
							JOIN tblMFRecipeItem ri1 ON r1.intRecipeId = ri1.intRecipeId
								AND r1.ysnActive = 1
								AND r1.intLocationId = @intDestinationLocationId
								AND r1.intItemId = @intBlendItemId
							)
					)
			BEGIN
				SET @ErrMsg = 'The Input Item(s) configured in the recipe for the Blend ''' + @strBlendItemNo + ''' is not same as the recipe configured in the destination location.'

				RAISERROR (
						@ErrMsg
						,16
						,1
						)
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tblMFRecipe
					WHERE intItemId = @intBlendItemId
						AND intLocationId = @intDestinationLocationId
						AND ysnActive = 1
					)
			BEGIN
				SET @ErrMsg = 'The item ' + @strBlendItemNo + ' is not configured in the receipe configuration for the destination location. Please configure this item in Recipe configuration to proceed.'

				RAISERROR (
						@ErrMsg
						,16
						,1
						)
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tblICItemFactoryManufacturingCell fc
					JOIN tblICItemFactory il ON fc.intItemFactoryId = il.intItemFactoryId
					WHERE il.intFactoryId = @intDestinationLocationId
						AND il.intItemId = @intBlendItemId
						AND fc.intManufacturingCellId = @intDestinationCellId
					)
			BEGIN
				SET @ErrMsg = 'The item ' + @strBlendItemNo + ' is not configured for the selected production line.'

				RAISERROR (
						@ErrMsg
						,16
						,1
						)
			END

			--Get the consumed Lots for the workorder
			DELETE
			FROM @tblConsumedLot

			INSERT INTO @tblConsumedLot (
				intWorkOrderConsumedLotId
				,intLotId
				,intItemId
				,dblQuantity
				,intItemUOMId
				)
			SELECT wc.intWorkOrderConsumedLotId
				,wc.intLotId
				,wc.intItemId
				,wc.dblQuantity
				,wc.intItemUOMId
			FROM tblMFWorkOrderConsumedLot wc
			WHERE wc.intWorkOrderId = @intWorkOrderId

			SELECT @intMinConsumedLot = Min(intRowNo)
			FROM @tblConsumedLot

			BEGIN TRAN

			UPDATE tblMFWorkOrder
			SET intLocationId = @intDestinationLocationId
				,intManufacturingCellId = @intDestinationCellId
			WHERE intWorkOrderId = @intWorkOrderId

			UPDATE tblMFWorkOrderRecipe
			SET intLocationId = @intDestinationLocationId
			WHERE intWorkOrderId = @intWorkOrderId

			WHILE (@intMinConsumedLot IS NOT NULL) --Loop WO Consumed Lots
			BEGIN
				SELECT @intWorkOrderConsumedLotId = intWorkOrderConsumedLotId
					,@intLotId = intLotId
					,@intItemId = intItemId
					,@dblQuantity = dblQuantity
					,@intItemUOMId = intItemUOMId
				FROM @tblConsumedLot
				WHERE intRowNo = @intMinConsumedLot

				EXEC [uspMFLotMove] @intLotId = @intLotId
					,@intNewSubLocationId = @intNewSubLocationId
					,@intNewStorageLocationId = @intDestinationStagingLocationId
					,@dblMoveQty = @dblQuantity
					,@intMoveItemUOMId = @intItemUOMId
					,@intUserId = @intUserId

				SELECT TOP 1 @intNewLotId = intLotId
				FROM tblICLot
				WHERE strLotNumber = @strLotNumber
					AND intItemId = @intItemId
					AND intLocationId = @intDestinationLocationId
					AND intSubLocationId = @intNewSubLocationId
					AND intStorageLocationId = @intDestinationStagingLocationId --And dblQty > 0

				UPDATE tblMFWorkOrderConsumedLot
				SET intLotId = @intNewLotId
					,dtmLastModified = @dtmCurrentDateTime
					,intLastModifiedUserId = @intUserId
				WHERE intWorkOrderConsumedLotId = @intWorkOrderConsumedLotId

				UPDATE tblMFWorkOrder
				SET intLastModifiedUserId = @intUserId
					,dtmLastModified = @dtmCurrentDateTime
					,intStagingLocationId = @intDestinationStagingLocationId
					,dtmStagedDate = @dtmCurrentDateTime
				WHERE intWorkOrderId = @intWorkOrderId

				UPDATE @ItemsToReserve
				SET intLotId = @intNewLotId
					,intStorageLocationId = @intDestinationStagingLocationId
					,intSubLocationId = @intNewSubLocationId
				WHERE intLotId = @intLotId

				SELECT @intMinConsumedLot = Min(intRowNo)
				FROM @tblConsumedLot
				WHERE intRowNo > @intMinConsumedLot
			END --Loop WO Consumed Lots End

			EXEC dbo.uspICCreateStockReservation @ItemsToReserve = @ItemsToReserve
				,@intTransactionId = @intWorkOrderId
				,@intInventoryTransactionType = 8

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()

			RAISERROR (
					@ErrMsg
					,16
					,1
					,'WITH NOWAIT'
					)
		END CATCH

		SELECT @intMinWorkOrder = Min(intRowNo)
		FROM @tblWorkOrder
		WHERE intRowNo > @intMinWorkOrder
	END --Loop WorkOrders End
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
