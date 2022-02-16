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
			SELECT id = 5,		name = 'Bank Transaction'		,debitCredit ='DC'	UNION ALL 
			SELECT id = 1,		name = 'Bank Deposit'			,debitCredit ='C'	UNION ALL 
			SELECT id = 2,		name = 'Bank Withdrawal'		,debitCredit ='D'	UNION ALL 
			SELECT id = 3,		name = 'Misc Checks'			,debitCredit ='D'	UNION ALL 
			SELECT id = 4,		name = 'Bank Transfer'			,debitCredit = NULL	UNION ALL 
			SELECT id = 51,		name = 'Bank Interest'	 		,debitCredit ='D'	UNION ALL 
			SELECT id = 6,		name = 'Credit Card Charge'		,debitCredit = NULL	UNION ALL 
			SELECT id = 52,		name = 'Bank Loan'		 		,debitCredit ='D'	UNION ALL 
			SELECT id = 7,		name = 'Credit Card Returns'	,debitCredit = NULL	UNION ALL 
			SELECT id = 8,		name = 'Credit Card Payments'	,debitCredit = NULL	UNION ALL 
			SELECT id = 9,		name = 'Bank Transfer (WD)'		,debitCredit ='D'	UNION ALL 
			SELECT id = 10,		name = 'Bank Transfer (DEP)'	,debitCredit ='C'	UNION ALL 
			SELECT id = 11,		name = 'Origin Deposit'			,debitCredit ='C'	UNION ALL 
			SELECT id = 12,		name = 'Origin Checks'			,debitCredit ='D'	UNION ALL 
			SELECT id = 13,		name = 'Origin EFT'				,debitCredit ='D'	UNION ALL 
			SELECT id = 14,		name = 'Origin Withdrawal'		,debitCredit ='D'	UNION ALL 
			SELECT id = 15,		name = 'Origin Wire'			,debitCredit ='D'	UNION ALL 
			SELECT id = 16,		name = 'AP Payment'				,debitCredit ='D'	UNION ALL 
			SELECT id = 17,		name = 'Bank Stmt Import'		,debitCredit = NULL	UNION ALL 
			SELECT id = 18,		name = 'AR Payment'				,debitCredit ='C'	UNION ALL 
			SELECT id = 19,		name = 'Void Check'				,debitCredit ='C'	UNION ALL 
			SELECT id = 20,		name = 'AP eCheck'				,debitCredit ='D'	UNION ALL 
			SELECT id = 21,		name = 'Paycheck'				,debitCredit ='D'	UNION ALL 
			SELECT id = 22,		name = 'ACH'					,debitCredit ='D'	UNION ALL 
			SELECT id = 23,		name = 'Direct Deposit'			,debitCredit ='D'	UNION ALL 
			SELECT id = 24,		name = 'Write Off'				,debitCredit = NULL	UNION ALL 
			SELECT id = 25,		name = 'Broker Settlement'		,debitCredit ='D' UNION ALL 
			SELECT id = 26,		name = 'Broker Commission'		,debitCredit ='D' UNION ALL 
			SELECT id = 103,	name = 'Void Misc Check'		,debitCredit ='C'	UNION ALL 
			SELECT id = 116,	name = 'Void AP Payment'		,debitCredit ='C'	UNION ALL 
			SELECT id = 121,	name = 'Void Paycheck'			,debitCredit ='C'	UNION ALL 
			SELECT id = 122,	name = 'Void ACH'				,debitCredit ='C'	UNION ALL 
			SELECT id = 123,	name = 'Void Direct Deposit'	,debitCredit ='C'	UNION ALL
			SELECT id = 124,	name = 'NSF'					,debitCredit ='D'
	) AS BankTransactionTypeHardCodedValues
		ON  BankTransactionTypeTable.intBankTransactionTypeId = BankTransactionTypeHardCodedValues.id

	-- When id is matched, make sure the name and form are up-to-date.
	WHEN MATCHED THEN 
		UPDATE 
		SET 	BankTransactionTypeTable.strBankTransactionTypeName = BankTransactionTypeHardCodedValues.name,
				BankTransactionTypeTable.strDebitCredit = BankTransactionTypeHardCodedValues.debitCredit
	-- When id is missing, then do an insert. 
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			intBankTransactionTypeId
			,strBankTransactionTypeName
			,strDebitCredit
			,intConcurrencyId
		)
		VALUES (
			BankTransactionTypeHardCodedValues.id
			,BankTransactionTypeHardCodedValues.name
			,BankTransactionTypeHardCodedValues.debitCredit
			,1
		)
	WHEN NOT MATCHED BY SOURCE THEN
	DELETE;
GO
PRINT('/*******************  END Populate Bank Transaction Types *******************/')
GO