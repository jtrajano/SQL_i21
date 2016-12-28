GO
	PRINT 'Start generating Multicurrency accounts'
GO

--DO NOT CHANGE THE ID NAME COMBINATION AS OTHER MODULES ARE USING ID AS REFERENCE
--TOTAL COUNT IS 56 AS OF 10-22-2015
--TOTAL COUNT IS 59 AS OF 01-26-2015
--TOTAL COUNT IS 60 AS OF 01-27-2015
BEGIN TRY --ACCOUNT CATEGORY DEFAULTS
	BEGIN TRANSACTION
	
	SET  IDENTITY_INSERT tblGLMulticurrencyAccount ON
	MERGE 
	INTO	dbo.tblGLMulticurrencyAccount
	WITH	(HOLDLOCK) 
	AS		MulticurrencyTable
	USING	(
			 select strDescription = 'Realized Gain or Loss Basis', id = 1 union all
			 select strDescription = 'Realized Gain or Loss Futures', id = 2 union all
			 select strDescription = 'Realized Gain or Loss Cash', id = 3 union all 
			 select strDescription = 'Inventory Offset for Realized Gain or Loss', id=4 union all
			 select strDescription = 'Unrealized Gain or Loss Basis', id = 5 union all
			 select strDescription = 'Unrealized Gain or Loss Futures', id=6 union all
			 select strDescription = 'Unrealized Gain or Loss Cash', id = 7 union all
			 select strDescription = 'Inventory Offset for Realized Gain or Loss', id = 8

	) AS HardCodedValues
		ON  MulticurrencyTable.intMulticurrencyAccountId = HardCodedValues.id

	-- When id is matched, make sure the name and form are up-to-date.
	WHEN MATCHED THEN 
		UPDATE 
		SET 	MulticurrencyTable.strDescription = HardCodedValues.strDescription
	-- When id is missing, then do an insert. 
	WHEN NOT MATCHED THEN
		INSERT (
			intMulticurrencyAccountId
			,strDescription
			,intConcurrencyId
		)
		VALUES (
			HardCodedValues.id
			,HardCodedValues.strDescription
			,1
		);
	SET  IDENTITY_INSERT tblGLMulticurrencyAccount OFF
	

	--UPDATE RELATED TABLES
		COMMIT TRANSACTION
END TRY
BEGIN CATCH
	PRINT 'Error in Generating Multicurrency accounts: ' +  ERROR_MESSAGE()
	ROLLBACK TRANSACTION
END CATCH

	PRINT 'Finished generating Multicurrency accounts'
GO
	

