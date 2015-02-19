CREATE PROCEDURE [dbo].[uspICCreatePOInventoryTransaction]
	@intInventoryReceiptId AS INT
	,@intUserId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

/*
	Receipt Types: 
	-------------------
	Contract
	Purchase Order
	Transfer Receipt
	Direct Transfer
	Direct
*/

-- Get the transation type id
BEGIN 
	DECLARE @intTransactionTypeId AS INT 
			,@TransactionTypeName AS NVARCHAR(200)

	SELECT	@intTransactionTypeId = intTransactionTypeId
			,@TransactionTypeName = strName
	FROM	tblICInventoryTransactionType 
	WHERE	strName = 'Purchase Order'
END 

-- Get a distinct list of items, per location, per UOM, and per Purchase order. 
-- Store it in a temporary table 
BEGIN 
	CREATE TABLE #tmpPurchaseOrderItems (
		intItemId INT NOT NULL 
		,intItemLocationId INT NOT NULL 
		,intItemUOMId INT 
		,dtmDate DATETIME
		,dblOrderQty NUMERIC(18,6) DEFAULT 0
		,dblUOMQty NUMERIC(18,6) DEFAULT 0		
		,dblValue NUMERIC(18,6)
		,intTransactionId INT
		,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	)

	INSERT INTO #tmpPurchaseOrderItems (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,dtmDate
			,intTransactionId
			,strTransactionId			
	)
	SELECT 	DISTINCT 
			Items.intItemId 
			,ItemLocation.intItemLocationId
			,Items.intUnitMeasureId
			,PO.dtmDate
			,intTransactionId = Items.intSourceId
			,strTransactionId = PO.strPurchaseOrderNumber			
	FROM	dbo.tblICInventoryReceipt Header INNER JOIN dbo.tblICInventoryReceiptItem Items
				ON Header.intInventoryReceiptId = Items.intInventoryReceiptId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = Items.intItemId
				AND ItemLocation.intLocationId = Header.intLocationId
			INNER JOIN dbo.tblPOPurchase PO
				ON PO.intPurchaseId = Items.intSourceId
	WHERE	Header.intInventoryReceiptId = @intInventoryReceiptId
			AND Header.strReceiptType = 'Purchase Order'
			AND Items.intSourceId IS NOT NULL 

	-- Remove duplicate records 
	DELETE	POItems
	FROM	#tmpPurchaseOrderItems POItems
	WHERE	EXISTS (
				SELECT	TOP 1 1 
				FROM	dbo.tblICInventoryTransaction InvTransactions
				WHERE	InvTransactions.intItemId = POItems.intItemId
						AND InvTransactions.intItemLocationId = POItems.intItemLocationId
						AND InvTransactions.intItemUOMId = POItems.intItemLocationId
						AND InvTransactions.intTransactionId = POItems.intTransactionId
						AND InvTransactions.strTransactionId = POItems.strTransactionId
			)

	-- Update the ordered qty. 
	-- Group it by item, location, and UOM. 
	UPDATE	tempItems
	SET		dblOrderQty = AggregrateOrderQty.dblOrderQty
			,dblValue = AggregrateOrderQty.dblValue 
	FROM	(
				SELECT	dblOrderQty = SUM(ISNULL(POItems.dblQtyOrdered, 0)) 
						,dblValue = SUM(ISNULL(POItems.dblQtyOrdered, 0) * ISNULL(POItems.dblCost, 0)) 
						,Items.intItemId
						,Items.intItemLocationId
						,POItems.intUnitOfMeasureId
				FROM	dbo.tblPOPurchase PO INNER JOIN dbo.tblPOPurchaseDetail POItems
							ON PO.intPurchaseId = POItems.intPurchaseId				
						INNER JOIN dbo.tblICItemLocation ItemLocation
							ON POItems.intItemId = ItemLocation.intItemId
							AND ItemLocation.intLocationId = PO.intShipToId						
						INNER JOIN #tmpPurchaseOrderItems Items 
							ON Items.intItemId = POItems.intItemId
							AND Items.intItemLocationId = ItemLocation.intItemLocationId
				GROUP BY Items.intItemId, Items.intItemLocationId, POItems.intUnitOfMeasureId
			) AggregrateOrderQty INNER JOIN #tmpPurchaseOrderItems tempItems
				ON AggregrateOrderQty.intItemId = tempItems.intItemId
				AND AggregrateOrderQty.intItemLocationId = tempItems.intItemLocationId
				AND AggregrateOrderQty.intUnitOfMeasureId = tempItems.intItemUOMId

	-- Get the UOM Qty 
	UPDATE	tempItems
	SET		dblUOMQty = ItemUOM.dblUnitQty
	FROM	#tmpPurchaseOrderItems tempItems INNER JOIN dbo.tblICItemUOM ItemUOM
				ON tempItems.intItemId = ItemUOM.intItemId
				AND tempItems.intItemUOMId = ItemUOM.intItemUOMId

END

-- Insert the Purchase Order to the Inventory Transaction table from the temporary table
BEGIN 	
	INSERT INTO dbo.tblICInventoryTransaction (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,dtmDate
			,dblQty
			,dblUOMQty
			,dblCost
			,dblValue
			,dblSalesPrice
			,intCurrencyId
			,dblExchangeRate
			,intTransactionId
			,strTransactionId
			,strBatchId
			,intTransactionTypeId
			,intLotId
			,ysnIsUnposted
			,strTransactionForm
			,dtmCreated
			,intCreatedUserId
			,intConcurrencyId
	)
	SELECT 	intItemId 
			,intItemLocationId
			,intItemUOMId			= Items.intItemUOMId -- UOM used in the PO. 
			,dtmDate				
			,dblQty					= dblOrderQty -- (total qty ordered from PO)
			,dblUOMQty				= dblUOMQty -- (unit qty of the UOM)
			,dblCost				= 0 -- Unable to track it. 
			,dblValue				-- (total value from PO)			
			,dblSalesPrice			= 0 -- Tracking not needed
			,intCurrencyId			= NULL -- Tracking not needed
			,dblExchangeRate		= 1 -- Tracking not needed
			,intTransactionId		
			,strTransactionId 
			,strBatchId				= ''  -- Tracking not needed
			,intTransactionTypeId	= @intTransactionTypeId
			,intLotId				= NULL  -- Tracking not needed
			,ysnIsUnposted			= 0
			,strTransactionForm		= @TransactionTypeName
			,dtmCreated				= GETDATE()
			,intCreatedUserId		= @intUserId
			,intConcurrencyId		= 1
	FROM	#tmpPurchaseOrderItems Items 
END

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpPurchaseOrderItems')) 
	DROP TABLE #tmpPurchaseOrderItems