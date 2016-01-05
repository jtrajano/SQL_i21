CREATE PROCEDURE testi21Database.[test fnGetGLAccountFromCompanyLocation for retrieving the gl accounts]
AS 
BEGIN
	-- Arrange
	DECLARE @locationId AS INT = 1
	DECLARE @Expected AS INT
	DECLARE @result AS INT
	
	EXEC [testi21Database].[Fake data company location];

	-- Cash Accounts
	BEGIN 
		-- Act
		SET @Expected = 2
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Cash Account');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END
	
	-- Deposit Account
	BEGIN 
		-- Act
		SET @Expected = 3
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Deposit Account');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- AR Account
	BEGIN 
		-- Act
		SET @Expected = 4
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'AR Account');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- AP Account
	BEGIN 
		-- Act
		SET @Expected = 5
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'AP Account');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- Sales Adv Account
	BEGIN 
		-- Act
		SET @Expected = 6
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Sales Adv Account');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- Purchase Adv Account
	BEGIN 
		-- Act
		SET @Expected = 7
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Purchase Adv Account');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- Freight AP Account
	BEGIN 
		-- Act
		SET @Expected = 8
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Freight AP Account');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- Freight Expenses
	BEGIN 
		-- Act
		SET @Expected = 9
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Freight Expenses');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- Freight Income
	BEGIN 
		-- Act
		SET @Expected = 10
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Freight Income');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- Service Charges
	BEGIN 
		-- Act
		SET @Expected = 11
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Service Charges');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- Sales Discount
	BEGIN 
		-- Act
		SET @Expected = 12
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Sales Discount');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- Cash Over/Short
	BEGIN 
		-- Act
		SET @Expected = 13
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Cash Over/Short');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- Write Off
	BEGIN 
		-- Act
		SET @Expected = 14
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Write Off');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- Credit Card Fee
	BEGIN 
		-- Act
		SET @Expected = 15
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Credit Card Fee');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- Sales Account
	BEGIN 
		-- Act
		SET @Expected = 16
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Sales Account');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- Cost of Goods
	BEGIN 
		-- Act
		SET @Expected = 17
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Cost of Goods');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- Inventory
	BEGIN 
		-- Act
		SET @Expected = 18
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Inventory');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- Write-Off Sold
	BEGIN 
		-- Act
		SET @Expected = 19
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Write-Off Sold');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- Revalue Sold
	BEGIN 
		-- Act
		SET @Expected = 20
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Revalue Sold');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- Auto-Negative
	BEGIN 
		-- Act
		SET @Expected = 21
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Auto-Negative');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- AP Clearing
	BEGIN 
		-- Act
		SET @Expected = 22
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'AP Clearing');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END

	-- Inventory In-Transit
	BEGIN 
		-- Act
		SET @Expected = 23
		SELECT @result = dbo.fnGetGLAccountFromCompanyLocation(@locationId, 'Inventory In-Transit');
		-- Assert 
		EXEC tSQLt.AssertEquals @Expected, @result;
	END
END