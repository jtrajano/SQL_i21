/*
	This stored procedure either inserts or updates a Lot cost bucket. 
	When new stock is coming IN, it will try to determine if there are any negative Lot buckets it needs to update. 
	Otherwise, it inserts a new cost bucket. 
	
	Parameters: 

*/
CREATE PROCEDURE dbo.uspICIncreaseStockInLotCustody
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT 
	,@intLotId AS INT
	,@intSubLocationId AS INT
	,@intStorageLocationId AS INT
	,@dtmDate AS DATETIME 
	,@dblQty NUMERIC(18,6) 
	,@dblCost AS NUMERIC(18,6)
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT 
	,@intUserId AS INT
	,@NewInventoryLotInCustodyId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Ensure the qty is a positive number
SET @dblQty = ABS(@dblQty);
SET @NewInventoryLotInCustodyId = NULL;

INSERT dbo.tblICInventoryLotInCustody (
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

-- Do a follow-up retrieval of the new Lot In Custody id.
SELECT	@NewInventoryLotInCustodyId = SCOPE_IDENTITY() 

_Exit: