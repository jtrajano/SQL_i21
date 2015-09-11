CREATE PROCEDURE [dbo].[uspICCreateStockReservation]
	@ItemsToReserve AS ItemReservationTableType READONLY
	,@intTransactionId AS INT
	,@intTransactionTypeId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ItemsToReserveAggregrate AS ItemReservationTableType

INSERT INTO @ItemsToReserveAggregrate (
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
SELECT	intItemId
		,intItemLocationId
		,intItemUOMId
		,intLotId
		,SUM(dblQty)
		,intTransactionId
		,strTransactionId
		,intTransactionTypeId
		,intSubLocationId
		,intStorageLocationId	 
FROM	@ItemsToReserve
GROUP  BY intItemId, intItemLocationId, intItemUOMId, intLotId, intTransactionId, strTransactionId, intTransactionTypeId, intSubLocationId, intStorageLocationId

-- Clear the list (if it exists)
DELETE	Reservations
FROM	dbo.tblICStockReservation Reservations 
WHERE	intTransactionId = @intTransactionId
		AND @intTransactionTypeId = @intTransactionTypeId

-- Add new reservations
INSERT INTO dbo.tblICStockReservation (
		intItemId
		,intLocationId
		,intItemLocationId
		,intItemUOMId
		,intLotId
		,dblQty
		,intTransactionId
		,strTransactionId
		,intSort
		,intInventoryTransactionType
		,intConcurrencyId
		,intSubLocationId
		,intStorageLocationId
)
SELECT	intItemId						= Items.intItemId
		,intLocationId					= ItemLocation.intLocationId
		,intItemLocationId				= Items.intItemLocationId
		,intItemUOMId					= Items.intItemUOMId
		,intLotId						= Items.intLotId
		,dblQty							= Items.dblQty
		,intTransactionId				= Items.intTransactionId
		,strTransactionId				= Items.strTransactionId
		,intSort						= Items.intId
		,intInventoryTransactionType	= Items.intTransactionTypeId
		,intConcurrencyId				= 1
		,intSubLocationId				= Items.intSubLocationId
		,intStorageLocationId			= Items.intStorageLocationId
FROM	@ItemsToReserveAggregrate Items INNER JOIN dbo.tblICItemLocation ItemLocation
			ON Items.intItemLocationId = ItemLocation.intItemLocationId