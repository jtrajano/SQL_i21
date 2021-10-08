﻿CREATE PROCEDURE [dbo].[uspICCreateStockReservation]
	@ItemsToReserve AS ItemReservationTableType READONLY
	,@intTransactionId AS INT
	,@intTransactionTypeId AS INT
	,@intUserId AS INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @ReservationToClear AS ItemReservationTableType
DECLARE @ItemsToReserveAggregrate AS ItemReservationTableType
		,@intReturn AS INT = 0 

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
		,dtmDate
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
		,dtmDate
FROM	@ItemsToReserve
GROUP  BY 
	intItemId
	, intItemLocationId
	, intItemUOMId
	, intLotId
	, intTransactionId
	, strTransactionId
	, intTransactionTypeId
	, intSubLocationId
	, intStorageLocationId
	, dtmDate

-- Clear the existing reserved records. 
IF EXISTS (
	SELECT TOP 1 1 
	FROM	dbo.tblICStockReservation Reservations 
	WHERE	intTransactionId = @intTransactionId
			AND intInventoryTransactionType = @intTransactionTypeId	
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
			,dtmDate
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
			,dtmDate
	FROM	dbo.tblICStockReservation Reservations 
	WHERE	intTransactionId = @intTransactionId
			AND intInventoryTransactionType = @intTransactionTypeId

	-- Call this SP to decrease the reserved qty. 
	EXEC @intReturn = dbo.uspICIncreaseReservedQty
		@ReservationToClear
		,@intUserId

	IF @intReturn <> 0
		RETURN @intReturn
		
	-- Clear the list (if it exists)
	DELETE	Reservations
	FROM	dbo.tblICStockReservation Reservations 
	WHERE	intTransactionId = @intTransactionId
			AND intInventoryTransactionType = @intTransactionTypeId

END 

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
		,intSubLocationId
		,intStorageLocationId
		,intConcurrencyId
		,dtmDate
		,dtmDateCreated
		,intCreatedByUserId
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
		,intSubLocationId				= Items.intSubLocationId
		,intStorageLocationId			= Items.intStorageLocationId
		,intConcurrencyId				= 1
		,dtmDate
		,dtmDateCreated					= GETDATE()
		,intCreatedByUserId				= @intUserId
FROM	@ItemsToReserveAggregrate Items INNER JOIN dbo.tblICItemLocation ItemLocation
			ON Items.intItemLocationId = ItemLocation.intItemLocationId

-- Call this SP to increase the reserved qty. 
EXEC @intReturn = dbo.uspICIncreaseReservedQty
	@ItemsToReserveAggregrate
	,@intUserId

IF @intReturn <> 0
	RETURN @intReturn
