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

		INSERT INTO tblSMCompanyLocation (intCompanyLocationId, strLocationName) VALUES (1, '')
		INSERT INTO tblSMCompanyLocation (intCompanyLocationId, strLocationName) VALUES (2, 'NEW HAVEN')

		-- G/L Accounts for Company Location 1 ('')
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (1, 'Inventory', 1000);
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (1, 'Sales', 2000);
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (1, 'Purchases', 3000);

		-- G/L Accounts for Company Location 2 ('NEW HAVEN')
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (2, 'Inventory', 1001);
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (2, 'Sales', 2001);
		INSERT INTO tblSMCompanyLocationAccount (intCompanyLocationId, strAccountDescription, intAccountId) VALUES (2, 'Purchases', 3001);

		-- Items 
		INSERT INTO tblICItem (intItemId, strDescription) VALUES (1, 'BANANA')
		INSERT INTO tblICItem (intItemId, strDescription) VALUES (2, 'APPLE')
		INSERT INTO tblICItem (intItemId, strDescription) VALUES (3, 'ORANGE')
		INSERT INTO tblICItem (intItemId, strDescription) VALUES (4, 'MAIS CON YELO')
		INSERT INTO tblICItem (intItemId, strDescription) VALUES (5, 'BAKED AND BROILED POTATO')

		-- Add items for location 1 ('')
		INSERT INTO tblICItemLocation (intItemId, intLocationId) VALUES (1, 1)
		INSERT INTO tblICItemLocation (intItemId, intLocationId) VALUES (2, 1)
		INSERT INTO tblICItemLocation (intItemId, intLocationId) VALUES (3, 1)
		INSERT INTO tblICItemLocation (intItemId, intLocationId) VALUES (4, 1)
		INSERT INTO tblICItemLocation (intItemId, intLocationId) VALUES (5, 1)

		-- Add items for location 2 ('NEW HAVEN')
		INSERT INTO tblICItemLocation (intItemId, intLocationId) VALUES (1, 2)
		INSERT INTO tblICItemLocation (intItemId, intLocationId) VALUES (2, 2)
		INSERT INTO tblICItemLocation (intItemId, intLocationId) VALUES (3, 2)
		INSERT INTO tblICItemLocation (intItemId, intLocationId) VALUES (4, 2)
		INSERT INTO tblICItemLocation (intItemId, intLocationId) VALUES (5, 2)

		-- Add the G/L accounts for BANANA
		--		for Location 1
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (1, 1, 'Inventory', 1000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (1, 1, 'Sales', 2000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (1, 1, 'Purchases', 3000);

		--		for Location 2 (NEW HAVEN)
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (1, 2, 'Inventory', 1001);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (1, 2, 'Sales', 2001);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (1, 2, 'Purchases', 3001);

		-- Add the G/L accounts for APPLE
		--		for Location 1
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (2, 1, 'Inventory', 1000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (2, 1, 'Sales', 2000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (2, 1, 'Purchases', 3000);

		--		for Location 2 (NEW HAVEN)
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (2, 2, 'Inventory', 1001);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (2, 2, 'Sales', 2001);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (2, 2, 'Purchases', 3001);

		-- Add the G/L accounts for ORANGE 
		--		for Location 1
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (3, 1, 'Inventory', 1000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (3, 1, 'Sales', 2000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (3, 1, 'Purchases', 3000);

		--		for Location 2 (NEW HAVEN)
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (3, 2, 'Inventory', 1001);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (3, 2, 'Sales', 2001);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (3, 2, 'Purchases', 3001);

		-- Add the G/L accounts for MAIS CON YELO 
		--		for Location 1
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (4, 1, 'Inventory', 1000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (4, 1, 'Sales', 2000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (4, 1, 'Purchases', 3000);

		--		for Location 2 (NEW HAVEN)
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (4, 2, 'Inventory', 1001);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (4, 2, 'Sales', 2001);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (4, 2, 'Purchases', 3001);

		-- Add the G/L accounts for BAKED AND BROILED POTATO
		--		for Location 1
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (5, 1, 'Inventory', 1000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (5, 1, 'Sales', 2000);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (5, 1, 'Purchases', 3000);

		--		for Location 2 (NEW HAVEN)
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (5, 2, 'Inventory', 1001);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (5, 2, 'Sales', 2001);
		INSERT INTO tblICItemAccount (intItemId, intLocationId, strAccountDescription, intAccountId) VALUES (5, 2, 'Purchases', 3001);
END 