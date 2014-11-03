
/*
	This is the stored procedure that handles the "posting" of items. 
	
	It uses a cursor to iterate over the list of records found in the @ItemsToProcess table-parameter(variable). 

	The each iteration, it does the following: 
		1. Determines if a stock is for incoming or outgoing then calls the appropriate stored procedure. 
		2. Determines the type of inventory transaction it is, whether an in, out, or cost adjustment. 

	Parameters: 
	@ItemsToProcess - A user-defined table type. This is a table variable that tells this SP what items to process. 
	
	@strBatchId - The generated batch id from the calling code. This is the same batch id this SP will use when posting the financials of an item. 

	@strAccountDescription - The contra g/l account id to use when posting an item. By default, it is set to "Cost of Goods". 
				The calling code needs to specify it because each module may use a different contra g/l account against the 
				Inventory account. For example, a Sales transaction will contra Inventory account with "Cost of Goods" while 
				Receive stocks from AP module may use "A/P Clearing".
*/

CREATE PROCEDURE [dbo].[uspICPostCosting]
	@ItemsToProcess AS ItemCostingTableType READONLY
	,@strBatchId AS NVARCHAR(20)
	,@strAccountDescription AS NVARCHAR(255) = 'Cost of Goods'
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

	-- Get the g/l accounts id to use. 
	-- 1. Internal values: Retrieve Inventory, RevalueSold, WriteOffSold, and AutoNegative. 
	-- 2. Defined value: retrieve the contra-g/l account id (ContraInventory). 
	INSERT INTO @GLAccounts (
		Inventory
		,ContraInventory
		,RevalueSold
		,WriteOffSold
		,AutoNegative
	)
	SELECT	Inventory = dbo.fnGetItemGLAccount(@intItemId, @intItemLocationId, 'Inventory')
			,ContraInventory = dbo.fnGetItemGLAccount(@intItemId, @intItemLocationId, @strAccountDescription)
			,RevalueSold = NULL -- TODO
			,WriteOffSold = NULL -- TODO
			,AutoNegative = NULL -- TODO

	-- Moving Average Cost

	-- FIFO

	-- LIFO

	-- Generate the G/L entries by reading the data from tblICInventoryTransaction


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