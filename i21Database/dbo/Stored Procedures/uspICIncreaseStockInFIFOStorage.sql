/*
	This stored procedure will add a cost bucket for Storage items. 
	It does not accept or process negative stocks. Non-company owned stocks does not accept negative stocks. 

*/
CREATE PROCEDURE dbo.uspICIncreaseStockInFIFOStorage
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT 
	,@dtmDate AS DATETIME
	,@dblQty NUMERIC(38,20) 
	,@dblCost AS NUMERIC(38,20)
	,@intEntityUserSecurityId AS INT
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT 
	,@intTransactionDetailId AS INT 
	,@NewFifoStorageId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Ensure the qty is a positive number
SET @dblQty = ABS(@dblQty);
SET @NewFifoStorageId = NULL;

INSERT dbo.tblICInventoryFIFOStorage (
	[intItemId]
	,[intItemLocationId]
	,[intItemUOMId]
	,[dtmDate]
	,[dblStockIn]
	,[dblStockOut]
	,[dblCost]		
	,[strTransactionId]
	,[intTransactionId]
	,[intTransactionDetailId]
	,[dtmCreated]
	,[intCreatedEntityId]
	,[intConcurrencyId]
)
VALUES (
	@intItemId
	,@intItemLocationId
	,@intItemUOMId
	,@dtmDate
	,@dblQty
	,0
	,@dblCost
	,@strTransactionId
	,@intTransactionId
	,@intTransactionDetailId
	,GETDATE()
	,@intEntityUserSecurityId
	,1
)

-- Do a follow-up retrieval of the new Lot In Storage id.
SELECT	@NewFifoStorageId = SCOPE_IDENTITY() 
