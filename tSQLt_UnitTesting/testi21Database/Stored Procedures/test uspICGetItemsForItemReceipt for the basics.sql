
CREATE PROCEDURE [testi21Database].[test uspICGetItemsForItemReceipt for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Create the assert tables 
		-- Assert table for the expected
		SELECT	intItemId				= PODetail.intItemId
				,intItemLocationId		= ItemLocation.intItemLocationId
				,dtmDate				= dbo.fnRemoveTimeOnDate(GETDATE())
				,dblUnitQty				= PODetail.dblQtyOrdered 
				,dblUOMQty				= ItemUOM.dblUnitQty 
				,dblCost				= PODetail.dblCost
				,dblSalesPrice			= 0
				,intCurrencyId			= PO.intCurrencyId
				,dblExchangeRate		= 1
				,intTransactionId		= PO.intPurchaseId
				,strTransactionId		= PO.strPurchaseOrderNumber
				,intTransactionTypeId	= CAST(NULL AS INT) 
				,intLotId				= CAST(NULL AS INT) 
		INTO	expected
		FROM	dbo.tblPOPurchase PO INNER JOIN dbo.tblPOPurchaseDetail PODetail
					ON PO.intPurchaseId = PODetail.intPurchaseId
				INNER JOIN dbo.tblICItemUOM ItemUOM
					ON PODetail.intItemId = ItemUOM.intItemId
					AND PODetail.intUnitOfMeasureId = ItemUOM.intUnitMeasureId
				INNER JOIN dbo.tblICUnitMeasure UOM
					ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
				INNER JOIN dbo.tblICItemLocation ItemLocation
					ON PODetail.intItemId = ItemLocation.intItemId
					AND PODetail.intLocationId = ItemLocation.intLocationId
		WHERE	1 = 0

		-- Assert table for the actual 
		SELECT	* 
		INTO	actual
		FROM	expected
	END 
	
	-- Act 
	-- Try to use the SP with NULL arguments on all parameters
	BEGIN 
		INSERT INTO actual (
			intItemId
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
		)
		EXEC dbo.uspICGetItemsForItemReceipt 
			@intSourceTransactionId = NULL 
			,@strSourceType = NULL 
	END 

	-- Assert
	BEGIN
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END 