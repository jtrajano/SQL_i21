GO
PRINT 'Start generating default Bank Account Types'

GO
SET  IDENTITY_INSERT tblCMBankAccountType ON
	MERGE 
	INTO	dbo.tblCMBankAccountType
	WITH	(HOLDLOCK) 
	AS		BankAccountTypeTable
	USING	(
			SELECT id = 1,  bankAccountType = 'Bank' UNION ALL 
			SELECT id = 2,  bankAccountType = 'Brokerage'
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
	intBankAccountTypeId = 1
WHERE
	intBankAccountTypeId = 0 OR intBankAccountTypeId IS NULL

GO
PRINT 'Finish updating old zero-valued bank account type'