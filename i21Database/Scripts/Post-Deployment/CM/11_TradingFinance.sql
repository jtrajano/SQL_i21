
GO
PRINT('/*******************  BEGIN Populate Trading Finance Limit Types *******************/')
GO
    SET  IDENTITY_INSERT tblCMTradingFinanceLimitType ON
	MERGE 
	INTO	dbo.tblCMTradingFinanceLimitType
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
    SET  IDENTITY_INSERT tblCMTradingFinanceLimitType OFF
GO
PRINT('/*******************  END Populate Trading Finance Limit Types *******************/')
GO