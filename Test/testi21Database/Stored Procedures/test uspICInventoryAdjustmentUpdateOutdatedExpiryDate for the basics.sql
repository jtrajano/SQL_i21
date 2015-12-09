﻿CREATE PROCEDURE [testi21Database].[test uspICInventoryAdjustmentUpdateOutdatedExpiryDate for the basics]
AS
BEGIN
	-- Constant for Adjustment Types
	DECLARE @ADJUSTMENT_TYPE_QTY_CHANGE AS INT = 1
			,@ADJUSTMENT_TYPE_UOM_CHANGE AS INT = 2
			,@ADJUSTMENT_TYPE_ITEM_CHANGE AS INT = 3
			,@ADJUSTMENT_TYPE_LOT_STATUS_CHANGE AS INT = 4
			,@ADJUSTMENT_TYPE_LOT_ID_CHANGE AS INT = 5
			,@ADJUSTMENT_TYPE_EXPIRY_DATE_CHANGE AS INT = 6

	-- Arrange 
	BEGIN 
		DECLARE @strTransactionId AS NVARCHAR(50)
	END 

	-- Assert for no exceptions
	BEGIN 
		EXEC tSQLt.ExpectNoException;
	END
	
	-- Act
	BEGIN 
		EXEC dbo.uspICInventoryAdjustmentUpdateOutdatedExpiryDate 
			@strTransactionId
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
END 
