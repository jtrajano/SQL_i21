CREATE PROCEDURE [dbo].[uspICPostStockReservation]
	@intTransactionId AS INT
	,@intTransactionTypeId AS INT
	,@ysnPosted AS BIT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

UPDATE	dbo.tblICStockReservation
SET		ysnPosted = @ysnPosted
WHERE	intTransactionId = @intTransactionId
		AND intInventoryTransactionType = @intTransactionTypeId

-- If posted, reduce the reserved qty. 
IF @ysnPosted = 1 
BEGIN 
	DECLARE @ReservationToClear AS ItemReservationTableType

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
	SELECT 
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,-dblQty -- Negate the qty to reduce the reserved qty. 
			,intTransactionId
			,strTransactionId
			,intInventoryTransactionType
			,intSubLocationId
			,intStorageLocationId
	FROM	dbo.tblICStockReservation Reservations 
	WHERE	intTransactionId = @intTransactionId
			AND @intTransactionTypeId = @intTransactionTypeId

	-- Call this SP to decrease the reserved qty. 
	EXEC dbo.uspICIncreaseReservedQty
		@ReservationToClear
END 

-- If unposted, increase the reserved qty. 
IF ISNULL(@ysnPosted, 0) = 0 
BEGIN 
	DECLARE @ReservationToRestore AS ItemReservationTableType

	INSERT INTO @ReservationToRestore (
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
	SELECT 
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,dblQty 
			,intTransactionId
			,strTransactionId
			,intInventoryTransactionType
			,intSubLocationId
			,intStorageLocationId
	FROM	dbo.tblICStockReservation Reservations 
	WHERE	intTransactionId = @intTransactionId
			AND @intTransactionTypeId = @intTransactionTypeId

	-- Call this SP to decrease the reserved qty. 
	EXEC dbo.uspICIncreaseReservedQty
		@ReservationToRestore
END 