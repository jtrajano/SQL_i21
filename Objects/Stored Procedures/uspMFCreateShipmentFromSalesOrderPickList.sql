CREATE PROCEDURE [dbo].[uspMFCreateShipmentFromSalesOrderPickList] @intSalesOrderId INT
	,@intUserId INT
	,@intInventoryShipmentId INT = 0 OUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @InitTranCount AS INT
DECLARE @Savepoint AS VARCHAR(MAX)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('uspMFCreateShipmentFromSalesOrderPickList' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

DECLARE @ErrMsg NVARCHAR(max)
DECLARE @intMinPickListDetail INT
DECLARE @intPickListId INT
DECLARE @intLotId INT
DECLARE @dblShipQty NUMERIC(38, 20)
DECLARE @intInventoryShipmentItemId INT
DECLARE @intItemId INT
DECLARE @intMinSalesOrderItem INT
DECLARE @dblReqQty NUMERIC(38, 20)
DECLARE @strItemNo NVARCHAR(50)
DECLARE @dblSelQty NUMERIC(38, 20)
DECLARE @strUOM NVARCHAR(50)
DECLARE @intItemUOMId INT
	,@dblWeightPerQty NUMERIC(38, 20)
DECLARE @tblInputItem TABLE (
	intRowNo INT IDENTITY(1, 1)
	,intItemId INT
	,dblQty NUMERIC(38, 20)
	,intItemUOMId INT
	,strLotTracking NVARCHAR(50)
	)
DECLARE @Items ShipmentStagingTable
	,@Charges ShipmentChargeStagingTable
	,@Lots ShipmentItemLotStagingTable
DECLARE @lotsOnly ShipmentItemLotsOnlyStagingTable

SELECT TOP 1 @intPickListId = intPickListId
FROM tblMFPickList
WHERE intSalesOrderId = @intSalesOrderId

IF ISNULL(@intPickListId, 0) = 0
	RAISERROR (
			'Please save the pick list before shipping.'
			,16
			,1
			)

IF EXISTS (
		SELECT 1
		FROM tblICInventoryShipment sh
		JOIN tblICInventoryShipmentItem sd ON sh.intInventoryShipmentId = sd.intInventoryShipmentId
		WHERE sh.intOrderType = 2
			AND sd.intOrderId = @intSalesOrderId
		)
BEGIN
	RAISERROR (
			'Shipment is already created for the sales order.'
			,16
			,1
			)

	RETURN;
END

IF (
		SELECT ISNULL(intFreightTermId, 0)
		FROM tblSOSalesOrder
		WHERE intSalesOrderId = @intSalesOrderId
		) = 0
	RAISERROR (
			'Please enter freight term in Sales Order before shipping.'
			,16
			,1
			)

INSERT INTO @tblInputItem (
	intItemId
	,dblQty
	,intItemUOMId
	)
SELECT sd.intItemId
	,SUM(sd.dblQtyOrdered)
	,sd.intItemUOMId
FROM tblSOSalesOrderDetail sd
JOIN tblICItem i ON sd.intItemId = i.intItemId
WHERE intSalesOrderId = @intSalesOrderId
	AND i.strType NOT IN (
		'Comment'
		,'Other Charge'
		)
GROUP BY sd.intItemId
	,sd.intItemUOMId

SELECT @intMinSalesOrderItem = MIN(intRowNo)
FROM @tblInputItem

WHILE @intMinSalesOrderItem IS NOT NULL
BEGIN
	SELECT @intItemId = intItemId
		,@dblReqQty = dblQty
		,@intItemUOMId = intItemUOMId
	FROM @tblInputItem
	WHERE intRowNo = @intMinSalesOrderItem

	SELECT @strItemNo = strItemNo
	FROM tblICItem
	WHERE intItemId = @intItemId

	IF NOT EXISTS (
			SELECT 1
			FROM tblMFPickListDetail
			WHERE intPickListId = @intPickListId
				AND intItemId = @intItemId
			)
	BEGIN
		SET @ErrMsg = 'Item ' + @strItemNo + ' is not selected in the pick list.'

		RAISERROR (
				@ErrMsg
				,16
				,1
				)
	END

	SELECT @dblSelQty = SUM(dblQuantity)
	FROM tblMFPickListDetail
	WHERE intPickListId = @intPickListId
		AND intItemId = @intItemId

	SELECT @strUOM = um.strUnitMeasure
	FROM tblICUnitMeasure um
	JOIN tblICItemUOM iu ON um.intUnitMeasureId = iu.intUnitMeasureId
	WHERE iu.intItemUOMId = @intItemUOMId

	IF @dblSelQty < @dblReqQty
	BEGIN
		SET @ErrMsg = 'Item ' + @strItemNo + ' is required ' + dbo.fnRemoveTrailingZeroes(@dblReqQty) + ' ' + @strUOM + ' but selected ' + dbo.fnRemoveTrailingZeroes(@dblSelQty) + ' ' + @strUOM + '.'

		RAISERROR (
				@ErrMsg
				,16
				,1
				)
	END

	SELECT @intMinSalesOrderItem = MIN(intRowNo)
	FROM @tblInputItem
	WHERE intRowNo > @intMinSalesOrderItem
END

BEGIN TRY
	BEGIN TRANSACTION

	--Create Shipment Header and Line	
	EXEC uspSOProcessToItemShipment @intSalesOrderId
		,@intUserId
		,0
		,@intInventoryShipmentId OUT

	SELECT @intMinPickListDetail = MIN(intPickListDetailId)
	FROM tblMFPickListDetail
	WHERE intPickListId = @intPickListId
		AND ISNULL(intLotId, 0) > 0

	--Add Shipment Lot
	WHILE @intMinPickListDetail IS NOT NULL
	BEGIN
		SELECT @dblWeightPerQty = NULL
			,@intInventoryShipmentItemId = NULL

		SELECT @intLotId = intLotId
			,@dblShipQty = dblPickQuantity
			,@intItemId = intItemId
		FROM tblMFPickListDetail
		WHERE intPickListDetailId = @intMinPickListDetail

		SELECT @dblWeightPerQty = dblWeightPerQty
		FROM tblICLot
		WHERE intLotId = @intLotId

		SELECT TOP 1 @intInventoryShipmentItemId = intInventoryShipmentItemId
		FROM tblICInventoryShipmentItem
		WHERE intInventoryShipmentId = @intInventoryShipmentId
			AND intItemId = @intItemId

		--INSERT INTO tblICInventoryShipmentItemLot (
		--	intInventoryShipmentItemId
		--	,intLotId
		--	,dblQuantityShipped
		--	,dblGrossWeight
		--	,dblTareWeight
		--	)
		--VALUES (
		--	@intInventoryShipmentItemId
		--	,@intLotId
		--	,@dblShipQty
		--	,0
		--	,0
		--	)
		DELETE
		FROM @lotsOnly

		INSERT INTO @lotsOnly (
			intInventoryShipmentId
			,intInventoryShipmentItemId
			-- Lot Details 
			,intLotId
			,dblQuantityShipped
			,dblGrossWeight
			,dblTareWeight
			,dblWeightPerQty
			,strWarehouseCargoNumber
			)
		SELECT intInventoryShipmentId = @intInventoryShipmentId
			,intInventoryShipmentItemId = @intInventoryShipmentItemId
			-- Lot Details 
			,intLotId = @intLotId
			,dblQuantityShipped = @dblShipQty
			,dblGrossWeight = @dblShipQty * @dblWeightPerQty
			,dblTareWeight = 0
			,dblWeightPerQty = @dblWeightPerQty
			,strWarehouseCargoNumber = ''

		EXEC dbo.uspICAddItemShipment @Items = @Items
			,@Charges = @Charges
			,@Lots = @Lots
			,@LotsOnly = @lotsOnly
			,@intUserId = 1

		SELECT @intMinPickListDetail = MIN(intPickListDetailId)
		FROM tblMFPickListDetail
		WHERE intPickListId = @intPickListId
			AND ISNULL(intLotId, 0) > 0
			AND intPickListDetailId > @intMinPickListDetail
	END

	--Remove reservation against pick list
	UPDATE tblICStockReservation
	SET ysnPosted = 1
	WHERE intTransactionId = @intPickListId
		AND intInventoryTransactionType = 34

	--Reserve against shipment
	EXEC uspICReserveStockForInventoryShipment @intInventoryShipmentId

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	--IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
	--SET @ErrMsg = ERROR_MESSAGE()  
	--RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
	IF @InitTranCount = 0
		IF (XACT_STATE()) <> 0
			ROLLBACK TRANSACTION
		ELSE IF (XACT_STATE()) <> 0
			ROLLBACK TRANSACTION @Savepoint
		ELSE
			ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
