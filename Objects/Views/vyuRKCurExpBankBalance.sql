CREATE VIEW [dbo].[vyuRKCurExpBankBalance]

	AS
	
SELECT BankBal.intCurExpBankBalanceId
	, BankBal.intConcurrencyId
	, BankBal.intCurrencyExposureId
	, BankBal.intBankId
	, Bank.strBankName
	, BankBal.intBankAccountId
	, BA.strBankAccountNo
	, BankBal.dblAmount
FROM tblRKCurExpBankBalance BankBal
LEFT JOIN vyuCMBankAccount BA ON BA.intBankAccountId = BankBal.intBankAccountId
LEFT JOIN tblCMBank Bank ON Bank.intBankId = BankBal.intBankId
GO
