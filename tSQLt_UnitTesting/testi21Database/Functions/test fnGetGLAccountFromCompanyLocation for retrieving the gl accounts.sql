CREATE PROCEDURE testi21Database.[test fnGetGLAccountFromCompanyLocation for retrieving the gl accounts]
AS 
BEGIN
	-- Arrange
	DECLARE @locationId AS INT = 1
	DECLARE @expected AS INT
	DECLARE @result AS INT
	
	EXEC [testi21Database].[Fake data company location];

	-- Cash Accounts
	BEGIN 
		-- Act
		SET @expected = 2
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Cash Account');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END
	
	-- Deposit Account
	BEGIN 
		-- Act
		SET @expected = 3
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Deposit Account');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- AR Account
	BEGIN 
		-- Act
		SET @expected = 4
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'AR Account');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- AP Account
	BEGIN 
		-- Act
		SET @expected = 5
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'AP Account');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- Sales Adv Account
	BEGIN 
		-- Act
		SET @expected = 6
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Sales Adv Account');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- Purchase Adv Account
	BEGIN 
		-- Act
		SET @expected = 7
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Purchase Adv Account');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- Freight AP Account
	BEGIN 
		-- Act
		SET @expected = 8
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Freight AP Account');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- Freight Expenses
	BEGIN 
		-- Act
		SET @expected = 9
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Freight Expenses');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- Freight Income
	BEGIN 
		-- Act
		SET @expected = 10
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Freight Income');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- Service Charges
	BEGIN 
		-- Act
		SET @expected = 11
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Service Charges');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- Sales Discount
	BEGIN 
		-- Act
		SET @expected = 12
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Sales Discount');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- Cash Over/Short
	BEGIN 
		-- Act
		SET @expected = 13
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Cash Over/Short');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- Write Off
	BEGIN 
		-- Act
		SET @expected = 14
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Write Off');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- Credit Card Fee
	BEGIN 
		-- Act
		SET @expected = 15
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Credit Card Fee');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- Sales Account
	BEGIN 
		-- Act
		SET @expected = 16
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Sales Account');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- Cost of Goods
	BEGIN 
		-- Act
		SET @expected = 17
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Cost of Goods');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- Inventory
	BEGIN 
		-- Act
		SET @expected = 18
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Inventory');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- Write-Off Sold
	BEGIN 
		-- Act
		SET @expected = 19
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Write-Off Sold');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- Revalue Sold
	BEGIN 
		-- Act
		SET @expected = 20
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Revalue Sold');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- Auto-Negative
	BEGIN 
		-- Act
		SET @expected = 21
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Auto-Negative');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- AP Clearing
	BEGIN 
		-- Act
		SET @expected = 22
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'AP Clearing');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END

	-- Inventory In-Transit
	BEGIN 
		-- Act
		SET @expected = 23
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Inventory In-Transit');
		-- Assert 
		EXEC tSQLt.AssertEquals @expected, @result;
	END
END 