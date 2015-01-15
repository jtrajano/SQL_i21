CREATE PROCEDURE [testi21Database].[Fake COA used in Cash Management]
AS
BEGIN
		-- Create the fake table		
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountGroup';
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountStructure';
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountSegment';
		EXEC tSQLt.FakeTable 'dbo.tblGLAccount';
		EXEC tSQLt.FakeTable 'dbo.tblGLAccountSegmentMapping', @Identity = 1;	

		-- Declare the account ids
		DECLARE @BankOfAmerica_Default AS INT = 1000
		DECLARE @MiscExpenses_Default AS INT = 4000
		DECLARE @BankOfAmerica_NewHaven AS INT = 1001
		DECLARE @MiscExpenses_NewHaven AS INT = 4001
		DECLARE @BankOfAmerica_BetterHaven AS INT = 1002
		DECLARE @MiscExpenses_BetterHaven AS INT = 4002

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
		DECLARE @SegmentId_BANK_OF_AMERICA AS INT = 1
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SegmentId_BANK_OF_AMERICA, '100100', 'BANK OF AMERICA', @AccountStructureId_Primary)
		
		DECLARE @SegmentId_MISC_EXPENSES AS INT = 4
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SegmentId_MISC_EXPENSES, '400100', 'MISC EXPENSES', @AccountStructureId_Primary)

		DECLARE @SegmentId_DEFAULT_LOCATION AS INT = 100
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SegmentId_DEFAULT_LOCATION, '1000', 'DEFAULT', @AccountStructureId_Location)

		DECLARE @SegmentId_NEW_HAVEN_LOCATION AS INT = 101
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SegmentId_NEW_HAVEN_LOCATION, '1001', 'NEW HAVEN', @AccountStructureId_Location)

		DECLARE @SegmentId_BETTER_HAVEN_LOCATION AS INT = 102
		INSERT INTO tblGLAccountSegment (intAccountSegmentId, strCode, strDescription, intAccountStructureId) VALUES (@SegmentId_BETTER_HAVEN_LOCATION, '1002', 'BETTER HAVEN', @AccountStructureId_Location)

		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Add fake data for GL Account
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@BankOfAmerica_Default, 'BANK OF AMERICA-DEFAULT', '100100-1000', @Group_CashAccounts);
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@MiscExpenses_Default, 'MISC EXPENSES-DEFAULT', '400100-1000', @Group_Expenses);

		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@BankOfAmerica_NewHaven, 'BANK OF AMERICA-NEW HAVEN', '100100-1001', @Group_CashAccounts);
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@MiscExpenses_NewHaven, 'MISC EXPENSES-NEW HAVEN', '400100-1001', @Group_Expenses);

		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@BankOfAmerica_BetterHaven, 'BANK OF AMERICA-BETTER HAVEN', '100100-1002', @Group_CashAccounts);
		INSERT INTO tblGLAccount(intAccountId, strDescription, strAccountId, intAccountGroupId) VALUES (@MiscExpenses_BetterHaven, 'MISC EXPENSES-BETTER HAVEN', '400100-1002', @Group_Expenses);		

		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Add fake data for Segment Mapping
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- for DEFAULT location 
		BEGIN 
			--BANK OF AMERICA
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@BankOfAmerica_Default, @SegmentId_BANK_OF_AMERICA);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@BankOfAmerica_Default, @SegmentId_DEFAULT_LOCATION);

			-- MISC EXPENSES 
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@MiscExpenses_Default, @SegmentId_MISC_EXPENSES);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@MiscExpenses_Default, @SegmentId_DEFAULT_LOCATION);			
		END 

		-- for NEW HAVEN location 
		BEGIN 
			--BANK OF AMERICA
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@BankOfAmerica_NewHaven, @SegmentId_BANK_OF_AMERICA);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@BankOfAmerica_NewHaven, @SegmentId_NEW_HAVEN_LOCATION);

			-- MISC EXPENSES 
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@MiscExpenses_NewHaven, @SegmentId_MISC_EXPENSES);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@MiscExpenses_NewHaven, @SegmentId_NEW_HAVEN_LOCATION);			
		END 

		-- for BETTER HAVEN location 
		BEGIN 
			--BANK OF AMERICA
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@BankOfAmerica_BetterHaven, @SegmentId_BANK_OF_AMERICA);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@BankOfAmerica_BetterHaven, @SegmentId_BETTER_HAVEN_LOCATION);

			-- MISC EXPENSES 
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@MiscExpenses_BetterHaven, @SegmentId_MISC_EXPENSES);
			INSERT INTO tblGLAccountSegmentMapping (intAccountId, intAccountSegmentId) VALUES (@MiscExpenses_BetterHaven, @SegmentId_BETTER_HAVEN_LOCATION);			
		END
END 