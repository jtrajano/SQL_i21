GO
	IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountRange WHERE strAccountType IN ('Sales','Cost of Goods Sold'))
	BEGIN
		PRINT N'Begin removing account range for COGS and Sales'
		DECLARE @intRangeIdExpense INT
		DECLARE @intRangeIdRevenue INT
		SELECT @intRangeIdExpense = intAccountRangeId FROM tblGLAccountRange WHERE strAccountType = 'Expense'
		SELECT @intRangeIdRevenue = intAccountRangeId FROM tblGLAccountRange WHERE strAccountType = 'Revenue'
		UPDATE tblGLAccountGroup SET intAccountRangeId = @intRangeIdExpense,strAccountType ='Expense'
		WHERE strAccountType = 'Cost of Goods Sold'
		UPDATE tblGLAccountGroup SET intAccountRangeId = @intRangeIdRevenue,strAccountType ='Revenue'
		WHERE strAccountType = 'Sales'
		DELETE FROM tblGLAccountRange WHERE strAccountType IN ('Sales','Cost of Goods Sold')
		PRINT N'Finished removing account range for COGS and Sales'
	END
GO