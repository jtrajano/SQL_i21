/*
	This stored procedure will add a cost bucket to the non-company owned stocks. 
	It does not accept or process negative stocks. Non-company owned stocks does not accept negative stocks. 
	
	Parameters: 

*/
CREATE PROCEDURE dbo.uspICIncreaseStockInFIFOCustody
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT 
	,@dtmDate AS DATETIME
	,@dblQty NUMERIC(18,6) 
	,@dblCost AS NUMERIC(18,6)
	,@intUserId AS INT
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT 
	,@NewFifoInCustodyId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Ensure the qty is a positive number
SET @dblQty = ABS(@dblQty);
SET @NewFifoInCustodyId = NULL;

INSERT dbo.tblICInventoryFIFOInCustody (
	[intItemId]
	,[intItemLocationId]
	,[intItemUOMId]
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
SELECT	@NewFifoInCustodyId = SCOPE_IDENTITY() 