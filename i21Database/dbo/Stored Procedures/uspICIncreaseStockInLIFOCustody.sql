/*
	This stored procedure will add a cost bucket for custody items. 
	It does not accept or process negative stocks. Non-company owned stocks does not accept negative stocks. 

*/
CREATE PROCEDURE dbo.uspICIncreaseStockInLIFOCustody
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT 
	,@dtmDate AS DATETIME
	,@dblQty NUMERIC(18,6) 
	,@dblCost AS NUMERIC(18,6)
	,@intUserId AS INT
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT 
	,@NewLIFOInCustodyId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Ensure the qty is a positive number
SET @dblQty = ABS(@dblQty);
SET @NewLIFOInCustodyId = NULL;

INSERT dbo.tblICInventoryLIFOInCustody (
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
SELECT	@NewLIFOInCustodyId = SCOPE_IDENTITY() 