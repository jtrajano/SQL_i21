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
		EXEC tSQLt.FakeTable 'dbo.tblICItemStock', @Identity = 1;	
		EXEC tSQLt.FakeTable 'dbo.tblICItemAccount', @Identity = 1;

		EXEC tSQLt.FakeTable 'dbo.tblICCategory';
		EXEC tSQLt.FakeTable 'dbo.tblICCategoryAccount', @Identity = 1;

		INSERT INTO tblSMCompanyLocation (intCompanyLocationId, strLocationName) VALUES (1, '')
		INSERT INTO tblSMCompanyLocation (intCompanyLocationId, strLocationName) VALUES (2, 'NEW HAVEN')
		INSERT INTO tblSMCompanyLocation (intCompanyLocationId, strLocationName, intProfitCenter) VALUES (3, 'BETTER HAVEN', 100)

		-- G/L Accounts for Company Location 1 ('')
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (1, 'Inventory', 1000);
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (1, 'Cost of Goods', 2000);
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (1, 'Purchase Account', 3000);

		-- G/L Accounts for Company Location 2 ('NEW HAVEN')
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (2, 'Inventory', 1001);
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (2, 'Cost of Goods', 2001);
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (2, 'Purchase Account', 3001);

		-- G/L Accounts for Company Location 3 ('BETTER HAVEN')
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (3, 'Inventory', 1000);
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (3, 'Cost of Goods', 2000);
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (3, 'Purchase Account', 3000);

		-- Category
		INSERT INTO tblICCategory (intCategoryId, strDescription) VALUES (1, 'Hot Items');
		INSERT INTO tblICCategory (intCategoryId, strDescription) VALUES (2, 'Cold Items');

		-- Category Account
		-- Add G/L setup for Hot items
		INSERT INTO tblICCategoryAccount (intCategoryId, intAccountId, strAccountDescription) VALUES (1, 1001, 'Inventory')
		INSERT INTO tblICCategoryAccount (intCategoryId, intAccountId, strAccountDescription) VALUES (1, 2001, 'Cost of Goods')
		INSERT INTO tblICCategoryAccount (intCategoryId, intAccountId, strAccountDescription) VALUES (1, 3001, 'Purchase Account')

		-- Add G/L setup for Cold items
		-- No category-level g/l account overrides for Cold items. Use default g/l account from Location. 
		
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
		
		-- Add stock information for items under location 1 ('')
		INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (1, 1, 100)
		INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (2, 1, 150)
		INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (3, 1, 200)
		INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (4, 1, 250)
		INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (5, 1, 300)

		-- Add stock information for items under location 2 ('NEW HAVEN')
		INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (1, 2, 0)
		INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (2, 2, 0)
		INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (3, 2, 0)
		INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (4, 2, 0)
		INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (5, 2, 0)

		-- Add stock information for items under location 3 ('BETTER HAVEN')
		INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (1, 3, 0)
		INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (2, 3, 0)
		INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (3, 3, 0)
		INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (4, 3, 0)
		INSERT INTO tblICItemStock (intItemId, intLocationId, dblUnitOnHand) VALUES (5, 3, 0)

		-- Add the G/L accounts for WET GRAINS
		INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (1, 'Inventory', 1000);
		INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (1, 'Cost of Goods', 2000);
		INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (1, 'Purchase Account', 3000);

		-- Add the G/L accounts for STICKY GRAINS
		INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (2, 'Inventory', 1001);
		INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (2, 'Cost of Goods', 2001);
		INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (2, 'Purchase Account', 3001);

		-- Add the G/L accounts for PREMIUM GRAINS 
		INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (3, 'Inventory', 1002);
		INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (3, 'Cost of Goods', 2002);
		INSERT INTO tblICItemAccount (intItemId, strAccountDescription, intAccountId) VALUES (3, 'Purchase Account', 3002);

		-- Add the G/L accounts for COLD GRAINS 
		-- No item level g/l account overrides for cold grains. Use g/l from category
		
		-- Add the G/L accounts for HOT GRAINS
		-- No item level g/l account overrides for hot grains. Use g/l from category

END 
