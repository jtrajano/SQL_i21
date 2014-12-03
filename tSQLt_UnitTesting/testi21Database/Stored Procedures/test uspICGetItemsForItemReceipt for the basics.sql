
CREATE PROCEDURE [testi21Database].[test uspICGetItemsForItemReceipt for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Create the assert tables 
		-- Assert table for the expected
		SELECT	intItemId				= PODetail.intItemId
				,intLocationId			= PODetail.intLocationId
				,dtmDate				= dbo.fnRemoveTimeOnDate(GETDATE())
				,dblUnitQty				= PODetail.dblQtyOrdered 
				,dblUOMQty				= UOMConversion.dblConversionToStock 
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
				LEFT JOIN dbo.tblICUnitMeasure UOM
					ON PODetail.intUnitOfMeasureId = UOM.intUnitMeasureId
				INNER JOIN dbo.tblICUnitMeasureConversion UOMConversion
					ON UOM.intUnitMeasureId = UOMConversion.intUnitMeasureId
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
			,intLocationId
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