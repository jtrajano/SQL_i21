CREATE PROCEDURE [dbo].[uspICCreateStockReservation]
	@ItemsToReserve AS ItemReservationTableType READONLY
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
)
SELECT	intItemId
		,intItemLocationId
		,intItemUOMId
		,intLotId
		,SUM(dblQty)
		,intTransactionId
		,strTransactionId
		,intTransactionTypeId	 
FROM	@ItemsToReserve
GROUP  BY intItemId, intItemLocationId, intItemUOMId, intLotId, intTransactionId, strTransactionId, intTransactionTypeId

-- Clear the list (if it exists)
DELETE	Reservations
FROM	dbo.tblICStockReservation Reservations INNER JOIN @ItemsToReserveAggregrate Items
			ON Reservations.intItemId = Items.intItemId
			AND Reservations.intItemLocationId = Items.intItemLocationId
			AND Reservations.intItemUOMId = Items.intItemUOMId
			AND Reservations.intInventoryTransactionType = Items.intTransactionTypeId
			AND ISNULL(Reservations.intLotId, 0) = ISNULL(Items.intLotId, 0)

-- Add new reservations
INSERT INTO dbo.tblICStockReservation (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intLotId
		,dblQuantity
		,intTransactionId
		,strTransactionId
		,intSort
		,intInventoryTransactionType
		,intConcurrencyId
)
SELECT	intItemId						= Items.intItemId
		,intItemLocationId				= Items.intItemLocationId
		,intItemUOMId					= Items.intItemUOMId
		,intLotId						= Items.intLotId
		,dblQuantity					= Items.dblQty
		,intTransactionId				= Items.intTransactionId
		,strTransactionId				= Items.strTransactionId
		,intSort						= Items.intId
		,intInventoryTransactionType	= Items.intTransactionTypeId
		,intConcurrencyId				= 1
FROM	@ItemsToReserveAggregrate Items