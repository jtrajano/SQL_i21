
GO
PRINT('/*******************  BEGIN Populate Trading Finance Limit Types *******************/')
GO
    SET  IDENTITY_INSERT tblCMTradeFinanceLimitType ON
	MERGE 
	INTO	dbo.tblCMTradeFinanceLimitType
	WITH	(HOLDLOCK) 
	AS		TradingFinanceLimitType
	USING	(
			SELECT id = 1,		name = 'Prefinance'	UNION ALL 
			SELECT id = 2,		name = 'BL'			UNION ALL 
			SELECT id = 3,		name = 'Warrants'	UNION ALL 
			SELECT id = 4,		name = 'Payables'	UNION ALL 
			SELECT id = 5,		name = 'Transit'	UNION ALL 
			SELECT id = 6,	    name = 'Receivables'				
	) AS TradingFinanceLimitTypeHardCodedValues
		ON  TradingFinanceLimitType.intLimitTypeId = TradingFinanceLimitTypeHardCodedValues.id

	-- When id is matched, make sure the name and form are up-to-date.
	WHEN MATCHED THEN 
		UPDATE 
		SET 	TradingFinanceLimitType.strLimitType = TradingFinanceLimitTypeHardCodedValues.name
				
	-- When id is missing, then do an insert. 
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
            intLimitTypeId
			,strLimitType
			,intConcurrencyId
		)
		VALUES (
			TradingFinanceLimitTypeHardCodedValues.id
			,TradingFinanceLimitTypeHardCodedValues.name
			,1
		)
	WHEN NOT MATCHED BY SOURCE THEN
	DELETE;
    SET  IDENTITY_INSERT tblCMTradeFinanceLimitType OFF
GO
PRINT('/*******************  END Populate Trading Finance Limit Types *******************/')
GO
PRINT('/*******************  BEGIN Populate Bank Valuation Rules *******************/')
GO
    SET  IDENTITY_INSERT tblCMBankValuationRule ON
	MERGE 
	INTO	dbo.tblCMBankValuationRule
	WITH	(HOLDLOCK) 
	AS		BankValuationRule
	USING	(
			SELECT id = 1,		name = 'Purchase Price'						 								 ,description = 'Price on the purchase contract'					UNION ALL 
			SELECT id = 2,		name = 'Cost/M2M /(Lower of cost or market)' 								 ,description = 'Price on the purchase contract or the M2M'			UNION ALL 
			SELECT id = 3,		name = 'Sale Price'							 								 ,description = 'Price on the sales contract'						UNION ALL 
			SELECT id = 4,		name = 'LCM Lower of purchase or m2m unless sales is fixed then sales price' ,description = 'Lower of the cost of goods or M2M unless allocated to a sale and then it will be the sales price.' UNION ALL
			SELECT id = 5,		name = 'M2M', description='Price on M2M'
			
	) AS BankValuationRuleHardCodedValues
		ON  BankValuationRule.intBankValuationRuleId = BankValuationRuleHardCodedValues.id

	-- When id is matched, make sure the name and form are up-to-date.
	WHEN MATCHED THEN 
		UPDATE 
		SET 	BankValuationRule.strBankValuationRule = BankValuationRuleHardCodedValues.name,
				BankValuationRule.strDescription = BankValuationRuleHardCodedValues.description
				
	-- When id is missing, then do an insert. 
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
            intBankValuationRuleId
			,strBankValuationRule
			,strDescription
			,intConcurrencyId
		)
		VALUES (
			BankValuationRuleHardCodedValues.id
			,BankValuationRuleHardCodedValues.name
			,BankValuationRuleHardCodedValues.description
			,1
		)
	WHEN NOT MATCHED BY SOURCE THEN
	DELETE;
    SET  IDENTITY_INSERT tblCMBankValuationRule OFF
GO
PRINT('/*******************  END Populate Bank Valuation Rules *******************/')
GO