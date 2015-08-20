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
		DECLARE	 @Inventory_Default AS INT = 1000
				,@CostOfGoods_Default AS INT = 2000
				,@APClearing_Default AS INT = 3000
				,@WriteOffSold_Default AS INT = 4000
				,@RevalueSold_Default AS INT = 5000 
				,@AutoNegative_Default AS INT = 6000
				,@InventoryInTransit_Default AS INT = 7000
				,@AccountReceivable_Default AS INT = 8000
				,@InventoryAdjustment_Default AS INT = 9000
				,@OtherChargeExpense_Default AS INT = 10000
				,@OtherChargeIncome_Default AS INT = 11000
				,@OtherChargeAsset_Default AS INT = 12000

				,@Inventory_NewHaven AS INT = 1001
				,@CostOfGoods_NewHaven AS INT = 2001
				,@APClearing_NewHaven AS INT = 3001
				,@WriteOffSold_NewHaven AS INT = 4001
				,@RevalueSold_NewHaven AS INT = 5001
				,@AutoNegative_NewHaven AS INT = 6001
				,@InventoryInTransit_NewHaven AS INT = 7001
				,@AccountReceivable_NewHaven AS INT = 8001
				,@InventoryAdjustment_NewHaven AS INT = 9001
				,@OtherChargeExpense_NewHaven AS INT = 10001
				,@OtherChargeIncome_NewHaven AS INT = 11001
				,@OtherChargeAsset_NewHaven AS INT = 12001

				,@Inventory_BetterHaven AS INT = 1002
				,@CostOfGoods_BetterHaven AS INT = 2002
				,@APClearing_BetterHaven AS INT = 3002
				,@WriteOffSold_BetterHaven AS INT = 4002
				,@RevalueSold_BetterHaven AS INT = 5002
				,@AutoNegative_BetterHaven AS INT = 6002
				,@InventoryInTransit_BetterHaven AS INT = 7002
				,@AccountReceivable_BetterHaven AS INT = 8002
				,@InventoryAdjustment_BetterHaven AS INT = 9002
				,@OtherChargeExpense_BetterHaven AS INT = 10002
				,@OtherChargeIncome_BetterHaven AS INT = 11002
				,@OtherChargeAsset_BetterHaven AS INT = 12002

		-- Constant Variables
		DECLARE @GROUP_Asset AS INT = 1
		DECLARE @GROUP_Liability AS INT = 2
		DECLARE @GROUP_Equity AS INT = 3
		DECLARE @GROUP_Revenue AS INT = 4
		DECLARE @GROUP_Expenses AS INT = 5
		DECLARE @GROUP_Sales AS INT = 6
		DECLARE @GROUP_CostOfGoodsSold AS INT = 7
		DECLARE @GROUP_CashAccounts AS INT = 8
		DECLARE @GROUP_Receivables AS INT = 9
		DECLARE @GROUP_Inventory AS INT = 10
		DECLARE @GROUP_MiscExpenses AS INT = 11

		-- Add fake data for the Account Group
		INSERT INTO tblGLAccountGroup (intAccountGroupId, strAccountGroup, strAccountType, intParentGroupId,intGroup,intSort)
		SELECT				@GROUP_Asset, 'Asset', 'Asset', 0, 1, 10000
		UNION ALL SELECT	@GROUP_Liability, 'Liability', 'Liability', 0, 1, 20000
		UNION ALL SELECT	@GROUP_Equity, 'Equity', 'Equity', 0, 1, 30000
		UNION ALL SELECT	@GROUP_Revenue, 'Revenue', 'Revenue', 0, 1, 40000
		UNION ALL SELECT	@GROUP_Expenses, 'Expenses', 'Expenses', 0, 1, 50000
		UNION ALL SELECT	@GROUP_Sales, 'Sales', 'Sales', 0, 1, 60000
		UNION ALL SELECT	@GROUP_CostOfGoodsSold, 'Cost of Goods Sold', 'Cost of Goods Sold', 0, 1, 70000
		UNION ALL SELECT	@GROUP_CashAccounts, 'Cash Accounts', 'Asset', 1, NULL, 10001
		UNION ALL SELECT	@GROUP_Receivables, 'Receivables', 'Asset', 1, NULL, 10002
		UNION ALL SELECT	@GROUP_Inventory, 'Inventory', 'Asset', 1, NULL, 10003
		UNION ALL SELECT	@GROUP_MiscExpenses, 'Miscellaneous Expenses', 'Expenses', 5, NULL, 50001

		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
		-- Add fake data for Account Structure
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Primary account segment 
		DECLARE @ACCOUNT_STRUCTURE_ID_Primary AS INT = 90
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask, strStructureName) VALUES (@ACCOUNT_STRUCTURE_ID_Primary, 'Primary', 1, '0', 'Primary Segment')

		-- Divider
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask) VALUES (91, 'Divider', 0, '-')

		-- Location account segment 
		DECLARE @ACCOUNT_STRUCTURE_ID_Location AS INT = 92
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask, strStructureName) VALUES (@ACCOUNT_STRUCTURE_ID_Location, 'Segment', 2, '0', 'Location')

		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Add fake data for Account Segment
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		-- Primary Segments
		DECLARE @SEGMENT_ID_InventoryWheat AS INT = 1
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SEGMENT_ID_InventoryWheat, '12040', 'INVENTORY WHEAT', @ACCOUNT_STRUCTURE_ID_Primary)
		
		DECLARE @SEGMENT_ID_CostOfGoodsWheat AS INT = 2
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SEGMENT_ID_CostOfGoodsWheat, '20100', 'COST OF GOODS WHEAT', @ACCOUNT_STRUCTURE_ID_Primary)

		DECLARE @SEGMENT_ID_APClearingWheat AS INT = 3
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SEGMENT_ID_APClearingWheat, '30110', 'AP CLEARING WHEAT', @ACCOUNT_STRUCTURE_ID_Primary)

		DECLARE @SEGMENT_ID_WriteOffSoldWheat AS INT = 4
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SEGMENT_ID_WriteOffSoldWheat, '40110', 'WRITE-OFF SOLD WHEAT', @ACCOUNT_STRUCTURE_ID_Primary)

		DECLARE @SEGMENT_ID_RevalueSoldWheat AS INT = 5
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SEGMENT_ID_RevalueSoldWheat, '50110', 'REVALUE SOLD WHEAT', @ACCOUNT_STRUCTURE_ID_Primary)

		DECLARE @SEGMENT_ID_AutoNegativeWheat AS INT = 6
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SEGMENT_ID_AutoNegativeWheat, '60110', 'AUTO NEGATIVE WHEAT', @ACCOUNT_STRUCTURE_ID_Primary)

		DECLARE @SEGMENT_ID_InventoryInTransit AS INT = 7
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SEGMENT_ID_InventoryInTransit, '12050', 'INVENTORY IN TRANSIT', @ACCOUNT_STRUCTURE_ID_Primary)

		DECLARE @SEGMENT_ID_AccountReceivable AS INT = 8
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SEGMENT_ID_AccountReceivable, '10650', 'ACCOUNT RECEIVABLE', @ACCOUNT_STRUCTURE_ID_Primary)

		DECLARE @SEGMENT_ID_InventoryAdjustment AS INT = 9
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SEGMENT_ID_InventoryAdjustment, '20500', 'INVENTORY ADJUSTMENT', @ACCOUNT_STRUCTURE_ID_Primary)

		DECLARE @SEGMENT_ID_OtherChargeExpense AS INT = 10
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SEGMENT_ID_OtherChargeExpense, '30500', 'OTHER CHARGE EXPENSE', @ACCOUNT_STRUCTURE_ID_Primary)

		DECLARE @SEGMENT_ID_OtherChargeIncome AS INT = 11
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SEGMENT_ID_OtherChargeIncome, '40500', 'OTHER CHARGE INCOME', @ACCOUNT_STRUCTURE_ID_Primary)

		--DECLARE @SEGMENT_ID_OtherChargeAsset AS INT = 12
		--INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SEGMENT_ID_OtherChargeAsset, '50500', 'OTHER CHARGE (ASSET)', @ACCOUNT_STRUCTURE_ID_Primary)

		-- Location Segments 				
		DECLARE @SEGMENT_ID_DefaultLocation AS INT = 100
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SEGMENT_ID_DefaultLocation, '1000', 'DEFAULT', @ACCOUNT_STRUCTURE_ID_Location)

		DECLARE @SEGMENT_ID_NewHavenLocation AS INT = 101
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SEGMENT_ID_NewHavenLocation, '1001', 'NEW HAVEN', @ACCOUNT_STRUCTURE_ID_Location)

		DECLARE @SEGMENT_ID_BetterHavenLocation AS INT = 102
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SEGMENT_ID_BetterHavenLocation, '1002', 'BETTER HAVEN', @ACCOUNT_STRUCTURE_ID_Location)

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
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@AccountReceivable_Default, 'ACCOUNT RECEIVABLE-DEFAULT', '10650-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@InventoryAdjustment_Default, 'INVENTORY ADJUSTMENT-DEFAULT', '20500-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@OtherChargeExpense_Default, 'OTHER CHARGE EXPENSE-DEFAULT', '30500-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@OtherChargeIncome_Default, 'OTHER CHARGE INCOME-DEFAULT', '40500-1000');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@OtherChargeAsset_Default, 'OTHER CHARGE (ASSET)-DEFAULT', '50500-1000');

		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@Inventory_NewHaven, 'INVENTORY WHEAT-NEW HAVEN', '12040-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@CostOfGoods_NewHaven, 'COST OF GOODS WHEAT-NEW HAVEN', '20100-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@APClearing_NewHaven, 'AP CLEARING WHEAT-NEW HAVEN', '30110-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@WriteOffSold_NewHaven, 'WRITE-OFF SOLD WHEAT-NEW HAVEN', '40110-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@RevalueSold_NewHaven, 'REVALUE SOLD WHEAT-NEW HAVEN', '50110-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@AutoNegative_NewHaven, 'AUTO NEGATIVE WHEAT-NEW HAVEN', '60110-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@InventoryInTransit_NewHaven, 'INVENTORY IN TRANSIT-NEW HAVEN', '12050-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@AccountReceivable_NewHaven, 'ACCOUNT RECEIVABLE-NEW HAVEN', '10650-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@InventoryAdjustment_NewHaven, 'INVENTORY ADJUSTMENT-NEW HAVEN', '20500-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@OtherChargeExpense_NewHaven, 'OTHER CHARGE EXPENSE-NEW HAVEN', '30500-1001');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@OtherChargeIncome_NewHaven, 'OTHER CHARGE INCOME-NEW HAVEN', '40500-1001');
		--INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@OtherChargeAsset_NewHaven, 'OTHER CHARGE (ASSET)-NEW HAVEN', '50500-1001');

		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@Inventory_BetterHaven, 'INVENTORY WHEAT-BETTER HAVEN', '12040-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@CostOfGoods_BetterHaven, 'COST OF GOODS WHEAT-BETTER HAVEN', '20100-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@APClearing_BetterHaven, 'AP CLEARING WHEAT-BETTER HAVEN', '30110-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@WriteOffSold_BetterHaven, 'WRITE-OFF SOLD WHEAT-BETTER HAVEN', '40110-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@RevalueSold_BetterHaven, 'REVALUE SOLD WHEAT-BETTER HAVEN', '50110-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@AutoNegative_BetterHaven, 'AUTO NEGATIVE WHEAT-BETTER HAVEN', '60110-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@InventoryInTransit_BetterHaven, 'INVENTORY IN TRANSIT-BETTER HAVEN', '12050-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@AccountReceivable_BetterHaven, 'ACCOUNT RECEIVABLE-BETTER HAVEN', '10650-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@InventoryAdjustment_BetterHaven, 'INVENTORY ADJUSTMENT-BETTER HAVEN', '20500-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@OtherChargeExpense_BetterHaven, 'OTHER CHARGE EXPENSE-NEW HAVEN', '30500-1002');
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@OtherChargeIncome_BetterHaven, 'OTHER CHARGE INCOME-NEW HAVEN', '40500-1002');
		--INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId) VALUES (@OtherChargeAsset_BetterHaven, 'OTHER CHARGE (ASSET)-NEW HAVEN', '50500-1002');

		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Add fake data for Segment Mapping
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- for DEFAULT location 
		BEGIN 
			--INVENTORY WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@Inventory_Default, @SEGMENT_ID_InventoryWheat);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@Inventory_Default, @SEGMENT_ID_DefaultLocation);

			-- COST OF GOODS WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@CostOfGoods_Default, @SEGMENT_ID_CostOfGoodsWheat);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@CostOfGoods_Default, @SEGMENT_ID_DefaultLocation);
			-- AP CLEARING WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@APClearing_Default, @SEGMENT_ID_APClearingWheat);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@APClearing_Default, @SEGMENT_ID_DefaultLocation);

			-- WRITE-OFF SOLD WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@WriteOffSold_Default, @SEGMENT_ID_WriteOffSoldWheat);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@WriteOffSold_Default, @SEGMENT_ID_DefaultLocation);
			
			-- REVALUE SOLD WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@RevalueSold_Default, @SEGMENT_ID_RevalueSoldWheat);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@RevalueSold_Default, @SEGMENT_ID_DefaultLocation);
			
			-- AUTO NEGATIVE WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AutoNegative_Default, @SEGMENT_ID_AutoNegativeWheat);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AutoNegative_Default, @SEGMENT_ID_DefaultLocation);

			-- INVENTORY IN TRANSIT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@InventoryInTransit_Default, @SEGMENT_ID_InventoryInTransit);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@InventoryInTransit_Default, @SEGMENT_ID_DefaultLocation);

			-- ACCOUNT RECEIVABLE 
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountReceivable_Default, @SEGMENT_ID_AccountReceivable);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountReceivable_Default, @SEGMENT_ID_DefaultLocation);

			-- INVENTORY ADJUSTMENT 
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@InventoryAdjustment_Default, @SEGMENT_ID_InventoryAdjustment);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@InventoryAdjustment_Default, @SEGMENT_ID_DefaultLocation);

			-- OTHER CHARGE EXPENSE
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@OtherChargeExpense_Default, @SEGMENT_ID_OtherChargeExpense);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@OtherChargeExpense_Default, @SEGMENT_ID_DefaultLocation);

			-- OTHER CHARGE INCOME
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@OtherChargeIncome_Default, @SEGMENT_ID_OtherChargeIncome);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@OtherChargeIncome_Default, @SEGMENT_ID_DefaultLocation);

			---- OTHER CHARGE ASSET
			--INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@OtherChargeAsset_Default, @SEGMENT_ID_OtherChargeAsset);
			--INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@OtherChargeAsset_Default, @SEGMENT_ID_DefaultLocation);

		END 

		-- for NEW HAVEN location 
		BEGIN 
			-- INVENTORY WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@Inventory_NewHaven, @SEGMENT_ID_InventoryWheat);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@Inventory_NewHaven, @SEGMENT_ID_NewHavenLocation);

			-- COST OF GOODS WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@CostOfGoods_NewHaven, @SEGMENT_ID_CostOfGoodsWheat);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@CostOfGoods_NewHaven, @SEGMENT_ID_NewHavenLocation);

			-- AP CLEARING WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@APClearing_NewHaven, @SEGMENT_ID_APClearingWheat);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@APClearing_NewHaven, @SEGMENT_ID_NewHavenLocation);	

			-- WRITE-OFF SOLD WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@WriteOffSold_NewHaven, @SEGMENT_ID_WriteOffSoldWheat);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@WriteOffSold_NewHaven, @SEGMENT_ID_NewHavenLocation);

			-- REVALUE SOLD WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@RevalueSold_NewHaven, @SEGMENT_ID_RevalueSoldWheat);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@RevalueSold_NewHaven, @SEGMENT_ID_NewHavenLocation);
			
			-- AUTO NEGATIVE WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AutoNegative_NewHaven, @SEGMENT_ID_AutoNegativeWheat);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AutoNegative_NewHaven, @SEGMENT_ID_NewHavenLocation);

			-- INVENTORY IN TRANSIT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@InventoryInTransit_NewHaven, @SEGMENT_ID_InventoryInTransit);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@InventoryInTransit_NewHaven, @SEGMENT_ID_NewHavenLocation);

			-- ACCOUNT RECEIVABLE
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountReceivable_NewHaven, @SEGMENT_ID_AccountReceivable);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountReceivable_NewHaven, @SEGMENT_ID_NewHavenLocation);

			-- INVENTORY ADJUSTMENT 
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@InventoryAdjustment_NewHaven, @SEGMENT_ID_InventoryAdjustment);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@InventoryAdjustment_NewHaven, @SEGMENT_ID_NewHavenLocation);

			-- OTHER CHARGE EXPENSE
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@OtherChargeExpense_NewHaven, @SEGMENT_ID_OtherChargeExpense);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@OtherChargeExpense_NewHaven, @SEGMENT_ID_NewHavenLocation);

			-- OTHER CHARGE INCOME
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@OtherChargeIncome_NewHaven, @SEGMENT_ID_OtherChargeIncome);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@OtherChargeIncome_NewHaven, @SEGMENT_ID_NewHavenLocation);

			---- OTHER CHARGE ASSET
			--INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@OtherChargeAsset_NewHaven, @SEGMENT_ID_OtherChargeAsset);
			--INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@OtherChargeAsset_NewHaven, @SEGMENT_ID_NewHavenLocation);

		END 

		-- for BETTER HAVEN location 
		BEGIN 
			-- INVENTORY WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@Inventory_BetterHaven, @SEGMENT_ID_InventoryWheat);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@Inventory_BetterHaven, @SEGMENT_ID_BetterHavenLocation);

			-- COST OF GOODS WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@CostOfGoods_BetterHaven, @SEGMENT_ID_CostOfGoodsWheat);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@CostOfGoods_BetterHaven, @SEGMENT_ID_BetterHavenLocation);

			-- AP CLEARING WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@APClearing_BetterHaven, @SEGMENT_ID_APClearingWheat);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@APClearing_BetterHaven, @SEGMENT_ID_BetterHavenLocation);	

			-- WRITE-OFF SOLD WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@WriteOffSold_BetterHaven, @SEGMENT_ID_WriteOffSoldWheat);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@WriteOffSold_BetterHaven, @SEGMENT_ID_BetterHavenLocation);

			-- REVALUE SOLD WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@RevalueSold_BetterHaven, @SEGMENT_ID_RevalueSoldWheat);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@RevalueSold_BetterHaven, @SEGMENT_ID_BetterHavenLocation);
			
			-- AUTO NEGATIVE WHEAT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AutoNegative_BetterHaven, @SEGMENT_ID_AutoNegativeWheat);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AutoNegative_BetterHaven, @SEGMENT_ID_BetterHavenLocation);

			-- INVENTORY IN TRANSIT
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@InventoryInTransit_BetterHaven, @SEGMENT_ID_InventoryInTransit);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@InventoryInTransit_BetterHaven, @SEGMENT_ID_BetterHavenLocation);

			-- ACCOUNT RECEIVABLE
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountReceivable_BetterHaven, @SEGMENT_ID_AccountReceivable);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountReceivable_BetterHaven, @SEGMENT_ID_NewHavenLocation);

			-- INVENTORY ADJUSTMENT 
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@InventoryAdjustment_BetterHaven, @SEGMENT_ID_InventoryAdjustment);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@InventoryAdjustment_BetterHaven, @SEGMENT_ID_DefaultLocation);

			-- OTHER CHARGE EXPENSE
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@OtherChargeExpense_BetterHaven, @SEGMENT_ID_OtherChargeExpense);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@OtherChargeExpense_BetterHaven, @SEGMENT_ID_NewHavenLocation);

			-- OTHER CHARGE INCOME
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@OtherChargeIncome_BetterHaven, @SEGMENT_ID_OtherChargeIncome);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@OtherChargeIncome_BetterHaven, @SEGMENT_ID_NewHavenLocation);

			---- OTHER CHARGE ASSET
			--INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@OtherChargeAsset_BetterHaven, @SEGMENT_ID_OtherChargeAsset);
			--INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@OtherChargeAsset_BetterHaven, @SEGMENT_ID_NewHavenLocation);

		END
END