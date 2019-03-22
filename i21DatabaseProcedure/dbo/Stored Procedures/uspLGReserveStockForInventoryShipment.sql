CREATE PROCEDURE dbo.uspLGReserveStockForInventoryShipment
	@intLoadId AS INT,
	@ysnReserveStockForInventoryShipment AS BIT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ItemsToReserve AS dbo.ItemReservationTableType;
DECLARE @intInventoryShipmentTransactionType AS INT
DECLARE @strInvalidItemNo AS NVARCHAR(50) 
DECLARE @intInvalidItemId AS INT 
DECLARE @intPickLotHeaderId AS INT
DECLARE @intPickLotTransactionType AS INT

DECLARE @ReservationToClear AS ItemReservationTableType
DECLARE @ItemsToReserveAggregrate AS ItemReservationTableType
DECLARE @intLoadDetailPickLotId INT

 IF OBJECT_ID('tempdb..#tblLoadDetailPickLots ') IS NOT NULL  
 DROP TABLE #tblLoadDetailPickLots 
 
 CREATE TABLE #tblLoadDetailPickLots  
 (	
	intLoadDetailPickLotId INT IDENTITY(1,1),
	intLoadId INT,
	intPickLotHeaderId INT
 )
-- Get the transaction type id
BEGIN 
	SELECT TOP 1 
			@intPickLotTransactionType = intTransactionTypeId
	FROM	dbo.tblICInventoryTransactionType
	WHERE	strName = 'Pick Lots'

	SELECT TOP 1 
			@intInventoryShipmentTransactionType = intTransactionTypeId
	FROM	dbo.tblICInventoryTransactionType
	WHERE	strName = 'Outbound Shipment'
END


--Get the pick lot header id based on the supplied load id
BEGIN
	INSERT INTO #tblLoadDetailPickLots 
	SELECT DISTINCT @intLoadId, PLH.intPickLotHeaderId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	JOIN tblLGPickLotDetail PLD ON PLD.intPickLotDetailId = LD.intPickLotDetailId
	JOIN tblLGPickLotHeader PLH ON PLD.intPickLotHeaderId = PLH.intPickLotHeaderId
	WHERE L.intLoadId = @intLoadId
END

IF @ysnReserveStockForInventoryShipment=1
BEGIN
	SELECT @intLoadDetailPickLotId = MIN(intLoadDetailPickLotId) FROM #tblLoadDetailPickLots
	-- Clear the existing reserved records. 
	WHILE (@intLoadDetailPickLotId IS NOT NULL)
	BEGIN

		SET @intPickLotHeaderId = NULL

		SELECT @intPickLotHeaderId = intPickLotHeaderId
		FROM #tblLoadDetailPickLots
		WHERE intLoadDetailPickLotId = @intLoadDetailPickLotId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblICStockReservation WHERE intTransactionId = @intPickLotHeaderId)
		BEGIN
			BREAK;
		END

		IF EXISTS (SELECT TOP 1 1
				FROM dbo.tblICStockReservation Reservations
				WHERE intTransactionId = @intPickLotHeaderId
					AND intInventoryTransactionType = @intPickLotTransactionType)
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

			-- Call this SP to decrease the reserved qty. 
			EXEC dbo.uspICIncreaseReservedQty @ReservationToClear

			-- Clear the list (if it exists)
			DELETE Reservations
			FROM dbo.tblICStockReservation Reservations
			WHERE intTransactionId = @intPickLotHeaderId
				AND intInventoryTransactionType = @intPickLotTransactionType
		
			SELECT @intLoadDetailPickLotId = MIN(intLoadDetailPickLotId) FROM #tblLoadDetailPickLots WHERE intLoadDetailPickLotId > @intLoadDetailPickLotId
		END
	END

	-- Get the items to reserve
	BEGIN 
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
		SELECT	intItemId = Lot.intItemId
				,intItemLocationId = Lot.intItemLocationId
				,intItemUOMId = Lot.intItemUOMId
				,intLotId = Lot.intLotId
				,intSubLocationId = Lot.intSubLocationId
				,intStorageLocationId = Lot.intStorageLocationId
				,dblQty = LDL.dblLotQuantity
				,intTransactionId = L.intLoadId
				,strTransactionId = CAST(L.strLoadNumber AS VARCHAR(100))
				,intTransactionTypeId = @intInventoryShipmentTransactionType
		FROM	tblLGLoad L
				JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
				JOIN tblLGLoadDetailLot LDL ON LD.intLoadDetailId = LDL.intLoadDetailId
				JOIN tblICLot Lot ON Lot.intLotId = LDL.intLotId
		WHERE	L.intLoadId = @intLoadId
	END

	-- Do the reservations
	BEGIN 
		-- Validate the reservation 
		EXEC dbo.uspICValidateStockReserves 
			@ItemsToReserve
			,@strInvalidItemNo OUTPUT 
			,@intInvalidItemId OUTPUT 

		-- If there are enough stocks, let the system create the reservations
		IF (@intInvalidItemId IS NULL)	
		BEGIN 
			EXEC dbo.uspICCreateStockReservation
				@ItemsToReserve
				,@intPickLotHeaderId
				,@intPickLotTransactionType	
		END 	

	END 
END
ELSE
BEGIN
	IF EXISTS (SELECT TOP 1 1
		FROM dbo.tblICStockReservation Reservations
		WHERE intTransactionId = @intLoadId
			AND intInventoryTransactionType = @intInventoryShipmentTransactionType)
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
		WHERE intTransactionId = @intLoadId
			AND intInventoryTransactionType = @intInventoryShipmentTransactionType

		-- Call this SP to decrease the reserved qty. 
		EXEC dbo.uspICIncreaseReservedQty @ReservationToClear

		-- Clear the list (if it exists)
		DELETE Reservations
		FROM dbo.tblICStockReservation Reservations
		WHERE intTransactionId = @intLoadId
			AND intInventoryTransactionType = @intInventoryShipmentTransactionType
	END

	SELECT @intLoadDetailPickLotId = MIN(intLoadDetailPickLotId) FROM #tblLoadDetailPickLots
	-- Do the reservations for Picked Lot
	WHILE (@intLoadDetailPickLotId IS NOT NULL)
	BEGIN

		SET @intPickLotHeaderId = NULL

		SELECT @intPickLotHeaderId = intPickLotHeaderId
		FROM #tblLoadDetailPickLots
		WHERE intLoadDetailPickLotId = @intLoadDetailPickLotId

		EXEC uspLGReserveStockForPickLots @intPickLotHeaderId = @intPickLotHeaderId

		SELECT @intLoadDetailPickLotId = MIN(intLoadDetailPickLotId) FROM #tblLoadDetailPickLots WHERE intLoadDetailPickLotId > @intLoadDetailPickLotId
	END
END