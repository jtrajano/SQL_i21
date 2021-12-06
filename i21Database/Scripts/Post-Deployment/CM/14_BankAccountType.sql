GO
PRINT 'Start updating zero-valued CM Bank Account Types to 1'
UPDATE tblCMBankAccount
SET
	intBankAccountTypeId = 1
WHERE intBankAccountTypeId = 0
GO
PRINT 'Finished updating zero-valued CM Bank Account Types to 1'

GO
PRINT 'Start generating default CM Bank Account Types'
GO
	
SET  IDENTITY_INSERT tblCMBankAccountType ON
	MERGE 
	INTO	dbo.tblCMBankAccountType
	WITH	(HOLDLOCK) 
	AS		BankAccountTypeTable
	USING	(
			SELECT id = 1,  bankAccountType = 'Bank' UNION ALL 
			SELECT id = 2,  bankAccountType  = 'Brokerage'
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
PRINT 'Finished generating default CM Bank Account Types'

