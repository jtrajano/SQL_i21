CREATE PROCEDURE [dbo].[uspICUnpostActualCostIn]
	@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT
	,@ysnRecap AS BIT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the temp table if it does not exists. 
IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInventoryTransactionStockToReverse')) 
BEGIN 
	CREATE TABLE #tmpInventoryTransactionStockToReverse (
		intInventoryTransactionId INT NOT NULL 
		,intTransactionId INT NULL 
		,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,strRelatedTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,intRelatedTransactionId INT NULL 
		,intTransactionTypeId INT NOT NULL
		,dblQty NUMERIC(38,20) 
	)
END 

-- Create the variables for the internal transaction types used by costing. 
DECLARE @AUTO_NEGATIVE AS INT = 1
		,@WRITE_OFF_SOLD AS INT = 2
		,@REVALUE_SOLD AS INT = 3
		,@AUTO_VARIANCE_ON_SOLD_OR_USED_STOCK AS INT = 35

		,@COST_ADJUSTMENT AS INT = 26;

---- Validate the unpost of the stock in. Do not allow unpost if it has cost adjustments. 
--IF @ysnRecap = 0
--BEGIN 
--	DECLARE @strItemNo AS NVARCHAR(50)
--			,@strRelatedTransactionId AS NVARCHAR(50)

--	SELECT TOP 1 
--			@strItemNo = Item.strItemNo
--			,@strRelatedTransactionId = InvTrans.strTransactionId
--	FROM	dbo.tblICInventoryTransaction InvTrans INNER JOIN dbo.tblICItem Item
--				ON InvTrans.intItemId = Item.intItemId
--	WHERE	InvTrans.intRelatedTransactionId = @intTransactionId
--			AND InvTrans.strRelatedTransactionId = @strTransactionId
--			AND InvTrans.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
--			AND ISNULL(InvTrans.ysnIsUnposted, 0) = 0 
		
--	IF @strRelatedTransactionId IS NOT NULL 
--	BEGIN 
--		-- 'Unable to unpost because {Item} has a cost adjustment from {Transaction Id}.'
--		EXEC uspICRaiseError 80063, @strItemNo, @strRelatedTransactionId;
--		RETURN -1;
--	END 
--END 

-- Get all the inventory transaction related to the Unpost. 
-- While at it, update the ysnIsUnposted to true. 
-- Then grab the updated records and store it into the #tmpInventoryTransactionStockToReverse temp table
INSERT INTO #tmpInventoryTransactionStockToReverse (
	intInventoryTransactionId
	,intTransactionId
	,strTransactionId
	,intRelatedTransactionId
	,strRelatedTransactionId
	,intTransactionTypeId
	,dblQty
)
SELECT	Changes.intInventoryTransactionId
		,Changes.intTransactionId
		,Changes.strTransactionId
		,Changes.intRelatedTransactionId
		,Changes.strRelatedTransactionId
		,Changes.intTransactionTypeId
		,Changes.dblQty 
FROM	(
			-- Merge will help us get the records we need to unpost and update it at the same time. 
			MERGE	
				INTO	dbo.tblICInventoryTransaction 
				WITH	(HOLDLOCK) 
				AS		inventory_transaction	
				USING (
					SELECT	strTransactionId = @strTransactionId
							,intTransactionId = @intTransactionId
				) AS Source_Query  
					ON 
					(
						-- Link to the main transaction
						(	
							inventory_transaction.strTransactionId = Source_Query.strTransactionId
							AND inventory_transaction.intTransactionId = Source_Query.intTransactionId
							AND ISNULL(inventory_transaction.dblQty, 0) > 0 -- Reverse Qty that is positive. 
						)
						-- Link to revalue, write-off sold, auto variance on sold or used stock. 
						OR (
							inventory_transaction.strTransactionId = Source_Query.strTransactionId
							AND inventory_transaction.intTransactionId = Source_Query.intTransactionId
							AND inventory_transaction.intTransactionTypeId IN (@REVALUE_SOLD, @WRITE_OFF_SOLD, @AUTO_VARIANCE_ON_SOLD_OR_USED_STOCK)
						)
					)
					AND ISNULL(inventory_transaction.ysnIsUnposted, 0) = 0					
					AND inventory_transaction.intTransactionTypeId <> @AUTO_NEGATIVE

				-- If matched, update the ysnIsUnposted and set it to true (1) 
				WHEN MATCHED THEN 
					UPDATE 
					SET		ysnIsUnposted = 1

				OUTPUT	$action
						, inserted.intInventoryTransactionId
						, inserted.intTransactionId
						, inserted.strTransactionId
						, inserted.intRelatedTransactionId
						, inserted.strRelatedTransactionId
						, inserted.intTransactionTypeId
						, inserted.dblQty
		) AS Changes (
				action
				, intInventoryTransactionId
				, intTransactionId
				, strTransactionId
				, intRelatedTransactionId
				, strRelatedTransactionId
				, intTransactionTypeId
				, dblQty
		)
WHERE	Changes.action = 'UPDATE'
;

-- If there are revalue records, reduce the In-qty of the negative stock buckets
-- Since the In-qty is unposted, it must bring back these buckets back to negative qty. 
UPDATE	ActualCostBucket
SET		ActualCostBucket.dblStockIn = ISNULL(ActualCostBucket.dblStockIn, 0) - ActualCostOutGrouped.dblQty
FROM	dbo.tblICInventoryActualCost ActualCostBucket INNER JOIN (
			SELECT	ActualCostOut.intRevalueActualCostId
					,dblQty = SUM(ActualCostOut.dblQty)
			FROM	dbo.tblICInventoryActualCostOut ActualCostOut INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
						ON ActualCostOut.intInventoryTransactionId = Reversal.intInventoryTransactionId
					INNER JOIN dbo.tblICInventoryTransaction OutTransactions
						ON OutTransactions.intInventoryTransactionId = ActualCostOut.intInventoryTransactionId
			WHERE	ActualCostOut.intRevalueActualCostId IS NOT NULL 
					AND ISNULL(OutTransactions.ysnIsUnposted, 0) = 0
			GROUP BY ActualCostOut.intRevalueActualCostId
		) AS ActualCostOutGrouped
			ON ActualCostOutGrouped.intRevalueActualCostId = ActualCostBucket.intInventoryActualCostId
;

-- If there are out records, create a negative stock cost bucket 
INSERT INTO dbo.tblICInventoryActualCost (
		strActualCostId
		,intItemId
		,intItemLocationId
		,intItemUOMId
		,dblStockIn
		,dblStockOut
		,dblCost
		,strTransactionId
		,intTransactionId
		,dtmCreated
		,intCreatedUserId
		,intConcurrencyId
		,dtmDate
)
SELECT	strActualCostId = ActualCost.strActualCostId
		,intItemId = OutTransactions.intItemId
		,intItemLocationId = OutTransactions.intItemLocationId
		,intItemUOMId = OutTransactions.intItemUOMId
		,dblStockIn = 0 
		,dblStockOut = ABS(ISNULL(OutTransactions.dblQty, 0))
		,dblCost = OutTransactions.dblCost
		,strTransactionId = OutTransactions.strTransactionId
		,intTransactionId = OutTransactions.intTransactionId
		,dtmCreated = GETDATE()
		,intCreatedUserId = OutTransactions.intCreatedUserId
		,intConcurrencyId = 1
		,dtmDate = ActualCost.dtmDate
FROM	dbo.tblICInventoryActualCost ActualCost INNER JOIN dbo.tblICInventoryActualCostOut ActualCostOut
			ON ActualCost.intInventoryActualCostId = ActualCostOut.intInventoryActualCostId
		INNER JOIN dbo.tblICInventoryTransaction OutTransactions
			ON OutTransactions.intInventoryTransactionId = ActualCostOut.intInventoryTransactionId
			AND ISNULL(OutTransactions.dblQty, 0) < 0 
WHERE	ISNULL(OutTransactions.ysnIsUnposted, 0) = 0
		AND ActualCost.intTransactionId = @intTransactionId
		AND ActualCost.strTransactionId = @strTransactionId
;

-- Plug the Out-qty so that it can't be used for future out-transactions. 
-- Mark the record as unposted too. 
UPDATE	ActualCost
SET		dblStockOut = dblStockIn
		,ysnIsUnposted = 1
FROM	dbo.tblICInventoryActualCost ActualCost INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
			ON ActualCost.intTransactionId = Reversal.intTransactionId
			AND ActualCost.strTransactionId = Reversal.strTransactionId
		INNER JOIN dbo.tblICInventoryTransaction InTransactions
			ON InTransactions.intInventoryTransactionId = Reversal.intInventoryTransactionId
			AND ISNULL(InTransactions.dblQty, 0) > 0 
WHERE	Reversal.intTransactionTypeId NOT IN (
			@WRITE_OFF_SOLD
			, @REVALUE_SOLD
			, @AUTO_NEGATIVE
			, @AUTO_VARIANCE_ON_SOLD_OR_USED_STOCK
			, @COST_ADJUSTMENT 
		) 
		AND ISNULL(Reversal.dblQty, 0) <> 0
;