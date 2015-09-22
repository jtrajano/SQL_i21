﻿/*
	This stored procedure either inserts or updates a Lot cost bucket. 
	When new stock is coming IN, it will try to determine if there are any negative Lot buckets it needs to update. 
	Otherwise, it inserts a new cost bucket. 
	
	Parameters: 

*/
CREATE PROCEDURE dbo.uspICIncreaseStockInLotStorage
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT 
	,@intLotId AS INT
	,@intSubLocationId AS INT
	,@intStorageLocationId AS INT
	,@dtmDate AS DATETIME 
	,@dblQty NUMERIC(18,6) 
	,@dblCost AS NUMERIC(38, 20)
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT 
	,@intUserId AS INT
	,@NewInventoryLotStorageId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Ensure the qty is a positive number
SET @dblQty = ABS(@dblQty);
SET @NewInventoryLotStorageId = NULL;

INSERT dbo.tblICInventoryLotStorage (
	[intItemId]
	,[intItemLocationId]
	,[intItemUOMId]
	,[intLotId]
	,[intSubLocationId]
	,[intStorageLocationId]
	,[dtmDate]
	,[dblStockIn]
	,[dblStockOut]
	,[dblCost]
	,[strTransactionId]
	,[intTransactionId]
	,[dtmCreated]
	,[intCreatedUserId]
	,[intConcurrencyId]
)
VALUES (
	@intItemId
	,@intItemLocationId
	,@intItemUOMId
	,@intLotId
	,@intSubLocationId
	,@intStorageLocationId
	,@dtmDate
	,@dblQty
	,0
	,@dblCost
	,@strTransactionId
	,@intTransactionId
	,GETDATE()
	,@intUserId
	,1	
)

-- Do a follow-up retrieval of the new Lot In Storage id.
SELECT	@NewInventoryLotStorageId = SCOPE_IDENTITY() 

_Exit: