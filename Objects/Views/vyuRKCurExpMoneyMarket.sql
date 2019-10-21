CREATE VIEW [dbo].[vyuRKCurExpMoneyMarket]

	AS
	
SELECT   BankBal.intCurExpMoneyMarketId
		,BankBal.intConcurrencyId
		,BankBal.intCurrencyExposureId
		,BankBal.intBankId
		,dtmDateOpened
		,strDescription
		,dblAmount
		,dblAnnualInterest
		,dblInterestAmount
		,dtmMaturityDate
		, Bank.strBankName
FROM tblRKCurExpMoneyMarket BankBal
LEFT JOIN tblCMBank Bank ON Bank.intBankId = BankBal.intBankId
GO