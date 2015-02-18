﻿CREATE PROCEDURE [dbo].[uspICCreatePOInventoryTransaction]
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

-- Get a distinct list of items, per location, and per Purchase order. 
-- Store it in a temporary table 
BEGIN 
	CREATE TABLE #tmpPurchaseOrderItems (
		intItemId INT NOT NULL 
		,intItemLocationId INT NOT NULL 
		,dtmDate DATETIME
		,dblOrderQty NUMERIC(18,6) DEFAULT 0
		,dblUOMQty NUMERIC(18,6) DEFAULT 0
		,intItemUOMId INT 
		,dblValue NUMERIC(18,6)
		,intTransactionId INT
		,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	)

	INSERT INTO #tmpPurchaseOrderItems (
			intItemId
			,intItemLocationId
			,dtmDate
			,intTransactionId
			,strTransactionId
	)
	SELECT 	DISTINCT 
			Items.intItemId 
			,ItemLocation.intItemLocationId
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
	DELETE	SOItems
	FROM	#tmpPurchaseOrderItems SOItems
	WHERE	EXISTS (
				SELECT	TOP 1 1 
				FROM	dbo.tblICInventoryTransaction InvTransactions
				WHERE	InvTransactions.intItemId = SOItems.intItemId
						AND InvTransactions.intItemLocationId = SOItems.intItemLocationId
						AND InvTransactions.intTransactionId = SOItems.intTransactionId
						AND InvTransactions.strTransactionId = SOItems.strTransactionId
			)

	UPDATE	tempItems
	SET		dblOrderQty = AggregrateOrderQty.dblOrderQty
			,dblValue = AggregrateOrderQty.dblValue 
	FROM	(
				SELECT	dblOrderQty = SUM(ISNULL(POItems.dblQtyOrdered, 0)) 
						,dblValue = SUM(ISNULL(POItems.dblQtyOrdered, 0) * ISNULL(POItems.dblCost, 0)) 
						,Items.intItemId
						,Items.intItemLocationId
				FROM	dbo.tblPOPurchase PO INNER JOIN dbo.tblPOPurchaseDetail POItems
							ON PO.intPurchaseId = POItems.intPurchaseId				
						INNER JOIN dbo.tblICItemLocation ItemLocation
							ON POItems.intItemId = ItemLocation.intItemId
							AND ItemLocation.intLocationId = PO.intShipToId						
						INNER JOIN #tmpPurchaseOrderItems Items 
							ON Items.intItemId = POItems.intItemId
							AND Items.intItemLocationId = ItemLocation.intItemLocationId
				GROUP BY Items.intItemId, Items.intItemLocationId
			) AggregrateOrderQty INNER JOIN #tmpPurchaseOrderItems tempItems
				ON AggregrateOrderQty.intItemId = tempItems.intItemId
				AND AggregrateOrderQty.intItemLocationId = tempItems.intItemLocationId
END

-- Insert the Purchase Order to the Inventory Transaction table from the temporary table
BEGIN 	
	INSERT INTO dbo.tblICInventoryTransaction (
			intItemId
			,intItemLocationId
			,dtmDate
			,dblQty
			,dblUOMQty
			,dblCost
			,dblValue
			,intItemUOMId
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
			,dtmDate				
			,dblUnitQty				= dblOrderQty -- (total qty ordered from PO)
			,dblCost				= 0 -- Unable to track it. 
			,dblValue				-- (total value from PO)				
			,intItemUOMId			= 
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