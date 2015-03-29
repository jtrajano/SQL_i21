CREATE PROCEDURE [testi21Database].[Fake data for Item Stock Path]
AS
BEGIN
	EXEC testi21Database.[Fake inventory items]

	-- Create the fake tables for the stock path
	EXEC tSQLt.FakeTable 'dbo.tblICItemStockPath', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;

	-- Re-apply the constraints for the Item stock path table. 
	EXEC tSQLt.ApplyConstraint 'dbo.tblICItemStockPath','UN_tblICItemStockPath';
	EXEC tSQLt.ApplyConstraint 'dbo.tblICItemStockPath','FK_tblICItemStockPath_tblICItem';
	EXEC tSQLt.ApplyConstraint 'dbo.tblICItemStockPath','FK_tblICItemStockPath_tblICItemLocation';
	EXEC tSQLt.ApplyConstraint 'dbo.tblICItemStockPath','FK_tblICItemStockPath_tblICInventoryTransaction_Ancestor';
	EXEC tSQLt.ApplyConstraint 'dbo.tblICItemStockPath','FK_tblICItemStockPath_tblICInventoryTransaction_Descendant';

	-- Build fake data: inventory transactions
	/*
		WET GRAINS - NEW HAVEN
		----------------------
				|
				+--- PO-0001 (id: 1)
				|		|
				|		+---INVRCPT-0001 (id: 2)
				|				|
				|				+--- INVSHIP-0001 (id: 3)
				|						|
				|						+--- SO-0001 (id: 4)
				|
				+--- INVSHIP-0002 (id: 5, Partial shipment)
				|		|
				|		+--- SO-0002 (id 6, Big sales order)
				|
				+--- INVRCPT-0002 (id: 7)
				|
				+--- INVSHIP-0003 (id: 8, Another partial shipment for SO-0002)
						|
						+--- SO-0002 (id: 6)
	*/
	DECLARE @WetGrains AS INT = 1
	DECLARE @WetGrains_NewHaven AS INT = 6

	DECLARE @InventoryAutoNegative AS INT = 1
			,@InventoryWriteOffSold AS INT = 2
			,@InventoryRevalueSold AS INT = 3
			,@InventoryReceipt AS INT = 4
			,@InventoryShipment AS INT = 5
			,@PuchaseOrder AS INT = 6
			,@SalesOrder AS INT = 7

	INSERT INTO dbo.tblICInventoryTransaction (
		intItemId
		,intItemLocationId
		,dtmDate
		,dblQty
		,dblCost
		,dblValue
		,dblSalesPrice 		
		,strBatchId
		,strTransactionId
		,intTransactionId
		,ysnIsUnposted
		,intTransactionTypeId
	)
	-- intInventoryTransactionId: 1
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @WetGrains_NewHaven
			,dtmDate = '01/01/2014'
			,dblQty = 100
			,dblCost = 2.15
			,dblValue = 0
			,dblSalesPrice = 0
			,strBatchId = ''
			,strTransactionId = 'PO-0001'
			,intTransactionId = 1
			,ysnIsUnposted = 0
			,intTransactionTypeId = @PuchaseOrder
	-- intInventoryTransactionId: 2
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @WetGrains_NewHaven
			,dtmDate = '01/02/2014'
			,dblQty = 100
			,dblCost = 2.15
			,dblValue = 0
			,dblSalesPrice = 0
			,strBatchId = 'BATCH-0001'
			,strTransactionId = 'INVRCPT-0001'
			,intTransactionId = 1
			,ysnIsUnposted = 0
			,intTransactionTypeId = @InventoryReceipt
	-- intInventoryTransactionId: 3
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @WetGrains_NewHaven
			,dtmDate = '01/03/2014'
			,dblQty = -25
			,dblCost = 2.15
			,dblValue = 0
			,dblSalesPrice = 15.00
			,strBatchId = 'BATCH-0002'
			,strTransactionId = 'INVSHIP-0001'
			,intTransactionId = 1
			,ysnIsUnposted = 0
			,intTransactionTypeId = @InventoryShipment
	-- intInventoryTransactionId: 4
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @WetGrains_NewHaven
			,dtmDate = '01/04/2014'
			,dblQty = 25
			,dblCost = 2.00
			,dblValue = 0
			,dblSalesPrice = 16.00
			,strBatchId = ''
			,strTransactionId = 'SO-0001'
			,intTransactionId = 1
			,ysnIsUnposted = 0
			,intTransactionTypeId = @SalesOrder
	-- intInventoryTransactionId: 5
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @WetGrains_NewHaven
			,dtmDate = '01/05/2014'
			,dblQty = -30
			,dblCost = 2.00
			,dblValue = 0
			,dblSalesPrice = 17.00
			,strBatchId = 'BATCH-0003'
			,strTransactionId = 'INVSHIP-0002'
			,intTransactionId = 2
			,ysnIsUnposted = 0
			,intTransactionTypeId = @InventoryShipment
	-- intInventoryTransactionId: 6
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @WetGrains_NewHaven
			,dtmDate = '01/06/2014'
			,dblQty = 200
			,dblCost = 2.00
			,dblValue = 0
			,dblSalesPrice = 17.00
			,strBatchId = ''
			,strTransactionId = 'SO-0002'
			,intTransactionId = 2
			,ysnIsUnposted = 0
			,intTransactionTypeId = @SalesOrder
	-- intInventoryTransactionId: 7
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @WetGrains_NewHaven
			,dtmDate = '01/07/2014'
			,dblQty = 500
			,dblCost = 2.25
			,dblValue = 0
			,dblSalesPrice = 17.00
			,strBatchId = 'BATCH-0004'
			,strTransactionId = 'INVRCPT-0002'
			,intTransactionId = 2
			,ysnIsUnposted = 0
			,intTransactionTypeId = @InventoryReceipt
	-- intInventoryTransactionId: 8
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @WetGrains_NewHaven
			,dtmDate = '01/08/2014'
			,dblQty = -75
			,dblCost = 1.25
			,dblValue = 0
			,dblSalesPrice = 0
			,strBatchId = 'BATCH-0005'
			,strTransactionId = 'INVSHIP-0003'
			,intTransactionId = 3
			,ysnIsUnposted = 0
			,intTransactionTypeId = @InventoryShipment

	-- intInventoryTransactionId: 9
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @WetGrains_NewHaven
			,dtmDate = '01/05/2014'
			,dblQty = -30
			,dblCost = 2.00
			,dblValue = 0
			,dblSalesPrice = 17.00
			,strBatchId = 'BATCH-0003'
			,strTransactionId = 'INVSHIP-0002'
			,intTransactionId = 2
			,ysnIsUnposted = 0
			,intTransactionTypeId = @InventoryAutoNegative

	-- intInventoryTransactionId: 10
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @WetGrains_NewHaven
			,dtmDate = '01/05/2014'
			,dblQty = -30
			,dblCost = 2.00
			,dblValue = 0
			,dblSalesPrice = 17.00
			,strBatchId = 'BATCH-0003'
			,strTransactionId = 'INVSHIP-0002'
			,intTransactionId = 2
			,ysnIsUnposted = 0
			,intTransactionTypeId = @InventoryWriteOffSold

	-- intInventoryTransactionId: 11
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @WetGrains_NewHaven
			,dtmDate = '01/05/2014'
			,dblQty = -30
			,dblCost = 2.00
			,dblValue = 0
			,dblSalesPrice = 17.00
			,strBatchId = 'BATCH-0003'
			,strTransactionId = 'INVSHIP-0002'
			,intTransactionId = 2
			,ysnIsUnposted = 0
			,intTransactionTypeId = @InventoryRevalueSold

	-- intInventoryTransactionId: 12 (Unposted INVSHIP-0002)
	UNION ALL 
	SELECT	intItemId = @WetGrains
			,intItemLocationId = @WetGrains_NewHaven
			,dtmDate = '01/05/2014'
			,dblQty = -30
			,dblCost = 2.00
			,dblValue = 0
			,dblSalesPrice = 17.00
			,strBatchId = 'BATCH-0003'
			,strTransactionId = 'INVSHIP-0002'
			,intTransactionId = 2
			,ysnIsUnposted = 1
			,intTransactionTypeId = @InventoryShipment
END 
