CREATE PROCEDURE uspLGSplitPickedLotBatch @intPickLotDetailId INT
	,@intEntityUserSecurityId INT
	,@dblNewPickedQty NUMERIC(18, 6)
AS
BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @dblPickedQty NUMERIC(18, 6)
	DECLARE @dblOldPickedQty NUMERIC(18, 6)
	DECLARE @strNewPickLotNumber NVARCHAR(100)
	DECLARE @intPickLotHeaderId INT
	DECLARE @intPickLotTransactionType AS INT
	DECLARE @ReservationToClear AS ItemReservationTableType
	DECLARE @intPickedLotId INT
	DECLARE @intNewPickLotHeaderId INT
	DECLARE @intPickLotDetailCount INT
	DECLARE @intItemId INT

	SELECT TOP 1 @intPickLotTransactionType = intTransactionTypeId
	FROM dbo.tblICInventoryTransactionType
	WHERE strName = 'Pick Lots'

	SELECT @intPickLotHeaderId = intPickLotHeaderId
		  ,@intPickedLotId = intLotId
		  ,@dblOldPickedQty = dblLotPickedQty
	FROM tblLGPickLotDetail
	WHERE intPickLotDetailId = @intPickLotDetailId

	SELECT @intItemId = intItemId
	FROM tblICLot
	WHERE intLotId = @intPickedLotId
	
	IF (@dblNewPickedQty = @dblOldPickedQty)
	BEGIN
		RAISERROR ('Old and new qty are same. Cannot split.',16,1)
	END

	IF EXISTS (SELECT TOP 1 1
			   FROM tblLGStockSalesHeader SSH
			   JOIN tblLGPickLotDetail PLD ON PLD.intPickLotHeaderId = SSH.intPickLotHeaderId
			   WHERE PLD.intPickLotDetailId = @intPickLotDetailId)
	BEGIN
		RAISERROR ('Pick lot batch was created from stock sale. Cannot split.',16,1)
	END

	IF (@dblOldPickedQty - @dblNewPickedQty < = 0.00 )
		RETURN;

	IF (@dblNewPickedQty > @dblOldPickedQty)
	BEGIN
		RAISERROR ('Split qty cannot be greater than original picked qty.',16,1)
	END

	IF EXISTS(SELECT TOP 1 1 FROM tblLGLoadDetail WHERE intPickLotDetailId = @intPickLotDetailId)
	BEGIN
		RAISERROR('Load Schedule has been created for the selected picked lot. Cannot split.',16,1)
	ENd

	BEGIN TRANSACTION

	EXEC uspSMGetStartingNumber 49
		,@strNewPickLotNumber OUT

	IF (@dblNewPickedQty = 0.00)
	BEGIN
		INSERT INTO tblLGPickLotHeader (
			intConcurrencyId
			,strPickLotNumber
			,dtmPickDate
			,intCustomerEntityId
			,intCompanyLocationId
			,intCommodityId
			,intSubLocationId
			,intWeightUnitMeasureId
			,intUserSecurityId
			,intDeliveryHeaderId
			,intParentPickLotHeaderId
			)
		SELECT intConcurrencyId
			,@strNewPickLotNumber
			,dtmPickDate
			,intCustomerEntityId
			,intCompanyLocationId
			,intCommodityId
			,intSubLocationId
			,intWeightUnitMeasureId
			,intUserSecurityId
			,intDeliveryHeaderId
			,@intPickLotHeaderId
		FROM tblLGPickLotHeader
		WHERE intPickLotHeaderId = @intPickLotHeaderId

		SELECT @intNewPickLotHeaderId = SCOPE_IDENTITY()

		INSERT INTO tblLGPickLotDetail (
			intConcurrencyId
			,intPickLotHeaderId
			,intAllocationDetailId
			,intLotId
			,dblSalePickedQty
			,dblLotPickedQty
			,intSaleUnitMeasureId
			,intLotUnitMeasureId
			,dblGrossWt
			,dblTareWt
			,dblNetWt
			,intWeightUnitMeasureId
			,dtmPickedDate
			,intUserSecurityId
			,strComments
			)
		SELECT intConcurrencyId
			,@intNewPickLotHeaderId
			,intAllocationDetailId
			,intLotId
			,dblSalePickedQty
			,dblLotPickedQty
			,intSaleUnitMeasureId
			,intLotUnitMeasureId
			,dblGrossWt
			,dblTareWt
			,dblNetWt
			,intWeightUnitMeasureId
			,dtmPickedDate
			,intUserSecurityId
			,strComments
		FROM tblLGPickLotDetail
		WHERE intPickLotDetailId = @intPickLotDetailId

		IF EXISTS (
				SELECT TOP 1 1
				FROM dbo.tblICStockReservation Reservations
				WHERE intTransactionId = @intPickLotHeaderId
					AND intInventoryTransactionType = @intPickLotTransactionType
				)
		BEGIN
			INSERT INTO @ReservationToClear (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,intLotId
				,dblQty
				,intTransactionId
				,strTransactionId
				,intTransactionTypeId
				,intSubLocationId
				,intStorageLocationId
				)
			SELECT intItemId
				,intItemLocationId
				,intItemUOMId
				,intLotId
				,dblQty * - 1 -- Negate the qty to reduce the reserved qty. 
				,intTransactionId
				,strTransactionId
				,intInventoryTransactionType
				,intSubLocationId
				,intStorageLocationId
			FROM dbo.tblICStockReservation Reservations
			WHERE intTransactionId = @intPickLotHeaderId
				AND intInventoryTransactionType = @intPickLotTransactionType
				AND intLotId = @intPickedLotId

			-- Call this SP to decrease the reserved qty. 
			EXEC dbo.uspICIncreaseReservedQty @ReservationToClear

			-- Clear the list (if it exists)
			DELETE Reservations
			FROM dbo.tblICStockReservation Reservations
			WHERE intTransactionId = @intPickLotHeaderId
				AND intInventoryTransactionType = @intPickLotTransactionType
				AND intLotId = @intPickedLotId

			EXEC uspLGReserveStockForPickLots @intPickLotHeaderId = @intNewPickLotHeaderId

			DELETE
			FROM tblLGPickLotDetail 
			WHERE intPickLotDetailId = @intPickLotDetailId
			
			SELECT @intPickLotDetailCount = COUNT(*)
			FROM tblLGPickLotDetail
			WHERE intPickLotHeaderId = @intPickLotHeaderId

 			IF(ISNULL(@intPickLotDetailCount,0) < = 0)
			BEGIN 
				DELETE FROM tblLGPickLotHeader WHERE intPickLotHeaderId = @intPickLotHeaderId
			END
		END
	END

	IF (@dblOldPickedQty - @dblNewPickedQty > 0)
	BEGIN
		INSERT INTO tblLGPickLotHeader (
			intConcurrencyId
			,strPickLotNumber
			,dtmPickDate
			,intCustomerEntityId
			,intCompanyLocationId
			,intCommodityId
			,intSubLocationId
			,intWeightUnitMeasureId
			,intUserSecurityId
			,intDeliveryHeaderId
			,intParentPickLotHeaderId
			)
		SELECT intConcurrencyId
			,@strNewPickLotNumber
			,dtmPickDate
			,intCustomerEntityId
			,intCompanyLocationId
			,intCommodityId
			,intSubLocationId
			,intWeightUnitMeasureId
			,intUserSecurityId
			,intDeliveryHeaderId
			,@intPickLotHeaderId
		FROM tblLGPickLotHeader
		WHERE intPickLotHeaderId = @intPickLotHeaderId

		SELECT @intNewPickLotHeaderId = SCOPE_IDENTITY()

		INSERT INTO tblLGPickLotDetail (
			intConcurrencyId
			,intPickLotHeaderId
			,intAllocationDetailId
			,intLotId
			,dblSalePickedQty
			,dblLotPickedQty
			,intSaleUnitMeasureId
			,intLotUnitMeasureId
			,dblGrossWt
			,dblTareWt
			,dblNetWt
			,intWeightUnitMeasureId
			,dtmPickedDate
			,intUserSecurityId
			,strComments
			)
		SELECT intConcurrencyId
			,@intNewPickLotHeaderId
			,intAllocationDetailId
			,intLotId
			,(@dblOldPickedQty - @dblNewPickedQty)
			,(@dblOldPickedQty - @dblNewPickedQty)
			,intSaleUnitMeasureId
			,intLotUnitMeasureId
			,dblGrossWt = dbo.[fnCTConvertQuantityToTargetItemUOM](@intItemId, intLotUnitMeasureId, intWeightUnitMeasureId, (@dblOldPickedQty - @dblNewPickedQty))
			,dblNetWt = dbo.[fnCTConvertQuantityToTargetItemUOM](@intItemId, intLotUnitMeasureId, intWeightUnitMeasureId, (@dblOldPickedQty - @dblNewPickedQty))
			,dblNetWt
			,intWeightUnitMeasureId
			,dtmPickedDate
			,intUserSecurityId
			,strComments
		FROM tblLGPickLotDetail
		WHERE intPickLotDetailId = @intPickLotDetailId

		IF EXISTS (
				SELECT TOP 1 1
				FROM dbo.tblICStockReservation Reservations
				WHERE intTransactionId = @intPickLotHeaderId
					AND intInventoryTransactionType = @intPickLotTransactionType
				)
		BEGIN
			INSERT INTO @ReservationToClear (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,intLotId
				,dblQty
				,intTransactionId
				,strTransactionId
				,intTransactionTypeId
				,intSubLocationId
				,intStorageLocationId
				)
			SELECT intItemId
				,intItemLocationId
				,intItemUOMId
				,intLotId
				,dblQty * - 1 -- Negate the qty to reduce the reserved qty. 
				,intTransactionId
				,strTransactionId
				,intInventoryTransactionType
				,intSubLocationId
				,intStorageLocationId
			FROM dbo.tblICStockReservation Reservations
			WHERE intTransactionId = @intPickLotHeaderId
				AND intInventoryTransactionType = @intPickLotTransactionType
				AND intLotId = @intPickedLotId

			-- Call this SP to decrease the reserved qty. 
			EXEC dbo.uspICIncreaseReservedQty @ReservationToClear

			-- Clear the list (if it exists)
			DELETE Reservations
			FROM dbo.tblICStockReservation Reservations
			WHERE intTransactionId = @intPickLotHeaderId
				AND intInventoryTransactionType = @intPickLotTransactionType
				AND intLotId = @intPickedLotId

			EXEC uspLGReserveStockForPickLots @intPickLotHeaderId = @intNewPickLotHeaderId

			UPDATE tblLGPickLotDetail
			SET dblLotPickedQty = @dblNewPickedQty
				,dblSalePickedQty = @dblNewPickedQty
				,dblGrossWt = dbo.[fnCTConvertQuantityToTargetItemUOM](@intItemId, intLotUnitMeasureId, intWeightUnitMeasureId, @dblNewPickedQty)
				,dblNetWt = dbo.[fnCTConvertQuantityToTargetItemUOM](@intItemId, intLotUnitMeasureId, intWeightUnitMeasureId, @dblNewPickedQty)
			WHERE intPickLotDetailId = @intPickLotDetailId

			EXEC uspLGReserveStockForPickLots @intPickLotHeaderId = @intPickLotHeaderId

		END
	END

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
	SET @strErrMsg = ERROR_MESSAGE()
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH