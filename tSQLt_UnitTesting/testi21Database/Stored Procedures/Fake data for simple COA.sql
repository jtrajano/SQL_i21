CREATE PROCEDURE [testi21Database].[Fake data for simple COA]
AS
BEGIN
		---- Drop these views. It has dependencies with tblGLAccount table. Can't do fake table if these exists. 
		---- note: when tSQLt do the rollback, the views are rolled back as well. 
		--DROP VIEW vyuAPBill
		--DROP VIEW vyuAPBillBatch
		--DROP VIEW vyuAPPayablesAgingSummary
		--DROP VIEW vyuAPPaymentDetail
		--DROP VIEW vyuAPVendor
		--DROP VIEW vyuAPRecapTransaction

		-- Create the fake table		
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountStructure';
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountSegment';
		EXEC tSQLt.FakeTable 'dbo.tblGLAccount';
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountSegmentMapping', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountGroup';

		-- Constant variables
		DECLARE @AccountId_InventoryWheat_Default AS INT = 1000
		DECLARE @AccountId_CostOfGoods_Default AS INT = 2000
		DECLARE @AccountId_Purchase_Default AS INT = 3000
		DECLARE @AccountId_InventoryWheat_NewHaven AS INT = 1001
		DECLARE @AccountId_CostOfGoods_NewHaven AS INT = 2001
		DECLARE @AccountId_Purchase_NewHaven AS INT = 3001
		DECLARE @AccountId_InventoryWheat_BetterHaven AS INT = 1002
		DECLARE @AccountId_CostOfGoods_BetterHaven AS INT = 2002
		DECLARE @AccountId_Purchase_BetterHaven AS INT = 3003
		DECLARE @AccountId_BankAccount_Default AS INT = 4000
		DECLARE @AccountId_BankAccount_NewHaven AS INT = 4001
		DECLARE @AccountId_BankAccount_BetterHaven AS INT = 4002
		DECLARE @AccountId_MiscExpenses_Default AS INT = 5000
		DECLARE @AccountId_MiscExpenses_NewHaven AS INT = 5001
		DECLARE @AccountId_MiscExpenses_BetterHaven AS INT = 5002

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
		
		-- Add fake data for Account Structure
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask) VALUES (90, 'Primary', 1, '0')
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask) VALUES (91, 'Divider', 0, '-')
		INSERT INTO tblGLAccountStructure (intAccountStructureId, strType, intStartingPosition, strMask) VALUES (92, 'Segment', 2, '0')

		-- Add fake data for Account Segment
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId, intAccountGroupId) VALUES (1, '12040', 'INVENTORY WHEAT', 90, @Group_Asset)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId, intAccountGroupId) VALUES (2, '40100', 'COST OF GOODS WHEAT', 90, @Group_CostOfGoodsSold)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId, intAccountGroupId) VALUES (3, '50110', 'PURCHASES WHEAT', 90, @Group_Expenses)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId, intAccountGroupId) VALUES (4, '10000', 'BANK OF AMERICA', 90, @Group_CashAccounts)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId, intAccountGroupId) VALUES (5, '50000', 'MISCELLANEOUS EXPENESE', 90, @Group_Expenses)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (100, '1000', '', 92)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (101, '1001', 'NEW HAVEN GRAIN', 92)
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (102, '1002', 'BETTER HAVEN GRAIN', 92)

		-- Add fake data for GL Account
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@AccountId_InventoryWheat_Default, 'INVENTORY WHEAT-', '12040-1000', @Group_Inventory);
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@AccountId_CostOfGoods_Default, 'COST OF GOODS WHEAT-', '40100-1000', @Group_CostOfGoodsSold);
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@AccountId_Purchase_Default, 'PURCHASES WHEAT-', '50110-1000', @Group_Expenses);
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@AccountId_InventoryWheat_NewHaven, 'INVENTORY WHEAT-NEW HAVEN GRAIN', '12040-1001', @Group_Inventory);
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@AccountId_CostOfGoods_NewHaven, 'COST OF GOODS WHEAT-NEW HAVEN GRAIN', '40100-1001', @Group_CostOfGoodsSold);
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@AccountId_Purchase_NewHaven, 'PURCHASES WHEAT-NEW HAVEN GRAIN', '50110-1001', @Group_Expenses);
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@AccountId_InventoryWheat_BetterHaven, 'INVENTORY WHEAT-BETTER HAVEN GRAIN', '12040-1002', @Group_Inventory);
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@AccountId_CostOfGoods_BetterHaven, 'COST OF GOODS WHEAT-BETTER HAVEN GRAIN', '40100-1002', @Group_CostOfGoodsSold);
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@AccountId_Purchase_BetterHaven, 'PURCHASES WHEAT-BETTER HAVEN GRAIN', '50110-1002', @Group_Expenses);
		
		-- Fake Cash Accounts
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@AccountId_BankAccount_Default, 'BANK OF AMERICA MAIN BRANCH', '10000-1000', @Group_CashAccounts);
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@AccountId_BankAccount_NewHaven, 'BANK OF AMERICA NEW HAVEN', '10000-1001', @Group_CashAccounts);
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@AccountId_BankAccount_BetterHaven, 'BANK OF AMERICA BETTER HAVEN', '10000-1002', @Group_CashAccounts);
		
		-- Fake Expenses 
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@AccountId_MiscExpenses_Default, 'MISCELLANEOUS EXPENSES MAIN BRANCH', '50000-1000', @Group_Expenses);
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@AccountId_MiscExpenses_NewHaven, 'MISCELLANEOUS EXPENSES NEW HAVEN', '50000-1001', @Group_Expenses);
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@AccountId_MiscExpenses_BetterHaven, 'MISCELLANEOUS EXPENSES BETTER HAVEN', '50000-1002', @Group_Expenses);

		-- Add fake data for Segment Mapping
		-- INVENTORY WHEAT-'
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_InventoryWheat_Default, 1);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_InventoryWheat_Default, 100);
		-- COST OF GOODS WHEAT-
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_CostOfGoods_Default, 2);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_CostOfGoods_Default, 100);
		-- PURCHASES WHEAT-
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_Purchase_Default, 3);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_Purchase_Default, 100);

		-- INVENTORY WHEAT-NEW HAVEN GRAIN
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_InventoryWheat_NewHaven, 1);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_InventoryWheat_NewHaven, 101);
		-- COST OF GOODS WHEAT-NEW HAVEN GRAIN
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_CostOfGoods_NewHaven, 2);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_CostOfGoods_NewHaven, 101);
		-- PURCHASES WHEAT-NEW HAVEN GRAIN
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_Purchase_NewHaven, 3);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_Purchase_NewHaven, 101);	

		-- INVENTORY WHEAT-BETTER HAVEN GRAIN
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_InventoryWheat_BetterHaven, 1);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_InventoryWheat_BetterHaven, 102);
		-- COST OF GOODS WHEAT-BETTER HAVEN GRAIN
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_CostOfGoods_BetterHaven, 2);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_CostOfGoods_BetterHaven, 102);
		-- PURCHASES WHEAT-BETTER HAVEN GRAIN
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_Purchase_BetterHaven, 3);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_Purchase_BetterHaven, 102);	

		-- CASH ACCOUNTS
		-- Bank of America Main Branch
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_BankAccount_Default, 4);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_BankAccount_Default, 100);
		-- Bank of America New Haven
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_BankAccount_NewHaven, 4);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_BankAccount_NewHaven, 101);
		-- Bank of America Better Haven
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_BankAccount_BetterHaven, 4);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_BankAccount_BetterHaven, 102);

		-- MISCELLANEOUS EXPENSES 
		-- Miscellaneous Expenses Main Branch
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_MiscExpenses_Default, 5);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_MiscExpenses_Default, 100);
		-- Miscellaneous Expenses New Haven
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_MiscExpenses_NewHaven, 5);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_MiscExpenses_NewHaven, 101);
		-- Miscellaneous Expenses Better Haven
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_MiscExpenses_BetterHaven, 5);
		INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@AccountId_MiscExpenses_BetterHaven, 102);
END 

