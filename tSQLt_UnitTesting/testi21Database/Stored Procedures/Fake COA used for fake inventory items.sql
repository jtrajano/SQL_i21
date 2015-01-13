CREATE PROCEDURE [testi21Database].[Fake COA used for fake inventory items]
AS
BEGIN
		-- Create the fake table		
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountGroup';
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
		DECLARE @InventoryInTransit_Default AS INT = 7000

		DECLARE @Inventory_NewHaven AS INT = 1001
		DECLARE @CostOfGoods_NewHaven AS INT = 2001
		DECLARE @APClearing_NewHaven AS INT = 3001
		DECLARE @WriteOffSold_NewHaven AS INT = 4001
		DECLARE @RevalueSold_NewHaven AS INT = 5001
		DECLARE @AutoNegative_NewHaven AS INT = 6001
		DECLARE @InventoryInTransit_NewHaven AS INT = 7001

		DECLARE @Inventory_BetterHaven AS INT = 1002
		DECLARE @CostOfGoods_BetterHaven AS INT = 2002
		DECLARE @APClearing_BetterHaven AS INT = 3002
		DECLARE @WriteOffSold_BetterHaven AS INT = 4002
		DECLARE @RevalueSold_BetterHaven AS INT = 5002
		DECLARE @AutoNegative_BetterHaven AS INT = 6002
		DECLARE @InventoryInTransit_BetterHaven AS INT = 7002

		-- Constant Variables
		DECLARE @Group_Asset AS INT = 1
		DECLARE @Group_Liability AS INT = 2
		DECLARE @Group_Equity AS INT = 3
		DECLARE @Group_Revenue AS INT = 4
		DECLARE @Group_Expenses AS INT = 5
		DECLARE @Group_Sales AS INT = 6
		DECLARE @Group_CostOfGoodsSold AS INT = 7
		DECLARE @Group_CashAccounts AS INT = 8
		DECLARE @Group_Receivables AS INT = 9
		DECLARE @Group_Inventory AS INT = 10
		DECLARE @Group_MiscExpenses AS INT = 11

		-- Add fake data fro the Account Group
		INSERT INTO tblGLAccountGroup (intAccountGroupId, strAccountGroup, strAccountType, intParentGroupId,intGroup,intSort)
		SELECT				@Group_Asset, 'Asset', 'Asset', 0, 1, 10000
		UNION ALL SELECT	@Group_Liability, 'Liability', 'Liability', 0, 1, 20000
		UNION ALL SELECT	@Group_Equity, 'Equity', 'Equity', 0, 1, 30000
		UNION ALL SELECT	@Group_Revenue, 'Revenue', 'Revenue', 0, 1, 40000
		UNION ALL SELECT	@Group_Expenses, 'Expenses', 'Expenses', 0, 1, 50000
		UNION ALL SELECT	@Group_Sales, 'Sales', 'Sales', 0, 1, 60000
		UNION ALL SELECT	@Group_CostOfGoodsSold, 'Cost of Goods Sold', 'Cost of Goods Sold', 0, 1, 70000
		UNION ALL SELECT	@Group_CashAccounts, 'Cash Accounts', 'Asset', 1, NULL, 10001
		UNION ALL SELECT	@Group_Receivables, 'Receivables', 'Asset', 1, NULL, 10002
		UNION ALL SELECT	@Group_Inventory, 'Inventory', 'Asset', 1, NULL, 10003
		UNION ALL SELECT	@Group_MiscExpenses, 'Miscellaneous Expenses', 'Expenses', 5, NULL, 50001

		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
		-- Add fake data for Account Structure
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Primary account segment 
		DECLARE @AccountStructureId_Primary AS INT = 90
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask, strStructureName) VALUES (90, 'Primary', 1, '0', 'Primary Segment')

		-- Divider
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask) VALUES (91, 'Divider', 0, '-')

		-- Location account segment 
		DECLARE @AccountStructureId_Location AS INT = 92
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask, strStructureName) VALUES (@AccountStructureId_Location, 'Segment', 2, '0', 'Location')

		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Add fake data for Account Segment
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		DECLARE @SegmentId_INVENTORY_WHEAT AS INT = 1
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SegmentId_INVENTORY_WHEAT, '12040', 'INVENTORY WHEAT', @AccountStructureId_Primary)
		
		DECLARE @SegmentId_COST_OF_GOODS_WHEAT AS INT = 2
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SegmentId_COST_OF_GOODS_WHEAT, '20100', 'COST OF GOODS WHEAT', @AccountStructureId_Primary)

		DECLARE @SegmentId_AP_Clearing_WHEAT AS INT = 3
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SegmentId_AP_Clearing_WHEAT, '30110', 'AP CLEARING WHEAT', @AccountStructureId_Primary)

		DECLARE @SegmentId_WRITE_OFF_SOLD_WHEAT AS INT = 4
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SegmentId_WRITE_OFF_SOLD_WHEAT, '40110', 'WRITE-OFF SOLD WHEAT', @AccountStructureId_Primary)

		DECLARE @SegmentId_REVALUE_SOLD_WHEAT AS INT = 5
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SegmentId_REVALUE_SOLD_WHEAT, '50110', 'REVALUE SOLD WHEAT', @AccountStructureId_Primary)

		DECLARE @SegmentId_AUTO_NEGATIVE_WHEAT AS INT = 6
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SegmentId_AUTO_NEGATIVE_WHEAT, '60110', 'AUTO NEGATIVE WHEAT', @AccountStructureId_Primary)

		DECLARE @SegmentId_INVENTORY_IN_TRANSIT AS INT = 7
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SegmentId_INVENTORY_IN_TRANSIT, '12050', 'INVENTORY IN TRANSIT', @AccountStructureId_Primary)

		DECLARE @SegmentId_DEFAULT_LOCATION AS INT = 100
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SegmentId_DEFAULT_LOCATION, '1000', 'DEFAULT', @AccountStructureId_Location)

		DECLARE @SegmentId_NEW_HAVEN_LOCATION AS INT = 101
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SegmentId_NEW_HAVEN_LOCATION, '1001', 'NEW HAVEN', @AccountStructureId_Location)

		DECLARE @SegmentId_BETTER_HAVEN_LOCATION AS INT = 102
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SegmentId_BETTER_HAVEN_LOCATION, '1002', 'BETTER HAVEN', @AccountStructureId_Location)

		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Add fake data for GL Account
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@Inventory_Default, 'INVENTORY WHEAT-DEFAULT', '12040-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@CostOfGoods_Default, 'COST OF GOODS WHEAT-DEFAULT', '20100-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@APClearing_Default, 'AP CLEARING WHEAT-DEFAULT', '30110-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@WriteOffSold_Default, 'WRITE-OFF SOLD WHEAT-DEFAULT', '40110-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@RevalueSold_Default, 'REVALUE SOLD WHEAT-DEFAULT', '50110-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@AutoNegative_Default, 'AUTO NEGATIVE WHEAT-DEFAULT', '60110-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@InventoryInTransit_Default, 'INVENTORY IN TRANSIT-DEFAULT', '12050-1000');

		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@Inventory_NewHaven, 'INVENTORY WHEAT-NEW HAVEN', '12040-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@CostOfGoods_NewHaven, 'COST OF GOODS WHEAT-NEW HAVEN', '20100-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@APClearing_NewHaven, 'AP CLEARING WHEAT-NEW HAVEN', '30110-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@WriteOffSold_NewHaven, 'WRITE-OFF SOLD WHEAT-NEW HAVEN', '40110-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@RevalueSold_NewHaven, 'REVALUE SOLD WHEAT-NEW HAVEN', '50110-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@AutoNegative_NewHaven, 'AUTO NEGATIVE WHEAT-NEW HAVEN', '60110-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@InventoryInTransit_NewHaven, 'INVENTORY IN TRANSIT-NEW HAVEN', '12050-1001');

		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@Inventory_BetterHaven, 'INVENTORY WHEAT-BETTER HAVEN', '12040-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@CostOfGoods_BetterHaven, 'COST OF GOODS WHEAT-BETTER HAVEN', '20100-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@APClearing_BetterHaven, 'AP CLEARING WHEAT-BETTER HAVEN', '30110-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@WriteOffSold_BetterHaven, 'WRITE-OFF SOLD WHEAT-BETTER HAVEN', '40110-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@RevalueSold_BetterHaven, 'REVALUE SOLD WHEAT-BETTER HAVEN', '50110-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@AutoNegative_BetterHaven, 'AUTO NEGATIVE WHEAT-BETTER HAVEN', '60110-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@InventoryInTransit_BetterHaven, 'INVENTORY IN TRANSIT-BETTER HAVEN', '12050-1001');

		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Add fake data for Segment Mapping
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- for DEFAULT location 
		BEGIN 
			--INVENTORY WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@Inventory_Default, @SegmentId_INVENTORY_WHEAT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@Inventory_Default, @SegmentId_DEFAULT_LOCATION);

			-- COST OF GOODS WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@CostOfGoods_Default, @SegmentId_COST_OF_GOODS_WHEAT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@CostOfGoods_Default, @SegmentId_DEFAULT_LOCATION);
			-- AP CLEARING WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@APClearing_Default, @SegmentId_AP_Clearing_WHEAT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@APClearing_Default, @SegmentId_DEFAULT_LOCATION);

			-- WRITE-OFF SOLD WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@WriteOffSold_Default, @SegmentId_WRITE_OFF_SOLD_WHEAT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@WriteOffSold_Default, @SegmentId_DEFAULT_LOCATION);
			
			-- REVALUE SOLD WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@RevalueSold_Default, @SegmentId_REVALUE_SOLD_WHEAT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@RevalueSold_Default, @SegmentId_DEFAULT_LOCATION);
			
			-- AUTO NEGATIVE WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AutoNegative_Default, @SegmentId_AUTO_NEGATIVE_WHEAT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AutoNegative_Default, @SegmentId_DEFAULT_LOCATION);

			-- INVENTORY IN TRANSIT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@InventoryInTransit_Default, @SegmentId_INVENTORY_IN_TRANSIT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@InventoryInTransit_Default, @SegmentId_DEFAULT_LOCATION);
		END 

		-- for NEW HAVEN location 
		BEGIN 
			-- INVENTORY WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@Inventory_NewHaven, @SegmentId_INVENTORY_WHEAT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@Inventory_NewHaven, @SegmentId_NEW_HAVEN_LOCATION);

			-- COST OF GOODS WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@CostOfGoods_NewHaven, @SegmentId_COST_OF_GOODS_WHEAT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@CostOfGoods_NewHaven, @SegmentId_NEW_HAVEN_LOCATION);

			-- AP CLEARING WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@APClearing_NewHaven, @SegmentId_AP_Clearing_WHEAT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@APClearing_NewHaven, @SegmentId_NEW_HAVEN_LOCATION);	

			-- WRITE-OFF SOLD WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@WriteOffSold_NewHaven, @SegmentId_WRITE_OFF_SOLD_WHEAT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@WriteOffSold_NewHaven, @SegmentId_NEW_HAVEN_LOCATION);

			-- REVALUE SOLD WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@RevalueSold_NewHaven, @SegmentId_REVALUE_SOLD_WHEAT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@RevalueSold_NewHaven, @SegmentId_NEW_HAVEN_LOCATION);
			
			-- AUTO NEGATIVE WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AutoNegative_NewHaven, @SegmentId_AUTO_NEGATIVE_WHEAT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AutoNegative_NewHaven, @SegmentId_NEW_HAVEN_LOCATION);

			-- INVENTORY IN TRANSIT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@InventoryInTransit_NewHaven, @SegmentId_INVENTORY_IN_TRANSIT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@InventoryInTransit_NewHaven, @SegmentId_NEW_HAVEN_LOCATION);
		END 

		-- for BETTER HAVEN location 
		BEGIN 
			-- INVENTORY WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@Inventory_BetterHaven, @SegmentId_INVENTORY_WHEAT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@Inventory_BetterHaven, @SegmentId_BETTER_HAVEN_LOCATION);

			-- COST OF GOODS WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@CostOfGoods_BetterHaven, @SegmentId_COST_OF_GOODS_WHEAT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@CostOfGoods_BetterHaven, @SegmentId_BETTER_HAVEN_LOCATION);

			-- AP CLEARING WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@APClearing_BetterHaven, @SegmentId_AP_Clearing_WHEAT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@APClearing_BetterHaven, @SegmentId_BETTER_HAVEN_LOCATION);	

			-- WRITE-OFF SOLD WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@WriteOffSold_BetterHaven, @SegmentId_WRITE_OFF_SOLD_WHEAT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@WriteOffSold_BetterHaven, @SegmentId_BETTER_HAVEN_LOCATION);

			-- REVALUE SOLD WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@RevalueSold_BetterHaven, @SegmentId_REVALUE_SOLD_WHEAT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@RevalueSold_BetterHaven, @SegmentId_BETTER_HAVEN_LOCATION);
			
			-- AUTO NEGATIVE WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AutoNegative_BetterHaven, @SegmentId_AUTO_NEGATIVE_WHEAT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AutoNegative_BetterHaven, @SegmentId_BETTER_HAVEN_LOCATION);

			-- INVENTORY IN TRANSIT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@InventoryInTransit_BetterHaven, @SegmentId_INVENTORY_IN_TRANSIT);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@InventoryInTransit_BetterHaven, @SegmentId_BETTER_HAVEN_LOCATION);
		END
END 