GO
PRINT 'Start generating default Bank Account Types'
GO

SET  IDENTITY_INSERT tblCMBankAccountType ON
	MERGE 
	INTO	dbo.tblCMBankAccountType
	WITH	(HOLDLOCK) 
	AS		BankAccountTypeTable
	USING	(
			SELECT id = 1,  bankAccountType = 'Payroll' UNION ALL 
			SELECT id = 2,  bankAccountType = 'Bank' UNION ALL 
			SELECT id = 3,  bankAccountType = 'Brokerage' UNION ALL 
			SELECT id = 4,  bankAccountType = 'Operating (AR/AP)' UNION ALL 
			SELECT id = 5,  bankAccountType = 'Investing' UNION ALL 
			SELECT id = 6,  bankAccountType = 'Disbursement (AP Only)' UNION ALL 
			SELECT id = 7,  bankAccountType = 'Collection (AR Only)' UNION ALL 
			SELECT id = 8,  bankAccountType = 'Sweep' UNION ALL 
			SELECT id = 9,  bankAccountType = 'Loan'
	) AS BankAccountTypeHardCodedValues
		ON  BankAccountTypeTable.intBankAccountTypeId = BankAccountTypeHardCodedValues.id
	WHEN MATCHED THEN 
		UPDATE 
		SET 	
			BankAccountTypeTable.strBankAccountType = BankAccountTypeHardCodedValues.bankAccountType
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			intBankAccountTypeId
			,strBankAccountType
			,intConcurrencyId
		)
		VALUES (
			BankAccountTypeHardCodedValues.id
			,BankAccountTypeHardCodedValues.bankAccountType
			,1
		);
	SET  IDENTITY_INSERT tblCMBankAccountType OFF
GO

PRINT 'Finished generating default Bank Account Types'
GO

PRINT 'Start updating old zero-valued bank account type'
GO

UPDATE tblCMBankAccount
SET
	intBankAccountTypeId = 2
WHERE
	ISNULL(intBankAccountTypeId, 0) = 0
GO

PRINT 'Finish updating old zero-valued bank account type'