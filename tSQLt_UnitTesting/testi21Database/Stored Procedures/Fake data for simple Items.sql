CREATE PROCEDURE [testi21Database].[Fake data for simple Items]
AS
BEGIN
		-- Use the 'fake data for simple COA' for the simple items
		EXEC testi21Database.[Fake data for simple COA]

		-- Create the fake table and data for the items
		EXEC tSQLt.FakeTable 'dbo.tblSMCompanyLocation';
		EXEC tSQLt.FakeTable 'dbo.tblSMCompanyLocationAccount', @Identity = 1;

		EXEC tSQLt.FakeTable 'dbo.tblICItem';
		EXEC tSQLt.FakeTable 'dbo.tblICItemLocation', @Identity = 1;	
		EXEC tSQLt.FakeTable 'dbo.tblICItemAccount', @Identity = 1;

		EXEC tSQLt.FakeTable 'dbo.tblICCategory';
		EXEC tSQLt.FakeTable 'dbo.tblICCategoryAccount', @Identity = 1;

		INSERT INTO tblSMCompanyLocation (intCompanyLocationId, strLocationName) VALUES (1, '')
		INSERT INTO tblSMCompanyLocation (intCompanyLocationId, strLocationName) VALUES (2, 'NEW HAVEN')
		INSERT INTO tblSMCompanyLocation (intCompanyLocationId, strLocationName, intProfitCenter) VALUES (3, 'BETTER HAVEN', 100)

		-- G/L Accounts for Company Location 1 ('')
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (1, 'Inventory', 1000);
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (1, 'Sales', 2000);
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (1, 'Purchases', 3000);

		-- G/L Accounts for Company Location 2 ('NEW HAVEN')
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (2, 'Inventory', 1001);
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (2, 'Sales', 2001);
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (2, 'Purchases', 3001);

		-- G/L Accounts for Company Location 3 ('BETTER HAVEN')
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (3, 'Inventory', 1000);
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (3, 'Sales', 2000);
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (3, 'Purchases', 3000);

		-- Category
		INSERT INTO tblICCategory (intCategoryId, strDescription) VALUES (1, 'Hot Items');
		INSERT INTO tblICCategory (intCategoryId, strDescription) VALUES (2, 'Cold Items');

		-- Category Account
		-- Add G/L setup for Hot items
		--		BETTER HAVEN location 
		INSERT INTO tblICCategoryAccount (intCategoryId, intLocationId, intAccountId, strAccountDescription) VALUES (1, 3, 1000, 'Inventory')
		INSERT INTO tblICCategoryAccount (intCategoryId, intLocationId, intAccountId, strAccountDescription) VALUES (1, 3, 2000, 'Sales')
		INSERT INTO tblICCategoryAccount (intCategoryId, intLocationId, intAccountId, strAccountDescription) VALUES (1, 3, 3000, 'Purchases')

		-- Add G/L setup for Cold items
		--		NEW HAVEN location 
		INSERT INTO tblICCategoryAccount (intCategoryId, intLocationId, intAccountId, strAccountDescription) VALUES (2, 2, 1002, 'Inventory')
		INSERT INTO tblICCategoryAccount (intCategoryId, intLocationId, intAccountId, strAccountDescription) VALUES (2, 2, 2002, 'Sales')
		INSERT INTO tblICCategoryAccount (intCategoryId, intLocationId, intAccountId, strAccountDescription) VALUES (2, 2, 3002, 'Purchases')

		--		BETTER HAVEN location 
		INSERT INTO tblICCategoryAccount (intCategoryId, intLocationId, intAccountId, strAccountDescription) VALUES (2, 3, 1002, 'Inventory')
		INSERT INTO tblICCategoryAccount (intCategoryId, intLocationId, intAccountId, strAccountDescription) VALUES (2, 3, 2002, 'Sales')
		INSERT INTO tblICCategoryAccount (intCategoryId, intLocationId, intAccountId, strAccountDescription) VALUES (2, 3, 3002, 'Purchases')
		
		-- Items 
		INSERT INTO tblICItem (intItemId, strDescription) VALUES (1, 'WET GRAINS')
		INSERT INTO tblICItem (intItemId, strDescription) VALUES (2, 'STICKY GRAINS')
		INSERT INTO tblICItem (intItemId, strDescription) VALUES (3, 'PREMIUM GRAINS')
		INSERT INTO tblICItem (intItemId, strDescription, intTrackingId) VALUES (4, 'COLD GRAINS', 2)
		INSERT INTO tblICItem (intItemId, strDescription, intTrackingId) VALUES (5, 'HOT GRAINS', 1)

		-- Add items for location 1 ('')
		INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory) VALUES (1, 1, 1)
		INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory) VALUES (2, 1, 1)
		INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory) VALUES (3, 1, 1)
		INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory) VALUES (4, 1, 1)
		INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory) VALUES (5, 1, 1)

		-- Add items for location 2 ('NEW HAVEN')
		INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory) VALUES (1, 2, 2)
		INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory) VALUES (2, 2, 2)
		INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory) VALUES (3, 2, 2)
		INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory) VALUES (4, 2, 2)
		INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory) VALUES (5, 2, 2)

		-- Add items for location 3 ('BETTER HAVEN')
		INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory) VALUES (1, 3, 3)
		INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory) VALUES (2, 3, 3)
		INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory) VALUES (3, 3, 3)
		INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory) VALUES (4, 3, 3)
		INSERT INTO tblICItemLocation (intItemId, intLocationId, intAllowNegativeInventory) VALUES (5, 3, 3)

		-- Add the G/L accounts for WET GRAINS
		--		for Location 1
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (1, 1, 'Inventory', 1000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (1, 1, 'Sales', 2000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (1, 1, 'Purchases', 3000);

		--		for Location 2 (NEW HAVEN)
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (1, 2, 'Inventory', 1001);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (1, 2, 'Sales', 2001);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (1, 2, 'Purchases', 3001);

		--		for Location 3 (BETTER HAVEN)
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId, intProfitCenterId) VALUES (1, 3, 'Inventory', 1001, 102);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId, intProfitCenterId) VALUES (1, 3, 'Sales', 2001, 102);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId, intProfitCenterId) VALUES (1, 3, 'Purchases', 3001, 102);

		-- Add the G/L accounts for STICKY GRAINS
		--		for Location 1
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (2, 1, 'Inventory', 1000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (2, 1, 'Sales', 2000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (2, 1, 'Purchases', 3000);

		--		for Location 2 (NEW HAVEN)
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (2, 2, 'Inventory', 1001);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (2, 2, 'Sales', 2001);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (2, 2, 'Purchases', 3001);

		--		for Location 3 (BETTER HAVEN)
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId, intProfitCenterId) VALUES (2, 3, 'Inventory', 1001, 102);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId, intProfitCenterId) VALUES (2, 3, 'Sales', 2001, 102);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId, intProfitCenterId) VALUES (2, 3, 'Purchases', 3001, 102);

		-- Add the G/L accounts for PREMIUM GRAINS 
		--		for Location 1
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (3, 1, 'Inventory', 1000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (3, 1, 'Sales', 2000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (3, 1, 'Purchases', 3000);

		--		for Location 2 (NEW HAVEN)
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (3, 2, 'Inventory', 1001);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (3, 2, 'Sales', 2001);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (3, 2, 'Purchases', 3001);

		--		for Location 2 (BETTER HAVEN)
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId, intProfitCenterId) VALUES (3, 3, 'Inventory', 1002, NULL);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId, intProfitCenterId) VALUES (3, 3, 'Sales', 2002, NULL);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId, intProfitCenterId) VALUES (3, 3, 'Purchases', 3002, NULL);


		-- Add the G/L accounts for COLD GRAINS 
		--		for Location 1
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (4, 1, 'Inventory', 1000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (4, 1, 'Sales', 2000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (4, 1, 'Purchases', 3000);

		--		for Location 2 (NEW HAVEN)
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (4, 2, 'Inventory', 1001);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (4, 2, 'Sales', 2001);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (4, 2, 'Purchases', 3001);

		--		for Location 3 (BETTER HAVEN)
		--		NO SETUP

		-- Add the G/L accounts for HOT GRAINS
		--		for Location 1
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (5, 1, 'Inventory', 1000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (5, 1, 'Sales', 2000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (5, 1, 'Purchases', 3000);

		--		for Location 2 (NEW HAVEN)
		--		NO SETUP 

		--		for Location 3 (BETTER HAVEN)
		--		NO SETUP

END 
