CREATE PROCEDURE testi21Database.[test the fnGetGLAccountIdFromItemLocation function]
AS 
BEGIN
	-- Arrange
	BEGIN 
		DECLARE @intItemId AS INT
		DECLARE @intLocationId AS INT

		DECLARE @actual AS INT;
		DECLARE @expected AS INT;

		-- GL Account types used in inventory costing
		DECLARE @InventoryAccountId AS INT = 1;
		DECLARE @COGSAccountId AS INT = 2;
		DECLARE @SalesAccountId AS INT = 3;
		DECLARE @RevalueCostAccountId AS INT = 4;
		DECLARE @WriteOffCostAccountId AS INT = 5;
		DECLARE @AutoNegativeAccountId AS INT = 6;
		
		-- Drop these views. It has dependencies with tblGLAccount table. Can't do fake table if these exists. 
		-- note: when tSQLt do the rollback, the views are rolled back as well. 
		DROP VIEW vyuAPBill
		DROP VIEW vyuAPBillBatch
		DROP VIEW vyuAPPayablesAgingSummary
		DROP VIEW vyuAPPaymentDetail
		DROP VIEW vyuAPVendor
		
		EXEC tSQLt.FakeTable 'dbo.tblICItemLocationStore', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLAccount';
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountSegment';
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountSegmentMapping', @Identity = 1;

		-- Add fake data for Item-Location
		-- TODO: Add the fields for the g/l account ids
		INSERT INTO tblICItemLocation (intItemId, intLocationId) VALUES (1, 100)
		INSERT INTO tblICItemLocation (intItemId, intLocationId) VALUES (2, 100)
		INSERT INTO tblICItemLocation (intItemId, intLocationId) VALUES (3, 200)
		INSERT INTO tblICItemLocation (intItemId, intLocationId) VALUES (4, 200)
		INSERT INTO tblICItemLocation (intItemId, intLocationId) VALUES (400, 200)
		INSERT INTO tblICItemLocation (intItemId, intLocationId) VALUES (10000, 100)

		-- Add fake data for Account Segment
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription) VALUES (1, '12040', 'INVENTORY WHEAT')
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription) VALUES (2, '40100', 'SALES WHEAT')
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription) VALUES (3, '50110', 'PURCHASES WHEAT')
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription) VALUES (100, '1000', '')
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription) VALUES (101, '1001', 'NEW HAVEN GRAIN')

		-- Add fake data for GL Account
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (1000, 'INVENTORY WHEAT-', '12040-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (2000, 'SALES WHEAT-', '40100-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (3000, 'PURCHASES WHEAT-', '50110-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (1001, 'INVENTORY WHEAT-NEW HAVEN GRAIN', '12040-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (2001, 'SALES WHEAT-NEW HAVEN GRAIN', '40100-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (3001, 'PURCHASES WHEAT-NEW HAVEN GRAIN', '50110-1001');

		-- Add fake data for Segment Mapping
		-- INVENTORY WHEAT-'
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (1000, 1);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (1000, 100);
		-- SALES WHEAT-
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (2000, 1);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (2000, 100);
		-- PURCHASES WHEAT-
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (3000, 1);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (3000, 100);
		-- INVENTORY WHEAT-NEW HAVEN GRAIN
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (1001, 1);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (1001, 101);
		-- SALES WHEAT-NEW HAVEN GRAIN
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (2001, 1);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (2001, 101);
		-- PURCHASES WHEAT-NEW HAVEN GRAIN
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (3001, 1);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (3001, 101);

	END

	-- Act
	-- 1. Must return NULL if item id and location are both NULL. 
	BEGIN 
		SELECT @actual = [dbo].[fnGetGLAccountIdFromItemLocation](@intItemId, @intLocationId, @InventoryAccountId);

		-- Assert
		-- If item and location is null, expected must return NULL. 
		SET @expected = NULL;
		EXEC tSQLt.AssertEquals @expected, @actual; 
	END

	-- 2. Must return account id 12040-1001 (INVENTORY WHEAT-NEW HAVEN GRAIN)
	BEGIN 
		SET @intItemId = 1;
		SET @intLocationId = 100;	

		SELECT @actual = [dbo].[fnGetGLAccountIdFromItemLocation](@intItemId, @intLocationId, @InventoryAccountId);

		-- Assert
		SET @expected = 1001;
		EXEC tSQLt.AssertEquals @expected, @actual; 

	END 
	
	-- Clean-up: remove the tables used in the unit test
	--IF OBJECT_ID('actual') IS NOT NULL 
	--	DROP TABLE actual

	--IF OBJECT_ID('expected') IS NOT NULL 
	--	DROP TABLE dbo.expected
END 