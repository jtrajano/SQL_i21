GO
	PRINT 'Start generating default account categories'
GO
	MERGE 
	INTO	dbo.tblGLAccountRange
	WITH	(HOLDLOCK) 
	AS		RangeTable
	USING	(
			SELECT strAccountType = 'All',			intConcurrencyId = 1, intAccountGroupId = 0 union all
			SELECT strAccountType = 'Asset',		intConcurrencyId = 1, intAccountGroupId = 1 union all
			SELECT strAccountType = 'Liability',	intConcurrencyId = 1, intAccountGroupId = 2 union all
			SELECT strAccountType = 'Revenue',		intConcurrencyId = 1, intAccountGroupId = 4 union all
			SELECT strAccountType = 'Revenue 2',	intConcurrencyId = 1, intAccountGroupId = 4 union all
			SELECT strAccountType = 'Revenue 3',	intConcurrencyId = 1, intAccountGroupId = 4 union all
			SELECT strAccountType = 'Revenue 4',	intConcurrencyId = 1, intAccountGroupId = 4 union all
			SELECT strAccountType = 'Expense',		intConcurrencyId = 1, intAccountGroupId = 5 union all
			SELECT strAccountType = 'Expense 2',	intConcurrencyId = 1, intAccountGroupId = 5 union all
			SELECT strAccountType = 'Expense 3',	intConcurrencyId = 1, intAccountGroupId = 5 union all
			SELECT strAccountType = 'Expense 4',	intConcurrencyId = 1, intAccountGroupId = 5 
	) AS RangeHardCodedValues
		ON  RangeTable.strAccountType = RangeHardCodedValues.strAccountType
	WHEN MATCHED THEN 
		UPDATE 
		SET 	RangeTable.intAccountGroupId = RangeHardCodedValues.intAccountGroupId
	WHEN NOT MATCHED THEN
		INSERT (
			strAccountType
			,intAccountGroupId
			,intConcurrencyId
		)
		VALUES (
			RangeHardCodedValues.strAccountType
			,RangeHardCodedValues.intAccountGroupId
			,1
		);
GO
