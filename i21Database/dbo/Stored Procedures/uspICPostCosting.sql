
/*
	It process each the items submitted for costing. There is cursor used in this procedure. 
	It iterates over the list of items in @ItemsToProcess. 

	The each iteration, it does the following: 
		1. Determines if a stock is for incoming or outgoing then calls the appropriate stored procedure. 
		2. Determines the type of inventory transaction it is, whether an in, out, or cost adjustment. 
*/

CREATE PROCEDURE [dbo].[uspICPostCosting]
	@ItemsToProcess AS ItemCostingTableType READONLY
	,@strBatchId AS NVARCHAR(20)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Declare the variables to use for the cursor
DECLARE @intItemId AS INT
		,@intItemLocationId AS INT 
		,@dtmDate AS DATETIME
		,@dblUnitQty AS NUMERIC(18, 6) 
		,@dblUOMQty AS NUMERIC(18, 6)
		,@dblCost AS NUMERIC(18, 6)
		,@dblSalesPrice AS NUMERIC(18, 6)
		,@intCurrencyId AS INT 
		,@dblExchangeRate AS DECIMAL (38, 20) 
		,@intTransactionId AS INT
		,@strTransactionId AS NVARCHAR(40) 
		,@intTransactionTypeId AS INT 
		,@intLotId AS INT

DECLARE @CostingMethod AS INT 
DECLARE @NegativeInventoryOption AS INT
DECLARE @GLAccounts AS ItemGLAccount

-- Create the cursor
-- Use LOCAL. It specifies that the scope of the cursor is local to the stored procedure where it was created. The cursor name is only valid within this scope. 
-- Use FAST_FORWARD. It specifies a FORWARD_ONLY, READ_ONLY cursor with performance optimizations enabled. 
DECLARE loopItems CURSOR LOCAL FAST_FORWARD
FOR 
SELECT  intItemId
		,intItemLocationId
		,dtmDate
		,dblUnitQty
		,dblUOMQty
		,dblCost
		,dblSalesPrice
		,intCurrencyId
		,dblExchangeRate
		,intTransactionId
		,strTransactionId
		,intTransactionTypeId
		,intLotId
FROM	@ItemsToProcess

OPEN loopItems;

-- Initial fetch attempt
FETCH NEXT FROM loopItems INTO @intItemId, @intItemLocationId, @dtmDate, @dblUnitQty, @dblUOMQty, @dblCost, @dblSalesPrice, @intCurrencyId, @dblExchangeRate, @intTransactionId, @strTransactionId, @intTransactionTypeId, @intLotId;

-- The loop
WHILE @@FETCH_STATUS = 0
BEGIN 
	-- Initialize the costing method and negative inventory option. 
	SET @CostingMethod = NULL;
	SET @NegativeInventoryOption = NULL;
	DELETE FROM @GLAccounts;

	-- Get the costing method of an item and the negative stock option
	SELECT @CostingMethod = dbo.fnGetCostingMethod(@intItemId, @intItemLocationId)
			,@NegativeInventoryOption = dbo.fnGetNegativeInventoryOptions(@intItemId, @intItemLocationId);

	-- Get the g/l accounts for the item based on its item level setup, category setup, or location setup. 
	INSERT INTO @GLAccounts (Inventory, Sales, Purchases, COGS)	
	SELECT	Inventory, Sales, Purchases, NULL 
	FROM	dbo.fnGetItemGLAccounts(@intItemId, @intItemLocationId); 

	-- Moving Average Cost

	-- FIFO

	-- LIFO


	-- Attempt to fetch the next row from cursor. 
	FETCH NEXT FROM loopItems INTO @intItemId, @intItemLocationId, @dtmDate, @dblUnitQty, @dblUOMQty, @dblCost, @dblSalesPrice, @intCurrencyId, @dblExchangeRate, @intTransactionId, @strTransactionId, @intTransactionTypeId, @intLotId;
END;

CLOSE loopItems;
DEALLOCATE loopItems;


-- Generate the GL entries
--SELECT	[strTransactionId		= A.strTransactionId
--		,@intTransactionId		= A.intTransactionId
--		,@dtmDate				= A.dtmDate
--		,@strBatchId			= @strBatchId
--		,@intAccountId			= 
--		,@dblDebit				= 
--		,@dblCredit			= 
--		,@dblDebitUnit			= 
--		,@dblCreditUnit		= 
--		,@strDescription		= 
--		,@strCode				= 
--		,@strReference			= 
--		,@intCurrencyId		= 
--		,@dblExchangeRate		= 
--		,@dtmDateEntered		= GETDATE()
--		,@dtmTransactionDate	= A.dtmDate
--		,@strJournalLineDescription = NULL 
--		,@ysnIsUnposted		= 0 
--		,@intConcurrencyId		= 1
--		,@intUserId			= 
--		,@strTransactionForm	= @TRANSACTION_FORM
--		,@strModuleName		= @MODULE_NAME
--		,@intEntityId			= A.intEntityId
--FROM	tblICInventoryTransaction A INNER JOIN @ItemsForProcessing B
--			ON A.intTransactionId = B.intTransactionId