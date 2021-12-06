GO
PRINT 'Start updating zero-valued CM Bank Account Types to 1'
GO
UPDATE tblCMBankAccount
SET
	intBankAccountTypeId = 1
WHERE intBankAccountTypeId = 0

GO
PRINT 'Finished updating zero-valued CM Bank Account Types to 1'
