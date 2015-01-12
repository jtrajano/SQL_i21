CREATE PROCEDURE [testi21Database].[Fake data for COA used in costing]
AS
BEGIN
		-- Drop these views. It has dependencies with tblGLAccount table. Can't do fake table if these exists. 
		-- note: when tSQLt do the rollback, the views are rolled back as well. 
		DROP VIEW vyuAPBill
		DROP VIEW vyuAPBillBatch
		DROP VIEW vyuAPPayablesAgingSummary
		DROP VIEW vyuAPPaymentDetail
		DROP VIEW vyuAPVendor
		DROP VIEW vyuAPRecapTransaction

		-- Create the fake table		
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountStructure';
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountSegment';
		EXEC tSQLt.FakeTable 'dbo.tblGLAccount';
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountSegmentMapping', @Identity = 1;

		-- Declare the account ids
		DECLARE @Inventory_Default AS INT = 1000
		DECLARE @CostOfGoods_Default AS INT = 2000
		DECLARE @APClearing_Default AS INT = 3000
		DECLARE @WriteOffSold_Default AS INT = 4000
		DECLARE @RevalueSold_Default AS INT = 5000 
		DECLARE @AutoNegative_Default AS INT = 6000

		DECLARE @Inventory_NewHaven AS INT = 1001
		DECLARE @CostOfGoods_NewHaven AS INT = 2001
		DECLARE @APClearing_NewHaven AS INT = 3001
		DECLARE @WriteOffSold_NewHaven AS INT = 4001
		DECLARE @RevalueSold_NewHaven AS INT = 5001
		DECLARE @AutoNegative_NewHaven AS INT = 6001

		DECLARE @Inventory_BetterHaven AS INT = 1002
		DECLARE @CostOfGoods_BetterHaven AS INT = 2002
		DECLARE @APClearing_BetterHaven AS INT = 3002
		DECLARE @WriteOffSold_BetterHaven AS INT = 4002
		DECLARE @RevalueSold_BetterHaven AS INT = 5002
		DECLARE @AutoNegative_BetterHaven AS INT = 6002

		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
		-- Add fake data for Account Structure
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask) VALUES (90, 'Primary', 1, '0')
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask) VALUES (91, 'Divider', 0, '-')
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask) VALUES (92, 'Segment', 2, '0')

		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Add fake data for Account Segment
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (1, '12040', 'INVENTORY WHEAT', 90)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (2, '20100', 'COST OF GOODS WHEAT', 90)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (3, '30110', 'AP Clearing WHEAT', 90)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (4, '40110', 'WRITE-OFF SOLD WHEAT', 90)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (5, '50110', 'REVALUE SOLD WHEAT', 90)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (6, '60110', 'AUTO NEGATIVE WHEAT', 90)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (100, '1000', 'DEFAULT', 92)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (101, '1001', 'NEW HAVEN GRAIN', 92)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (102, '1002', 'BETTER HAVEN GRAIN', 92)

		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Add fake data for GL Account
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@Inventory_Default, 'INVENTORY WHEAT-DEFAULT', '12040-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@CostOfGoods_Default, 'COST OF GOODS WHEAT-DEFAULT', '20100-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@APClearing_Default, 'AP Clearing WHEAT-DEFAULT', '30110-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@WriteOffSold_Default, 'WRITE-OFF SOLD WHEAT-DEFAULT', '40110-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@RevalueSold_Default, 'REVALUE SOLD WHEAT-DEFAULT', '50110-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@AutoNegative_Default, 'AUTO NEGATIVE WHEAT-DEFAULT', '60110-1000');

		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@Inventory_NewHaven, 'INVENTORY WHEAT-NEW HAVEN GRAIN', '12040-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@CostOfGoods_NewHaven, 'COST OF GOODS WHEAT-NEW HAVEN GRAIN', '20100-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@APClearing_NewHaven, 'AP Clearing WHEAT-NEW HAVEN GRAIN', '30110-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@WriteOffSold_NewHaven, 'WRITE-OFF SOLD WHEAT-NEW HAVEN GRAIN', '40110-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@RevalueSold_NewHaven, 'REVALUE SOLD WHEAT-NEW HAVEN GRAIN', '50110-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@AutoNegative_NewHaven, 'AUTO NEGATIVE WHEAT-NEW HAVEN GRAIN', '60110-1001');

		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@Inventory_BetterHaven, 'INVENTORY WHEAT-BETTER HAVEN GRAIN', '12040-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@CostOfGoods_BetterHaven, 'COST OF GOODS WHEAT-BETTER HAVEN GRAIN', '20100-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@APClearing_BetterHaven, 'AP Clearing WHEAT-BETTER HAVEN GRAIN', '30110-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@WriteOffSold_BetterHaven, 'WRITE-OFF SOLD WHEAT-BETTER HAVEN GRAIN', '40110-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@RevalueSold_BetterHaven, 'REVALUE SOLD WHEAT-BETTER HAVEN GRAIN', '50110-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@AutoNegative_BetterHaven, 'AUTO NEGATIVE WHEAT-BETTER HAVEN GRAIN', '60110-1002');

		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Add fake data for Segment Mapping
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- for DEFAULT location 
		BEGIN 
			--INVENTORY WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@Inventory_Default, 1);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@Inventory_Default, 100);
			-- COST OF GOODS WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@CostOfGoods_Default, 2);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@CostOfGoods_Default, 100);
			-- AP Clearing WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@APClearing_Default, 3);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@APClearing_Default, 100);

			-- WRITE-OFF SOLD WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@WriteOffSold_Default, 4);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@WriteOffSold_Default, 100);
			
			-- REVALUE SOLD WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@RevalueSold_Default, 5);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@RevalueSold_Default, 100);
			
			-- AUTO NEGATIVE WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AutoNegative_Default, 6);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AutoNegative_Default, 100);
		END 

		-- for NEW HAVEN location 
		BEGIN 
			-- INVENTORY WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@Inventory_NewHaven, 1);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@Inventory_NewHaven, 101);

			-- COST OF GOODS WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@CostOfGoods_NewHaven, 2);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@CostOfGoods_NewHaven, 101);

			-- AP Clearing WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@APClearing_NewHaven, 3);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@APClearing_NewHaven, 101);	

			-- WRITE-OFF SOLD WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@WriteOffSold_NewHaven, 4);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@WriteOffSold_NewHaven, 101);

			-- REVALUE SOLD WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@RevalueSold_NewHaven, 5);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@RevalueSold_NewHaven, 101);
			
			-- AUTO NEGATIVE WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AutoNegative_NewHaven, 6);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AutoNegative_NewHaven, 101);
		END 

		-- for BETTER HAVEN location 
		BEGIN 
			-- INVENTORY WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@Inventory_BetterHaven, 1);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@Inventory_BetterHaven, 102);

			-- COST OF GOODS WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@CostOfGoods_BetterHaven, 2);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@CostOfGoods_BetterHaven, 102);

			-- AP Clearing WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@APClearing_BetterHaven, 3);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@APClearing_BetterHaven, 102);	

			-- WRITE-OFF SOLD WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@WriteOffSold_BetterHaven, 4);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@WriteOffSold_BetterHaven, 102);

			-- REVALUE SOLD WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@RevalueSold_BetterHaven, 5);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@RevalueSold_BetterHaven, 102);
			
			-- AUTO NEGATIVE WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AutoNegative_BetterHaven, 6);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AutoNegative_BetterHaven, 102);
		END
END 