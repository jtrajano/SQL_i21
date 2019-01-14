-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for CM transaction types. 
-- --------------------------------------------------
-- Date Created: 10/09/2013 5:32 PM
-- Created by: Feb Montefrio
-- --------------------------------------------------
GO
PRINT('/*******************  BEGIN Populate Bank Transaction Types *******************/')
GO
	MERGE 
	INTO	dbo.tblCMBankTransactionType
	WITH	(HOLDLOCK) 
	AS		BankTransactionTypeTable
	USING	(
			SELECT id = 1,		name = 'Bank Deposit'			UNION ALL 
			SELECT id = 2,		name = 'Bank Withdrawal'		UNION ALL 
			SELECT id = 3,		name = 'Misc Checks'			UNION ALL 
			SELECT id = 4,		name = 'Bank Transfer'			UNION ALL 
			SELECT id = 5,		name = 'Bank Transaction'		UNION ALL 
			SELECT id = 6,		name = 'Credit Card Charge'		UNION ALL 
			SELECT id = 7,		name = 'Credit Card Returns'	UNION ALL 
			SELECT id = 8,		name = 'Credit Card Payments'	UNION ALL 
			SELECT id = 9,		name = 'Bank Transfer (WD)'		UNION ALL 
			SELECT id = 10,		name = 'Bank Transfer (DEP)'	UNION ALL 
			SELECT id = 11,		name = 'Origin Deposit'			UNION ALL 
			SELECT id = 12,		name = 'Origin Checks'			UNION ALL 
			SELECT id = 13,		name = 'Origin EFT'				UNION ALL 
			SELECT id = 14,		name = 'Origin Withdrawal'		UNION ALL 
			SELECT id = 15,		name = 'Origin Wire'			UNION ALL 
			SELECT id = 16,		name = 'AP Payment'				UNION ALL 
			SELECT id = 17,		name = 'Bank Stmt Import'		UNION ALL 
			SELECT id = 18,		name = 'AR Payment'				UNION ALL 
			SELECT id = 19,		name = 'Void Check'				UNION ALL 
			SELECT id = 20,		name = 'AP eCheck'				UNION ALL 
			SELECT id = 21,		name = 'Paycheck'				UNION ALL 
			SELECT id = 22,		name = 'ACH'					UNION ALL 
			SELECT id = 23,		name = 'Direct Deposit'			UNION ALL 
			SELECT id = 24,		name = 'Write Off'				UNION ALL 
			--SELECT id = 25,		name = 'NSF'					UNION ALL 
			SELECT id = 103,	name = 'Void Misc Check'		UNION ALL 
			SELECT id = 116,	name = 'Void AP Payment'		UNION ALL 
			SELECT id = 121,	name = 'Void Paycheck'			UNION ALL 
			SELECT id = 122,	name = 'Void ACH'				UNION ALL 
			SELECT id = 123,	name = 'Void Direct Deposit'
	) AS BankTransactionTypeHardCodedValues
		ON  BankTransactionTypeTable.intBankTransactionTypeId = BankTransactionTypeHardCodedValues.id

	-- When id is matched, make sure the name and form are up-to-date.
	WHEN MATCHED THEN 
		UPDATE 
		SET 	BankTransactionTypeTable.strBankTransactionTypeName = BankTransactionTypeHardCodedValues.name
	-- When id is missing, then do an insert. 
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			intBankTransactionTypeId
			,strBankTransactionTypeName
			,intConcurrencyId
		)
		VALUES (
			BankTransactionTypeHardCodedValues.id
			,BankTransactionTypeHardCodedValues.name
			,1
		);
	--WHEN NOT MATCHED BY SOURCE THEN
	--DELETE;
GO
PRINT('/*******************  END Populate Bank Transaction Types *******************/')
GO